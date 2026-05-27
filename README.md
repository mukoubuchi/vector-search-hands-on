# Vector Search ハンズオン

**IBM Building Blocks** と **IBM Bob** で実現する、次世代ベクトル検索の実践ハンズオン

## 🎯 このハンズオンの特徴

### Building Blocks + IBM Bob の価値

このハンズオンでは、**IBM Building Blocks**（事前構築済み技術コンポーネント）と **IBM Bob**（AI開発アシスタント）を組み合わせることで、通常数日〜数週間かかる開発を **約60分** で完了できることを体験します。

| 開発方法 | 所要時間 | 必要なスキル | コード品質 |
|---------|---------|------------|-----------|
| **従来の開発** | 数日〜数週間 | プログラミング、DB設計、API設計 | 開発者のスキルに依存 |
| **IBM Bob のみ** | 数時間〜数日 | 基本的な技術理解 | 高品質だが構築に時間 |
| **Building Blocks + IBM Bob** | 数分〜数時間 | 自然言語で指示できればOK | 本番レベルの高品質 |

### 使用する Building Block

**Vector Search Builder** (Milvus ベース)

- Milvus データベースのセットアップと管理
- 埋め込みモデルの統合（watsonx、HuggingFace、ローカル）
- データ取り込みパイプラインの構築
- ベクトル検索の最適化
- IBM Cloud Object Storage との連携

### IBM Bob との連携

Vector Search Builder モードにより、IBM Bob が以下を提供:

- Vector Search に特化した AI アシスタント
- Building Blocks の機能を理解した上でのコード生成
- ベストプラクティスに基づいた実装支援
- 自然言語での指示だけで機能追加・カスタマイズ

## 🚀 クイックスタート

### 👨‍🏫 講師向け

```bash
# 1. コンテナランタイムを起動
# 前提条件: 初回起動時のみ `colima start --runtime docker` を実行（5〜10 分程度）
# 2 回目以降は以下のコマンドのみで OK
colima start

# 2. Milvus 環境と MkDocs を起動
cd setup/instructor
./start-all.sh

# 3. アクセス確認
# - MkDocs: http://localhost:8001 (ローカル修正作業用)
# - 同一ネットワーク共有: http://<IP アドレス>:8001

# 4. IP アドレス確認
ifconfig | grep "inet " | grep -v 127.0.0.1

# 5. ドキュメントを Code Engine にデプロイ（リモート参加者向け）
cd ../..
./deploy-to-code-engine.sh

# 6. 受講者に共有
# - Milvus: <IP アドレス>:19530 (root/Milvus)
# - ドキュメント (同一ネットワーク): http://<IP アドレス>:8001
# - ドキュメント (リモート): Code Engine URL

# 7. ハンズオン終了後、環境を停止
cd setup/instructor
./stop-all.sh
```

詳細: [setup/instructor/deploy-docs-to-cloud.md](setup/instructor/deploy-docs-to-cloud.md)

### 👨‍🎓 受講者向け

**配布ファイル**:

- `vector-search-builder.zip` - Building Block (Vector Search Builder モード定義) と接続テスト

**セットアップ手順**:

1. `vector-search-builder.zip` を解凍

   - Mac: ダブルクリック
   - Windows: 右クリック → 「すべて展開」

2. IBM Bob IDE でプロジェクトフォルダを開く

   - `File` → `Open Folder`
   - IBM Bob が `.bob/modes/` を検出し、Vector Search Builder モードを自動読み込み

3. 講師から受け取った接続情報を設定

   - `setup/participant/.env.example` をコピーして `setup/participant/.env` を作成
   - `MILVUS_HOST` に講師から共有された IP アドレスを設定

4. IBM Bob をリロード

   - Mac: `Cmd+Shift+P` → 「Reload Window」
   - Windows: `Ctrl+Shift+P` → 「Reload Window」

5. Vector Search Builder モードが認識されたことを確認

   - 画面右下の「Mode」セレクターに「Vector Search Builder」が表示される

6. ハンズオン開始

詳細: [docs/preparation.md](docs/preparation.md)

## 📚 ハンズオンの流れ

| パート | 内容 | 所要時間 | 学習内容 |
|-------|------|---------|---------|
| [事前準備](docs/preparation.md) | Building Block のセットアップ | 10分 | Vector Search Builder のインストール |
| [Part 1](docs/part1.md) | Vector Search を体験 | 15分 | 意味検索の仕組みと価値 |
| [Part 2](docs/part2.md) | IBM Bob で機能を追加 | 20分 | 自然言語での開発体験 |
| [Part 3](docs/part3.md) | 動作確認とレビュー | 15分 | コード品質の確認 |

**合計**: 約 60 分

## 💡 このハンズオンで学べること

### Building Blocks の価値

- **即座に使える**: 複雑な設定や学習なしに、すぐに使い始められる
- **ベストプラクティス**: IBM のエンジニアリングチームが設計した最適な実装パターン
- **統合済み**: watsonx.ai、watsonx.data などの IBM サービスとシームレスに連携
- **カスタマイズ可能**: IBM Bob を使って、ビジネス要件に合わせて柔軟に拡張

### IBM Bob の活用

- **自然言語で指示**: やりたいことを言葉で伝えるだけ
- **コードを自動生成**: 高品質なコードを自動的に生成
- **コードレビュー**: コードの問題点を指摘
- **Building Blocks との連携**: カスタムモードで、技術に特化した支援を提供

### 開発効率の向上

**従来の開発**:
- Milvus のドキュメントを読む（数時間）
- Python SDK を学習（数時間）
- 埋め込みモデルを選定・統合（数時間〜数日）
- コードを一から実装（数日）

**Building Blocks + IBM Bob**:
- Vector Search Builder をインストール（数分）
- IBM Bob に自然言語で指示（数分）
- 完成（数分〜数時間）

## 📖 ドキュメント

### 講師向け

- **Code Engine デプロイ**: [`setup/instructor/deploy-docs-to-cloud.md`](setup/instructor/deploy-docs-to-cloud.md)
- **TechZone 環境ガイド**: [`setup/instructor/techzone-code-engine-guide.md`](setup/instructor/techzone-code-engine-guide.md)
- **講師向け情報共有**: [`setup/instructor/instructor-share-info.md`](setup/instructor/instructor-share-info.md)

### 受講者向け

- **事前準備**: [docs/preparation.md](docs/preparation.md)
- **Part 1 - Vector Search を体験**: [docs/part1.md](docs/part1.md)
- **Part 2 - IBM Bob で機能を追加**: [docs/part2.md](docs/part2.md)
- **Part 3 - 動作確認とレビュー**: [docs/part3.md](docs/part3.md)
- **まとめ**: [docs/summary.md](docs/summary.md)

## 📦 必要なツール

**講師**: Docker/Podman/Colima、IBM Cloud CLI

**受講者**: IBM Bob IDE（Building Blocks 対応）

## 🎓 このハンズオンの独自の工夫

### 1. 講師・受講者分離アーキテクチャ

**Building Blocks 単体**:
- 各自が Milvus 環境を構築（Docker/Podman/Colima）
- 個別に埋め込みモデルをダウンロード（約 200 MB）
- 環境構築に 30 分程度必要

**このハンズオンの工夫**:
- **講師**: Milvus 環境を一元管理（`setup/instructor/docker-compose.yml`）
- **受講者**: IBM Bob のみで参加（`.bob/modes/` + 接続情報のみ）
- **結果**: セットアップ時間を 30 分→ 5 分に短縮

### 2. ハイブリッド配信対応

**Building Blocks 単体**:
- ローカル環境での実行を想定

**このハンズオンの工夫**:
- **オンサイト**: ローカルネットワーク共有（`http://講師IP:8001`）
- **リモート**: Code Engine へのドキュメントデプロイ
- **結果**: オンサイト/リモート/ハイブリッド開催に対応

### 3. API キー不要の設計

**Building Blocks 単体**:
- watsonx.ai の API キーが必要
- 受講者が個別に取得・設定

**このハンズオンの工夫**:
- **Hugging Face Transformers** を使用（API キー不要）
- **ローカル実行**: インターネット接続のみで動作
- **結果**: 受講者の準備負担を削減

### 4. 段階的な学習パス

**Building Blocks 単体**:
- 技術的な実装に焦点

**このハンズオンの工夫**:
- **Part 1**: Vector Search の体験（理解）
- **Part 2**: IBM Bob での機能追加（実践）
- **Part 3**: コードレビューと改善（応用）
- **結果**: 初心者でも理解→実践→応用と進められる

## 🌟 Building Blocks の他の機能

Vector Search Builder 以外にも、専用の Bob Mode を持つ Building Blocks が多数あります:

- **Agent Builder**: 自律型 AI エージェント、音声対応エージェントの構築
- **Multi-Agent Orchestration**: 複数エージェントの協調制御
- **Agent Ops**: AI エージェントの運用管理とパフォーマンス監視
- **Model Evaluation**: Gen AI/予測 ML モデルの評価
- **Text2SQL**: 自然言語から SQL クエリを生成
- **Data Pipeline AI-Generated**: データパイプラインの自動生成
- **Zero-Copy Lakehouse**: データコピー不要のレイクハウス構築
- **IaaS**: Terraform/CloudFormation テンプレート生成
- **Automated Resilience and Compliance**: 自動レジリエンスとコンプライアンス
- **Automated Resource Management**: リソース自動管理とコスト最適化
- **Secrets Management**: シークレットと非人間アイデンティティの管理

詳細: [Building Blocks ドキュメント](https://ibm-self-serve-assets.github.io/building-blocks-docs/)

## 📝 技術スタック

- **Building Block**: Vector Search Builder (Milvus ベース)
- **AI 開発アシスタント**: IBM Bob
- **ベクトルデータベース**: Milvus 2.3.3
- **埋め込みモデル**: Hugging Face Transformers (`paraphrase-multilingual-MiniLM-L12-v2`)
- **プログラミング言語**: Python 3.11
- **ドキュメント**: MkDocs Material

## 📁 ディレクトリ構造

```
vector-search-handson/
├── .bob/                           # Building Block (Vector Search Builder モード)
│   └── modes/
│       └── vector-search-builder/ # IBM Bob カスタムモード定義
├── docs/                          # ハンズオン用ドキュメント（MkDocs）
│   ├── index.md                   # ホーム
│   ├── preparation.md             # 事前準備
│   ├── part1.md                   # Part 1: Vector Search を体験
│   ├── part2.md                   # Part 2: IBM Bob で機能を追加
│   ├── part3.md                   # Part 3: 動作確認とレビュー
│   ├── summary.md                 # まとめ
│   ├── javascripts/               # カスタム JavaScript
│   ├── stylesheets/               # カスタム CSS
│   └── overrides/                 # テーマカスタマイズ
├── setup/
│   ├── instructor/                # 講師用セットアップ
│   │   ├── docker-compose.yml     # Milvus 環境定義
│   │   ├── start-all.sh           # 全サービス起動スクリプト
│   │   ├── stop-all.sh            # 全サービス停止スクリプト
│   │   ├── deploy-docs-to-cloud.md # Code Engine デプロイ手順
│   │   ├── techzone-code-engine-guide.md # TechZone 環境ガイド
│   │   └── instructor-share-info.md # 講師向け情報共有
│   └── participant/               # 受講者用セットアップ
│       ├── .env.example           # 接続情報テンプレート
│       ├── requirements.txt       # Python 依存関係
│       ├── test_connection.py     # 接続テスト
│       └── test_embeddings_hf.py  # 埋め込みモデルテスト
├── lib/                           # 共通ライブラリ
│   ├── common.sh                  # 共通シェル関数
│   └── deploy-helpers.sh          # デプロイヘルパー関数
├── mkdocs.yml                     # MkDocs 設定ファイル
├── deploy-to-code-engine.sh       # Code Engine デプロイスクリプト
└── README.md                      # このファイル
```

### 主要ディレクトリの説明

#### `.bob/modes/` - Building Block

**Vector Search Builder モード定義**（IBM 提供）

- IBM Bob が Vector Search に特化した支援を提供
- Milvus データベースの操作方法を理解
- ベクトル検索のベストプラクティスを適用
- 埋め込みモデルの統合方法を把握

#### `docs/` - ハンズオン用ドキュメント

**MkDocs Material で構築された学習コンテンツ**

- 段階的な学習パス（理解→実践→応用）
- インタラクティブなコード例
- 視覚的な図解とアニメーション

#### `setup/instructor/` - 講師用環境

**Milvus 環境の一元管理**

- Docker Compose による環境構築
- ワンコマンドでの起動・停止
- ネットワーク共有とリモート配信対応

#### `setup/participant/` - 受講者用ツール

**接続テストと環境確認**

- Milvus 接続テスト
- 埋め込みモデルの動作確認
- 環境変数の設定テンプレート

## 🤝 サポート

質問や問題が発生した場合は、講師にお声がけください。
