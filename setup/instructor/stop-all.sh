#!/bin/bash
# Script to stop the Milvus environment, MkDocs documentation, and FastAPI demo

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load common functions
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

cd "$SCRIPT_DIR"

stop_port_processes() {
    local port="$1"
    local label="$2"
    local pids

    echo "Checking for $label on port $port..."
    pids=$(lsof -ti:"$port" 2>/dev/null || true)

    if [ -z "$pids" ]; then
        echo "No process running on port $port"
        return
    fi

    echo "Stopping process(es) on port $port (PID: $(echo "$pids" | tr '\n' ' ' | sed 's/[[:space:]]*$//'))..."
    while IFS= read -r pid; do
        [ -z "$pid" ] && continue
        kill "$pid" 2>/dev/null || true
    done <<< "$pids"

    sleep 1

    pids=$(lsof -ti:"$port" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        echo "Force killing..."
        while IFS= read -r pid; do
            [ -z "$pid" ] && continue
            kill -9 "$pid" 2>/dev/null || true
        done <<< "$pids"
    fi

    pids=$(lsof -ti:"$port" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        log_error "Failed to stop $label (port $port)"
        return 1
    fi

    log_info "$label (port $port) stopped"
}

# Print header
log_header "Stopping Vector Search hands-on environment..."

# Detect container runtime
if ! detect_container_runtime; then
    exit 1
fi

echo ""

# Stop Milvus environment, MkDocs, and FastAPI demo
echo "Stopping Milvus environment, MkDocs documentation, and FastAPI demo..."
if $COMPOSE_CMD --profile all down; then
    log_info "Docker containers stopped"
    echo "  - etcd, minio, milvus"
    echo "  - mkdocs (container version, port 8001)"
else
    log_error "Failed to stop Docker containers"
    exit 1
fi

echo ""

# Stop mkdocs development server running on port 8000
stop_port_processes 8000 "mkdocs development server"

echo ""

# Stop FastAPI demo application running on port 8002
stop_port_processes 8002 "FastAPI demo application"

echo ""
log_header "All services stopped successfully"
