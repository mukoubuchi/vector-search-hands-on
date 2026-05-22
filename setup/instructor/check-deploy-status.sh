#!/bin/bash

# Code Engineデプロイ状況確認スクリプト

set -e

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

APP_NAME="${1:-mkdocs-docs}"

echo "=========================================="
echo "Code Engine デプロイ状況確認"
echo "=========================================="
echo ""

# IBM Cloudログイン確認
if ! ibmcloud target &> /dev/null; then
    echo -e "${RED}❌ IBM Cloudにログインしていません${NC}"
    echo "以下のコマンドでログインしてください:"
    echo "  ibmcloud login --sso"
    exit 1
fi

echo -e "${GREEN}✓ IBM Cloudにログイン済み${NC}"
echo ""

# 現在のターゲット情報
echo -e "${BLUE}=== 現在のターゲット ===${NC}"
ibmcloud target
echo ""

# アプリケーション一覧
echo -e "${BLUE}=== アプリケーション一覧 ===${NC}"
ibmcloud ce app list
echo ""

# 特定アプリケーションの詳細
echo -e "${BLUE}=== アプリケーション詳細: $APP_NAME ===${NC}"
if ibmcloud ce app get --name "$APP_NAME" &> /dev/null; then
    ibmcloud ce app get --name "$APP_NAME"
    echo ""
    
    # ステータスを取得（Readyコンディションのステータスを確認）
    APP_JSON=$(ibmcloud ce app get --name "$APP_NAME" --output json 2>&1)
    
    # デバッグ: JSON全体を一時ファイルに保存
    TEMP_JSON="/tmp/ce-app-status-$$.json"
    echo "$APP_JSON" > "$TEMP_JSON"
    
    echo -e "${YELLOW}=== デバッグ: JSON出力を確認 ===${NC}"
    echo "JSON出力を $TEMP_JSON に保存しました"
    echo ""
    echo "conditions部分:"
    grep -A 20 '"conditions"' "$TEMP_JSON" | head -30
    echo ""
    
    # JSONからReadyコンディションのstatusを抽出
    READY_STATUS=""
    
    # 方法1: jqが利用可能な場合
    if command -v jq &> /dev/null; then
        READY_STATUS=$(jq -r '.status.conditions[]? | select(.type=="Ready")? | .status' "$TEMP_JSON" 2>/dev/null || echo "")
        echo -e "${YELLOW}方法1 (jq): READY_STATUS='$READY_STATUS'${NC}"
    fi
    
    # 方法2: pythonが利用可能な場合
    if [ -z "$READY_STATUS" ] && command -v python3 &> /dev/null; then
        READY_STATUS=$(python3 -c "
import sys, json
try:
    with open('$TEMP_JSON', 'r') as f:
        data = json.load(f)
    for cond in data.get('status', {}).get('conditions', []):
        if cond.get('type') == 'Ready':
            print(cond.get('status', ''))
            break
except Exception as e:
    print('', file=sys.stderr)
" 2>/dev/null || echo "")
        echo -e "${YELLOW}方法2 (python): READY_STATUS='$READY_STATUS'${NC}"
    fi
    
    # 方法3: 改善されたgrep+awk（複数行対応）
    if [ -z "$READY_STATUS" ]; then
        # "type": "Ready" を含む行から次の "status" までを抽出
        READY_STATUS=$(awk '
            /"type"[[:space:]]*:[[:space:]]*"Ready"/ { found=1; next }
            found && /"status"[[:space:]]*:[[:space:]]*"/ {
                match($0, /"status"[[:space:]]*:[[:space:]]*"([^"]*)"/, arr)
                print arr[1]
                exit
            }
        ' "$TEMP_JSON")
        echo -e "${YELLOW}方法3 (awk): READY_STATUS='$READY_STATUS'${NC}"
    fi
    
    # 一時ファイルを削除
    rm -f "$TEMP_JSON"
    
    echo ""
    
    # Readyステータスに基づいてアプリケーションステータスを判定
    if [ "$READY_STATUS" = "True" ]; then
        echo -e "${GREEN}✓ ステータス: Ready（正常稼働中）${NC}"
    elif [ "$READY_STATUS" = "False" ]; then
        echo -e "${YELLOW}⚠ ステータス: Deploying（デプロイ中）${NC}"
    elif [ -z "$READY_STATUS" ]; then
        echo -e "${YELLOW}⚠ ステータス: 確認中...${NC}"
    else
        echo -e "${YELLOW}⚠ ステータス: Unknown (Ready condition: $READY_STATUS)${NC}"
    fi
    echo ""
else
    echo -e "${RED}❌ アプリケーション '$APP_NAME' が見つかりません${NC}"
    echo ""
fi

# リビジョン一覧
echo -e "${BLUE}=== リビジョン一覧 ===${NC}"
if ibmcloud ce revision list --application "$APP_NAME" &> /dev/null; then
    ibmcloud ce revision list --application "$APP_NAME"
    echo ""
else
    echo -e "${YELLOW}リビジョン情報を取得できませんでした${NC}"
    echo ""
fi

# 最新のログ
echo -e "${BLUE}=== 最新のログ（最新50行） ===${NC}"
if ibmcloud ce app logs --name "$APP_NAME" --tail 50 &> /dev/null; then
    ibmcloud ce app logs --name "$APP_NAME" --tail 50
    echo ""
else
    echo -e "${YELLOW}ログを取得できませんでした${NC}"
    echo ""
fi

# トラブルシューティングのヒント
echo -e "${BLUE}=== トラブルシューティング ===${NC}"
echo ""
echo "デプロイが完了しない場合の確認事項:"
echo ""
echo "1. イメージのプル問題"
echo "   - Container Registryのアクセス権限を確認"
echo "   - シークレット設定を確認: ibmcloud ce secret list"
echo ""
echo "2. リソース不足"
echo "   - CPU/メモリ設定を確認"
echo "   - プロジェクトのクォータを確認"
echo ""
echo "3. アプリケーションの起動失敗"
echo "   - ログでエラーメッセージを確認"
echo "   - Dockerfileの設定を確認"
echo "   - ポート設定（8000）を確認"
echo ""
echo "4. ネットワーク問題"
echo "   - Code Engineのサービス状態を確認"
echo "   - リージョンの状態を確認"
echo ""
echo "詳細なログを確認:"
echo "  ibmcloud ce app logs --name $APP_NAME --follow"
echo ""
echo "アプリケーションを再デプロイ:"
echo "  ./deploy-to-code-engine.sh"
echo ""
echo "アプリケーションを削除して再作成:"
echo "  ibmcloud ce app delete --name $APP_NAME"
echo "  ./deploy-to-code-engine.sh"
echo ""

# Made with Bob
