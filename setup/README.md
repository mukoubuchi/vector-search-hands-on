# Vector Search ハンズオン - セットアップディレクトリ

このディレクトリは、講師用と受講者用のセットアップファイルに分かれています。

## 📁 ディレクトリ構造

```
setup/
├── instructor/              # 講師専用ファイル
│   ├── README.md           # 講師用セットアップガイド
│   ├── docker-compose.yml  # Milvus環境
│   ├── docker-compose-docs.yml  # MkDocsドキュメントサーバー
│   ├── start-all.sh        # 一括起動スクリプト
│   ├── stop-all.sh         # 一括停止スクリプト
│   └── instructor-share-info.md  # 受講者への共有情報準備ガイド
│
└── participant/            # 受講者配布用ファイル
    ├── README.md           # 受講者用セットアップガイド
    ├── .env.example        # 環境変数テンプレート
    ├── requirements.txt    # Python依存パッケージ
    ├── test_embeddings_hf.py  # 埋め込みモデルテスト
    ├── test_connection_simple.py  # Milvus接続テスト（シンプル版）
    ├── test_connection.py  # 包括的接続テスト
    └── vector-search-builder.zip  # IBM Bob IDEモード定義
```

## 👨‍🏫 講師の方へ

講師用のセットアップ手順は [`instructor/README.md`](instructor/README.md) を参照してください。

**コンテナランタイムの選択**:
- Docker Desktop（有償ライセンスが必要な場合あり）
- **Podman**（推奨 - 無料、Linux/macOS対応）
- **Colima**（推奨 - 無料、macOS専用）

**重要**: `docker-compose.yml`ファイルは、Docker Desktop、Podman、Colimaのいずれでも使用できます。

**クイックスタート**:
```bash
cd setup/instructor
./start-all.sh  # Docker/Podman/Colimaを自動検出
```

## 👨‍🎓 受講者の方へ

受講者用のセットアップ手順は [`participant/README.md`](participant/README.md) を参照してください。

**クイックスタート**:
```bash
cd setup
cp .env.example .env
# .envファイルを編集して講師から配布された情報を入力
pip install -r requirements.txt
python test_connection.py
```

## 🔄 ファイル配布方法

### 方法1: vector-search-builder.zipを配布

受講者に `participant/vector-search-builder.zip` を配布します。このZIPファイルには以下が含まれています：

- `.bob/` - IBM Bob IDEのVector Search Builderモード定義
- `setup/` - 接続テスト用スクリプトと設定ファイル

### 方法2: participantディレクトリ全体を配布

`setup/participant/` ディレクトリ全体をZIP化して配布することもできます：

```bash
cd setup
zip -r participant-setup.zip participant/
```

## 📝 注意事項

- **講師用ファイル（instructor/）は受講者に配布しないでください**
  - Docker Compose設定ファイル
  - 起動/停止スクリプト
  - 講師用準備ガイド

- **受講者への共有情報**
  - Milvus接続情報（IPアドレス、ポート、認証情報）
  - MkDocsドキュメントURL
  - これらの情報は `instructor/instructor-share-info.md` を参照

## 🔗 関連ドキュメント

- [講師用セットアップガイド](instructor/README.md)
- [受講者用セットアップガイド](participant/README.md)
- [講師用共有情報準備ガイド](instructor/instructor-share-info.md)
- [ハンズオン手順（MkDocs）](../docs/participant/)