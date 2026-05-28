#!/bin/bash

# Code Engineデプロイ専用ヘルパー関数

# 共通関数を読み込み
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/common.sh"

# Container Registryの設定
setup_container_registry() {
    log_section "Container Registryを設定中..."
    
    # 現在のリージョンを確認
    echo "現在のContainer Registryリージョンを確認中..."
    local current_region
    current_region=$(ibmcloud cr region 2>/dev/null | grep "現在のリージョン" | awk '{print $NF}' || echo "")
    echo "現在のリージョン: ${current_region:-未設定}"
    
    # Container Registryのリージョンを設定
    echo "Container Registryのリージョンをjp-tokに設定中..."
    if ! ibmcloud cr region-set jp-tok; then
        log_error "Container Registryのリージョン設定に失敗しました"
        return 1
    fi
    
    # Container Registryにログイン
    echo "Container Registryにログイン中..."
    if ! ibmcloud cr login; then
        log_error "Container Registryへのログインに失敗しました"
        return 1
    fi
    log_info "Container Registryにログインしました"
    
    # Container Registryの権限を確認（エラーは無視）
    echo ""
    echo "Container Registryの権限を確認中..."
    ibmcloud cr quota 2>&1 || log_warn "権限情報の取得に失敗しました（TechZone環境では正常です）"
    echo ""
    
    # ネームスペース一覧を表示（デバッグ用）
    echo "利用可能なネームスペース:"
    ibmcloud cr namespace-list
    echo ""
    
    return 0
}

# Dockerイメージのビルド
build_docker_image() {
    local full_image_name="$1"
    local build_tool="$2"
    
    # パラメータバリデーション
    if ! validate_not_empty "full_image_name" "$full_image_name"; then
        return 1
    fi
    if ! validate_not_empty "build_tool" "$build_tool"; then
        return 1
    fi
    
    log_section "Dockerイメージをビルド中..."
    
    if [ "$build_tool" = "podman" ]; then
        log_warn "Podmanを使用してビルドします（linux/amd64プラットフォーム）"
        if ! podman build --platform linux/amd64 -f docs/Dockerfile -t "$full_image_name" .; then
            log_error "Podmanでのビルドに失敗しました"
            return 1
        fi
        log_info "イメージをビルドしました"
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
    
    # パラメータバリデーション
    if ! validate_not_empty "full_image_name" "$full_image_name"; then
        return 1
    fi
    if ! validate_not_empty "build_tool" "$build_tool"; then
        return 1
    fi
    
    log_section "イメージをContainer Registryにプッシュ中..."
    
    # Podmanでビルドした場合は、Dockerにロードしてからプッシュ
    if [ "$build_tool" = "podman" ]; then
        echo "PodmanイメージをDockerにロード中..."
        
        # Podmanマシンが存在するか確認
        if ! podman machine list 2>/dev/null | grep -q "podman-machine-default"; then
            log_warn "Podmanマシンが存在しません。初期化中..."
            if ! podman machine init; then
                log_error "Podmanマシンの初期化に失敗しました"
                return 1
            fi
            log_info "Podmanマシンを初期化しました"
        fi
        
        # Podmanマシンが起動しているか確認
        if ! podman machine list 2>/dev/null | grep -q "Currently running"; then
            log_warn "Podmanマシンが起動していません。起動中..."
            if ! podman machine start; then
                log_error "Podmanマシンの起動に失敗しました"
                log_warn "以下のコマンドを試してください:"
                log_warn "  podman machine start"
                return 1
            fi
            # 起動後、少し待機
            sleep 5
            log_info "Podmanマシンを起動しました"
        fi
        
        # Podman接続を確認
        if ! podman info &> /dev/null; then
            log_error "Podmanに接続できません"
            log_warn "Podmanのステータス:"
            podman machine list
            echo ""
            log_warn "以下のコマンドを試してください:"
            log_warn "  podman machine start"
            return 1
        fi
        
        log_info "Podmanが利用可能です"
        
        # Dockerが利用可能か確認
        if ! command -v docker &> /dev/null; then
            log_error "dockerコマンドが見つかりません"
            log_warn "Colimaをインストールしてください:"
            log_warn "  brew install colima"
            return 1
        fi
        
        # Colimaが利用可能か確認
        if ! command -v colima &> /dev/null; then
            log_error "colimaコマンドが見つかりません"
            log_warn "Colimaをインストールしてください:"
            log_warn "  brew install colima"
            return 1
        fi
        
        # Colimaが起動しているか確認
        local colima_status
        colima_status=$(colima status 2>&1)
        
        if ! echo "$colima_status" | grep -q "colima is running"; then
            log_warn "Colimaが起動していません。起動中..."
            # colima startは初回実行時に自動的に初期化も行います
            if ! colima start; then
                log_error "Colimaの起動に失敗しました"
                log_warn "以下のコマンドを試してください:"
                log_warn "  colima start"
                return 1
            fi
            # 起動後、少し待機
            sleep 5
            log_info "Colimaを起動しました"
        else
            log_info "Colimaが起動しています"
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
        
        # Podmanイメージが存在するか確認
        if ! podman image exists "$full_image_name"; then
            log_error "Podmanイメージ '$full_image_name' が見つかりません"
            log_warn "イメージのビルドが失敗している可能性があります"
            return 1
        fi
        
        # PodmanイメージをDockerにロード
        echo "イメージをエクスポート中..."
        if ! podman save "$full_image_name" | docker load; then
            log_error "イメージのロードに失敗しました"
            return 1
        fi
        
        log_info "イメージをDockerにロードしました"
        
        # DockerでContainer Registryにログイン（認証情報をクリア）
        echo "DockerでContainer Registryにログイン中..."
        
        # 既存の認証情報をクリア
        docker logout jp.icr.io &> /dev/null || true
        
        # IBM Cloud Container Registryに再ログイン
        if ! ibmcloud cr login; then
            log_error "DockerでのContainer Registryログインに失敗しました"
            echo ""
            echo "IBM Cloudの認証状態を確認:"
            ibmcloud target
            echo ""
            echo "Container Registryリージョン:"
            ibmcloud cr region
            return 1
        fi
        
        # Docker認証情報を確認
        echo "Docker認証情報を確認中..."
        if ! docker login jp.icr.io -u iamapikey -p "$(ibmcloud iam oauth-tokens --output json 2>/dev/null | grep -o '"iam_token":"[^"]*' | cut -d'"' -f4 | sed 's/Bearer //')"; then
            log_warn "Docker認証情報の再設定に失敗しました（ibmcloud cr loginの認証情報を使用します）"
        fi
        
        # Dockerでプッシュ
        echo "Dockerでイメージをプッシュ中..."
        if ! docker push "$full_image_name"; then
            log_error "イメージのプッシュに失敗しました"
            echo ""
            log_warn "=== TechZone環境の制限 ==="
            echo ""
            echo "TechZone環境のContainer Registryポリシーにより、書き込み権限が制限されています。"
            echo ""
            echo "現在使用中:"
            echo "  アカウント: watsonx-events"
            echo "  ネームスペース: $(echo "$full_image_name" | cut -d'/' -f2)"
            echo ""
            log_warn "=== 解決方法（以下のいずれかを選択） ==="
            echo ""
            echo "【方法1】個人のIBM Cloudアカウントを使用（推奨）:"
            echo "  1. ログアウト:"
            echo "     ibmcloud logout"
            echo ""
            echo "  2. 個人アカウントでログイン:"
            echo "     ibmcloud login --sso"
            echo "     # プロンプトで個人アカウントを選択"
            echo ""
            echo "  3. デプロイスクリプトを再実行:"
            echo "     ./deploy-to-code-engine.sh"
            echo ""
            echo "【方法2】ローカル配信のみ使用（Code Engineなし）:"
            echo "  cd setup/instructor"
            echo "  ./start-all.sh"
            echo "  # http://localhost:8001 または http://<IP>:8001 で共有"
            echo ""
            echo "【参考】TechZone環境のポリシー:"
            echo "  'Container Registry Policy Provided - You must create your own namespaces.'"
            echo "  しかし、実際にはネームスペースの作成・書き込み権限がありません。"
            echo ""
            return 1
        fi
        log_info "イメージをプッシュしました"
        return 0
    elif [ "$build_tool" = "docker" ]; then
        # Dockerでビルドした場合は直接プッシュ
        if ! docker push "$full_image_name"; then
            log_error "イメージのプッシュに失敗しました"
            echo ""
            log_warn "=== トラブルシューティング情報 ==="
            echo "現在のIBM Cloudアカウント:"
            ibmcloud target
            echo ""
            echo "Container Registryネームスペース一覧:"
            ibmcloud cr namespace-list
            echo ""
            echo "ネームスペースへのアクセス権限を確認してください:"
            echo "  ibmcloud cr quota"
            return 1
        fi
        log_info "イメージをプッシュしました"
        return 0
    else
        log_error "ビルドツールが不明です"
        return 1
    fi
}

# Container Registryアクセス用のシークレット作成
create_registry_secret() {
    local registry_secret="$1"
    
    # パラメータバリデーション
    if ! validate_not_empty "registry_secret" "$registry_secret"; then
        return 1
    fi
    
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
    
    # パラメータバリデーション
    if ! validate_not_empty "app_name" "$app_name"; then
        return 1
    fi
    
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
                printf "${YELLOW}イメージをプル中...${NC}\n" >&2
            elif [ "$status" = "Deploying" ]; then
                printf "${YELLOW}デプロイ中...${NC}\n" >&2
            elif [ "$status" = "Ready" ]; then
                printf "${GREEN}✓ 準備完了 (%ds)${NC}\n" "$elapsed" >&2
                return 0
            elif [ "$status" = "Failed" ]; then
                printf "${RED}✗ デプロイ失敗 (%ds)${NC}\n" "$elapsed" >&2
                printf "\n${YELLOW}=== エラー詳細 ===${NC}\n" >&2
                ibmcloud ce app get --name "$app_name" 2>&1 | tee /dev/stderr
                printf "\n${YELLOW}=== 最新のログ ===${NC}\n" >&2
                ibmcloud ce app logs --name "$app_name" --tail 50 2>&1 | tee /dev/stderr
                return 1
            else
                printf "${YELLOW}状態: %s${NC}\n" "$status" >&2
            fi
            prev_status="$status"
        else
            # ステータスが変わっていない場合、ドットを表示
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
    
    # パラメータバリデーション
    if ! validate_not_empty "app_name" "$app_name"; then
        return 1
    fi
    if ! validate_not_empty "full_image_name" "$full_image_name"; then
        return 1
    fi
    if ! validate_not_empty "registry_secret" "$registry_secret"; then
        return 1
    fi
    
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
    
    # パラメータバリデーション
    if ! validate_not_empty "app_name" "$app_name"; then
        return 1
    fi
    if ! validate_not_empty "full_image_name" "$full_image_name"; then
        return 1
    fi
    if ! validate_not_empty "registry_secret" "$registry_secret"; then
        return 1
    fi
    
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

