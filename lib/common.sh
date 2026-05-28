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
        
        log_info "Dockerが見つかりました"
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
        return 1
    fi
    
    # 環境変数にエクスポート
    export CONTAINER_CMD="$container_cmd"
    export COMPOSE_CMD="$compose_cmd"
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

