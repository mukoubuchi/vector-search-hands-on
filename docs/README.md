# ドキュメント構成

このディレクトリには、Vector Search ハンズオンのドキュメントが含まれています。

## ディレクトリ構成

```
docs/
├── instructor/          # 講師向けドキュメント
│   └── setup-guide.md   # 環境セットアップガイド
│
└── participant/         # 受講者向けドキュメント
    ├── README.md        # 受講者向けガイド
    ├── index.md         # ハンズオン概要
    ├── preparation.md   # 事前準備
    ├── part1.md         # Part 1: 基本的なベクトル検索
    ├── part2.md         # Part 2: 高度な検索機能
    ├── part3.md         # Part 3: 実践的な応用
    ├── summary.md       # まとめ
    └── mkdocs.yml       # MkDocs設定ファイル
```

## 対象者別ガイド

### 講師の方へ

ハンズオンの環境準備については、以下をご覧ください：
- [環境セットアップガイド](instructor/setup-guide.md)

### 受講者の方へ

ハンズオンの実施内容については、以下をご覧ください：
- [受講者向けガイド](participant/README.md)
- [ハンズオン概要](participant/docs/index.md)

## ドキュメントサイトの閲覧（準備不要！）

**受講者は何もインストールせずに、ブラウザでドキュメントを閲覧できます。**

講師が事前にHTMLを生成済みなので、以下のスクリプトを実行するだけです：

**macOS / Linux:**
```bash
cd docs/participant
./open-docs.sh
```

**Windows:**
```cmd
cd docs\participant
open-docs.bat
```

**または手動で:**
`docs/participant/site/index.html` をブラウザで開く

**特徴:**
- ✅ インストール不要（準備なしで閲覧可能）
- 📱 レスポンシブデザイン
- 🔍 全文検索機能
- 🌓 ダークモード対応
- 📋 コードブロックのコピー機能
- 🎨 見やすいMaterial Design
- 📡 オフライン閲覧可能

### 開発者向け: MkDocsでの閲覧

ドキュメントを編集する場合のみ、MkDocsをインストールして使用します：

```bash
pip install mkdocs mkdocs-material
cd docs/participant
./start-docs.sh  # または start-docs.bat
```