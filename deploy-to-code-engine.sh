#!/bin/bash

# IBM Cloud Code Engine デプロイスクリプト
# MkDocsドキュメントをCode Engineにデプロイします

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通関数を読み込み
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/deploy-helpers.sh
source "$SCRIPT_DIR/lib/deploy-helpers.sh"

# ヘッダー表示
log_header "IBM Cloud Code Engine デプロイ"

# 1. 前提条件チェック
log_section "1. 前提条件をチェック中..."

if ! check_command ibmcloud "インストール方法: https://cloud.ibm.com/docs/cli"; then
    exit 1
fi
log_info "IBM Cloud CLI"

# ビルドツールの確認
if ! detect_build_tool; then
    exit 1
fi

# 2. IBM Cloudにログイン確認
log_section "2. IBM Cloudログイン状態を確認中..."
if ! check_ibmcloud_login; then
    exit 1
fi
log_info "IBM Cloudにログイン済み"

# 3. リソースグループの設定
log_section "3. リソースグループを設定中..."
select_resource_group

# 4. Code Engineプラグインの確認
log_section "4. Code Engineプラグインを確認中..."
if ! ibmcloud plugin show code-engine &> /dev/null; then
    log_warn "Code Engineプラグインをインストール中..."
    ibmcloud plugin install code-engine
fi
log_info "Code Engineプラグイン"

# 5. プロジェクト設定
log_section "5. Code Engineプロジェクトを設定中..."
PROJECT_NAME="${CODE_ENGINE_PROJECT:-vector-search-docs}"

# プロジェクトが存在するか確認
if ! ibmcloud ce project get --name "$PROJECT_NAME" &> /dev/null; then
    log_warn "プロジェクト '$PROJECT_NAME' を作成中..."
    ibmcloud ce project create --name "$PROJECT_NAME"
else
    log_info "プロジェクト '$PROJECT_NAME' が存在します"
fi

# プロジェクトを選択
ibmcloud ce project select --name "$PROJECT_NAME"

# 6. Container Registryの設定
setup_container_registry

# 既存のネームスペースを確認して選択
REGISTRY_NAMESPACE=$(select_registry_namespace)
if [ $? -ne 0 ]; then
    exit 1
fi

IMAGE_NAME="mkdocs-docs"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="jp.icr.io/$REGISTRY_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG"
log_info "イメージ名: $FULL_IMAGE_NAME"

# 7. Dockerイメージのビルド
if ! build_docker_image "$FULL_IMAGE_NAME" "$BUILD_TOOL"; then
    exit 1
fi

# 8. イメージのプッシュ
if ! push_docker_image "$FULL_IMAGE_NAME" "$BUILD_TOOL"; then
    exit 1
fi

# 9. Container Registryアクセス用のシークレットを作成
REGISTRY_SECRET="icr-secret"
if ! create_registry_secret "$REGISTRY_SECRET"; then
    exit 1
fi

# 10. Code Engineアプリケーションのデプロイ
log_section "10. Code Engineアプリケーションをデプロイ中..."
APP_NAME="mkdocs-docs"

# アプリケーションが存在するか確認
if ibmcloud ce app get --name "$APP_NAME" &> /dev/null; then
    if ! update_ce_app "$APP_NAME" "$FULL_IMAGE_NAME" "$REGISTRY_SECRET"; then
        exit 1
    fi
else
    if ! create_ce_app "$APP_NAME" "$FULL_IMAGE_NAME" "$REGISTRY_SECRET"; then
        exit 1
    fi
fi

# 11. アプリケーションURLの取得
log_section "11. アプリケーションURLを取得中..."
APP_JSON=$(ibmcloud ce app get --name "$APP_NAME" --output json 2>&1)
APP_URL=$(echo "$APP_JSON" | grep '"url":' | grep -v '"cluster_local_url"' | head -1 | sed 's/.*"url": "\([^"]*\)".*/\1/')

# デバッグ: URLが取得できたか確認
if [ -z "$APP_URL" ]; then
    log_warn "URLの取得に失敗しました。JSONから直接確認します..."
    echo "$APP_JSON" | grep -A 2 '"url"'
fi

echo ""
log_header "✓ デプロイ完了！"
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
