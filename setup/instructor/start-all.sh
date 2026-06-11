#!/bin/bash
# Script to start the Milvus environment and MkDocs documentation

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load common functions
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

cd "$SCRIPT_DIR"

ENV_FILE="$SCRIPT_DIR/.env"

generate_secret() {
    LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20
}

# Read NAME=value from .env (strips trailing inline comments)
read_env_value() {
    local name="$1"
    [ -f "$ENV_FILE" ] || return 0
    grep -E "^${name}=" "$ENV_FILE" | head -1 | cut -d= -f2- | sed 's/[[:space:]]*#.*$//; s/[[:space:]]*$//'
}

# Write NAME=value into .env, replacing an existing line
write_env_value() {
    local name="$1"
    local value="$2"
    touch "$ENV_FILE"
    if grep -qE "^${name}=" "$ENV_FILE"; then
        sed -i.bak "s|^${name}=.*|${name}=${value}|" "$ENV_FILE" && rm -f "$ENV_FILE.bak"
    else
        printf '%s=%s\n' "$name" "$value" >> "$ENV_FILE"
    fi
}

# Generate credentials on first start; never keep the documented defaults
ensure_credentials() {
    local milvus_password minio_password

    milvus_password="$(read_env_value MILVUS_PASSWORD)"
    if [ -z "$milvus_password" ] || [ "$milvus_password" = "Milvus" ]; then
        milvus_password="$(generate_secret)"
        write_env_value MILVUS_PASSWORD "$milvus_password"
        log_info "Generated Milvus root password (stored in setup/instructor/.env)"
    fi
    export MILVUS_PASSWORD="$milvus_password"

    minio_password="$(read_env_value MINIO_ROOT_PASSWORD)"
    if [ -z "$minio_password" ] || [ "$minio_password" = "minioadmin" ]; then
        minio_password="$(generate_secret)"
        write_env_value MINIO_ROOT_PASSWORD "$minio_password"
        log_info "Generated MinIO root password (stored in setup/instructor/.env)"
    fi
    export MINIO_ROOT_PASSWORD="$minio_password"
}

wait_for_milvus() {
    local retries=60

    echo "Waiting for Milvus to become healthy (this can take a minute)..."
    while [ "$retries" -gt 0 ]; do
        if curl -sf http://localhost:9091/healthz > /dev/null 2>&1; then
            log_info "Milvus is healthy"
            return 0
        fi
        sleep 3
        retries=$((retries - 1))
    done

    log_error "Milvus did not become healthy in time"
    echo "  Check the logs with: $COMPOSE_CMD --profile all logs milvus"
    return 1
}

# Replace the default root password with the generated one (idempotent)
rotate_milvus_password() {
    if ! python3 -c "import pymilvus" 2>/dev/null; then
        log_warn "pymilvus is not installed for python3; cannot rotate the Milvus root password automatically"
        echo "  Install it (pip install pymilvus) and rerun ./start-all.sh."
        return 0
    fi

    python3 - "$MILVUS_PASSWORD" <<'PYEOF'
import sys
from pymilvus import connections, utility

new_password = sys.argv[1]

try:
    connections.connect(alias="check", host="localhost", port="19530",
                        user="root", password=new_password)
    connections.disconnect("check")
    print("✓ Milvus root password is already set")
    sys.exit(0)
except Exception:
    pass

try:
    connections.connect(alias="rotate", host="localhost", port="19530",
                        user="root", password="Milvus")
    utility.reset_password("root", "Milvus", new_password, using="rotate")
    connections.disconnect("rotate")
    print("✓ Milvus root password rotated away from the default")
except Exception as exc:
    print(f"WARNING: could not rotate the Milvus root password automatically: {exc}")
    print("Rotate it manually, then update MILVUS_PASSWORD in setup/instructor/.env.")
PYEOF
}

# Print header
log_header "Starting Vector Search hands-on environment..."

# Detect container runtime
if ! detect_container_runtime; then
    exit 1
fi

echo ""

# Generate credentials before the containers read them
ensure_credentials

echo ""

# Start Milvus environment and MkDocs
echo "Starting Milvus environment and MkDocs documentation..."
if $COMPOSE_CMD --profile all up -d --build; then
    log_info "All services started"
    echo "  - etcd, minio, milvus"
    echo "  - mkdocs (documentation server)"
else
    log_error "Failed to start services"
    exit 1
fi

echo ""

wait_for_milvus
rotate_milvus_password

echo ""
log_header "All services started successfully"
LOCAL_IP="$(get_ip_address)"
echo "Access information:"
echo ""
echo "  Milvus:"
echo "    - Host: localhost"
echo "    - Port: 19530"
echo "    - User: root"
echo "    - Password: ${MILVUS_PASSWORD}"
echo "      (also stored as MILVUS_PASSWORD in setup/instructor/.env)"
echo ""
echo "  MkDocs:"
echo "    - Container version (port 8001): http://localhost:8001  (running)"
echo "      - Purpose: Sharing with participants, stable delivery"
echo "      - Note: Auto-reload on file changes not available (container restart required)"
echo ""
echo "    - Development version (port 8000): not started"
echo "      - How to start: python -m mkdocs serve (run from project root)"
echo "      - Purpose: Document editing (with auto-reload)"
echo ""
echo "Next steps:"
echo ""
echo "  1. Information to share with participants (for local delivery):"
echo "     - Milvus host: ${LOCAL_IP}:19530"
echo "     - Milvus password: ${MILVUS_PASSWORD}"
echo "     - Documentation: http://${LOCAL_IP}:8001"
echo ""
echo "  2. Delivery methods for remote participants:"
echo "     - Private network such as Tailscale/VPN (recommended): see README"
echo "     - GitHub Pages for documentation: see setup/instructor/deploy-docs-to-cloud.md"
echo "     - ngrok TCP (fallback; traffic is not encrypted): ngrok tcp 19530"
echo ""
echo "  3. If document editing is needed:"
echo "     - Move to project root: cd ../.."
echo "     - Start development version: python -m mkdocs serve"
echo "       (Note: this command occupies the terminal)"
echo "     - Background execution: python -m mkdocs serve &"
echo "     - Access: http://localhost:8000 or http://${LOCAL_IP}:8000"
echo "     - Real-time preview with auto-reload"
echo ""
echo "     How to stop:"
echo "       - Foreground execution: Ctrl+C"
echo "       - Background execution: cd setup/instructor && ./stop-all.sh"
echo "       - Manual stop: kill \$(lsof -ti:8000)"
echo ""
echo "  See: setup/instructor/deploy-docs-to-cloud.md"
echo ""
echo "=========================================="
echo ""
echo "To stop, run:"
echo "  ./stop-all.sh"
echo ""
