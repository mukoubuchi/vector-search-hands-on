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

### 📚 ドキュメントの使い分け

| 対象者 | 使用するドキュメント | 特徴 |
|--------|---------------------|------|
| **受講者（初心者）** | [MkDocsドキュメント](docs/participant/README.md) | 詳しい説明・Web形式 |
| **講師・経験者** | [講師用実践手順書](docs/instructor-walkthrough.md) | 簡潔な手順・進行ガイド |

---

### 講師の方

#### 事前準備
1. Docker Desktop をインストール
2. watsonx.ai API キーを準備
3. **すべてのサービスを一括起動**:
   ```bash
   cd setup
   ./start-all.sh
   ```
   これで以下が起動します:
   - Milvus（ポート 19530）
   - MkDocsドキュメントサーバー（ポート 8001）

4. **受講者に以下を共有**:
   - Milvus接続情報（IPアドレス、ポート）
   - watsonx.ai接続情報（API キー、プロジェクトID）
   - **ドキュメントURL**: `http://<講師のIPアドレス>:8001`

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

#### 事前準備
1. IBM Bob IDE をインストール
2. **講師から共有されたドキュメントURLにアクセス**:
   ```
   http://<講師のIPアドレス>:8001
   ```
3. ドキュメントの「事前準備」ページを参照
4. 講師から提供された接続情報を受け取る
5. IBM Bob IDE で `.env` ファイルを作成（`setup/.env.example` を参考）

#### ハンズオン当日
1. **講師が共有したドキュメントURL** を見ながら進める
2. 分からないことはドキュメントで確認
3. 講師に質問しながら進める

**メリット**:
- ✅ インストール不要（ブラウザだけでOK）
- ✅ ナビゲーション・検索機能が使える
- ✅ 全員が同じバージョンのドキュメントを見られる

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
