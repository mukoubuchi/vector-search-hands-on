#!/bin/bash
# Script to start the Milvus environment and MkDocs documentation

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load common functions
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

cd "$SCRIPT_DIR"

# Print header
log_header "Starting Vector Search hands-on environment..."

# Detect container runtime
if ! detect_container_runtime; then
    exit 1
fi

echo ""

# Start Milvus environment and MkDocs
echo "Starting Milvus environment and MkDocs documentation..."
if $COMPOSE_CMD --profile all up -d; then
    log_info "All services started"
    echo "  - etcd, minio, milvus"
    echo "  - mkdocs (documentation server)"
else
    log_error "Failed to start services"
    exit 1
fi

echo ""
log_header "All services started successfully"
LOCAL_IP="$(get_ip_address)"
echo "Access information:"
echo ""
echo "  Milvus:"
echo "    - Host: localhost"
echo "    - Port: 19530"
echo "    - Credentials: root/Milvus"
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
echo "     - Documentation: http://${LOCAL_IP}:8001"
echo ""
echo "  2. Delivery methods for remote participants:"
echo "     - GitHub Pages (recommended): see setup/instructor/deploy-docs-to-cloud.md"
echo "     - ngrok (temporary): ngrok http 8001"
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
