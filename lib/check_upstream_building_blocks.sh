#!/bin/bash
# Verify that the Building Blocks assets in setup/participant/.bob still match
# the pinned upstream release, apart from the one recorded custom_modes.yaml fix.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/common.sh"
# shellcheck source=lib/upstream-building-blocks.sh
source "$SCRIPT_DIR/upstream-building-blocks.sh"

SHIPPED_DIR="$REPO_ROOT/setup/participant/.bob"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

fetch_zip() {
    local path="$1"
    local blob="$2"
    local target="$3"
    local actual

    curl -fsSL -o "$target" \
        "https://raw.githubusercontent.com/$UPSTREAM_REPO/$UPSTREAM_REF/$path"

    # The blob id pins the exact bytes, independent of the delivery path
    actual="$(git hash-object "$target")"
    if [ "$actual" != "$blob" ]; then
        log_error "$path: blob id mismatch"
        echo "  expected: $blob"
        echo "  actual:   $actual"
        return 1
    fi
    log_info "$path: blob $blob"
}

log_header "Checking setup/participant/.bob against upstream $UPSTREAM_REPO@${UPSTREAM_REF:0:7}"

mkdir -p "$WORK_DIR/upstream"
fetch_zip "$MODE_ZIP_PATH" "$MODE_ZIP_BLOB" "$WORK_DIR/mode.zip"
fetch_zip "$SKILL_ZIP_PATH" "$SKILL_ZIP_BLOB" "$WORK_DIR/skill.zip"

unzip -q "$WORK_DIR/mode.zip" -d "$WORK_DIR/upstream"
unzip -q "$WORK_DIR/skill.zip" -d "$WORK_DIR/upstream"

# Apply the one recorded change to the upstream copy, then everything must match
CUSTOM_MODES="$WORK_DIR/upstream/.bob/custom_modes.yaml"
occurrences="$(grep -c -F -x "$CUSTOM_MODES_FIX_BEFORE" "$CUSTOM_MODES" || true)"
if [ "$occurrences" != "1" ]; then
    log_error "custom_modes.yaml: expected exactly one line to fix, found $occurrences"
    echo "  Upstream changed. Re-check the recorded fix in lib/upstream-building-blocks.sh."
    exit 1
fi
python3 - "$CUSTOM_MODES" "$CUSTOM_MODES_FIX_BEFORE" "$CUSTOM_MODES_FIX_AFTER" <<'PYEOF'
import sys
from pathlib import Path

path, before, after = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
path.write_text(path.read_text().replace(before + "\n", after + "\n", 1))
PYEOF
log_info "custom_modes.yaml: applied the recorded one-line fix"

echo ""
if diff -r "$WORK_DIR/upstream/.bob" "$SHIPPED_DIR"; then
    log_info "setup/participant/.bob matches upstream (with the recorded fix)"
else
    log_error "setup/participant/.bob differs from upstream"
    echo "  Update the shipped files, or record the change in lib/upstream-building-blocks.sh."
    exit 1
fi
