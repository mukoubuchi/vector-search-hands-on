# Vector Search ハンズオン

講師が Milvus 環境を提供し、受講者は IBM Bob IDE のみで参加できるハンズオン環境です。

## 📁 ディレクトリ構造

```
vector-search-handson/
├── docs/
│   └── alternative-setup.md        # 講師向け詳細セットアップガイド
├── setup/
│   ├── docker-compose.yml          # Milvus 環境設定（講師用）
│   ├── .env.example                # 受講者向け接続設定テンプレート
│   └── README.md                   # セットアップファイル説明
└── README.md                       # このファイル
```

## 🚀 クイックスタート

### 講師の方

1. [`docs/alternative-setup.md`](docs/alternative-setup.md) の「講師側の準備」セクションを参照
2. Docker Desktop をインストール
3. `setup/docker-compose.yml` で Milvus を起動
4. watsonx.ai API キーを準備
5. 受講者に接続情報を共有

### 受講者の方

1. 講師から提供された接続情報を受け取る
2. IBM Bob IDE で `.env` ファイルを作成（`setup/.env.example` を参考）
3. ハンズオンを開始

## 📖 詳細ドキュメント

- **講師向け**: [`docs/alternative-setup.md`](docs/alternative-setup.md)
- **セットアップファイル**: [`setup/README.md`](setup/README.md)

## 🔄 TechZone への切り替え

TechZone 環境が利用可能になった場合の切り替え手順は [`docs/alternative-setup.md`](docs/alternative-setup.md) の「TechZone 環境への切り替え」セクションを参照してください。

## 📝 ライセンス

このプロジェクトは IBM 社内での教育目的で使用されます。
