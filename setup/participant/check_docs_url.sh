#!/bin/bash

# ベクトル検索ハンズオン - ドキュメントURL確認スクリプト
# このスクリプトは、Code EngineにデプロイされたドキュメントのURLを確認します

echo "=========================================="
echo "ベクトル検索ハンズオン - ドキュメントURL確認"
echo "=========================================="
echo ""

# IBM Cloud CLIがインストールされているか確認
if ! command -v ibmcloud &> /dev/null; then
    echo "❌ IBM Cloud CLIがインストールされていません"
    echo ""
    echo "インストール方法:"
    echo "https://cloud.ibm.com/docs/cli?topic=cli-getting-started"
    echo ""
    exit 1
fi

# Code Engineプラグインがインストールされているか確認
if ! ibmcloud plugin list | grep -q "code-engine"; then
    echo "❌ Code Engineプラグインがインストールされていません"
    echo ""
    echo "インストールコマンド:"
    echo "ibmcloud plugin install code-engine"
    echo ""
    exit 1
fi

# ログイン状態を確認
if ! ibmcloud target &> /dev/null; then
    echo "❌ IBM Cloudにログインしていません"
    echo ""
    echo "ログインコマンド:"
    echo "ibmcloud login --sso"
    echo ""
    exit 1
fi

echo "✅ IBM Cloud CLIの準備完了"
echo ""

# 現在のリージョンを取得
CURRENT_REGION=$(ibmcloud target --output json 2>/dev/null | grep -o '"region": "[^"]*"' | cut -d'"' -f4)

if [ -z "$CURRENT_REGION" ]; then
    echo "⚠️  リージョンが設定されていません"
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
    echo "❌ Code Engineプロジェクトが見つかりません"
    echo ""
    echo "講師がまだドキュメントをデプロイしていない可能性があります。"
    echo "講師に確認してください。"
    echo ""
    exit 1
fi

# vector-search-docsプロジェクトを探す
PROJECT_NAME=$(echo "$PROJECTS" | grep -o '"name": "vector-search-docs"' | head -1 | cut -d'"' -f4)

if [ -z "$PROJECT_NAME" ]; then
    echo "⚠️  'vector-search-docs'プロジェクトが見つかりません"
    echo ""
    echo "利用可能なプロジェクト:"
    echo "$PROJECTS" | grep -o '"name": "[^"]*"' | cut -d'"' -f4
    echo ""
    echo "講師に正しいプロジェクト名を確認してください。"
    exit 1
fi

# プロジェクトを選択
ibmcloud ce project select -n "$PROJECT_NAME" &> /dev/null

echo "✅ プロジェクト '$PROJECT_NAME' を選択"
echo ""

# アプリケーションのURLを取得
echo "🔍 ドキュメントURLを取得中..."
APP_URL=$(ibmcloud ce app get -n mkdocs-docs --output json 2>/dev/null | grep -o '"url": "[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$APP_URL" ]; then
    echo "❌ ドキュメントアプリケーションが見つかりません"
    echo ""
    echo "講師がまだドキュメントをデプロイしていない可能性があります。"
    echo "講師に確認してください。"
    echo ""
    exit 1
fi

echo "=========================================="
echo "✅ ドキュメントURL確認完了"
echo "=========================================="
echo ""
echo "📖 ドキュメントURL:"
echo "$APP_URL"
echo ""
echo "このURLをブラウザで開いてください。"
echo "=========================================="

# Made with Bob
