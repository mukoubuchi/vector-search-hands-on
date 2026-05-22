#!/bin/bash

# Code Engineデプロイ状況確認スクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通関数を読み込み
# shellcheck source=../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

APP_NAME="${1:-mkdocs-docs}"

# ヘッダー表示
log_header "Code Engine デプロイ状況確認"

# IBM Cloudログイン確認
if ! check_ibmcloud_login; then
    exit 1
fi

log_info "IBM Cloudにログイン済み"
echo ""

# 現在のターゲット情報
log_blue "=== 現在のターゲット ==="
ibmcloud target
echo ""

# アプリケーション一覧
log_blue "=== アプリケーション一覧 ==="
ibmcloud ce app list
echo ""

# 特定アプリケーションの詳細
log_blue "=== アプリケーション詳細: $APP_NAME ==="
if ibmcloud ce app get --name "$APP_NAME" &> /dev/null; then
    ibmcloud ce app get --name "$APP_NAME"
    echo ""
    
    # ステータスを取得
    APP_JSON=$(ibmcloud ce app get --name "$APP_NAME" --output json 2>&1)
    
    # デバッグ: JSON全体を一時ファイルに保存
    TEMP_JSON="/tmp/ce-app-status-$$.json"
    echo "$APP_JSON" > "$TEMP_JSON"
    
    log_section "=== デバッグ: JSON出力を確認 ==="
    echo "JSON出力を $TEMP_JSON に保存しました"
    echo ""
    echo "conditions部分:"
    grep -A 20 '"conditions"' "$TEMP_JSON" | head -30
    echo ""
    
    # JSONからReadyコンディションのstatusを抽出
    READY_STATUS=$(extract_ce_ready_status "$APP_JSON")
    
    # 一時ファイルを削除
    rm -f "$TEMP_JSON"
    
    echo ""
    
    # Readyステータスに基づいてアプリケーションステータスを判定
    if [ "$READY_STATUS" = "True" ]; then
        log_info "ステータス: Ready（正常稼働中）"
    elif [ "$READY_STATUS" = "False" ]; then
        log_warn "ステータス: Deploying（デプロイ中）"
    elif [ -z "$READY_STATUS" ]; then
        log_warn "ステータス: 確認中..."
    else
        log_warn "ステータス: Unknown (Ready condition: $READY_STATUS)"
    fi
    echo ""
else
    log_error "アプリケーション '$APP_NAME' が見つかりません"
    echo ""
fi

# リビジョン一覧
log_blue "=== リビジョン一覧 ==="
if ibmcloud ce revision list --application "$APP_NAME" &> /dev/null; then
    ibmcloud ce revision list --application "$APP_NAME"
    echo ""
else
    log_warn "リビジョン情報を取得できませんでした"
    echo ""
fi

# 最新のログ
log_blue "=== 最新のログ（最新50行） ==="
if ibmcloud ce app logs --name "$APP_NAME" --tail 50 &> /dev/null; then
    ibmcloud ce app logs --name "$APP_NAME" --tail 50
    echo ""
else
    log_warn "ログを取得できませんでした"
    echo ""
fi

# トラブルシューティングのヒント
log_blue "=== トラブルシューティング ==="
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
