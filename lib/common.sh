#!/bin/bash

# Common function library
# Provides shared functionality used across all scripts

# Prevent multiple sourcing
if [ -n "${COMMON_SH_LOADED:-}" ]; then
    return 0
fi
readonly COMMON_SH_LOADED=1

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
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

# Check if command exists
check_command() {
    local cmd="$1"
    local install_msg="${2:-}"

    if ! command -v "$cmd" &> /dev/null; then
        log_error "$cmd is not installed"
        if [ -n "$install_msg" ]; then
            echo ""
            echo "$install_msg"
            echo ""
        fi
        return 1
    fi
    return 0
}

# Detect container runtime (Docker/Podman)
detect_container_runtime() {
    local container_cmd=""
    local compose_cmd=""

    if command -v docker &> /dev/null; then
        container_cmd="docker"

        # Check both docker compose and docker-compose
        if docker compose version &> /dev/null 2>&1; then
            compose_cmd="docker compose"
        elif command -v docker-compose &> /dev/null; then
            compose_cmd="docker-compose"
        else
            log_error "docker-compose is not installed"
            echo ""
            echo "Install with:"
            echo "  brew install docker-compose"
            echo ""
            return 1
        fi

        log_info "Docker found"
    elif command -v podman &> /dev/null; then
        container_cmd="podman"

        # Podman 4.0+ supports podman compose
        if podman compose version &> /dev/null 2>&1; then
            compose_cmd="podman compose"
        elif command -v podman-compose &> /dev/null; then
            compose_cmd="podman-compose"
        else
            log_error "podman-compose is not installed"
            echo ""
            echo "Install with:"
            echo "  brew install podman-compose"
            echo ""
            return 1
        fi
        log_info "Podman found"
    else
        log_error "Docker or Podman is not installed"
        echo ""
        echo "Install with:"
        echo "  Docker: https://docs.docker.com/get-docker/"
        echo "  Podman: https://podman.io/getting-started/installation"
        echo ""
        return 1
    fi

    # Export as environment variables
    export CONTAINER_CMD="$container_cmd"
    export COMPOSE_CMD="$compose_cmd"
    return 0
}

# Get IP address (cross-platform)
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
        echo "Please check IP address manually"
    else
        echo "$ip"
    fi
}

# Parameter validation functions
validate_not_empty() {
    local var_name="$1"
    local var_value="$2"

    if [ -z "$var_value" ]; then
        log_error "Required parameter '$var_name' is empty"
        return 1
    fi
    return 0
}

validate_file_exists() {
    local file_path="$1"

    if [ ! -f "$file_path" ]; then
        log_error "File not found: $file_path"
        return 1
    fi
    return 0
}

validate_dir_exists() {
    local dir_path="$1"

    if [ ! -d "$dir_path" ]; then
        log_error "Directory not found: $dir_path"
        return 1
    fi
    return 0
}

validate_port() {
    local port="$1"

    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        log_error "Invalid port number: $port"
        return 1
    fi
    return 0
}

validate_url() {
    local url="$1"

    if ! [[ "$url" =~ ^https?:// ]]; then
        log_error "Invalid URL format: $url"
        return 1
    fi
    return 0
}

# Safe cleanup function
cleanup_on_error() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Script exited with error (exit code: $exit_code)"
    fi
}

# Set up error handling
setup_error_handling() {
    set -euo pipefail
    trap cleanup_on_error EXIT
}
