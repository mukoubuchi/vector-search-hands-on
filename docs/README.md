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

## ドキュメントサイトの閲覧

### 最も簡単: オンライン版を閲覧（推奨）⭐

**インストール不要！ブラウザだけでOK！**

講師から共有されたCode Engine URLにアクセスするだけで、すぐにドキュメントを閲覧できます。

**URL例**:
```
https://mkdocs-docs.xxxxxxxxxx.us-south.codeengine.appdomain.cloud
```

> **注意**: URLは環境により異なります。必ず講師から共有された最新のURLを使用してください。

### 代替1: 簡易サーバーで閲覧（Pythonのみ必要）

**Pythonがインストールされていれば、追加のインストールなしで閲覧できます。**

**macOS / Linux:**
```bash
cd docs/participant
./serve-docs.sh
```

**Windows:**
```cmd
cd docs\participant
serve-docs.bat
```

ブラウザで http://localhost:8000 にアクセスしてドキュメントを閲覧できます。

### 代替2: 講師のローカルサーバーで閲覧

講師と同じWiFi/ネットワークに接続している場合：

```
http://<講師のIPアドレス>:8001
```

**注意:** 異なるWiFi/ネットワークからはアクセスできません。その場合はオンライン版を使用してください。

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