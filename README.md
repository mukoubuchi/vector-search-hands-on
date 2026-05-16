# Vector Search ハンズオン

講師が Milvus 環境を提供し、受講者は IBM Bob IDE のみで参加できるハンズオン環境です。

## 📁 ディレクトリ構造

```
vector-search-handson/
├── docs/
│   ├── README.md                   # ドキュメント構成の説明
│   ├── instructor/                 # 講師向けドキュメント
│   │   ├── README.md               # 講師向けガイド
│   │   └── setup-guide.md          # 環境セットアップガイド
│   └── participant/                # 受講者向けドキュメント
│       ├── README.md               # 受講者向けガイド
│       ├── index.md                # ハンズオン概要
│       ├── preparation.md          # 事前準備
│       ├── part1.md                # Part 1: 基本的なベクトル検索
│       ├── part2.md                # Part 2: 高度な検索機能
│       ├── part3.md                # Part 3: 実践的な応用
│       └── summary.md              # まとめ
├── setup/
│   ├── docker-compose.yml          # Milvus 環境設定（講師用）
│   ├── .env.example                # 受講者向け接続設定テンプレート
│   ├── test_connection.py          # 接続テストスクリプト
│   └── README.md                   # セットアップファイル説明
└── README.md                       # このファイル
```

## 🚀 クイックスタート

### 講師の方

1. [講師向けガイド](docs/instructor/README.md)を参照
2. [環境セットアップガイド](docs/instructor/setup-guide.md)に従って環境を準備
3. Docker Desktop をインストール
4. `setup/docker-compose.yml` で Milvus を起動
5. watsonx.ai API キーを準備
6. 受講者に接続情報を共有

### 受講者の方

1. [受講者向けガイド](docs/participant/README.md)を参照
2. **ドキュメントを開く（準備不要）:**
   ```bash
   cd docs/participant
   ./open-docs.sh  # macOS/Linux
   # または
   open-docs.bat   # Windows
   ```
3. [事前準備](docs/participant/docs/preparation.md)を完了
4. 講師から提供された接続情報を受け取る
5. IBM Bob IDE で `.env` ファイルを作成（`setup/.env.example` を参考）
6. ハンズオンを開始

## 📖 詳細ドキュメント

### 講師向け
- [講師向けガイド](docs/instructor/README.md)
- [環境セットアップガイド](docs/instructor/setup-guide.md)
- [セットアップファイル説明](setup/README.md)

### 受講者向け
- [受講者向けガイド](docs/participant/README.md)
- [ハンズオン概要](docs/participant/index.md)
- [事前準備](docs/participant/preparation.md)
- [Part 1: 基本的なベクトル検索](docs/participant/part1.md)
- [Part 2: 高度な検索機能](docs/participant/part2.md)
- [Part 3: 実践的な応用](docs/participant/part3.md)
- [まとめ](docs/participant/summary.md)

## 📝 ライセンス

このプロジェクトは IBM 社内での教育目的で使用されます。
