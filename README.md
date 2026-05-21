# Vector Search ハンズオン

IBM Bob IDE × Milvus × Hugging Face Transformersを使ったベクトル検索の実践ハンズオン

## 🎯 概要

- **講師**: Milvus環境とドキュメントを提供
- **受講者**: IBM Bob IDEのみで参加（APIキー不要）
- **特徴**: 環境構築不要、完全無料、オフライン対応

## 🚀 クイックスタート

### 👨‍🏫 講師向け

```bash
# 1. 環境起動（Docker/Podman/Colima対応）
cd setup/instructor
./start-all.sh

# 2. IPアドレス確認
ifconfig | grep "inet " | grep -v 127.0.0.1

# 3. ドキュメントをCode Engineにデプロイ（リモート参加者向け）
cd ../../docs/participant
./deploy-to-code-engine.sh

# 4. 受講者に共有
# - Milvus: <IPアドレス>:19530 (root/Milvus)
# - ドキュメント: Code Engine URL
```

詳細: [setup/instructor/README.md](setup/instructor/README.md)

### 👨‍🎓 受講者向け

```bash
# 1. IBM Bob IDEを起動

# 2. 講師から受け取った情報を設定
# - Milvus接続情報
# - ドキュメントURL

# 3. ハンズオン開始
# ドキュメントを見ながら進める
```

詳細: [docs/participant/hands-on-procedure.md](docs/participant/hands-on-procedure.md)

## 📁 主要ファイル

```
vector-search-handson/
├── setup/
│   ├── instructor/          # 講師用（Docker Compose、起動スクリプト）
│   └── participant/         # 受講者用（接続テスト、vector-search-builder.zip）
├── docs/
│   └── participant/         # MkDocsドキュメント
│       ├── docs/            # コンテンツ（index.md, part1-3.md等）
│       ├── mkdocs.yml       # 設定
│       ├── start-docs.sh    # ローカル起動
│       └── Dockerfile       # Code Engine用
└── .bob/                    # IBM Bob IDEカスタムモード
```

## 🔧 ローカル開発

### MkDocsドキュメント

```bash
cd docs/participant
./start-docs.sh
# http://localhost:8000
```

### Milvus環境

```bash
cd setup/instructor
./start-all.sh
# Milvus: localhost:19530
```

## 📖 ドキュメント

- **受講者用実践手順書**: [docs/participant/hands-on-procedure.md](docs/participant/hands-on-procedure.md)
- **講師用セットアップ**: [setup/instructor/README.md](setup/instructor/README.md)
- **Code Engineデプロイ**: [setup/instructor/deploy-docs-to-cloud.md](setup/instructor/deploy-docs-to-cloud.md)

## 📝 ライセンス

IBM社内教育目的
