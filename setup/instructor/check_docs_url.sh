#!/bin/bash

# ベクトル検索ハンズオン - ドキュメントURL確認スクリプト
# このスクリプトは、Code EngineにデプロイされたドキュメントのURLを確認します

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通関数を読み込み
# shellcheck source=../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

# ヘッダー表示
log_header "ベクトル検索ハンズオン - ドキュメントURL確認"

# IBM Cloud CLIがインストールされているか確認
if ! check_command ibmcloud "インストール方法:\nhttps://cloud.ibm.com/docs/cli?topic=cli-getting-started"; then
    exit 1
fi

# Code Engineプラグインがインストールされているか確認
if ! ibmcloud plugin list | grep -q "code-engine"; then
    log_error "Code Engineプラグインがインストールされていません"
    echo ""
    echo "インストールコマンド:"
    echo "ibmcloud plugin install code-engine"
    echo ""
    exit 1
fi

# ログイン状態を確認
if ! check_ibmcloud_login; then
    exit 1
fi

log_info "IBM Cloud CLIの準備完了"
echo ""

# 現在のリージョンを取得
CURRENT_REGION=$(ibmcloud target 2>/dev/null | grep "Region:" | awk '{print $2}')

if [ -z "$CURRENT_REGION" ] || [ "$CURRENT_REGION" = "Not" ]; then
    log_warn "リージョンが設定されていません"
    echo ""
    echo "リージョン設定コマンド例:"
    echo "ibmcloud target -r us-south"
    echo ""
    exit 1
fi

echo "📍 現在のリージョン: $CURRENT_REGION"
echo ""

# Code Engineプロジェクトを検索
echo "🔍 Code Engineプロジェクトを検索中..."
PROJECTS=$(ibmcloud ce project list --output json 2>/dev/null)

if [ -z "$PROJECTS" ] || [ "$PROJECTS" = "[]" ]; then
    log_error "Code Engineプロジェクトが見つかりません"
    echo ""
    echo "講師がまだドキュメントをデプロイしていない可能性があります。"
    echo "講師に確認してください。"
    echo ""
    exit 1
fi

# vector-search-docsプロジェクトを探す
PROJECT_NAME=$(echo "$PROJECTS" | grep -o '"name": "vector-search-docs"' | head -1 | cut -d'"' -f4)

if [ -z "$PROJECT_NAME" ]; then
    log_warn "'vector-search-docs'プロジェクトが見つかりません"
    echo ""
    echo "利用可能なプロジェクト:"
    echo "$PROJECTS" | grep -o '"name": "[^"]*"' | cut -d'"' -f4
    echo ""
    echo "講師に正しいプロジェクト名を確認してください。"
    exit 1
fi

# プロジェクトを選択
ibmcloud ce project select -n "$PROJECT_NAME" &> /dev/null

log_info "プロジェクト '$PROJECT_NAME' を選択"
echo ""

# アプリケーションのURLを取得
echo "🔍 ドキュメントURLを取得中..."
APP_URL=$(ibmcloud ce app get -n mkdocs-docs --output json 2>/dev/null | grep -o '"url": "[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$APP_URL" ]; then
    log_error "ドキュメントアプリケーションが見つかりません"
    echo ""
    echo "講師がまだドキュメントをデプロイしていない可能性があります。"
    echo "講師に確認してください。"
    echo ""
    exit 1
fi

log_header "✅ ドキュメントURL確認完了"
echo "📖 ドキュメントURL:"
echo "$APP_URL"
echo ""
echo "このURLをブラウザで開いてください。"
echo "=========================================="

