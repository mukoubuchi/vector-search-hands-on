# IBM Cloud Code Engine デプロイ手順

このドキュメントは、MkDocsドキュメントをIBM Cloud Code Engineにデプロイして、リモート参加者がアクセスできるようにする手順を説明します。

## 概要

- **目的**: リモート参加者（異なるWiFi/ネットワーク）がドキュメントにアクセスできるようにする
- **所要時間**: 初回 15-20分、2回目以降 5分
- **コスト**: 無料枠内で利用可能（月間180,000 vCPU秒まで無料）

## 前提条件

### 1. IBM Cloud アカウント
- IBM Cloudアカウントが必要です
- 無料アカウント（Lite）でも利用可能

### 2. 必要なツール
以下のツールがインストールされている必要があります：

```bash
# IBM Cloud CLI
curl -fsSL https://clis.cloud.ibm.com/install/osx | sh

# Docker（既にインストール済みの場合はスキップ）
# https://www.docker.com/products/docker-desktop
```

### 3. IBM Cloud CLIプラグイン
```bash
# Code Engineプラグインのインストール
ibmcloud plugin install code-engine

# Container Registryプラグインのインストール
ibmcloud plugin install container-registry
```

## デプロイ手順

### ステップ1: IBM Cloudにログイン

```bash
# SSOでログイン（IBM社員の場合）
ibmcloud login --sso

# リージョンを選択（東京リージョン推奨）
ibmcloud target -r jp-tok
```

### ステップ2: デプロイスクリプトの実行

```bash
# docs/participantディレクトリに移動
cd docs/participant

# デプロイスクリプトを実行
./deploy-to-code-engine.sh
```

スクリプトは以下を自動的に実行します：
1. ✅ 前提条件のチェック
2. ✅ Code Engineプロジェクトの作成/選択
3. ✅ Container Registryの設定
4. ✅ Dockerイメージのビルド
5. ✅ イメージのプッシュ
6. ✅ アプリケーションのデプロイ
7. ✅ パブリックURLの取得

### ステップ3: URLの確認と共有

デプロイが完了すると、以下のようなURLが表示されます：

```
========================================
✓ デプロイ完了！
========================================

アプリケーションURL:
https://mkdocs-docs.xxxxxxxxxx.jp-tok.codeengine.appdomain.cloud

このURLを受講者に共有してください。
========================================
```

このURLを受講者に共有すれば、どこからでもアクセス可能になります。

## カスタマイズ（オプション）

環境変数で設定をカスタマイズできます：

```bash
# プロジェクト名を変更
export CODE_ENGINE_PROJECT="my-handson-docs"

# リージョンを変更
export IBM_CLOUD_REGION="us-south"

# Container Registryネームスペースを変更
export REGISTRY_NAMESPACE="my-namespace"

# デプロイ実行
./deploy-to-code-engine.sh
```

## 管理コマンド

### アプリケーションの状態確認
```bash
ibmcloud ce app get --name mkdocs-docs
```

### ログの確認
```bash
# リアルタイムログ
ibmcloud ce app logs --name mkdocs-docs --follow

# 最新のログ
ibmcloud ce app logs --name mkdocs-docs --tail 100
```

### アプリケーションの更新
ドキュメントを更新した場合：

```bash
cd docs/participant
./deploy-to-code-engine.sh
```

スクリプトが既存のアプリケーションを自動的に更新します。

### アプリケーションの削除
ハンズオン終了後、リソースを削除する場合：

```bash
# アプリケーションの削除
ibmcloud ce app delete --name mkdocs-docs

# プロジェクト全体の削除（オプション）
ibmcloud ce project delete --name vector-search-docs
```

## トラブルシューティング

### エラー: "IBM Cloud CLIがインストールされていません"
```bash
# macOS
curl -fsSL https://clis.cloud.ibm.com/install/osx | sh

# Linux
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
```

### エラー: "IBM Cloudにログインしていません"
```bash
ibmcloud login --sso
```

ブラウザでワンタイムパスコードを取得し、ターミナルに入力してください。

### エラー: "Dockerがインストールされていません"
Docker Desktopをインストールしてください：
https://www.docker.com/products/docker-desktop

### エラー: "Code Engineプラグインがありません"
```bash
ibmcloud plugin install code-engine
```

### デプロイは成功したがアクセスできない
1. URLが正しいか確認
2. アプリケーションの状態を確認：
   ```bash
   ibmcloud ce app get --name mkdocs-docs
   ```
3. ログを確認：
   ```bash
   ibmcloud ce app logs --name mkdocs-docs
   ```

## コスト管理

### 無料枠
- **vCPU秒**: 180,000 vCPU秒/月（約50時間の稼働）
- **メモリ**: 360,000 GB秒/月
- **リクエスト**: 無制限

### 推奨設定（無料枠内）
```yaml
CPU: 0.25 vCPU
メモリ: 0.5 GB
最小インスタンス: 1
最大インスタンス: 2
```

この設定で、1日8時間のハンズオンを約6日間実施可能です。

### コスト削減のヒント
1. ハンズオン終了後はアプリケーションを削除
2. 最小インスタンスを0に設定（初回アクセスが遅くなります）
3. 必要な期間のみデプロイ

## セキュリティ

### パブリックアクセス
- デフォルトでインターネット上の誰でもアクセス可能
- 機密情報を含むドキュメントには使用しないでください

### アクセス制限（オプション）
Basic認証を追加する場合は、nginx経由でデプロイする必要があります。
詳細は別途ご相談ください。

## サポート

問題が発生した場合：
1. このドキュメントのトラブルシューティングセクションを確認
2. IBM Cloud Code Engineドキュメント: https://cloud.ibm.com/docs/codeengine
3. 講師に連絡

## 参考リンク

- [IBM Cloud Code Engine](https://cloud.ibm.com/codeengine)
- [Code Engine CLI リファレンス](https://cloud.ibm.com/docs/codeengine?topic=codeengine-cli)
- [Container Registry](https://cloud.ibm.com/registry)
- [MkDocs Material](https://squidfunk.github.io/mkdocs-material/)