# Translation Sync Guide / 翻訳同期ガイド

## Overview / 概要

このプロジェクトでは、英語版（`docs/*.md`）と日本語版（`docs/ja/*.md`）のドキュメントを並行管理しています。

This project maintains English (`docs/*.md`) and Japanese (`docs/ja/*.md`) documentation in parallel.

## Automatic Sync Check / 自動同期チェック

GitHub Actionsが以下の場合に自動的にチェックを実行します：

GitHub Actions automatically checks for sync in the following cases:

### EN → JA Sync Check

- **トリガー**: `docs/*.md`（日本語版以外）が更新された時
- **チェック内容**: 対応する`docs/ja/*.md`が同じコミットで更新されているか
- **アクション**: 同期されていない場合、Issueを自動作成

---

- **Trigger**: When `docs/*.md` (excluding Japanese version) is updated
- **Check**: Whether corresponding `docs/ja/*.md` is updated in the same commit
- **Action**: Automatically creates an issue if not synced

### JA → EN Sync Check

- **トリガー**: `docs/ja/*.md`が更新された時
- **チェック内容**: 対応する`docs/*.md`が同じコミットで更新されているか
- **アクション**: 同期されていない場合、Issueを自動作成

---

- **Trigger**: When `docs/ja/*.md` is updated
- **Check**: Whether corresponding `docs/*.md` is updated in the same commit
- **Action**: Automatically creates an issue if not synced

## Best Practices / ベストプラクティス

### 1. 両言語を同時に更新 / Update Both Languages Together

✅ **推奨 / Recommended**:

```bash
# 英語版を編集
vim docs/index.md

# 日本語版も編集
vim docs/ja/index.md

# 両方をコミット
git add docs/index.md docs/ja/index.md
git commit -m "Update index page in both EN and JA"
```

❌ **非推奨 / Not Recommended**:

```bash
# 英語版のみ更新
git add docs/index.md
git commit -m "Update index page"
# → 日本語版が同期されず、Issueが作成される
```

### 2. IBM Bobを活用 / Use IBM Bob

IBM Bobに翻訳を依頼できます：

You can ask IBM Bob to translate:

```text
docs/index.mdの変更内容をdocs/ja/index.mdに反映して
```

または / Or:

```text
Translate the changes in docs/index.md to docs/ja/index.md
```

### 3. PRでの確認 / Check in PR

Pull Request作成時に、以下を確認してください：

When creating a Pull Request, please check:

- [ ] 英語版と日本語版の両方が更新されている / Both EN and JA versions are updated
- [ ] 内容が一致している / Content matches
- [ ] GitHub Actionsのチェックがパスしている / GitHub Actions checks pass

## Workflow Files / ワークフローファイル

### `.github/workflows/sync-translations.yml`

英語版→日本語版の同期をチェック

Checks EN → JA sync

### `.github/workflows/sync-translations-ja-to-en.yml`

日本語版→英語版の同期をチェック

Checks JA → EN sync

## Issue Labels / Issueラベル

自動作成されるIssueには以下のラベルが付与されます：

Automatically created issues are labeled with:

- `translation-sync`: 翻訳同期が必要 / Translation sync required
- `documentation`: ドキュメント関連 / Documentation related

## Manual Sync / 手動同期

同期Issueが作成された場合：

When a sync issue is created:

1. **Issueを確認** / Check the issue
   - どのファイルが同期されていないか確認
   - Check which files are not synced

2. **対応するファイルを更新** / Update corresponding files
   - 英語版の変更を日本語版に反映（またはその逆）
   - Reflect EN changes to JA (or vice versa)

3. **コミット＆プッシュ** / Commit & Push
   ```bash
   git add docs/index.md docs/ja/index.md
   git commit -m "Sync EN-JA translations for index page"
   git push
   ```

4. **Issueをクローズ** / Close the issue
   - 同期が完了したらIssueをクローズ
   - Close the issue when sync is complete

## FAQ

### Q1: 意図的に片方だけ更新したい場合は？

A: コミットメッセージに`[skip-sync-check]`を含めることで、チェックをスキップできます（将来実装予定）。

---

Q: What if I intentionally want to update only one language?

A: Include `[skip-sync-check]` in the commit message to skip the check (planned for future implementation).

### Q2: 既存のファイルの同期状態を確認したい

A: 以下のスクリプトで確認できます：

---

Q: How to check sync status of existing files?

A: Use the following script:

```bash
# 英語版のファイル一覧
ls docs/*.md

# 対応する日本語版が存在するか確認
for file in docs/*.md; do
  ja_file="docs/ja/$(basename $file)"
  if [ ! -f "$ja_file" ]; then
    echo "Missing: $ja_file"
  fi
done
```

### Q3: ワークフローを手動実行したい

A: GitHubのActionsタブから`workflow_dispatch`で手動実行できます。

---

Q: How to manually trigger the workflow?

A: You can manually trigger it from the GitHub Actions tab using `workflow_dispatch`.

## Related Files / 関連ファイル

- `mkdocs.yml`: MkDocs設定（i18nプラグイン設定）
- `.github/workflows/deploy-docs.yml`: ドキュメントデプロイワークフロー
- `.github/workflows/sync-translations.yml`: EN→JA同期チェック
- `.github/workflows/sync-translations-ja-to-en.yml`: JA→EN同期チェック

---

Made with Bob