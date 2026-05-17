# Vector Search ハンズオン

講師が Milvus 環境を提供し、受講者は IBM Bob IDE のみで参加できるハンズオン環境です。

## ✨ 主な特徴

### 🎯 受講者にとって
- ✅ **APIキー不要** - Hugging Face Transformersを使用（完全無料）
- ✅ **環境構築不要** - IBM Bob IDEだけでOK
- ✅ **オフライン対応** - モデルダウンロード後はネット不要
- ✅ **段階的学習** - 実践手順書で迷わず進められる

### 👨‍🏫 講師にとって
- ✅ **一元管理** - Milvus + MkDocsをDocker Composeで提供
- ✅ **コスト削減** - 受講者のAPI利用料金が不要
- ✅ **簡単セットアップ** - `./start-all.sh`で全サービス起動
- ✅ **柔軟な運用** - Watsonx.ai版への切り替えも可能（git checkout）

## 🏗️ システムアーキテクチャ

```mermaid
graph LR
    subgraph instructor[講師環境]
        milvus[Milvus<br/>Port: 19530]
        mkdocs[MkDocs<br/>Port: 8001]
    end
    
    subgraph participant[受講者環境]
        bob[IBM Bob IDE]
        pymilvus[pymilvus]
        transformers[sentence-transformers]
    end
    
    bob --> pymilvus
    bob --> transformers
    pymilvus -->|ネットワーク| milvus
    bob -.->|閲覧| mkdocs
    
    style instructor fill:#e1f5ff
    style participant fill:#fff4e1
```

### データフロー

```mermaid
sequenceDiagram
    participant User as 受講者
    participant Bob as IBM Bob IDE
    participant Trans as sentence-transformers
    participant Pymilvus as pymilvus
    participant Milvus as Milvus (講師環境)
    
    User->>Bob: 1. テキスト入力
    Bob->>Trans: 2. テキスト送信
    Trans->>Trans: 3. ベクトル化 (384次元)
    Trans->>Pymilvus: 4. ベクトル返却
    Pymilvus->>Milvus: 5. 検索リクエスト
    Milvus->>Milvus: 6. ベクトル類似度検索
    Milvus->>Pymilvus: 7. 検索結果返却
    Pymilvus->>Bob: 8. 結果表示
    Bob->>User: 9. 結果確認
```

### 主な特徴

**講師側**:
- Docker Composeで全サービスを一元管理
- `./start-all.sh`で簡単起動
- 受講者にIPアドレスと認証情報を共有するだけ

**受講者側**:
- IBM Bob IDEのみで完結（ローカル環境構築不要）
- Hugging Face Transformersで埋め込み生成（APIキー不要）
- 初回のみモデルダウンロード、以降はオフライン可能

## 🔄 IBM製品との比較

このハンズオンでは **Hugging Face Transformers + Milvus** を使用していますが、本番環境では IBM 製品の利用も検討できます。

### 現在のアプローチ（Hugging Face + Milvus）

**メリット:**
- ✅ **完全無料** - APIキー不要、従量課金なし
- ✅ **学習に最適** - シンプルな構成で理解しやすい
- ✅ **オフライン対応** - モデルダウンロード後はネット不要
- ✅ **柔軟性** - オープンソースで自由にカスタマイズ可能
- ✅ **軽量** - 小規模データセットに最適

**デメリット:**
- ❌ **エンタープライズサポートなし** - 商用サポートが必要な場合は不向き
- ❌ **スケーラビリティ制限** - 大規模データには追加の設計が必要
- ❌ **セキュリティ機能が限定的** - 高度な認証・監査機能は自前実装
- ❌ **統合管理なし** - 各コンポーネントを個別に管理

### IBM watsonx.ai を使用する場合

**メリット:**
- ✅ **エンタープライズグレード** - IBM の商用サポート付き
- ✅ **高度なモデル** - 最新の基盤モデルにアクセス可能
- ✅ **統合環境** - モデル管理、デプロイ、監視が一元化
- ✅ **ガバナンス機能** - コンプライアンス、監査ログ、アクセス制御
- ✅ **スケーラビリティ** - 大規模ワークロードに対応
- ✅ **継続的更新** - モデルの定期的な改善とメンテナンス

**デメリット:**
- ❌ **コスト** - API呼び出しごとに課金（埋め込み生成、推論）
- ❌ **APIキー管理** - 認証情報の配布と管理が必要
- ❌ **ネット接続必須** - オフライン利用不可
- ❌ **学習コスト** - 受講者がAPIキーを取得・設定する手間

**適用シーン:**
- 本番環境での大規模RAGシステム
- エンタープライズレベルのセキュリティ要件
- 継続的なモデル改善が必要なケース
- IBM Cloud エコシステムとの統合

### IBM watsonx.data を使用する場合

**メリット:**
- ✅ **データレイクハウス** - 構造化・非構造化データを統合管理
- ✅ **マルチエンジン対応** - Presto, Spark, Milvus等を統合
- ✅ **ガバナンス** - データカタログ、リネージ、アクセス制御
- ✅ **コスト最適化** - ストレージとコンピュートの分離
- ✅ **エンタープライズ統合** - 既存のIBMシステムとシームレス連携
- ✅ **スケーラビリティ** - ペタバイト規模のデータに対応

**デメリット:**
- ❌ **高コスト** - ライセンス費用、インフラコスト
- ❌ **複雑性** - セットアップと運用に専門知識が必要
- ❌ **オーバースペック** - 小規模プロジェクトには不向き
- ❌ **ベンダーロックイン** - IBM エコシステムへの依存

**適用シーン:**
- 大規模エンタープライズデータ基盤
- 複数のデータソースを統合管理
- 厳格なデータガバナンスが必要
- 既存のIBM製品との連携

### 選択ガイド

| 要件 | 推奨アプローチ |
|------|---------------|
| **学習・PoC** | Hugging Face + Milvus（このハンズオン） |
| **小規模本番（<100万ドキュメント）** | Hugging Face + Milvus |
| **中規模本番（エンタープライズサポート必要）** | watsonx.ai + Milvus |
| **大規模本番（>1000万ドキュメント）** | watsonx.ai + watsonx.data |
| **エンタープライズデータ統合** | watsonx.data |

### 移行パス

このハンズオンで学んだ知識は、IBM製品への移行時にも活用できます：

1. **Hugging Face → watsonx.ai**
   - 埋め込み生成部分のみ変更（APIクライアント切り替え）
   - Milvusへの接続・検索ロジックは同じ
   - 参考: `git checkout f50d965`（watsonx.ai版）

2. **Milvus → watsonx.data**
   - ベクトル検索の概念は同じ
   - 接続情報とクエリ構文を調整
   - データガバナンス機能を追加

---

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
│       ├── hands-on-procedure.md   # 受講者用実践手順書（新規）
│       ├── mkdocs.yml              # MkDocs設定
│       └── docs/                   # MkDocsコンテンツ
│           ├── index.md            # ハンズオン概要
│           ├── preparation.md      # 事前準備
│           ├── part1.md            # Part 1: 基本的なベクトル検索
│           ├── part2.md            # Part 2: 高度な検索機能
│           ├── part3.md            # Part 3: 実践的な応用
│           └── summary.md          # まとめ
├── setup/
│   ├── docker-compose.yml          # Milvus 環境設定（講師用）
│   ├── docker-compose-docs.yml     # MkDocsサーバー設定（講師用）
│   ├── start-all.sh                # 全サービス起動スクリプト
│   ├── stop-all.sh                 # 全サービス停止スクリプト
│   ├── .env.example                # 受講者向け接続設定テンプレート
│   ├── test_connection.py          # 接続テストスクリプト
│   └── README.md                   # セットアップファイル説明
└── README.md                       # このファイル
```

## 🚀 クイックスタート

### 📚 ドキュメントの使い分け

| 対象者 | 使用するドキュメント | 特徴 |
|--------|---------------------|------|
| **受講者（初心者）** | [受講者用実践手順書](docs/participant/hands-on-procedure.md) | 段階的な実践手順・コード例付き |
| **受講者（Web版）** | MkDocsドキュメント（講師がホスト） | 詳しい説明・ナビゲーション・検索機能 |
| **講師・経験者** | [講師用実践手順書](docs/instructor-walkthrough.md) | 簡潔な手順・進行ガイド |

---

### 講師の方

#### 事前準備
1. Docker Desktop をインストール
2. **すべてのサービスを一括起動**:
   ```bash
   cd setup
   ./start-all.sh
   ```
   これで以下が起動します:
   - Milvus（ポート 19530）
   - MkDocsドキュメントサーバー（ポート 8001）

3. **受講者に以下を共有**:
   - Milvus接続情報（IPアドレス、ポート、認証情報）
   - **ドキュメントURL**: `http://<講師のIPアドレス>:8001`
   - **重要**: Watsonx.ai APIキーは不要（Hugging Face Transformersを使用）

#### ハンズオン当日
1. **[講師用実践手順書](docs/instructor-walkthrough.md)** を進行ガイドとして使用
2. 各ステップの所要時間を確認しながら進行
3. チェックリストで受講者の進捗を管理

#### ハンズオン終了後
```bash
cd setup
./stop-all.sh
```

---

### 受講者の方

#### ✅ 必要なもの

**IBM Bob IDE + ネット環境だけでOK！**
- ✅ IBM Bob IDE（コード実行環境）
- ✅ インターネット接続
- ✅ ブラウザ（ドキュメント閲覧用、オプション）

**不要なもの:**
- ❌ ローカルへのPythonインストール
- ❌ パッケージの手動インストール
- ❌ 複雑な環境構築
- ❌ **Watsonx.ai APIキー不要**（Hugging Face Transformersを使用）

#### 📖 2つの学習方法

**方法1: 実践手順書で学ぶ（推奨）**
1. [受講者用実践手順書](docs/participant/hands-on-procedure.md)を開く
2. IBM Bob IDEに指示を出してコードを作成・実行
3. 各ステップの期待される出力を確認

**方法2: Webドキュメントで学ぶ**
1. **講師から共有されたドキュメントURLにアクセス**:
   ```
   http://<講師のIPアドレス>:8001
   ```
2. ナビゲーションと検索機能を活用
3. 詳しい説明を参照しながら進める

#### 事前準備
1. IBM Bob IDEを起動
2. 講師から提供された接続情報を受け取る:
   - Milvus接続情報（IPアドレス、ポート、認証情報）
3. Bob IDEで環境セットアップ（Bobが自動実行）
   - 必要なパッケージ: `pymilvus`, `sentence-transformers`, `python-dotenv`
   - 埋め込みモデル: Hugging Face Transformers（APIキー不要、無料）

#### ハンズオン当日
1. **実践手順書**または**Webドキュメント**を見ながら進める
2. 各Partのコードを実行し、動作を確認
3. 分からないことは講師に質問

**実践手順書のメリット**:
- ✅ 完全なコード例が含まれている
- ✅ 期待される出力が明示されている
- ✅ トラブルシューティングガイド付き
- ✅ オフラインでも参照可能

**Webドキュメントのメリット**:
- ✅ ナビゲーション・検索機能が使える
- ✅ 全員が同じバージョンを見られる
- ✅ 詳しい説明と図解

## 📖 詳細ドキュメント

### 講師向け
- [講師向けガイド](docs/instructor/README.md)
- [環境セットアップガイド](docs/instructor/setup-guide.md)
- [セットアップファイル説明](setup/README.md)

### 受講者向け
- **[受講者用実践手順書](docs/participant/hands-on-procedure.md)** ⭐ 推奨
- [受講者向けガイド](docs/participant/README.md)
- MkDocsドキュメント（講師がホスト）:
  - [ハンズオン概要](docs/participant/docs/index.md)
  - [事前準備](docs/participant/docs/preparation.md)
  - [Part 1: 基本的なベクトル検索](docs/participant/docs/part1.md)
  - [Part 2: 高度な検索機能](docs/participant/docs/part2.md)
  - [Part 3: 実践的な応用](docs/participant/docs/part3.md)
  - [まとめ](docs/participant/docs/summary.md)

## 📝 ライセンス

このプロジェクトは IBM 社内での教育目的で使用されます。
