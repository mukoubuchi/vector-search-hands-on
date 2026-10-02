#!/bin/bash

set -euo pipefail

SKIP_LABEL="translation-sync-skip"
SKIP_MARKER="[skip translation-sync]"
# Commit trailer that declares one file as an intentional one-language change,
# for example "Translation-Sync-Skip: docs/ja/part2.md" (one file per trailer)
SKIP_TRAILER="Translation-Sync-Skip"
ZERO_SHA="0000000000000000000000000000000000000000"
SOURCE_LOCALE="${SOURCE_LOCALE:?SOURCE_LOCALE must be set to en or ja}"

# Working file for the changed-files list. In CI the workspace is ephemeral,
# so a fixed name is fine; for local runs use a temp file and clean it up so
# the repository is not littered with changed_files.txt.
if [ -z "${CHANGED_FILES_FILE:-}" ]; then
    if [ -n "${GITHUB_OUTPUT:-}" ]; then
        CHANGED_FILES_FILE="changed_files.txt"
    else
        CHANGED_FILES_FILE="$(mktemp)"
        trap 'rm -f "$CHANGED_FILES_FILE"' EXIT
    fi
fi

case "$SOURCE_LOCALE" in
    en)
        SOURCE_LABEL="English"
        TARGET_LABEL="Japanese"
        CHANGED_FILE_PATTERN='^(docs/(index|preparation|part1|part2|part3|summary|feedback)\.md|docs/images/.*-en\.svg)$'
        ;;
    ja)
        SOURCE_LABEL="Japanese"
        TARGET_LABEL="English"
        CHANGED_FILE_PATTERN='^(docs/ja/(index|preparation|part1|part2|part3|summary|feedback)\.md|docs/images/.*-ja\.svg)$'
        ;;
    *)
        echo "Unsupported SOURCE_LOCALE: $SOURCE_LOCALE" >&2
        exit 1
        ;;
esac

write_output() {
    local name="$1"
    local value="$2"

    if [ -n "${GITHUB_OUTPUT:-}" ]; then
        printf '%s=%s\n' "$name" "$value" >> "$GITHUB_OUTPUT"
    else
        printf '%s=%s\n' "$name" "$value"
    fi
}

write_multiline_output() {
    local name="$1"
    local value="$2"

    if [ -n "${GITHUB_OUTPUT:-}" ]; then
        {
            printf '%s<<EOF\n' "$name"
            printf '%s\n' "$value"
            printf 'EOF\n'
        } >> "$GITHUB_OUTPUT"
    else
        printf '%s:\n%s\n' "$name" "$value"
    fi
}

skip_with_success() {
    echo "$1"
    write_output "needs_sync" "false"
    exit 0
}

# Print the paths declared with SKIP_TRAILER in the given commits, one per line.
# Git reads trailers from the last paragraph of each message and matches the key
# case-insensitively.
read_declared_paths() {
    git log --format="%(trailers:key=$SKIP_TRAILER,valueonly)" "$@" \
        | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e '/^$/d' \
        | sort -u
}

# Write the changed files to CHANGED_FILES_FILE, and set declared_paths from the
# trailers of the same commits.
changed_files_for_event() {
    local event_name="${GITHUB_EVENT_NAME:-manual}"
    local head_sha="${GITHUB_SHA:-HEAD}"
    local before_sha="${GITHUB_EVENT_BEFORE:-}"

    case "$event_name" in
        pull_request)
            local base_sha="${PR_BASE_SHA:?PR_BASE_SHA must be set for pull_request events}"
            local pr_head_sha="${PR_HEAD_SHA:?PR_HEAD_SHA must be set for pull_request events}"
            git diff --name-only "$base_sha...$pr_head_sha" > "$CHANGED_FILES_FILE"
            declared_paths="$(read_declared_paths "$base_sha..$pr_head_sha")"
            ;;
        push)
            if [ -z "$before_sha" ] \
                || [ "$before_sha" = "$ZERO_SHA" ] \
                || ! git cat-file -e "$before_sha^{commit}" 2>/dev/null \
                || ! git merge-base "$before_sha" "$head_sha" >/dev/null; then
                git diff-tree --root --no-commit-id --name-only -r "$head_sha" > "$CHANGED_FILES_FILE"
                declared_paths="$(read_declared_paths -1 "$head_sha")"
            else
                git diff --name-only "$before_sha...$head_sha" > "$CHANGED_FILES_FILE"
                declared_paths="$(read_declared_paths "$before_sha..$head_sha")"
            fi
            ;;
        *)
            if git rev-parse --verify HEAD~1 >/dev/null 2>&1; then
                git diff --name-only "HEAD~1...HEAD" > "$CHANGED_FILES_FILE"
                declared_paths="$(read_declared_paths "HEAD~1..HEAD")"
            else
                git diff-tree --root --no-commit-id --name-only -r HEAD > "$CHANGED_FILES_FILE"
                declared_paths="$(read_declared_paths -1 HEAD)"
            fi
            ;;
    esac
}

counterpart_for_file() {
    local source_file="$1"

    if [ "$SOURCE_LOCALE" = "en" ]; then
        if [[ "$source_file" =~ ^docs/images/.*-en\.svg$ ]]; then
            printf '%s\n' "${source_file%-en.svg}-ja.svg"
        else
            printf 'docs/ja/%s\n' "$(basename "$source_file")"
        fi
        return
    fi

    if [[ "$source_file" =~ ^docs/images/.*-ja\.svg$ ]]; then
        printf '%s\n' "${source_file%-ja.svg}-en.svg"
    else
        printf 'docs/%s\n' "$(basename "$source_file")"
    fi
}

append_line() {
    local current="$1"
    local line="$2"

    if [ -n "$current" ]; then
        printf '%s\n%s' "$current" "$line"
    else
        printf '%s' "$line"
    fi
}

append_missing_file() {
    local current="$1"
    local line="$2"

    if [ -n "$current" ]; then
        printf '%s\n- %s' "$current" "$line"
    else
        printf -- '- %s' "$line"
    fi
}

if [ "${GITHUB_EVENT_NAME:-}" = "pull_request" ] \
    && printf '%s' "${PR_LABELS:-}" | grep -q "\"$SKIP_LABEL\""; then
    skip_with_success "Skipping translation sync check because $SKIP_LABEL label is present"
fi

if [ "${GITHUB_EVENT_NAME:-}" = "push" ] \
    && printf '%s' "${COMMIT_MESSAGE:-}" | grep -Fqi "$SKIP_MARKER"; then
    skip_with_success "Skipping translation sync check because commit message contains $SKIP_MARKER"
fi

declared_paths=""
changed_files_for_event

if [ -n "$declared_paths" ]; then
    echo "Declared with $SKIP_TRAILER:"
    echo "$declared_paths"
fi

# A declared path that the checked commits do not change is likely a typo. It
# excuses no other file.
while IFS= read -r declared_path; do
    [ -z "$declared_path" ] && continue
    if ! grep -Fxq -- "$declared_path" "$CHANGED_FILES_FILE"; then
        echo "Warning: $SKIP_TRAILER declares $declared_path, which the checked commits do not change"
    fi
done <<< "$declared_paths"

changed_source_files="$(grep -E "$CHANGED_FILE_PATTERN" "$CHANGED_FILES_FILE" || true)"

if [ -z "$changed_source_files" ]; then
    echo "No $SOURCE_LABEL participant documentation files changed"
    write_output "needs_sync" "false"
    exit 0
fi

echo "Changed $SOURCE_LABEL files:"
echo "$changed_source_files"

needs_sync=false
missing_files=""
skip_trailers=""

while IFS= read -r source_file; do
    [ -z "$source_file" ] && continue

    if grep -Fxq -- "$source_file" <<< "$declared_paths"; then
        echo "Skipping $source_file: declared with $SKIP_TRAILER"
        continue
    fi

    target_file="$(counterpart_for_file "$source_file")"

    if [ ! -f "$target_file" ]; then
        needs_sync=true
        missing_files="$(append_missing_file "$missing_files" "$target_file does not exist ($SOURCE_LABEL counterpart: $source_file)")"
        skip_trailers="$(append_line "$skip_trailers" "$SKIP_TRAILER: $source_file")"
    elif ! grep -Fxq "$target_file" "$CHANGED_FILES_FILE"; then
        needs_sync=true
        missing_files="$(append_missing_file "$missing_files" "$target_file ($SOURCE_LABEL counterpart: $source_file)")"
        skip_trailers="$(append_line "$skip_trailers" "$SKIP_TRAILER: $source_file")"
    fi
done <<< "$changed_source_files"

write_output "needs_sync" "$needs_sync"

if [ "$needs_sync" = true ]; then
    echo "$TARGET_LABEL sync is required:"
    echo "$missing_files"
    echo "If this is intentional, add these trailers to a commit message:"
    echo "$skip_trailers"
    write_multiline_output "missing_files" "$missing_files"
    write_multiline_output "skip_trailers" "$skip_trailers"
fi
