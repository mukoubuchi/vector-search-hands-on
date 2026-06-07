# Translation Sync Guide

## Overview

This project maintains the participant-facing English and Japanese documentation in parallel.

## Automatic Sync Check

GitHub Actions automatically checks for sync in Pull Requests and after pushes to `main`.
Both workflow files use the shared checker script `lib/check_translation_sync.sh`.

The check targets these participant-facing Markdown files:

- `index.md`
- `preparation.md`
- `part1.md`
- `part2.md`
- `part3.md`
- `summary.md`
- `feedback.md`

The check also covers paired diagram files that use `-en.svg` / `-ja.svg` suffixes under `docs/images/`.

Internal source guides such as `translation-sync.md` and `readme.md` are intentionally excluded from the sync check.

### EN → JA Sync Check

- **Trigger**: When an English participant-facing Markdown file or `docs/images/*-en.svg` is updated
- **Check**: Whether the corresponding Japanese file is updated in the same PR or push
- **Action in PRs**: Fails the check if not synced
- **Action after push to `main`**: Automatically creates an issue if not synced

### JA → EN Sync Check

- **Trigger**: When a Japanese participant-facing Markdown file or `docs/images/*-ja.svg` is updated
- **Check**: Whether the corresponding English file is updated in the same PR or push
- **Action in PRs**: Fails the check if not synced
- **Action after push to `main`**: Automatically creates an issue if not synced

## Best Practices

### 1. Update Both Languages Together

✅ **Recommended**:

```bash
# Edit English version
vim docs/index.md

# Edit Japanese version too
vim docs/ja/index.md

# Commit both
git add docs/index.md docs/ja/index.md
git commit -m "Update index page in both EN and JA"
```

❌ **Not Recommended**:

```bash
# Update only English version
git add docs/index.md
git commit -m "Update index page"
# → The PR check fails, or an issue is created after push to main
```

### 2. Use IBM Bob

You can ask IBM Bob to translate:

```text
Translate the changes in docs/index.md to docs/ja/index.md
```

### 3. Check in PR

When creating a Pull Request, please check:

- [ ] Both EN and JA versions are updated
- [ ] Content matches
- [ ] GitHub Actions checks pass

### 4. Intentional One-language Updates

If a one-language-only update is intentional:

- Add the `translation-sync-skip` label to the Pull Request
- Include `[skip translation-sync]` in the merge commit message so the push-to-main backstop does not create an issue

## Workflow Files

### `.github/workflows/sync-translations.yml`

Checks EN → JA sync by calling `lib/check_translation_sync.sh` with `SOURCE_LOCALE=en`.

### `.github/workflows/sync-translations-ja-to-en.yml`

Checks JA → EN sync by calling `lib/check_translation_sync.sh` with `SOURCE_LOCALE=ja`.

### `lib/check_translation_sync.sh`

Contains the common changed-file detection, skip-label handling, counterpart mapping, and GitHub Actions output writing used by both sync workflows.

## Issue Labels

Automatically created issues are labeled with:

- `translation-sync`: Translation sync required
- `documentation`: Documentation related

## Manual Sync

When a sync issue is created:

1. **Check the issue**

    - Check which files are not synced

2. **Update corresponding files**

    - Reflect EN changes to JA (or vice versa)

3. **Commit & Push**

    ```bash
    git add docs/index.md docs/ja/index.md
    git commit -m "Sync EN-JA translations for index page"
    git push
    ```

4. **Close the issue**

    - Close the issue when sync is complete

## FAQ

### Q1: What if I intentionally want to update only one language?

A: Add the `translation-sync-skip` label to the Pull Request. When merging, include `[skip translation-sync]` in the merge commit message.

### Q2: How to check sync status of existing files?

A: Use the following script:

```bash
# List participant-facing English files
printf '%s\n' docs/index.md docs/preparation.md docs/part1.md docs/part2.md docs/part3.md docs/summary.md docs/feedback.md

# Check if corresponding Japanese version exists
for file in docs/index.md docs/preparation.md docs/part1.md docs/part2.md docs/part3.md docs/summary.md docs/feedback.md; do
  ja_file="docs/ja/$(basename $file)"
  if [ ! -f "$ja_file" ]; then
    echo "Missing: $ja_file"
  fi
done
```

### Q3: How to manually trigger the workflow?

A: You can manually trigger it from the GitHub Actions tab using `workflow_dispatch`.

## Related Files

- `mkdocs.yml`: MkDocs configuration (i18n plugin settings)
- `.github/workflows/deploy-docs.yml`: Documentation deploy workflow
- `.github/workflows/sync-translations.yml`: EN → JA sync check
- `.github/workflows/sync-translations-ja-to-en.yml`: JA → EN sync check
- `lib/check_translation_sync.sh`: Shared translation sync checker
