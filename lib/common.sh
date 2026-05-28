#!/bin/bash

# 共通関数ライブラリ
# 全てのスクリプトで使用される共通機能を提供

# 多重読み込み防止
if [ -n "${COMMON_SH_LOADED:-}" ]; then
    return 0
fi
readonly COMMON_SH_LOADED=1

# 色定義
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${GREEN}✓ $*${NC}"
}

log_warn() {
    echo -e "${YELLOW}⚠ $*${NC}"
}

log_error() {
    echo -e "${RED}❌ $*${NC}"
}

log_section() {
    echo -e "\n${YELLOW}$*${NC}"
}

log_header() {
    echo "=========================================="
    echo "$*"
    echo "=========================================="
    echo ""
}

log_blue() {
    echo -e "${BLUE}$*${NC}"
}

# コマンド存在チェック
check_command() {
    local cmd="$1"
    local install_msg="${2:-}"
    
    if ! command -v "$cmd" &> /dev/null; then
        log_error "$cmd がインストールされていません"
        if [ -n "$install_msg" ]; then
            echo ""
            echo "$install_msg"
            echo ""
        fi
        return 1
    fi
    return 0
}

# IBM Cloud ログイン確認
check_ibmcloud_login() {
    if ! ibmcloud target &> /dev/null; then
        log_error "IBM Cloudにログインしていません"
        echo ""
        echo "以下のコマンドでログインしてください:"
        echo "  ibmcloud login --sso"
        echo ""
        return 1
    fi
    return 0
}

# Container runtime検出（Docker/Podman）
detect_container_runtime() {
    local container_cmd=""
    local compose_cmd=""
    
    if command -v docker &> /dev/null; then
        container_cmd="docker"
        
        # docker composeとdocker-composeの両方をチェック
        if docker compose version &> /dev/null 2>&1; then
            compose_cmd="docker compose"
        elif command -v docker-compose &> /dev/null; then
            compose_cmd="docker-compose"
        else
            log_error "docker-composeがインストールされていません"
            echo ""
            echo "インストール方法:"
            echo "  brew install docker-compose"
            echo ""
            return 1
        fi
        
        # Podmanのdockerエイリアスを使用している場合、DOCKER_HOSTを設定
        if docker version 2>&1 | grep -q "podman"; then
            local podman_sock
            podman_sock=$(podman machine inspect podman-machine-default 2>/dev/null | grep -o '"Path": "[^"]*"' | head -1 | cut -d'"' -f4)
            if [ -n "$podman_sock" ]; then
                export DOCKER_HOST="unix://$podman_sock"
                log_info "Podman（dockerエイリアス経由）が見つかりました"
            else
                log_info "Dockerが見つかりました"
            fi
        else
            log_info "Dockerが見つかりました"
        fi
    elif command -v podman &> /dev/null; then
        container_cmd="podman"
        
        # Podman 4.0以降はpodman composeをサポート
        if podman compose version &> /dev/null 2>&1; then
            compose_cmd="podman compose"
        elif command -v podman-compose &> /dev/null; then
            compose_cmd="podman-compose"
        else
            log_error "podman-composeがインストールされていません"
            echo ""
            echo "インストール方法:"
            echo "  brew install podman-compose"
            echo ""
            return 1
        fi
        log_info "Podmanが見つかりました"
    else
        log_error "DockerまたはPodmanがインストールされていません"
        echo ""
        echo "インストール方法:"
        echo "  Docker: https://docs.docker.com/get-docker/"
        echo "  Podman: https://podman.io/getting-started/installation"
        echo ""
        echo "macOSの場合（Homebrew）:"
        echo "  brew install podman"
        echo "  podman machine init"
        echo "  podman machine start"
        echo ""
        return 1
    fi
    
    # 環境変数にエクスポート
    export CONTAINER_CMD="$container_cmd"
    export COMPOSE_CMD="$compose_cmd"
    return 0
}

# ビルドツール検出（Docker/Podman）
detect_build_tool() {
    local build_tool=""
    
    if command -v podman &> /dev/null; then
        log_info "Podman（ビルド用）"
        build_tool="podman"
        
        # Podman使用時はDockerも必要
        if ! command -v docker &> /dev/null || ! docker info &> /dev/null 2>&1; then
            log_warn "Podmanでビルドする場合、イメージプッシュにはDockerが必要です"
            log_warn "Colimaを起動してください:"
            log_warn "  colima start --arch x86_64 --vm-type=vz --vz-rosetta"
        else
            log_info "Docker CLI（プッシュ用）"
        fi
    elif command -v docker &> /dev/null && docker info &> /dev/null 2>&1; then
        log_info "Docker CLI（Colima経由など）"
        build_tool="docker"
    else
        log_error "DockerまたはPodmanが必要です"
        echo "インストール方法:"
        echo "  brew install podman"
        echo "  colima start --arch x86_64 --vm-type=vz --vz-rosetta"
        return 1
    fi
    
    export BUILD_TOOL="$build_tool"
    return 0
}

# JSONからフィールド抽出（複数の方法を試行）
extract_json_field() {
    local json="$1"
    local field_path="$2"
    local result=""
    
    # 方法1: jqが利用可能な場合
    if command -v jq &> /dev/null; then
        result=$(echo "$json" | jq -r "$field_path" 2>/dev/null || echo "")
        if [ -n "$result" ] && [ "$result" != "null" ]; then
            echo "$result"
            return 0
        fi
    fi
    
    # 方法2: pythonが利用可能な場合
    if command -v python3 &> /dev/null; then
        result=$(echo "$json" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    # field_pathを評価（例: .status.conditions[].status）
    # 簡易実装: 特定のパターンのみサポート
    print('')
except:
    pass
" 2>/dev/null || echo "")
        if [ -n "$result" ]; then
            echo "$result"
            return 0
        fi
    fi
    
    return 1
}

# Code Engine Ready状態抽出
extract_ce_ready_status() {
    local app_json="$1"
    local ready_status=""
    
    # 方法1: jqが利用可能な場合
    if command -v jq &> /dev/null; then
        ready_status=$(echo "$app_json" | jq -r '.status.conditions[]? | select(.type=="Ready")? | .status' 2>/dev/null || echo "")
    fi
    
    # 方法2: pythonが利用可能な場合
    if [ -z "$ready_status" ] && command -v python3 &> /dev/null; then
        ready_status=$(echo "$app_json" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    for cond in data.get('status', {}).get('conditions', []):
        if cond.get('type') == 'Ready':
            print(cond.get('status', ''))
            break
except:
    pass
" 2>/dev/null || echo "")
    fi
    
    # 方法3: 改善されたawk（複数行対応）
    if [ -z "$ready_status" ]; then
        ready_status=$(echo "$app_json" | awk '
            /"type"[[:space:]]*:[[:space:]]*"Ready"/ { found=1; next }
            found && /"status"[[:space:]]*:[[:space:]]*"/ {
                match($0, /"status"[[:space:]]*:[[:space:]]*"([^"]*)"/, arr)
                print arr[1]
                exit
            }
        ')
    fi
    
    echo "$ready_status"
}

# プログレス表示（ドット）
show_progress() {
    local pid="$1"
    local message="${2:-処理中}"
    local dots=0
    
    printf "%s" "$message"
    while kill -0 "$pid" 2>/dev/null; do
        printf "."
        dots=$((dots + 1))
        if [ $dots -ge 60 ]; then
            printf "\n%s" "$message"
            dots=0
        fi
        sleep 1
    done
    printf "\n"
}

# タイムアウト付き待機
wait_with_timeout() {
    local max_wait="$1"
    local check_func="$2"
    local elapsed=0
    
    while [ $elapsed -lt "$max_wait" ]; do
        if $check_func; then
            return 0
        fi
        sleep 5
        elapsed=$((elapsed + 5))
    done
    
    return 1
}

# リソースグループ自動選択
select_resource_group() {
    local resource_group="${RESOURCE_GROUP:-}"
    
    if [ -z "$resource_group" ]; then
        log_section "利用可能なリソースグループを確認中..." >&2
        local resource_groups
        
        # 方法1: JSON出力からパース
        if command -v jq &> /dev/null; then
            resource_groups=$(ibmcloud resource groups --output json 2>/dev/null | jq -r '.[].name' 2>/dev/null)
        else
            # 方法2: grepでパース
            resource_groups=$(ibmcloud resource groups --output json 2>/dev/null | grep -o '"name":"[^"]*' | cut -d'"' -f4)
        fi
        
        # 方法3: テーブル形式から取得（JSONが失敗した場合）
        if [ -z "$resource_groups" ]; then
            resource_groups=$(ibmcloud resource groups 2>/dev/null | tail -n +4 | awk '{print $1}' | grep -v "^$" | grep -v "^OK$")
        fi
        
        if [ -n "$resource_groups" ]; then
            # TechZone環境（itz-*）を優先的に選択
            resource_group=$(echo "$resource_groups" | grep "^itz-" | head -n 1)
            
            # itz-*が見つからない場合は最初のリソースグループを使用
            if [ -z "$resource_group" ]; then
                resource_group=$(echo "$resource_groups" | head -n 1)
                log_warn "リソースグループ '$resource_group' を使用します" >&2
            else
                log_warn "TechZoneリソースグループ '$resource_group' を使用します" >&2
            fi
        fi
    fi
    
    if [ -n "$resource_group" ]; then
        ibmcloud target -g "$resource_group" > /dev/null 2>&1
        log_info "リソースグループ: $resource_group" >&2
        echo "$resource_group"
        return 0
    else
        # デフォルトのリソースグループを使用
        local current_rg
        current_rg=$(ibmcloud target 2>/dev/null | grep "Resource group:" | awk '{print $3}')
        if [ -n "$current_rg" ] && [ "$current_rg" != "No" ]; then
            log_info "現在のリソースグループを使用: $current_rg" >&2
            echo "$current_rg"
            return 0
        fi
        log_warn "リソースグループが設定されていません（デフォルトを使用）" >&2
        return 0
    fi
}

# Container Registry ネームスペース選択
select_registry_namespace() {
    local registry_namespace="${REGISTRY_NAMESPACE:-}"
    
    log_section "既存のネームスペースを確認中..." >&2
    # ANSIエスケープシーケンスを削除してから、ヘッダー行をスキップ
    local existing_namespaces
    existing_namespaces=$(ibmcloud cr namespace-list 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | tail -n +4 | grep -v "^OK$" | grep -v "^$" | awk '{print $1}')
    
    if [ -z "$registry_namespace" ]; then
        # TechZone環境（cr-itz-*ネームスペース）の場合
        if echo "$existing_namespaces" | grep -q "^cr-itz-"; then
            log_warn "TechZone環境を検出しました" >&2
            
            # まず既存のネームスペースを使用してみる
            registry_namespace=$(echo "$existing_namespaces" | grep "^cr-itz-" | head -n 1)
            log_warn "既存のネームスペース '$registry_namespace' を試します" >&2
            log_warn "プッシュに失敗する場合は、環境変数REGISTRY_NAMESPACEで明示的に指定してください" >&2
        elif [ -n "$existing_namespaces" ]; then
            # TechZone以外の環境では既存のネームスペースを使用
            registry_namespace=$(echo "$existing_namespaces" | head -n 1)
            log_warn "ネームスペース '$registry_namespace' を使用します" >&2
        else
            # ネームスペースが存在しない場合は新規作成
            log_warn "既存のネームスペースが見つかりません。新しいネームスペースを作成します..." >&2
            local new_namespace="mkdocs-$(date +%Y%m%d-%H%M%S)"
            
            if ibmcloud cr namespace-add "$new_namespace"; then
                registry_namespace="$new_namespace"
                log_info "新しいネームスペース '$registry_namespace' を作成しました" >&2
            else
                log_error "新しいネームスペースの作成に失敗しました" >&2
                return 1
            fi
        fi
    else
        # 環境変数で指定されたネームスペースを使用（優先）
        if [ -n "$existing_namespaces" ] && ! echo "$existing_namespaces" | grep -q "^${registry_namespace}$"; then
            log_warn "指定されたネームスペース '$registry_namespace' が見つかりません" >&2
            echo "利用可能なネームスペース:" >&2
            echo "$existing_namespaces" >&2
            log_warn "それでも指定されたネームスペースを使用します" >&2
        fi
        log_info "環境変数で指定されたネームスペース '$registry_namespace' を使用します" >&2
    fi
    
    echo "$registry_namespace"
    return 0
}

# IPアドレス取得（クロスプラットフォーム）
get_ip_address() {
    local ip=""
    
    # Linux
    if command -v hostname &> /dev/null; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    
    # macOS
    if [ -z "$ip" ] && command -v ipconfig &> /dev/null; then
        ip=$(ipconfig getifaddr en0 2>/dev/null)
    fi
    
    if [ -z "$ip" ]; then
        echo "IPアドレスを手動で確認してください"
    else
        echo "$ip"
    fi
}

# パラメータバリデーション関数
validate_not_empty() {
    local var_name="$1"
    local var_value="$2"
    
    if [ -z "$var_value" ]; then
        log_error "必須パラメータ '$var_name' が空です"
        return 1
    fi
    return 0
}

validate_file_exists() {
    local file_path="$1"
    
    if [ ! -f "$file_path" ]; then
        log_error "ファイルが見つかりません: $file_path"
        return 1
    fi
    return 0
}

validate_dir_exists() {
    local dir_path="$1"
    
    if [ ! -d "$dir_path" ]; then
        log_error "ディレクトリが見つかりません: $dir_path"
        return 1
    fi
    return 0
}

validate_port() {
    local port="$1"
    
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        log_error "無効なポート番号: $port"
        return 1
    fi
    return 0
}

validate_url() {
    local url="$1"
    
    if ! [[ "$url" =~ ^https?:// ]]; then
        log_error "無効なURL形式: $url"
        return 1
    fi
    return 0
}

# 安全なクリーンアップ関数
cleanup_on_error() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "スクリプトがエラーで終了しました (終了コード: $exit_code)"
    fi
}

# エラートラップの設定
setup_error_handling() {
    set -euo pipefail
    trap cleanup_on_error EXIT
}

