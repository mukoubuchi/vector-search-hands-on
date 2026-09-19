#!/bin/bash
# Script to start the OpenSearch environment and MkDocs documentation

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load common functions
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

cd "$SCRIPT_DIR"

ENV_FILE="$SCRIPT_DIR/.env"
OPENSEARCH_URL="https://localhost:9200"

# The security plugin rejects a weak password, so the generated value carries
# an upper-case letter, a lower-case letter, a digit and a symbol by construction
generate_secret() {
    printf 'Os%s!7' "$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)"
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

# Generate the admin password on first start; the containers read it from .env
ensure_credentials() {
    local password

    password="$(read_env_value OPENSEARCH_INITIAL_ADMIN_PASSWORD)"
    if [ -z "$password" ]; then
        password="$(generate_secret)"
        write_env_value OPENSEARCH_INITIAL_ADMIN_PASSWORD "$password"
        log_info "Generated OpenSearch admin password (stored in setup/instructor/.env)"
    fi
    export OPENSEARCH_INITIAL_ADMIN_PASSWORD="$password"

    # The participant-style scripts read OPENSEARCH_PASSWORD; keep both in sync
    write_env_value OPENSEARCH_PASSWORD "$password"
}

wait_for_opensearch() {
    local retries=60
    local health

    echo "Waiting for OpenSearch to become healthy (this can take a minute)..."
    while [ "$retries" -gt 0 ]; do
        health="$(curl -sk -u "admin:${OPENSEARCH_INITIAL_ADMIN_PASSWORD}" \
            "$OPENSEARCH_URL/_cluster/health" 2>/dev/null || true)"
        if echo "$health" | grep -qE '"status":"(green|yellow)"'; then
            log_info "OpenSearch is healthy"
            return 0
        fi
        sleep 3
        retries=$((retries - 1))
    done

    log_error "OpenSearch did not become healthy in time"
    echo "  Check the logs with: $COMPOSE_CMD --profile all logs opensearch"
    return 1
}

# The hands-on needs the k-NN plugin; report it instead of failing later
report_knn_plugin() {
    if curl -sk -u "admin:${OPENSEARCH_INITIAL_ADMIN_PASSWORD}" \
        "$OPENSEARCH_URL/_cat/plugins?h=component" 2>/dev/null | grep -q '^opensearch-knn'; then
        log_info "k-NN plugin is available"
    else
        log_warn "k-NN plugin was not found; vector search will not work"
    fi
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

# Start OpenSearch and MkDocs
echo "Starting OpenSearch and MkDocs documentation..."
if $COMPOSE_CMD --profile all up -d --build; then
    log_info "All services started"
    echo "  - opensearch"
    echo "  - mkdocs (documentation server)"
else
    log_error "Failed to start services"
    exit 1
fi

echo ""

wait_for_opensearch
report_knn_plugin

echo ""
log_header "All services started successfully"
LOCAL_IP="$(get_ip_address)"
echo "Access information:"
echo ""
echo "  OpenSearch:"
echo "    - Host: localhost"
echo "    - Port: 9200 (HTTPS, self-signed certificate)"
echo "    - User: admin"
echo "    - Password: ${OPENSEARCH_INITIAL_ADMIN_PASSWORD}"
echo "      (also stored as OPENSEARCH_PASSWORD in setup/instructor/.env)"
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
echo "     - OpenSearch host: ${LOCAL_IP}:9200"
echo "     - OpenSearch password: ${OPENSEARCH_INITIAL_ADMIN_PASSWORD}"
echo "     - Documentation: http://${LOCAL_IP}:8001"
echo "     - Remind them to set a unique INDEX_NAME in setup/participant/.env"
echo ""
echo "  2. Delivery methods for remote participants:"
echo "     - Private network such as Tailscale/VPN (recommended): see README"
echo "     - GitHub Pages for documentation: see setup/instructor/deploy-docs-to-cloud.md"
echo "     - ngrok TCP (fallback): ngrok tcp 9200"
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
echo "     See: setup/instructor/deploy-docs-to-cloud.md"
echo ""
echo "=========================================="
echo ""
echo "To stop, run:"
echo "  ./stop-all.sh"
echo ""
