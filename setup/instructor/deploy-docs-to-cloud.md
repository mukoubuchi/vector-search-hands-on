# ドキュメントのクラウドデプロイ

## 概要

リモート参加者がドキュメントにアクセスできるよう、クラウドにデプロイします。

## 🌐 GitHub Pages（推奨）

### メリット
- 無料で利用可能
- HTTPSで安全
- 設定が簡単
- 固定URLで安定

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
./start-docs.sh
```

各自のマシンで<http://localhost:8000>にアクセス。
