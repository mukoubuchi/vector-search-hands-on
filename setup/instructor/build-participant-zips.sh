#!/bin/bash
# Build the participant distribution zips (vector-search-builder-en.zip / -ja.zip)
# from the repository sources. The zips are not committed: the release workflow
# attaches them to GitHub releases, and local builds are gitignored.
#
# Usage:
#   ./build-participant-zips.sh [output-dir]   # default output: repository root

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load common functions
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$(cd "${1:-$REPO_ROOT}" && pwd)"

# Participant files shared by both language packages
PARTICIPANT_FILES=(
    app.py
    common.py
    insert_sample_data.py
    requirements.txt
    sample_products.py
    schema.py
    test_connection.py
    test_embeddings_hf.py
)

build_zip() {
    local lang="$1"
    local zip_name="vector-search-builder-$lang.zip"
    local staging
    staging="$(mktemp -d)"

    mkdir -p "$staging/.bob" "$staging/setup/participant"

    cp "$REPO_ROOT/.bob/custom_modes.yaml" "$staging/.bob/"
    cp -R "$REPO_ROOT/.bob/rules-vector-search-builder" "$staging/.bob/"

    local file
    for file in "${PARTICIPANT_FILES[@]}"; do
        cp "$REPO_ROOT/setup/participant/$file" "$staging/setup/participant/"
    done

    # Language-specific sample data and .env template
    cp "$REPO_ROOT/setup/participant/sample_products_$lang.py" "$staging/setup/participant/"
    cp "$REPO_ROOT/setup/participant/.env.example.$lang" "$staging/setup/participant/.env.example"

    # Never ship caches or OS metadata
    find "$staging" \( -name '__pycache__' -o -name '.DS_Store' \) -exec rm -rf {} + 2>/dev/null || true

    rm -f "$OUTPUT_DIR/$zip_name"
    (cd "$staging" && zip -r -X -q "$OUTPUT_DIR/$zip_name" .bob setup)
    rm -rf "$staging"

    log_info "Built $OUTPUT_DIR/$zip_name"
}

log_header "Building participant distribution zips..."

build_zip en
build_zip ja

echo ""
log_info "Done. The zips are local build artifacts (gitignored); releases attach them automatically."
