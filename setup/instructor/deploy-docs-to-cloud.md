# ドキュメントのクラウドデプロイ

## 概要

リモート参加者がドキュメントにアクセスできるよう、クラウドにデプロイします。

## 🌐 GitHub Pages（推奨）

### メリット
- 無料で利用可能
- HTTPSで安全
- 設定が簡単
- 固定URLで安定
- 自動デプロイ対応

### 制限事項

> [!IMPORTANT]
> **GitHub Pagesの制限**
>
> - **無料アカウント**: リポジトリを**Public**にする必要があります
> - **GitHub Pro/Team/Enterprise**: Privateリポジトリでも利用可能
>
> ハンズオン資料を公開したくない場合は、ngrokまたはローカル配信を使用してください。

### 前提条件

1. GitHub.com（個人アカウント）にリポジトリを作成（**Public**）
2. ローカルリポジトリのリモートをGitHub.comに変更

```bash
# 現在のリモートを確認
git remote -v

# GitHub.comのリポジトリに変更
git remote set-url origin https://github.com/YOUR_USERNAME/vector-search-hands-on.git

# プッシュ
git push -u origin main
```

### デプロイ手順

#### 方法1: GitHub Actions（自動デプロイ）

1. `.github/workflows/deploy-docs.yml`を作成（既に含まれています）

2. GitHubリポジトリの設定:
   - `Settings` → `Pages`
   - `Source`: `GitHub Actions`を選択

3. コミット＆プッシュで自動デプロイ:
   ```bash
   git add .
   git commit -m "Update docs"
   git push
   ```

4. デプロイ完了後、以下のURLでアクセス可能:
   ```
   https://YOUR_USERNAME.github.io/vector-search-hands-on/
   ```

#### 方法2: 手動デプロイ

```bash
# MkDocsでビルド
mkdocs build

# gh-pagesブランチにデプロイ
mkdocs gh-deploy
```

### 受講者への共有

```
ハンズオン資料: https://YOUR_USERNAME.github.io/vector-search-hands-on/
```

---

## 🔗 ngrok（一時的な公開）

ローカルサーバーを即座に公開したい場合に使用します。

### インストール

```bash
# macOS
brew install ngrok

# 認証（無料アカウント登録後）
ngrok config add-authtoken YOUR_TOKEN
```

### 使用方法

```bash
# MkDocsを起動
cd setup/instructor
./start-all.sh

# 別のターミナルでngrokを起動
ngrok http 8001
```

出力されたURLを受講者に共有:
```
Forwarding: https://xxxx-xx-xx-xx-xx.ngrok-free.app -> http://localhost:8001
```

> [!WARNING]
> 無料版のngrokはセッションごとにURLが変わります。

---

## 🏠 ローカル配信（同一ネットワーク内）

同じネットワーク内の受講者に配信する場合に使用します。

### 使用方法

```bash
# 1. Milvus環境とMkDocsを起動
cd setup/instructor
./start-all.sh

# 2. IPアドレスを確認
ifconfig | grep "inet " | grep -v 127.0.0.1

# 3. 受講者に共有
# - Milvus: <IPアドレス>:19530 (root/Milvus)
# - ドキュメント: http://<IPアドレス>:8001
```

### メリット
- インターネット接続不要
- 低レイテンシ
- セキュアな環境

### 制限事項
- 同一ネットワーク内のみ
- 講師のマシンが起動している必要がある

---

## 🔗 代替案

### オプション A: 静的 HTML 配布

```bash
cd /path/to/vector-search-hands-on
mkdocs build
zip -r mkdocs-site.zip site/
```

受講者に`mkdocs-site.zip`を配布し、解凍後`site/index.html`を開いてもらう。

### オプション B: 各自がローカルで起動

受講者に以下を実行してもらう:

```bash
cd /path/to/vector-search-hands-on
python -m mkdocs serve
```

各自のマシンで<http://localhost:8000>にアクセス。

---

## 📊 配信方法の比較

| 方法 | メリット | デメリット | 推奨シーン |
|------|---------|-----------|-----------|
| **GitHub Pages** | 無料、安定、HTTPS | Publicリポジトリ必須 | リモート参加者あり |
| **ngrok** | 即座に公開、簡単 | URLが変わる（無料版） | 一時的な公開 |
| **ローカル配信** | セキュア、低レイテンシ | 同一ネットワーク必須 | オンサイトのみ |
| **静的HTML配布** | オフライン可 | 配布の手間 | インターネット不可 |
| **各自起動** | 完全独立 | 環境構築必要 | 上級者向け |

---

## 🎯 推奨フロー

### リモート参加者あり
1. GitHub Pagesでドキュメントを公開
2. 講師のMilvus環境をngrokで公開（または各自構築）

### オンサイトのみ
1. ローカル配信でドキュメントとMilvusを共有
2. 同一ネットワーク内でアクセス

### ハイブリッド
1. GitHub Pagesでドキュメントを公開
2. オンサイト参加者は講師のMilvusに接続
3. リモート参加者は各自Milvusを構築
