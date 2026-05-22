#!/bin/bash

# Code Engineデプロイ専用ヘルパー関数

# 共通関数を読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/common.sh"

# Container Registryの設定
setup_container_registry() {
    log_section "Container Registryを設定中..."
    
    # Container Registryのリージョンを設定
    echo "Container Registryのリージョンを設定中..."
    ibmcloud cr region-set jp-tok
    
    # Container Registryにログイン
    echo "Container Registryにログイン中..."
    ibmcloud cr login
    log_info "Container Registryにログインしました"
}

# Dockerイメージのビルド
build_docker_image() {
    local full_image_name="$1"
    local build_tool="$2"
    
    log_section "Dockerイメージをビルド中..."
    
    if [ "$build_tool" = "podman" ]; then
        log_warn "Podmanを使用してビルドします（linux/amd64プラットフォーム）"
        podman build --platform linux/amd64 -f docs/Dockerfile -t "$full_image_name" .
    elif [ "$build_tool" = "docker" ]; then
        # docker buildxが利用可能か確認
        if docker buildx version &> /dev/null; then
            log_warn "Docker Buildxを使用してビルドします（linux/amd64プラットフォーム）"
            
            # マルチアーキテクチャビルダーが存在するか確認
            if ! docker buildx inspect multiarch &> /dev/null; then
                echo "マルチアーキテクチャビルダーを作成中..."
                docker buildx create --name multiarch --driver docker-container --use
            else
                docker buildx use multiarch
            fi
            
            docker buildx build --platform linux/amd64 -f docs/Dockerfile -t "$full_image_name" --load .
        else
            log_error "Docker Buildxが利用できません"
            log_warn "Podmanをインストールすることをお勧めします:"
            log_warn "  brew install podman"
            log_warn "  colima start --arch x86_64 --vm-type=vz --vz-rosetta"
            return 1
        fi
    else
        log_error "DockerまたはPodmanが必要です"
        return 1
    fi
    
    return 0
}

# イメージのプッシュ
push_docker_image() {
    local full_image_name="$1"
    local build_tool="$2"
    
    log_section "イメージをContainer Registryにプッシュ中..."
    
    # Podmanでビルドした場合は、Dockerにロードしてからプッシュ
    if [ "$build_tool" = "podman" ]; then
        echo "PodmanイメージをDockerにロード中..."
        
        # Dockerが利用可能か確認
        if ! command -v docker &> /dev/null; then
            log_error "dockerコマンドが見つかりません"
            log_warn "Colimaを起動してください:"
            log_warn "  colima start"
            return 1
        fi
        
        # Docker contextをcolimaに設定
        if docker context ls | grep -q "colima"; then
            echo "Docker contextをcolimaに設定中..."
            docker context use colima &> /dev/null || true
        fi
        
        # Docker daemonが起動しているか確認
        if ! docker info &> /dev/null; then
            log_error "Docker daemonに接続できません"
            log_warn "Colimaのステータス:"
            colima status
            echo ""
            log_warn "以下のコマンドを試してください:"
            log_warn "  docker context use colima"
            log_warn "  docker info"
            return 1
        fi
        
        log_info "Dockerが利用可能です"
        
        # PodmanイメージをDockerにロード
        podman save "$full_image_name" | docker load
        
        if [ $? -ne 0 ]; then
            log_error "イメージのロードに失敗しました"
            return 1
        fi
        
        log_info "イメージをDockerにロードしました"
        
        # Dockerでプッシュ
        echo "Dockerでイメージをプッシュ中..."
        docker push "$full_image_name"
    elif [ "$build_tool" = "docker" ]; then
        # Dockerでビルドした場合は直接プッシュ
        docker push "$full_image_name"
    else
        log_error "ビルドツールが不明です"
        return 1
    fi
    
    if [ $? -eq 0 ]; then
        log_info "イメージをプッシュしました"
        return 0
    else
        log_error "イメージのプッシュに失敗しました"
        return 1
    fi
}

# Container Registryアクセス用のシークレット作成
create_registry_secret() {
    local registry_secret="$1"
    
    log_section "Container Registryアクセス用のシークレットを設定中..."
    
    # 既存のシークレットを確認
    if ibmcloud ce secret get --name "$registry_secret" &> /dev/null; then
        log_info "シークレット '$registry_secret' は既に存在します"
        return 0
    fi
    
    echo "シークレット '$registry_secret' を作成中..."
    
    # API Keyを作成
    local api_key_name="ce-registry-access-$(date +%s)"
    echo "API Key '$api_key_name' を作成中..."
    local api_key_json
    api_key_json=$(ibmcloud iam api-key-create "$api_key_name" --output json)
    
    if [ $? -ne 0 ]; then
        log_error "API Keyの作成に失敗しました"
        return 1
    fi
    
    # JSONから apikey フィールドを抽出
    local api_key
    api_key=$(echo "$api_key_json" | grep '"apikey"' | sed 's/.*"apikey": "\([^"]*\)".*/\1/')
    
    if [ -z "$api_key" ]; then
        log_error "API Keyの取得に失敗しました"
        return 1
    fi
    
    # シークレットを作成
    ibmcloud ce secret create --name "$registry_secret" \
        --format registry \
        --server jp.icr.io \
        --username iamapikey \
        --password "$api_key"
    
    if [ $? -eq 0 ]; then
        log_info "シークレットを作成しました"
        return 0
    else
        log_error "シークレットの作成に失敗しました"
        return 1
    fi
}

# アプリケーションのデプロイ状態監視
monitor_app_deployment() {
    local app_name="$1"
    local max_wait="${2:-300}"
    local elapsed=0
    local prev_status=""
    
    log_section "アプリケーションの準備状態を確認中..."
    
    while true; do
        # タイムアウトチェック
        if [ $elapsed -ge "$max_wait" ]; then
            printf "\n"
            log_error "タイムアウト: %d秒経過してもデプロイが完了しません" "$max_wait"
            log_warn "現在の状態を確認しています..."
            
            # 詳細情報を取得
            printf "\n"
            log_section "=== アプリケーション詳細 ==="
            ibmcloud ce app get --name "$app_name" 2>&1 | tee /dev/stderr
            
            printf "\n"
            log_section "=== 最新のログ ==="
            ibmcloud ce app logs --name "$app_name" --tail 50 2>&1 | tee /dev/stderr
            
            printf "\n"
            log_section "=== リビジョン一覧 ==="
            ibmcloud ce revision list --application "$app_name" 2>&1 | tee /dev/stderr
            
            printf "\n"
            log_error "デプロイに失敗した可能性があります。上記の情報を確認してください。"
            return 1
        fi
        
        # ステータスを取得
        local app_json
        app_json=$(ibmcloud ce app get --name "$app_name" --output json 2>&1)
        
        # Readyステータスを抽出
        local ready_status
        ready_status=$(extract_ce_ready_status "$app_json")
        
        # アプリケーションステータスを判定
        local status=""
        if [ "$ready_status" = "True" ]; then
            status="Ready"
        elif [ "$ready_status" = "False" ]; then
            status="Deploying"
        elif [ "$ready_status" = "Unknown" ]; then
            status="Deploying"
        else
            status=""
        fi
        
        # デバッグ: 初回のみステータスを表示
        if [ $elapsed -eq 0 ]; then
            printf "${YELLOW}初回ステータス確認: READY_STATUS='%s', STATUS='%s'${NC}\n" "$ready_status" "$status" >&2
        fi
        
        # ステータスが変わった場合のみ表示を更新
        if [ "$status" != "$prev_status" ]; then
            if [ -z "$status" ]; then
                printf "${YELLOW}[%3ds] イメージをプル中...${NC}\n" "$elapsed" >&2
            elif [ "$status" = "Deploying" ]; then
                printf "${YELLOW}[%3ds] デプロイ中...${NC}\n" "$elapsed" >&2
            elif [ "$status" = "Ready" ]; then
                printf "${GREEN}[%3ds] ✓ 準備完了${NC}\n" "$elapsed" >&2
                return 0
            elif [ "$status" = "Failed" ]; then
                printf "${RED}[%3ds] ✗ デプロイ失敗${NC}\n" "$elapsed" >&2
                printf "\n${YELLOW}=== エラー詳細 ===${NC}\n" >&2
                ibmcloud ce app get --name "$app_name" 2>&1 | tee /dev/stderr
                printf "\n${YELLOW}=== 最新のログ ===${NC}\n" >&2
                ibmcloud ce app logs --name "$app_name" --tail 50 2>&1 | tee /dev/stderr
                return 1
            else
                printf "${YELLOW}[%3ds] 状態: %s${NC}\n" "$elapsed" "$status" >&2
            fi
            prev_status="$status"
        else
            # ステータスが変わっていない場合でも、進行中であることを示すドットを表示
            if [ "$status" = "Deploying" ] || [ -z "$status" ]; then
                printf "." >&2
            fi
        fi
        
        sleep 5
        elapsed=$((elapsed + 5))
    done
}

# Code Engineアプリケーションの更新
update_ce_app() {
    local app_name="$1"
    local full_image_name="$2"
    local registry_secret="$3"
    
    log_section "既存のアプリケーションを更新中..."
    printf "${YELLOW}アプリケーション '%s' を最新リビジョンに更新しています。${NC}\n" "$app_name" >&2
    
    # バックグラウンドでアプリケーション更新を実行
    ibmcloud ce app update --name "$app_name" \
        --image "$full_image_name" \
        --registry-secret "$registry_secret" \
        --port 8000 \
        --min-scale 1 \
        --max-scale 2 \
        --cpu 0.25 \
        --memory 0.5G \
        --no-wait &
    
    local update_pid=$!
    
    # 更新コマンドの実行を監視
    show_progress "$update_pid" "${YELLOW}更新コマンドを実行中...${NC}"
    
    wait "$update_pid"
    local update_exit_code=$?
    
    if [ $update_exit_code -eq 0 ]; then
        log_info "アプリケーションの更新コマンドが完了しました"
        
        # 更新状態を監視
        monitor_app_deployment "$app_name"
        return $?
    else
        log_error "アプリケーションの更新に失敗しました (終了コード: $update_exit_code)"
        return 1
    fi
}

# Code Engineアプリケーションの作成
create_ce_app() {
    local app_name="$1"
    local full_image_name="$2"
    local registry_secret="$3"
    
    log_section "新しいアプリケーションを作成中..."
    printf "${YELLOW}アプリケーション '%s' を作成しています。${NC}\n" "$app_name" >&2
    
    # バックグラウンドでアプリケーション作成を実行
    ibmcloud ce app create --name "$app_name" \
        --image "$full_image_name" \
        --registry-secret "$registry_secret" \
        --port 8000 \
        --min-scale 1 \
        --max-scale 2 \
        --cpu 0.25 \
        --memory 0.5G \
        --no-wait &
    
    local create_pid=$!
    
    # 作成コマンドの実行を監視
    show_progress "$create_pid" "${YELLOW}作成コマンドを実行中...${NC}"
    
    wait "$create_pid"
    local create_exit_code=$?
    
    if [ $create_exit_code -eq 0 ]; then
        log_info "アプリケーションの作成コマンドが完了しました"
        
        # 作成状態を監視
        monitor_app_deployment "$app_name"
        return $?
    else
        log_error "アプリケーションの作成に失敗しました (終了コード: $create_exit_code)"
        return 1
    fi
}

# Made with Bob
