# TechZone 予約環境での Code Engine 使用ガイド

## 概要

IBM TechZone で予約した**watsonx-events**アカウントには、Code Engine と Container Registry が既に含まれています。このガイドでは、既存の TechZone リソースを使用して MkDocs ドキュメントをデプロイする方法を説明します。

## TechZone 予約環境

### 環境名
**WX.data ONLY watsonx Data - Dallas**
- Environment: `ibmcloud-2`
- TechZone 環境 ID: `ibmcloud-2 environment`

### 含まれる製品・サービス

#### watsonx.data
- watsonx.data プラットフォーム

#### watsonX Assistant
- Watson Discovery
- Speech
- NeuralSeek

#### watsonX.ai
- Cloud Object Storage
- watsonx Orchestrate Trial

#### インフラストラクチャ（本ハンズオンで使用）
- **Code Engine** - コンテナアプリケーション実行環境
- **Container Registry** - Docker イメージレジストリ

### 予約方法

1. IBM TechZone (https://techzone.ibm.com/) にアクセス
2. "WX.data ONLY watsonx Data - Dallas" を検索
3. 予約を作成（通常 7-14 日間）
4. 予約完了後、watsonx-events アカウントが作成される

## TechZone 予約の確認

### 1. リソースの確認

IBM Cloud Console (https://cloud.ibm.com/resources) にアクセスし、watsonx-events アカウントを選択します。

**Containers**セクションに以下が表示されます：
- **Code Engine**: `ce-itz-wxd-xxxxxxxxxx` (Tokyo, Active)
- **Container Registry**: `cr-itz-xxxxxxx` (Tokyo)

### 2. プロジェクト名の取得

Code Engine のリソース名をメモします。例：
```
ce-itz-wxd-6a08d26e2b7a7a1e72c97a
```

## デプロイ方法

### オプション 1: 既存プロジェクトを使用（推奨）

既存の TechZone Code Engine プロジェクトを使用します。

```bash
# 1. IBM Cloud にログイン
ibmcloud login --sso

# 2. watsonx-events アカウントを選択（通常は 3）
数値を入力してください> 3

# 3. 既存プロジェクトを指定してデプロイ
cd docs/participant
export CODE_ENGINE_PROJECT="ce-itz-wxd-6a08d26e2b7a7a1e72c97a"
./deploy-to-code-engine.sh
```

### オプション 2: 新規プロジェクトを作成

TechZone 環境内に新しいプロジェクトを作成する場合：

```bash
cd docs/participant
export CODE_ENGINE_PROJECT="mkdocs-handson-2024"
./deploy-to-code-engine.sh
```

## 環境変数の設定

デプロイスクリプトは以下の環境変数をサポートしています：

```bash
# Code Engine プロジェクト名（デフォルト: vector-search-docs）
export CODE_ENGINE_PROJECT="ce-itz-wxd-6a08d26e2b7a7a1e72c97a"

# リージョン（デフォルト: jp-tok）
export IBM_CLOUD_REGION="jp-tok"

# Container Registry ネームスペース（デフォルト: vector-search）
export REGISTRY_NAMESPACE="vector-search"
```

## TechZone 予約の期限管理

### 期限切れ前の対応

TechZone 予約には期限があります（通常 7-14 日）。期限切れ前に以下を実施してください：

#### 1. 新しい予約を作成

1. IBM TechZone (https://techzone.ibm.com/) にアクセス
2. watsonx 環境を再予約
3. 新しいアカウントとリソースが作成される

#### 2. 新しいプロジェクト名を確認

```bash
# 新しい Code Engine プロジェクト名を確認
ibmcloud ce project list
```

#### 3. 再デプロイ

```bash
cd docs/participant
export CODE_ENGINE_PROJECT="<新しいプロジェクト名>"
./deploy-to-code-engine.sh
```

#### 4. 新しい URL を受講者に共有

デプロイ完了後、新しい URL が表示されます：
```
https://mkdocs-docs.xxxxxxxxxx.jp-tok.codeengine.appdomain.cloud
```

### 期限切れ後のクリーンアップ

古い予約が期限切れになった場合、リソースは自動的に削除されます。手動でのクリーンアップは不要です。

## コスト管理

### TechZone 環境の利点

✅ **無料**: TechZone 予約は無料で使用可能
✅ **課金なし**: 予約期間中は課金されません
✅ **自動削除**: 期限切れ後は自動的にリソースが削除される

### 注意事項

⚠️ **予約期間**: 通常 7-14 日間（延長可能な場合あり）
⚠️ **リソース制限**: TechZone 環境には一定のリソース制限があります
⚠️ **共有アカウント**: 他のユーザーと共有される場合があります

## トラブルシューティング

### エラー: "Project not found"

既存プロジェクト名が間違っている可能性があります。

```bash
# プロジェクト一覧を確認
ibmcloud ce project list

# 正しいプロジェクト名を指定
export CODE_ENGINE_PROJECT="<正しいプロジェクト名>"
./deploy-to-code-engine.sh
```

### エラー: "Insufficient permissions"

watsonx-events アカウントを選択しているか確認してください。

```bash
# 現在のアカウントを確認
ibmcloud target

# アカウントを切り替え
ibmcloud target -c <account-id>
```

### エラー: "Registry namespace not found"

Container Registry ネームスペースを作成してください。

```bash
# ネームスペース一覧を確認
ibmcloud cr namespace-list

# 新しいネームスペースを作成
ibmcloud cr namespace-add vector-search
```

## ベストプラクティス

### 1. 予約期限の管理

- 📅 カレンダーに期限をリマインダー設定
- 📧 TechZone からの期限通知メールを確認
- 🔄 期限の 3 日前に新規予約を作成

### 2. ドキュメント URL 管理

- 📝 現在の URL をドキュメントに記録
- 🔗 講師が受講者への案内メールに URL を記載
- 🔄 再デプロイ時は講師が新 URL を受講者に再通知

### 3. バックアップ

- 💾 重要なドキュメントは Git で管理
- 📦 静的 HTML ビルドをバックアップ
- 🗂️ 受講者配布用 ZIP を準備

## 参考リンク

- [IBM TechZone](https://techzone.ibm.com/)
- [IBM Cloud Code Engine](https://cloud.ibm.com/codeengine)
- [Container Registry](https://cloud.ibm.com/registry)
- [watsonx Documentation](https://www.ibm.com/docs/en/watsonx)

## まとめ

TechZone 予約環境を使用することで：
- ✅ 無料で Code Engine を利用可能
- ✅ 課金リスクなし
- ✅ イベント毎に新規環境を使用
- ✅ 期限切れ後は自動クリーンアップ

現在のデプロイスクリプトは環境変数で柔軟に対応できるため、**追加の修正は不要**です。