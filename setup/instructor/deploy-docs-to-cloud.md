# ドキュメントのクラウドデプロイ

## 概要

リモート参加者がドキュメントにアクセスできるよう、IBM Cloud Code Engineにデプロイします。

## 🚀 クイックスタート（5分）

### 1. 前提条件

```bash
# IBM Cloud CLIの確認
ibmcloud version

# なければインストール（macOS）
curl -fsSL https://clis.cloud.ibm.com/install/osx | sh

# プラグインのインストール
ibmcloud plugin install code-engine
ibmcloud plugin install container-registry
```

### 2. IBM Cloudにログイン

```bash
# SSOでログイン
ibmcloud login --sso

# リージョン選択（東京）
ibmcloud target -r jp-tok

# リソースグループ確認
ibmcloud resource groups

# リソースグループ設定（TechZone環境の例）
ibmcloud target -g itz-wxd-6a08d26e2b7a7a1e72c97a
```

### 3. デプロイ実行

```bash
cd /path/to/vector-search-handson
./deploy-to-code-engine.sh
```

### 4. URL確認

#### 方法1: デプロイスクリプトの出力

```
https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud
```

#### 方法2: URL確認スクリプト

```bash
cd setup/instructor
./check_docs_url.sh
```

### 5. URLを受講者に共有

確認したURLを受講者に共有してください。

---

## 📝 受講者への案内文（コピー用）

```text
【ハンズオン資料URL】

以下のURLからハンズオン資料にアクセスできます：
https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud

※ インターネット接続があればどこからでもアクセス可能
※ ブックマーク推奨
```

---

## 🔄 ドキュメント更新方法

### ローカル環境 vs Code Engineの違い

| 環境 | 更新方法 | 自動更新 | 理由 |
|------|---------|---------|------|
| **ローカル**<br>(`docker-compose`) | ファイル編集のみ | ✅ 自動 | ボリュームマウント + 開発サーバー |
| **Code Engine**<br>(クラウド) | デプロイスクリプト再実行 | ❌ 手動 | Dockerイメージに焼き込み |

### ローカル環境の自動更新

`docker-compose.yml`の設定により自動更新されます：

```yaml
volumes:
  - ../../:/docs  # プロジェクトディレクトリをマウント
command: serve --dev-addr=0.0.0.0:8000  # 開発サーバーモード
```

- ファイル変更がコンテナに即座に反映
- MkDocsが変更を自動検知してリアルタイム再ビルド
- ブラウザが自動リロード

### Code Engineの手動更新

`docs/Dockerfile`でファイルがイメージに焼き込まれます：

```dockerfile
COPY mkdocs.yml /docs/
COPY docs/ /docs/docs/
```

- ビルド時点のファイルがDockerイメージ内に固定
- デプロイ後はイメージ内容が変更されない
- 更新には新しいイメージのビルド＆デプロイが必要

### 更新手順

ドキュメントを更新した場合：

```bash
cd /path/to/vector-search-handson
./deploy-to-code-engine.sh
```

既存のアプリケーションが自動更新されます（URLは変わりません）。

> [!TIP]
> **ベストプラクティス**
> - **開発中**: ローカル環境で編集 → 自動更新で確認
> - **公開時**: 内容確定後にCode Engineへデプロイ
> - **修正時**: ローカルで修正確認 → Code Engineへ再デプロイ

---

## 🧹 ハンズオン終了後

リソースを削除してコストを節約：

```bash
# アプリケーション削除
ibmcloud ce app delete --name mkdocs-docs

# プロジェクト全体削除（オプション）
ibmcloud ce project delete --name vector-search-docs
```

---

## ⚠️ 重要な注意事項

### Apple Silicon（M1/M2/M3）Mac

Dockerfileに以下の設定が必要です：

```dockerfile
FROM --platform=linux/amd64 squidfunk/mkdocs-material:latest
```

これにより、Code Engine（AMD64）で正しく動作するイメージが作成されます。

### TechZone環境

- Container Registryの既存ネームスペース（`cr-itz-*`）が自動検出されます
- リソースグループ（`itz-*`）が優先的に選択されます
- 環境を再予約すると新しいプロジェクトが作成され、**URLが変わります**

> [!WARNING]
> **TechZone環境再予約時**
> 1. 新しい環境でデプロイスクリプトを再実行
> 2. 新しいURLを受講者に共有
> 3. 必要に応じてドキュメント内のURL例を更新

---

## 🔧 トラブルシューティング

### Podman認証エラー

#### 症状
```
Error: unable to retrieve auth token: invalid username/password
Error: auth file contains an Identity token
```

#### 原因
IBM Cloud Container RegistryのIdentity tokenがPodmanと互換性がない

#### 解決方法1: Podman→Docker経由でプッシュ（推奨）

```bash
# 1. Podmanでビルド
podman build --platform linux/amd64 -t jp.icr.io/namespace/mkdocs-docs:latest .

# 2. PodmanイメージをDockerにロード
podman save jp.icr.io/namespace/mkdocs-docs:latest | docker load

# 3. Dockerでプッシュ
docker push jp.icr.io/namespace/mkdocs-docs:latest
```

#### 解決方法2: Dockerのみを使用

```bash
# Colimaを起動（macOS）
colima start

# Dockerでビルド＆プッシュ
docker build --platform linux/amd64 -t jp.icr.io/namespace/mkdocs-docs:latest .
docker push jp.icr.io/namespace/mkdocs-docs:latest
```

> [!NOTE]
> `deploy-to-code-engine.sh`は、Dockerが利用可能な場合は自動的にDockerを優先します。

### デプロイが失敗する

#### 1. IBM Cloudログイン確認
```bash
ibmcloud target
```

#### 2. Docker起動確認
```bash
docker ps
```

#### 3. ログ確認
```bash
ibmcloud ce app logs --name mkdocs-docs
```

### URLにアクセスできない

#### 1. アプリケーション状態確認
```bash
ibmcloud ce app get --name mkdocs-docs
```

#### 2. 初回起動の待機
初回起動に数分かかる場合があります。少し待ってから再度アクセスしてください。

---

## 🔗 代替案

Code Engineが使えない場合：

### オプションA: 静的HTML配布

```bash
cd /path/to/vector-search-handson
mkdocs build
zip -r mkdocs-site.zip site/
```

受講者に`mkdocs-site.zip`を配布し、解凍後`site/index.html`を開いてもらう。

### オプションB: 各自がローカルで起動

受講者に以下を実行してもらう：

```bash
cd /path/to/vector-search-handson
./start-docs.sh
```

各自のマシンで<http://localhost:8000>にアクセス。

---

## 📚 参考リンク

- [IBM Cloud Code Engine](https://cloud.ibm.com/codeengine)
- [Code Engine CLI](https://cloud.ibm.com/docs/codeengine?topic=codeengine-cli)
- [TechZone環境詳細ガイド](./techzone-code-engine-guide.md)
