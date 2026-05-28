# ドキュメントのクラウドデプロイ

## 概要

リモート参加者がドキュメントにアクセスできるよう、IBM Cloud Code Engine にデプロイします。

## 🚀 クイックスタート（5 分）

### 1. 前提条件

```bash
# IBM Cloud CLI の確認
ibmcloud version

# なければインストール（macOS）
curl -fsSL https://clis.cloud.ibm.com/install/osx | sh

# プラグインのインストール
ibmcloud plugin install code-engine
ibmcloud plugin install container-registry
```

### 2. IBM Cloud にログイン

```bash
# SSO でログイン
ibmcloud login --sso

# アカウント選択（初回のみ）
# 複数のアカウントがある場合、使用するアカウントを選択してください
# 例: TechZone 環境の場合は該当する番号を入力
```

> [!IMPORTANT]
> **初回実行時の注意**
>
> `ibmcloud login --sso`実行後、複数のアカウントがある場合はアカウント選択を求められます:
> ```
> アカウントを選択:
> 1. Personal Account
> 2. IBM - ISE Cloud
> 3. watsonx-events
> 数値を入力してください>
> ```
> 使用するアカウントの番号を入力してください。
>
> ログイン後、デプロイスクリプトを実行してください。
> リソースグループは自動的に選択されます（TechZone環境の場合は`itz-`で始まるリソースグループが優先されます）。

### 3. デプロイ実行

```bash
cd /path/to/vector-search-handson
./deploy-to-code-engine.sh
```

### 4. URL 確認

#### 方法 1: デプロイスクリプトの出力

```
https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud
```

#### 方法 2: URL 確認スクリプト

```bash
cd setup/instructor
./check_docs_url.sh
```

### 5. URL を受講者に共有

確認した URL を受講者に共有してください。

---

## 📝 受講者への案内文（コピー用）

```text
【ハンズオン資料 URL】

以下の URL からハンズオン資料にアクセスできます:
https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud

※ インターネット接続があればどこからでもアクセス可能
※ ブックマーク推奨
```

---

## 🔄 ドキュメント更新方法

### ローカル環境 vs Code Engine の違い

| 環境 | 更新方法 | 自動更新 | 理由 |
|------|---------|---------|------|
| **ローカル**<br>(`docker-compose`) | ファイル編集のみ | ✅ 自動 | ボリュームマウント + 開発サーバー |
| **Code Engine**<br>(クラウド) | デプロイスクリプト再実行 | ❌ 手動 | Docker イメージに焼き込み |

### ローカル環境の自動更新

`docker-compose.yml`の設定により自動更新されます:

```yaml
volumes:
  - ../../:/docs  # プロジェクトディレクトリをマウント
command: serve --dev-addr=0.0.0.0:8000  # 開発サーバーモード
```

- ファイル変更がコンテナに即座に反映
- MkDocs が変更を自動検知してリアルタイム再ビルド
- ブラウザが自動リロード

### Code Engine の手動更新

`docs/Dockerfile`でファイルがイメージに焼き込まれます:

```dockerfile
COPY mkdocs.yml /docs/
COPY docs/ /docs/docs/
```

- ビルド時点のファイルが Docker イメージ内に固定
- デプロイ後はイメージ内容が変更されない
- 更新には新しいイメージのビルド＆デプロイが必要

### 更新手順

ドキュメントを更新した場合:

```bash
cd /path/to/vector-search-handson
./deploy-to-code-engine.sh
```

既存のアプリケーションが自動更新されます（URL は変わりません）。

> [!TIP]
> **ベストプラクティス**
>
> - **開発中**: ローカル環境で編集 → 自動更新で確認
> - **公開時**: 内容確定後に Code Engine へデプロイ
> - **修正時**: ローカルで修正確認 → Code Engine へ再デプロイ

---

## 🧹 ハンズオン終了後

リソースを削除してコストを節約:

```bash
# アプリケーション削除
ibmcloud ce app delete --name mkdocs-docs

# プロジェクト全体削除（オプション）
ibmcloud ce project delete --name vector-search-docs
```

---

## ⚠️ 重要な注意事項

### Apple Silicon（M1/M2/M3）Mac

Dockerfile に以下の設定が必要です:

```dockerfile
FROM --platform=linux/amd64 squidfunk/mkdocs-material:latest
```

これにより、Code Engine（AMD64）で正しく動作するイメージが作成されます。

### TechZone 環境

TechZone環境では、Container Registryの既存ネームスペース（`cr-itz-*`）が提供されています。

> [!IMPORTANT]
> **TechZone 環境でのデプロイ**
>
> TechZone環境のContainer Registryポリシーにより、提供されたネームスペースへの書き込み権限が制限されている場合があります。
>
> **方法1: 既存ネームスペースを明示的に指定**
>
> 環境変数で既存のネームスペースを指定してデプロイを試みます：
>
> ```bash
> # 既存のネームスペース名を確認
> ibmcloud cr namespace-list
> # 例: cr-itz-9erb9avb
>
> # ネームスペースを指定してデプロイ
> export REGISTRY_NAMESPACE="cr-itz-9erb9avb"
> ./deploy-to-code-engine.sh
> ```
>
> **方法2: 個人のIBM Cloudアカウントを使用**
>
> 方法1が失敗する場合は、個人アカウントを使用します：
>
> ```bash
> ibmcloud logout
> ibmcloud login --sso  # 個人アカウントを選択
> ./deploy-to-code-engine.sh
> ```
>
> **方法3: ローカル配信のみ使用**
>
> Code Engineを使用せず、ローカルで配信します：
>
> ```bash
> cd setup/instructor
> ./start-all.sh
> # http://localhost:8001 または http://<IP>:8001
> ```

> [!WARNING]
> **TechZone 環境再予約時**
>
> 1. 新しい環境でデプロイスクリプトを再実行
> 2. 新しい URL を受講者に共有
> 3. 必要に応じてドキュメント内の URL 例を更新

---

## 🔧 トラブルシューティング

### Podman 認証エラー

#### 症状

```
Error: unable to retrieve auth token: invalid username/password
Error: auth file contains an Identity token
```

#### 原因

IBM Cloud Container Registry の Identity token が Podman と互換性がない

#### 解決方法 1: Podman→Docker 経由でプッシュ（推奨）

```bash
# 1. Podman でビルド
podman build --platform linux/amd64 -t jp.icr.io/namespace/mkdocs-docs:latest .

# 2. Podman イメージを Docker にロード
podman save jp.icr.io/namespace/mkdocs-docs:latest | docker load

# 3. Docker でプッシュ
docker push jp.icr.io/namespace/mkdocs-docs:latest
```

#### 解決方法 2: Docker のみを使用

```bash
# Colima を起動（macOS）
# 前提条件: 初回起動時のみ `colima start --runtime docker` を実行（5〜10 分程度）
# 2 回目以降は以下のコマンドのみで OK
colima start

# Docker でビルド＆プッシュ
docker build --platform linux/amd64 -t jp.icr.io/namespace/mkdocs-docs:latest .
docker push jp.icr.io/namespace/mkdocs-docs:latest
```

> [!NOTE]
> `deploy-to-code-engine.sh`は、Docker が利用可能な場合は自動的に Docker を優先します。

### デプロイが失敗する

#### 1. IBM Cloud ログイン確認

```bash
ibmcloud target
```

#### 2. Docker 起動確認

```bash
docker ps
```

#### 3. ログ確認

```bash
ibmcloud ce app logs --name mkdocs-docs
```

### URL にアクセスできない

#### 1. アプリケーション状態確認

```bash
ibmcloud ce app get --name mkdocs-docs
```

#### 2. 初回起動の待機

初回起動に数分かかる場合があります。少し待ってから再度アクセスしてください。

---

## 🔗 代替案

Code Engine が使えない場合:

### オプション A: 静的 HTML 配布

```bash
cd /path/to/vector-search-handson
mkdocs build
zip -r mkdocs-site.zip site/
```

受講者に`mkdocs-site.zip`を配布し、解凍後`site/index.html`を開いてもらう。

### オプション B: 各自がローカルで起動

受講者に以下を実行してもらう:

```bash
cd /path/to/vector-search-handson
./start-docs.sh
```

各自のマシンで<http://localhost:8000>にアクセス。

---

## 📚 参考リンク

- [IBM Cloud Code Engine](https://cloud.ibm.com/codeengine)
- [Code Engine CLI](https://cloud.ibm.com/docs/codeengine?topic=codeengine-cli)
- [TechZone 環境詳細ガイド](./techzone-code-engine-guide.md)
