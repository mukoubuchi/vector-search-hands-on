# リモート参加者対応：ドキュメントのクラウドデプロイ

## 概要

リモート参加者（異なる WiFi/ネットワーク）がドキュメントにアクセスできるよう、IBM Cloud Code Engine にデプロイします。

## クイックスタート（5 分）

### 1. 前提条件の確認

```bash
# IBM Cloud CLI がインストールされているか確認
ibmcloud version

# なければインストール
curl -fsSL https://clis.cloud.ibm.com/install/osx | sh

# プラグインのインストール
ibmcloud plugin install code-engine
ibmcloud plugin install container-registry
```

### 2. IBM Cloud にログイン

```bash
# SSO でログイン
ibmcloud login --sso

# 東京リージョンを選択
ibmcloud target -r jp-tok
```

### 3. リソースグループの設定

```bash
# 利用可能なリソースグループを確認
ibmcloud resource groups

# リソースグループを設定（TechZone 環境の場合）
ibmcloud target -g itz-wxd-6a08d26e2b7a7a1e72c97a

# または、自分の環境に合わせて設定
# ibmcloud target -g <your-resource-group-name>
```

**注意**: リソースグループが設定されていないと、デプロイスクリプトがエラーになる場合があります。

### 4. デプロイ実行

```bash
# docs/participant ディレクトリに移動
cd docs/participant

# デプロイスクリプトを実行
./deploy-to-code-engine.sh
```

### 5. URL を確認

デプロイ完了後、URL を確認する方法は 2 つあります：

**方法 1: デプロイスクリプトの出力から確認**

```
https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud
```

> **注意**: **xxxxx**の部分は環境により異なります（あくまで例）。必ず講師から共有された最新の URL を使用してください。

**方法 2: URL 確認スクリプトを使用**

```bash
cd setup/instructor
./check_docs_url.sh
```

このスクリプトは、Code Engine プロジェクトから自動的に URL を取得します。

### 6. URL を受講者に共有

確認した URL を受講者に共有してください。

**実際のデプロイ例**:

- プロジェクト: `vector-search-docs`
- リージョン: `us-south`
- URL 例: `https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud`
  > **注意**: **xxxxx**の部分は環境により異なります（あくまで例）。
- ステータス: ✅ 稼働中

!!! warning "TechZone 環境での URL 変更について"
    TechZone 環境の期限切れ後、再予約すると新しい Code Engine プロジェクトが作成され、URL が変わります。

    **対応方法**:

    1. 新しい環境でデプロイスクリプトを再実行
    2. 新しい URL を受講者に共有
    3. 必要に応じてドキュメント内の URL 例を更新

## 受講者への案内文例

```text
【ハンズオン資料の URL】

以下の URL からハンズオン資料にアクセスできます：
<https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud>
```

> **注意**: **xxxxx**の部分は環境により異なります（あくまで例）。必ず講師から共有された最新の URL を使用してください。

※ インターネット接続があればどこからでもアクセス可能です
※ ブックマーク推奨
※ 異なる WiFi/ネットワークからもアクセス可能

## ドキュメント更新時

ドキュメントを更新した場合、再度デプロイスクリプトを実行するだけです：

```bash
cd docs/participant
./deploy-to-code-engine.sh
```

既存のアプリケーションが自動的に更新されます（URL は変わりません）。

## ハンズオン終了後

リソースを削除してコストを節約：

```bash
# アプリケーションの削除
ibmcloud ce app delete --name mkdocs-docs

# プロジェクト全体の削除（オプション）
ibmcloud ce project delete --name vector-search-docs
```

## 重要な注意事項

### プラットフォーム互換性

Apple Silicon（M1/M2/M3）Mac でビルドする場合、Dockerfile に以下の設定が必要です：

```dockerfile
FROM --platform=linux/amd64 squidfunk/mkdocs-material:latest
```

これにより、Code Engine（AMD64）で正しく動作するイメージが作成されます。

### TechZone 環境での利用

TechZone 環境を使用する場合：

- Container Registry の既存ネームスペース（`cr-itz-*`）が自動検出されます
- リソースグループ（`itz-*`）が優先的に選択されます
- 詳細は `techzone-code-engine-guide.md` を参照

## トラブルシューティング

### Podman 認証エラー（Identity Token 問題）

**症状**:

```
Error: unable to retrieve auth token: invalid username/password: unauthorized
```

または

```
Error: currently logged in, auth file contains an Identity token
```

**原因**:
IBM Cloud Container Registry（ICR）の`ibmcloud cr login`コマンドは「Identity token」という一時的な認証トークンを使用します。このトークンは Docker では動作しますが、Podman では互換性の問題があります。

**解決方法**:

**方法 1: Podman→Docker 経由でプッシュ（推奨）**

```bash
# 1. Podman でビルド（AMD64 用）
podman build --platform linux/amd64 -t jp.icr.io/cr-itz-btxelcjs/mkdocs-docs:latest .

# 2. Podman イメージを Docker にロード
podman save jp.icr.io/cr-itz-btxelcjs/mkdocs-docs:latest | docker load

# 3. Docker でプッシュ
docker push jp.icr.io/cr-itz-btxelcjs/mkdocs-docs:latest
```

**方法 2: Docker のみを使用**

```bash
# Colima を起動（macOS）
colima start

# Docker でビルド＆プッシュ
docker build --platform linux/amd64 -t jp.icr.io/cr-itz-btxelcjs/mkdocs-docs:latest .
docker push jp.icr.io/cr-itz-btxelcjs/mkdocs-docs:latest
```

**注意**:

- `deploy-to-code-engine.sh`スクリプトは、Docker が利用可能な場合は自動的に Docker を優先します
- Podman 単独での認証は、IBM Cloud の Identity token 方式との互換性問題により困難です

### デプロイが失敗する

1. IBM Cloud にログインしているか確認：

   ```bash
   ibmcloud target
   ```

2. Docker が起動しているか確認：

   ```bash
   docker ps
   ```

3. ログを確認：

   ```bash
   ibmcloud ce app logs --name mkdocs-docs
   ```

### URL にアクセスできない

1. アプリケーションの状態を確認：

   ```bash
   ibmcloud ce app get --name mkdocs-docs
   ```

2. 数分待ってから再度アクセス（初回起動に時間がかかる場合があります）

## コスト

- **無料枠**: 月間 180,000 vCPU 秒（約 50 時間）
- **推奨設定**: CPU 0.25、メモリ 0.5GB
- **想定コスト**: 1 日 8 時間のハンズオンを約 6 日間実施可能（無料枠内）

## 詳細ドキュメント

詳細な手順やトラブルシューティングは以下を参照：

- `docs/participant/code-engine-deploy.md`

## 代替案

Code Engine が使えない場合：

### オプション A: 静的 HTML を ZIP 配布

```bash
cd docs/participant
docker run --rm -v $(pwd):/docs squidfunk/mkdocs-material:latest build
zip -r mkdocs-site.zip site/
```

受講者に`mkdocs-site.zip`を配布し、解凍後`site/index.html`を開いてもらう。

### オプション B: 各自がローカルで起動

受講者に以下を実行してもらう：

```bash
cd docs/participant
docker-compose -f ../../setup/instructor/docker-compose-docs.yml up
```

各自のマシンで`http://localhost:8001`にアクセス。

## 参考リンク

- [IBM Cloud Code Engine](https://cloud.ibm.com/codeengine)
- [Code Engine CLI](https://cloud.ibm.com/docs/codeengine?topic=codeengine-cli)
