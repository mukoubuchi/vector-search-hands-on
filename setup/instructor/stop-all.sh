#!/bin/bash
# Script to stop the Milvus environment, MkDocs documentation, and FastAPI demo

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load common functions
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

cd "$SCRIPT_DIR"

# Return PIDs on the port whose command line matches the expected pattern,
# so unrelated processes that happen to use the port are left alone
matching_pids_on_port() {
    local port="$1"
    local pattern="$2"
    local pid command

    for pid in $(lsof -ti:"$port" 2>/dev/null || true); do
        command=$(ps -p "$pid" -o command= 2>/dev/null || true)
        if echo "$command" | grep -Eq "$pattern"; then
            echo "$pid"
        else
            log_warn "Skipping PID $pid on port $port (unrelated process: ${command:-unknown})"
        fi
    done
}

stop_port_processes() {
    local port="$1"
    local label="$2"
    local pattern="$3"
    local pids

    echo "Checking for $label on port $port..."
    pids=$(matching_pids_on_port "$port" "$pattern")

    if [ -z "$pids" ]; then
        echo "No $label running on port $port"
        return
    fi

    echo "Stopping process(es) on port $port (PID: $(echo "$pids" | tr '\n' ' ' | sed 's/[[:space:]]*$//'))..."
    while IFS= read -r pid; do
        [ -z "$pid" ] && continue
        kill "$pid" 2>/dev/null || true
    done <<< "$pids"

    sleep 1

    pids=$(matching_pids_on_port "$port" "$pattern")
    if [ -n "$pids" ]; then
        echo "Force killing..."
        while IFS= read -r pid; do
            [ -z "$pid" ] && continue
            kill -9 "$pid" 2>/dev/null || true
        done <<< "$pids"
    fi

    pids=$(matching_pids_on_port "$port" "$pattern")
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
stop_port_processes 8000 "mkdocs development server" "mkdocs"

echo ""

# Stop FastAPI demo application running on port 8002
stop_port_processes 8002 "FastAPI demo application" "app\.py|uvicorn"

echo ""
log_header "All services stopped successfully"
