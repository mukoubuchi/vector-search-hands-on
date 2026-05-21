# Vector Search ハンズオン

IBM Bob IDE × Milvus × Hugging Face Transformers を使ったベクトル検索の実践ハンズオン

## 🎯 概要

- **講師**: Milvus 環境とドキュメントを提供
- **受講者**: IBM Bob IDE のみで参加（API キー不要）
- **特徴**: 環境構築不要、完全無料、オフライン対応

## 🚀 クイックスタート

### 👨‍🏫 講師向け

```bash
# 1. 環境起動（Docker/Podman/Colima 対応）
cd setup/instructor
./start-all.sh

# 2. IP アドレス確認
ifconfig | grep "inet " | grep -v 127.0.0.1

# 3. ドキュメントを Code Engine にデプロイ（リモート参加者向け）
cd ../../docs
./deploy-to-code-engine.sh

# 4. 受講者に共有
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

## 📁 主要ファイル

```
vector-search-handson/
├── vector-search-builder.zip # 受講者配布ファイル
├── setup/
│   ├── instructor/          # 講師用（Docker Compose、起動スクリプト）
│   └── participant/         # 受講者用（接続テスト）
├── docs/                    # MkDocs ドキュメント（モジュール化済み）
│   ├── README.md            # ドキュメント構造の説明
│   ├── index.md, part1-3.md # コンテンツ
│   ├── mkdocs.yml           # 設定
│   ├── start-docs.sh        # ローカル起動
│   ├── Dockerfile           # Code Engine 用
│   ├── stylesheets/         # カスタムCSS（モジュール化）
│   │   ├── extra.css        # メインファイル
│   │   ├── typography.css   # タイポグラフィ
│   │   ├── navigation.css   # ナビゲーション
│   │   ├── code.css         # コードブロック
│   │   └── components.css   # UIコンポーネント
│   └── javascripts/         # カスタムJS（モジュール化）
│       ├── extra.js         # メインファイル
│       ├── search.js        # 検索機能
│       ├── navigation.js    # ナビゲーション
│       ├── tasks.js         # タスクリスト
│       └── syntax-highlight.js # シンタックスハイライト
└── .bob/                    # IBM Bob IDE カスタムモード
```

## 🔧 ローカル開発

### MkDocs ドキュメント

```bash
cd docs
./start-docs.sh
# http://localhost:8000
```

**リファクタリング済み:**

- CSS と JavaScript がモジュール化され、保守性が向上
- 各機能が独立したファイルに分離
- 詳細は [`docs/README.md`](docs/README.md) を参照

### Milvus 環境

```bash
cd setup/instructor
./start-all.sh
# Milvus: localhost:19530
```

## 📖 ドキュメント

- **受講者用実践手順書**: [docs/hands-on-procedure.md](docs/hands-on-procedure.md)
- **Code Engine デプロイ**: [setup/instructor/deploy-docs-to-cloud.md](setup/instructor/deploy-docs-to-cloud.md)
