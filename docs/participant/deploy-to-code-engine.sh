#!/bin/bash

# IBM Cloud Code Engine デプロイスクリプト
# MkDocsドキュメントをCode Engineにデプロイします

set -e

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "IBM Cloud Code Engine デプロイ"
echo "=========================================="

# 1. 前提条件チェック
echo -e "\n${YELLOW}1. 前提条件をチェック中...${NC}"

if ! command -v ibmcloud &> /dev/null; then
    echo -e "${RED}❌ IBM Cloud CLIがインストールされていません${NC}"
    echo "インストール方法: https://cloud.ibm.com/docs/cli"
    exit 1
fi
echo -e "${GREEN}✓ IBM Cloud CLI${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Dockerがインストールされていません${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker${NC}"

# 2. IBM Cloudにログイン確認
echo -e "\n${YELLOW}2. IBM Cloudログイン状態を確認中...${NC}"
if ! ibmcloud target &> /dev/null; then
    echo -e "${RED}❌ IBM Cloudにログインしていません${NC}"
    echo "以下のコマンドでログインしてください:"
    echo "  ibmcloud login --sso"
    exit 1
fi
echo -e "${GREEN}✓ IBM Cloudにログイン済み${NC}"

# 3. Code Engineプラグインの確認
echo -e "\n${YELLOW}3. Code Engineプラグインを確認中...${NC}"
if ! ibmcloud plugin show code-engine &> /dev/null; then
    echo -e "${YELLOW}Code Engineプラグインをインストール中...${NC}"
    ibmcloud plugin install code-engine
fi
echo -e "${GREEN}✓ Code Engineプラグイン${NC}"

# 4. プロジェクト設定
echo -e "\n${YELLOW}4. Code Engineプロジェクトを設定中...${NC}"
PROJECT_NAME="${CODE_ENGINE_PROJECT:-vector-search-docs}"

# プロジェクトが存在するか確認
if ! ibmcloud ce project get --name "$PROJECT_NAME" &> /dev/null; then
    echo -e "${YELLOW}プロジェクト '$PROJECT_NAME' を作成中...${NC}"
    ibmcloud ce project create --name "$PROJECT_NAME"
else
    echo -e "${GREEN}✓ プロジェクト '$PROJECT_NAME' が存在します${NC}"
fi

# プロジェクトを選択
ibmcloud ce project select --name "$PROJECT_NAME"

# 5. Container Registryの設定
echo -e "\n${YELLOW}5. Container Registryを設定中...${NC}"
REGISTRY_NAMESPACE="${REGISTRY_NAMESPACE:-vector-search}"
IMAGE_NAME="mkdocs-docs"
IMAGE_TAG="latest"

# Container Registryにログイン
ibmcloud cr login

# ネームスペースが存在するか確認
if ! ibmcloud cr namespace-list | grep -q "$REGISTRY_NAMESPACE"; then
    echo -e "${YELLOW}ネームスペース '$REGISTRY_NAMESPACE' を作成中...${NC}"
    ibmcloud cr namespace-add "$REGISTRY_NAMESPACE"
fi

FULL_IMAGE_NAME="jp.icr.io/$REGISTRY_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG"
echo -e "${GREEN}✓ イメージ名: $FULL_IMAGE_NAME${NC}"

# 6. Dockerイメージのビルド
echo -e "\n${YELLOW}6. Dockerイメージをビルド中...${NC}"
docker build -t "$FULL_IMAGE_NAME" .

# 7. イメージをプッシュ
echo -e "\n${YELLOW}7. イメージをContainer Registryにプッシュ中...${NC}"
docker push "$FULL_IMAGE_NAME"

# 8. Code Engineアプリケーションのデプロイ
echo -e "\n${YELLOW}8. Code Engineアプリケーションをデプロイ中...${NC}"
APP_NAME="mkdocs-docs"

# アプリケーションが存在するか確認
if ibmcloud ce app get --name "$APP_NAME" &> /dev/null; then
    echo -e "${YELLOW}既存のアプリケーションを更新中...${NC}"
    ibmcloud ce app update --name "$APP_NAME" \
        --image "$FULL_IMAGE_NAME" \
        --port 8000 \
        --min-scale 1 \
        --max-scale 2 \
        --cpu 0.25 \
        --memory 0.5G
else
    echo -e "${YELLOW}新しいアプリケーションを作成中...${NC}"
    ibmcloud ce app create --name "$APP_NAME" \
        --image "$FULL_IMAGE_NAME" \
        --port 8000 \
        --min-scale 1 \
        --max-scale 2 \
        --cpu 0.25 \
        --memory 0.5G
fi

# 9. アプリケーションURLの取得
echo -e "\n${YELLOW}9. アプリケーションURLを取得中...${NC}"
APP_URL=$(ibmcloud ce app get --name "$APP_NAME" --output json | grep -o '"url":"[^"]*' | cut -d'"' -f4)

echo ""
echo "=========================================="
echo -e "${GREEN}✓ デプロイ完了！${NC}"
echo "=========================================="
echo ""
echo -e "${GREEN}アプリケーションURL:${NC}"
echo -e "${YELLOW}$APP_URL${NC}"
echo ""
echo "このURLを受講者に共有してください。"
echo ""
echo "=========================================="
echo ""
echo "管理コマンド:"
echo "  ログ確認: ibmcloud ce app logs --name $APP_NAME"
echo "  状態確認: ibmcloud ce app get --name $APP_NAME"
echo "  削除:     ibmcloud ce app delete --name $APP_NAME"
echo ""

# Made with Bob
