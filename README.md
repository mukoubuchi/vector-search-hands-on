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
