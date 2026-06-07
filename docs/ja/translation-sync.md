# 翻訳同期ガイド

## 概要

このプロジェクトでは、受講者向けの英語版ドキュメントと日本語版ドキュメントを並行管理しています。

## 自動同期チェック

GitHub Actions が Pull Request と `main` への push 後に自動的にチェックを実行します。2 つのワークフローファイルは、共通チェックスクリプト `lib/check_translation_sync.sh` を使用します。チェック対象は、以下の受講者向け Markdown ファイルです。

- `index.md`
- `preparation.md`
- `part1.md`
- `part2.md`
- `part3.md`
- `summary.md`
- `feedback.md`

また、`docs/images/` 配下で `-en.svg` / `-ja.svg` の接尾辞を持つ図のペアもチェック対象です。`translation-sync.md` や `readme.md` のような内部向けソースガイドは、同期チェック対象から意図的に除外しています。

### EN → JA 同期チェック

- **トリガー**: 英語版の受講者向け Markdown ファイル、または `docs/images/*-en.svg` が更新された時
- **チェック内容**: 対応する日本語版ファイルが同じ PR または push で更新されているか
- **PR でのアクション**: 同期されていない場合、チェックを失敗させる
- **`main` push 後のアクション**: 同期されていない場合、Issue を自動作成

### JA → EN 同期チェック

- **トリガー**: 日本語版の受講者向け Markdown ファイル、または `docs/images/*-ja.svg` が更新された時
- **チェック内容**: 対応する英語版ファイルが同じ PR または push で更新されているか
- **PR でのアクション**: 同期されていない場合、チェックを失敗させる
- **`main` push 後のアクション**: 同期されていない場合、Issue を自動作成

## ベストプラクティス

### 1. 両言語を同時に更新する

✅ **推奨**:

```bash
# 英語版を編集
vim docs/index.md

# 日本語版も編集
vim docs/ja/index.md

# 両方をコミット
git add docs/index.md docs/ja/index.md
git commit -m "Update index page in both EN and JA"
```

❌ **非推奨**:

```bash
# 英語版のみ更新
git add docs/index.md
git commit -m "Update index page"
# → PR チェックが失敗する、または main push 後に Issue が作成されます
```

### 2. IBM Bob を使う

IBM Bob に翻訳を依頼できます：

```text
docs/index.md の変更内容を docs/ja/index.md に翻訳して
```

### 3. PR での確認

Pull Request 作成時に以下を確認してください。

- [ ] 英語版と日本語版の両方が更新されている
- [ ] 内容が一致している
- [ ] GitHub Actions のチェックがパスしている

### 4. 意図的に片言語だけ更新する場合

片方の言語だけを更新することが意図的な場合:

- Pull Request に `translation-sync-skip` ラベルを付ける
- `main` push 後のバックストップで Issue が作成されないよう、マージコミットメッセージに `[skip translation-sync]` を含める

## ワークフローファイル

### `.github/workflows/sync-translations.yml`

`SOURCE_LOCALE=en` を指定して `lib/check_translation_sync.sh` を呼び出し、EN → JA の同期をチェックします。

### `.github/workflows/sync-translations-ja-to-en.yml`

`SOURCE_LOCALE=ja` を指定して `lib/check_translation_sync.sh` を呼び出し、JA → EN の同期をチェックします。

### `lib/check_translation_sync.sh`

両方の同期ワークフローで使う、変更ファイルの検出、スキップラベルの処理、対応ファイルの判定、GitHub Actions 出力の書き込みをまとめた共通スクリプトです。

## Issue ラベル

自動作成される Issue には以下のラベルが付与されます。

- `translation-sync`: 翻訳同期が必要
- `documentation`: ドキュメント関連

## 手動同期の手順

同期 Issue が作成された場合:

1. **Issue を確認する**

    - 同期されていないファイルを確認する

2. **対応するファイルを更新する**

    - EN の変更を JA に反映する（またはその逆）

3. **コミット & プッシュ**

    ```bash
    git add docs/index.md docs/ja/index.md
    git commit -m "Sync EN-JA translations for index page"
    git push
    ```

4. **Issue をクローズする**

    - 同期が完了したら Issue をクローズする

## FAQ

### Q1: 意図的に片方だけ更新したい場合は？

A: Pull Request に `translation-sync-skip` ラベルを付けてください。マージ時には、マージコミットメッセージに `[skip translation-sync]` を含めてください。

### Q2: 既存のファイルの同期状態を確認したい

A: 以下のスクリプトで確認できます。

```bash
# 受講者向け英語版ファイルを一覧表示
printf '%s\n' docs/index.md docs/preparation.md docs/part1.md docs/part2.md docs/part3.md docs/summary.md docs/feedback.md

# 対応する日本語版が存在するか確認
for file in docs/index.md docs/preparation.md docs/part1.md docs/part2.md docs/part3.md docs/summary.md docs/feedback.md; do
  ja_file="docs/ja/$(basename $file)"
  if [ ! -f "$ja_file" ]; then
    echo "Missing: $ja_file"
  fi
done
```

### Q3: ワークフローを手動実行したい

A: GitHub の Actions タブから `workflow_dispatch` で手動実行できます。

## 関連ファイル

- `mkdocs.yml`: MkDocs 設定（i18n プラグイン設定）
- `.github/workflows/deploy-docs.yml`: ドキュメントデプロイワークフロー
- `.github/workflows/sync-translations.yml`: EN → JA 同期チェック
- `.github/workflows/sync-translations-ja-to-en.yml`: JA → EN 同期チェック
- `lib/check_translation_sync.sh`: 翻訳同期チェックの共通スクリプト
