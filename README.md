# Vector Search ハンズオン

IBM Bob IDE × Milvus × Hugging Face Transformers を使ったベクトル検索の実践ハンズオン

## 🎯 概要

- **講師**: Milvus 環境とドキュメントを提供
- **受講者**: IBM Bob IDE のみで参加（API キー不要）
- **特徴**: 環境構築不要、完全無料、オフライン対応

## 🚀 クイックスタート

### 👨‍🏫 講師向け

```bash
# 1. コンテナランタイムを起動
# 初回起動時（Podman ランタイムで初期化）
colima start --runtime podman

# 既に起動済みの場合、または既存のランタイムを使用する場合
colima start

# 2. Milvus環境を起動
cd setup/instructor
./start-all.sh

# 3. IP アドレス確認
ifconfig | grep "inet " | grep -v 127.0.0.1

# 4. ドキュメントを Code Engine にデプロイ（リモート参加者向け）
cd ../..
./deploy-to-code-engine.sh

# 5. 受講者に共有
# - Milvus: <IP アドレス>:19530 (root/Milvus)
# - ドキュメント: Code Engine URL
```

詳細: [setup/instructor/deploy-docs-to-cloud.md](setup/instructor/deploy-docs-to-cloud.md)

### 👨‍🎓 受講者向け

**配布ファイル:**

- `vector-search-builder.zip` - IBM Bob IDE モード定義と接続テスト

**セットアップ手順:**

1. `vector-search-builder.zip` を解凍

   - Mac: ダブルクリック
   - Windows: 右クリック → 「すべて展開」
2. IBM Bob IDE でプロジェクトフォルダを開く

   - `File` → `Open Folder`
3. 講師から受け取った接続情報を設定

   - `setup/participant/.env.example` をコピーして `setup/participant/.env` を作成
   - `MILVUS_HOST` に講師から共有された IP アドレスを設定
4. ハンズオン開始

詳細: [docs/preparation.md](docs/preparation.md)

## 📖 ドキュメント

- **Code Engine デプロイ**: [`setup/instructor/deploy-docs-to-cloud.md`](setup/instructor/deploy-docs-to-cloud.md)
- **TechZone 環境ガイド**: [`setup/instructor/techzone-code-engine-guide.md`](setup/instructor/techzone-code-engine-guide.md)
- **講師向け情報共有**: [`setup/instructor/instructor-share-info.md`](setup/instructor/instructor-share-info.md)

## 📦 必要なツール

**講師**: Docker/Podman/Colima、IBM Cloud CLI

**受講者**: IBM Bob IDE
