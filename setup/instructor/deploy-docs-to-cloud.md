# リモート参加者対応：ドキュメントのクラウドデプロイ

## 概要

リモート参加者（異なるWiFi/ネットワーク）がドキュメントにアクセスできるよう、IBM Cloud Code Engineにデプロイします。

## クイックスタート（5分）

### 1. 前提条件の確認

```bash
# IBM Cloud CLIがインストールされているか確認
ibmcloud version

# なければインストール
curl -fsSL https://clis.cloud.ibm.com/install/osx | sh

# プラグインのインストール
ibmcloud plugin install code-engine
ibmcloud plugin install container-registry
```

### 2. IBM Cloudにログイン

```bash
# SSOでログイン
ibmcloud login --sso

# 東京リージョンを選択
ibmcloud target -r jp-tok
```

### 3. リソースグループの設定

```bash
# 利用可能なリソースグループを確認
ibmcloud resource groups

# リソースグループを設定（TechZone環境の場合）
ibmcloud target -g itz-wxd-6a08d26e2b7a7a1e72c97a

# または、自分の環境に合わせて設定
# ibmcloud target -g <your-resource-group-name>
```

**注意**: リソースグループが設定されていないと、デプロイスクリプトがエラーになる場合があります。

### 4. デプロイ実行

```bash
# docs/participantディレクトリに移動
cd docs/participant

# デプロイスクリプトを実行
./deploy-to-code-engine.sh
```

### 5. URLを確認

デプロイ完了後、URLを確認する方法は2つあります：

**方法1: デプロイスクリプトの出力から確認**
```
https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud
```

> **注**: **xxxxx**の部分は環境により異なります。これはあくまで例です。

**方法2: URL確認スクリプトを使用**
```bash
cd setup/instructor
./check_docs_url.sh
```

このスクリプトは、Code Engineプロジェクトから自動的にURLを取得します。

### 6. URLを受講者に共有

確認したURLを受講者に共有してください。

**実際のデプロイ例**:
- プロジェクト: `vector-search-docs`
- リージョン: `us-south`
- URL例: https://mkdocs-docs.**xxxxx**.us-south.codeengine.appdomain.cloud ※**xxxxx**は環境により異なります（あくまで例）
- ステータス: ✅ 稼働中

!!! warning "TechZone環境でのURL変更について"
    TechZone環境の期限切れ後、再予約すると新しいCode Engineプロジェクトが作成され、URLが変わります。
    
    **対応方法**:
    1. 新しい環境でデプロイスクリプトを再実行
    2. 新しいURLを受講者に共有
    3. 必要に応じてドキュメント内のURL例を更新

## 受講者への案内文例

```
【ハンズオン資料のURL】

以下のURLからハンズオン資料にアクセスできます：
https://mkdocs-docs.**xxxxx**.us-south.codeengine.appdomain.cloud

※ **xxxxx**の部分は環境により異なります（あくまで例）
※ インターネット接続があればどこからでもアクセス可能です
※ ブックマーク推奨
※ 異なるWiFi/ネットワークからもアクセス可能
```

## ドキュメント更新時

ドキュメントを更新した場合、再度デプロイスクリプトを実行するだけです：

```bash
cd docs/participant
./deploy-to-code-engine.sh
```

既存のアプリケーションが自動的に更新されます（URLは変わりません）。

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

Apple Silicon（M1/M2/M3）Macでビルドする場合、Dockerfileに以下の設定が必要です：

```dockerfile
FROM --platform=linux/amd64 squidfunk/mkdocs-material:latest
```

これにより、Code Engine（AMD64）で正しく動作するイメージが作成されます。

### TechZone環境での利用

TechZone環境を使用する場合：
- Container Registryの既存ネームスペース（`cr-itz-*`）が自動検出されます
- リソースグループ（`itz-*`）が優先的に選択されます
- 詳細は `techzone-code-engine-guide.md` を参照

## トラブルシューティング

### デプロイが失敗する

1. IBM Cloudにログインしているか確認：
   ```bash
   ibmcloud target
   ```

2. Dockerが起動しているか確認：
   ```bash
   docker ps
   ```

3. ログを確認：
   ```bash
   ibmcloud ce app logs --name mkdocs-docs
   ```

### URLにアクセスできない

1. アプリケーションの状態を確認：
   ```bash
   ibmcloud ce app get --name mkdocs-docs
   ```

2. 数分待ってから再度アクセス（初回起動に時間がかかる場合があります）

## コスト

- **無料枠**: 月間180,000 vCPU秒（約50時間）
- **推奨設定**: CPU 0.25、メモリ 0.5GB
- **想定コスト**: 1日8時間のハンズオンを約6日間実施可能（無料枠内）

## 詳細ドキュメント

詳細な手順やトラブルシューティングは以下を参照：
- `docs/participant/code-engine-deploy.md`

## 代替案

Code Engineが使えない場合：

### オプションA: 静的HTMLをZIP配布
```bash
cd docs/participant
docker run --rm -v $(pwd):/docs squidfunk/mkdocs-material:latest build
zip -r mkdocs-site.zip site/
```
受講者に`mkdocs-site.zip`を配布し、解凍後`site/index.html`を開いてもらう。

### オプションB: 各自がローカルで起動
受講者に以下を実行してもらう：
```bash
cd docs/participant
docker-compose -f ../../setup/instructor/docker-compose-docs.yml up
```
各自のマシンで`http://localhost:8001`にアクセス。

## 参考リンク

- [IBM Cloud Code Engine](https://cloud.ibm.com/codeengine)
- [Code Engine CLI](https://cloud.ibm.com/docs/codeengine?topic=codeengine-cli)