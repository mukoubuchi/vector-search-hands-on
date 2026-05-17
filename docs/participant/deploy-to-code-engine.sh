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

# 3. リソースグループの設定
echo -e "\n${YELLOW}3. リソースグループを設定中...${NC}"
RESOURCE_GROUP="${RESOURCE_GROUP:-}"

if [ -z "$RESOURCE_GROUP" ]; then
    # リソースグループが指定されていない場合、利用可能なものを確認
    echo -e "${YELLOW}利用可能なリソースグループを確認中...${NC}"
    RESOURCE_GROUPS=$(ibmcloud resource groups --output json 2>/dev/null | grep -o '"name":"[^"]*' | cut -d'"' -f4)
    
    if [ -n "$RESOURCE_GROUPS" ]; then
        # TechZone環境（itz-*）を優先的に選択
        RESOURCE_GROUP=$(echo "$RESOURCE_GROUPS" | grep "^itz-" | head -n 1)
        
        # itz-*が見つからない場合は最初のリソースグループを使用
        if [ -z "$RESOURCE_GROUP" ]; then
            RESOURCE_GROUP=$(echo "$RESOURCE_GROUPS" | head -n 1)
            echo -e "${YELLOW}リソースグループ '$RESOURCE_GROUP' を使用します${NC}"
        else
            echo -e "${YELLOW}TechZoneリソースグループ '$RESOURCE_GROUP' を使用します${NC}"
        fi
    fi
fi

if [ -n "$RESOURCE_GROUP" ]; then
    ibmcloud target -g "$RESOURCE_GROUP" > /dev/null 2>&1
    echo -e "${GREEN}✓ リソースグループ: $RESOURCE_GROUP${NC}"
else
    echo -e "${YELLOW}⚠ リソースグループが設定されていません（デフォルトを使用）${NC}"
fi

# 4. Code Engineプラグインの確認
echo -e "\n${YELLOW}3. Code Engineプラグインを確認中...${NC}"
if ! ibmcloud plugin show code-engine &> /dev/null; then
    echo -e "${YELLOW}Code Engineプラグインをインストール中...${NC}"
    ibmcloud plugin install code-engine
fi
echo -e "${GREEN}✓ Code Engineプラグイン${NC}"

# 5. プロジェクト設定
echo -e "\n${YELLOW}5. Code Engineプロジェクトを設定中...${NC}"
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

# 6. Container Registryの設定
echo -e "\n${YELLOW}6. Container Registryを設定中...${NC}"

# Container Registryのリージョンを設定
echo -e "${YELLOW}Container Registryのリージョンを設定中...${NC}"
ibmcloud cr region-set jp-tok

# Container Registryにログイン
ibmcloud cr login

# 既存のネームスペースを確認
echo -e "${YELLOW}既存のネームスペースを確認中...${NC}"
# ANSIエスケープシーケンスを削除してから、ヘッダー行をスキップ（最初の3行をスキップ）
EXISTING_NAMESPACES=$(ibmcloud cr namespace-list 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | tail -n +4 | grep -v "^OK$" | grep -v "^$" | awk '{print $1}')

if [ -z "$EXISTING_NAMESPACES" ]; then
    echo -e "${RED}❌ 利用可能なContainer Registryネームスペースがありません${NC}"
    echo "TechZone環境では、既存のネームスペースを使用する必要があります"
    exit 1
fi

# 環境変数で指定されたネームスペースを使用、なければ最初のものを使用
REGISTRY_NAMESPACE="${REGISTRY_NAMESPACE:-}"
if [ -z "$REGISTRY_NAMESPACE" ]; then
    REGISTRY_NAMESPACE=$(echo "$EXISTING_NAMESPACES" | head -n 1)
    echo -e "${YELLOW}ネームスペース '$REGISTRY_NAMESPACE' を使用します${NC}"
else
    # 指定されたネームスペースが存在するか確認
    if ! echo "$EXISTING_NAMESPACES" | grep -q "^${REGISTRY_NAMESPACE}$"; then
        echo -e "${RED}❌ 指定されたネームスペース '$REGISTRY_NAMESPACE' が見つかりません${NC}"
        echo "利用可能なネームスペース:"
        echo "$EXISTING_NAMESPACES"
        exit 1
    fi
    echo -e "${GREEN}✓ ネームスペース '$REGISTRY_NAMESPACE' を使用します${NC}"
fi

IMAGE_NAME="mkdocs-docs"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="jp.icr.io/$REGISTRY_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG"
echo -e "${GREEN}✓ イメージ名: $FULL_IMAGE_NAME${NC}"

# 7. Dockerイメージのビルド
echo -e "\n${YELLOW}7. Dockerイメージをビルド中...${NC}"
echo -e "${YELLOW}マルチプラットフォーム対応（amd64/arm64）でビルドします${NC}"
docker buildx build --platform linux/amd64,linux/arm64 -t "$FULL_IMAGE_NAME" --push .

# 8. イメージのプッシュ確認
echo -e "\n${YELLOW}8. イメージのプッシュを確認中...${NC}"
echo -e "${GREEN}✓ イメージは buildx により自動的にプッシュされました${NC}"

# 9. Container Registryアクセス用のシークレットを作成
echo -e "\n${YELLOW}9. Container Registryアクセス用のシークレットを設定中...${NC}"
REGISTRY_SECRET="icr-secret"

# 既存のシークレットを確認
if ibmcloud ce secret get --name "$REGISTRY_SECRET" &> /dev/null; then
    echo -e "${GREEN}✓ シークレット '$REGISTRY_SECRET' は既に存在します${NC}"
else
    echo -e "${YELLOW}シークレット '$REGISTRY_SECRET' を作成中...${NC}"
    
    # API Keyを作成
    API_KEY_NAME="ce-registry-access-$(date +%s)"
    echo -e "${YELLOW}API Key '$API_KEY_NAME' を作成中...${NC}"
    API_KEY_JSON=$(ibmcloud iam api-key-create "$API_KEY_NAME" --output json)
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ API Keyの作成に失敗しました${NC}"
        exit 1
    fi
    
    # JSONから apikey フィールドを抽出
    API_KEY=$(echo "$API_KEY_JSON" | grep '"apikey"' | sed 's/.*"apikey": "\([^"]*\)".*/\1/')
    
    if [ -z "$API_KEY" ]; then
        echo -e "${RED}❌ API Keyの取得に失敗しました${NC}"
        exit 1
    fi
    
    # シークレットを作成
    ibmcloud ce secret create --name "$REGISTRY_SECRET" \
        --format registry \
        --server jp.icr.io \
        --username iamapikey \
        --password "$API_KEY"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ シークレットを作成しました${NC}"
    else
        echo -e "${RED}❌ シークレットの作成に失敗しました${NC}"
        exit 1
    fi
fi

# 10. Code Engineアプリケーションのデプロイ
echo -e "\n${YELLOW}10. Code Engineアプリケーションをデプロイ中...${NC}"
APP_NAME="mkdocs-docs"

# アプリケーションが存在するか確認
if ibmcloud ce app get --name "$APP_NAME" &> /dev/null; then
    echo -e "${YELLOW}既存のアプリケーションを更新中...${NC}"
    ibmcloud ce app update --name "$APP_NAME" \
        --image "$FULL_IMAGE_NAME" \
        --registry-secret "$REGISTRY_SECRET" \
        --port 8000 \
        --min-scale 1 \
        --max-scale 2 \
        --cpu 0.25 \
        --memory 0.5G
else
    echo -e "${YELLOW}新しいアプリケーションを作成中...${NC}"
    ibmcloud ce app create --name "$APP_NAME" \
        --image "$FULL_IMAGE_NAME" \
        --registry-secret "$REGISTRY_SECRET" \
        --port 8000 \
        --min-scale 1 \
        --max-scale 2 \
        --cpu 0.25 \
        --memory 0.5G
fi

# 11. アプリケーションURLの取得
echo -e "\n${YELLOW}11. アプリケーションURLを取得中...${NC}"
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
