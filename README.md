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
├── DEPENDENCIES.md              # 依存関係の完全ドキュメント
├── REFACTORING.md               # v1.0 リファクタリング履歴
├── REFACTORING_V2.md            # v2.0 包括的リファクタリング履歴
├── deploy-to-code-engine.sh     # Code Engine デプロイスクリプト
├── mkdocs.yml                   # MkDocs 設定ファイル
├── start-docs.sh                # ローカルドキュメント起動スクリプト
├── vector-search-builder.zip    # 受講者配布ファイル
├── .bob/                        # IBM Bob IDE カスタムモード
├── .github/                     # GitHub Actions CI/CD
│   └── workflows/
│       └── test.yml             # 自動テストワークフロー
├── config/                      # プロジェクト設定
│   └── project.conf             # 集中設定ファイル
├── lib/                         # 共通関数ライブラリ
│   ├── common.sh                # 全スクリプト共通関数（バリデーション含む）
│   └── deploy-helpers.sh        # デプロイ専用ヘルパー関数
├── tests/                       # テストスイート
│   ├── run_all_tests.sh         # 統合テストランナー
│   ├── test_common.sh           # Bashスクリプトユニットテスト
│   └── test_python_scripts.py  # Pythonスクリプトテスト
├── docs/                        # MkDocs ドキュメント（モジュール化済み）
│   ├── README.md                # ドキュメント構造の説明
│   ├── index.md                 # ホームページ
│   ├── preparation.md           # 事前準備
│   ├── part1.md                 # Part 1: Vector Search を体験
│   ├── part2.md                 # Part 2: IBM Bob で機能を追加
│   ├── part3.md                 # Part 3: 動作確認
│   ├── summary.md               # まとめ
│   ├── Dockerfile               # Code Engine 用
│   ├── stylesheets/             # カスタムCSS（モジュール化）
│   │   ├── extra.css            # メインファイル
│   │   ├── typography.css       # タイポグラフィ
│   │   ├── navigation.css       # ナビゲーション
│   │   ├── code.css             # コードブロック
│   │   └── components.css       # UIコンポーネント
│   ├── javascripts/             # カスタムJS（モジュール化）
│   │   ├── extra.js             # メインファイル
│   │   ├── search.js            # 検索機能
│   │   ├── navigation.js        # ナビゲーション
│   │   ├── tasks.js             # タスクリスト
│   │   └── syntax-highlight.js  # シンタックスハイライト
│   └── overrides/               # テーマオーバーライド
│       └── main.html            # カスタムHTMLテンプレート
└── setup/
    ├── instructor/              # 講師用
    │   ├── docker-compose.yml   # Milvus 環境
    │   ├── start-all.sh         # 環境起動スクリプト
    │   ├── stop-all.sh          # 環境停止スクリプト
    │   ├── check_docs_url.sh    # Code Engine URL 確認
    │   ├── check-deploy-status.sh # デプロイ状況確認
    │   └── deploy-docs-to-cloud.md  # デプロイ手順
    └── participant/             # 受講者用
        ├── .env.example         # 接続設定テンプレート
        ├── test_connection.py   # Milvus 接続テスト
        └── test_embeddings_hf.py # Embedding テスト
```

## 🔧 ローカル開発

### MkDocs ドキュメント

プロジェクトルートから起動：

```bash
./start-docs.sh
# http://localhost:8000
```

または MkDocs コマンドを直接使用：

```bash
mkdocs serve
# http://localhost:8000
```

### Milvus 環境

```bash
cd setup/instructor
./start-all.sh
# Milvus: localhost:19530 (root/Milvus)
```

停止する場合：

```bash
cd setup/instructor
./stop-all.sh
```

## 📖 関連ドキュメント

### ユーザー向け
- **ドキュメント構造**: [`docs/README.md`](docs/README.md)
- **Code Engine デプロイ**: [`setup/instructor/deploy-docs-to-cloud.md`](setup/instructor/deploy-docs-to-cloud.md)
- **TechZone 環境ガイド**: [`setup/instructor/techzone-code-engine-guide.md`](setup/instructor/techzone-code-engine-guide.md)
- **講師向け情報共有**: [`setup/instructor/instructor-share-info.md`](setup/instructor/instructor-share-info.md)

### 開発者向け
- **依存関係**: [`DEPENDENCIES.md`](DEPENDENCIES.md) - 必要なツールとインストール方法
- **リファクタリング履歴**:
  - [`REFACTORING.md`](REFACTORING.md) - v1.0 Bashスクリプト改善
  - [`REFACTORING_V2.md`](REFACTORING_V2.md) - v2.0 包括的改善
- **プロジェクト設定**: [`config/project.conf`](config/project.conf)
- **テスト**: [`tests/`](tests/) - テストスクリプトとランナー

## 🛠️ 技術スタック

- **Vector Database**: Milvus 2.3+
- **Embedding Model**: Hugging Face Transformers (sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2)
- **IDE**: IBM Bob IDE
- **Documentation**: MkDocs Material
- **Container**: Docker / Podman / Colima
- **Cloud**: IBM Cloud Code Engine

## 🧪 テストとCI/CD

### ローカルテスト実行

```bash
# 全テスト実行
./tests/run_all_tests.sh

# 個別テスト
./tests/test_common.sh              # Bashスクリプトテスト
python tests/test_python_scripts.py # Pythonテスト
```

### CI/CD

- **GitHub Actions**: プッシュ・プルリクエスト時に自動実行
- **テスト項目**: ShellCheck、Bashテスト、Pythonテスト、Markdownリント、MkDocsビルド
- **設定ファイル**: [`.github/workflows/test.yml`](.github/workflows/test.yml)

## 📦 依存関係

詳細は [`DEPENDENCIES.md`](DEPENDENCIES.md) を参照してください。

### 講師向け必須ツール
- Docker/Podman/Colima
- IBM Cloud CLI (code-engine, container-registry プラグイン)
- MkDocs

### 受講者向け必須ツール
- IBM Bob IDE
- Python 3.9+ (接続テスト用)

### 開発者向けツール
- ShellCheck (静的解析)
- Git
- Node.js (ドキュメント開発)

## 🎨 プロジェクトの特徴

### コード品質
- ✅ **包括的なテスト**: Bash/Pythonユニットテスト、統合テスト
- ✅ **静的解析**: ShellCheck、markdownlint統合
- ✅ **CI/CD**: GitHub Actionsによる自動品質チェック
- ✅ **バリデーション**: 全関数にパラメータ検証実装

### 保守性
- ✅ **DRY原則**: 共通関数ライブラリによる重複排除
- ✅ **モジュール化**: 機能別に分離された構造
- ✅ **ドキュメント**: 完全な技術文書とコメント
- ✅ **設定管理**: 一元化された設定ファイル

### 開発効率
- ✅ **自動化**: テスト、デプロイ、品質チェック
- ✅ **エラーハンドリング**: 統一されたエラー処理
- ✅ **ログ**: 一貫したログフォーマット
- ✅ **クロスプラットフォーム**: Docker/Podman/Colima対応

## 📊 プロジェクト統計

### コードベース
- **Bashスクリプト**: 8ファイル（約1,200行）
- **Pythonスクリプト**: 3ファイル（約350行）
- **テストコード**: 3ファイル（約400行）
- **ドキュメント**: 10+ファイル（約2,000行）

### リファクタリング成果（v2.0）
- **新規ファイル**: 7個（1,203+行）
- **コード削減**: 約800行（v1.0）
- **テストカバレッジ**: 主要機能の80%以上
- **CI/CDジョブ**: 5個（並列実行）

## 🤝 コントリビューション

### 開発ワークフロー

1. **ブランチ作成**
   ```bash
   git checkout -b feature/your-feature
   ```

2. **変更実施**
   - コードの変更
   - テストの追加/更新

3. **テスト実行**
   ```bash
   ./tests/run_all_tests.sh
   ```

4. **コミット**
   ```bash
   git add .
   git commit -m "feat: your feature description"
   ```

5. **プッシュ**
   ```bash
   git push origin feature/your-feature
   ```

6. **プルリクエスト作成**
   - GitHub上でPR作成
   - CI/CDが自動実行
   - レビュー後マージ

### コーディング規約

- **Bash**: ShellCheck準拠
- **Python**: PEP 8準拠
- **Markdown**: markdownlint準拠
- **コミットメッセージ**: Conventional Commits形式

## 📝 ライセンス

このプロジェクトはIBM Build Teamによって管理されています。

## 🙏 謝辞

- IBM Bob IDE チーム
- Milvus コミュニティ
- Hugging Face チーム
- MkDocs Material 開発者

---

**バージョン**: 2.0
**最終更新**: 2024年
**メンテナー**: IBM Build Team
