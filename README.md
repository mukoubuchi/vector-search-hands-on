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
cd ../..
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

## 📁 プロジェクト構造

```
vector-search-handson/
├── README.md                    # このファイル
├── deploy-to-code-engine.sh     # Code Engine デプロイスクリプト
├── mkdocs.yml                   # MkDocs 設定ファイル
├── start-docs.sh                # ローカルドキュメント起動スクリプト
├── vector-search-builder.zip    # 受講者配布ファイル
├── .bob/                        # IBM Bob IDE カスタムモード
├── lib/                         # 共通関数ライブラリ
│   ├── common.sh                # 全スクリプト共通関数
│   └── deploy-helpers.sh        # デプロイ専用ヘルパー関数
├── docs/                        # MkDocs ドキュメント
│   ├── index.md                 # ホームページ
│   ├── preparation.md           # 事前準備
│   ├── part1.md                 # Part 1: Vector Search を体験
│   ├── part2.md                 # Part 2: IBM Bob で機能を追加
│   ├── part3.md                 # Part 3: 動作確認
│   └── summary.md               # まとめ
└── setup/
    ├── instructor/              # 講師用
    │   ├── docker-compose.yml   # Milvus 環境
    │   ├── start-all.sh         # 環境起動スクリプト
    │   ├── stop-all.sh          # 環境停止スクリプト
    │   └── deploy-docs-to-cloud.md  # デプロイ手順
    └── participant/             # 受講者用
        ├── .env.example         # 接続設定テンプレート
        ├── test_connection.py   # Milvus 接続テスト
        └── test_embeddings_hf.py # Embedding テスト
```

## 📖 関連ドキュメント

- **Code Engine デプロイ**: [`setup/instructor/deploy-docs-to-cloud.md`](setup/instructor/deploy-docs-to-cloud.md)
- **TechZone 環境ガイド**: [`setup/instructor/techzone-code-engine-guide.md`](setup/instructor/techzone-code-engine-guide.md)
- **講師向け情報共有**: [`setup/instructor/instructor-share-info.md`](setup/instructor/instructor-share-info.md)

## 🛠️ 技術スタック

- **Vector Database**: Milvus 2.3+
- **Embedding Model**: Hugging Face Transformers (sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2)
- **IDE**: IBM Bob IDE
- **Documentation**: MkDocs Material
- **Container**: Docker / Podman / Colima
- **Cloud**: IBM Cloud Code Engine

## 📦 必要なツール

### 講師向け
- Docker/Podman/Colima
- IBM Cloud CLI (code-engine, container-registry プラグイン)

### 受講者向け
- IBM Bob IDE
- Python 3.9+ (接続テスト用)

