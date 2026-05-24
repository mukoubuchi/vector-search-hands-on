#!/bin/bash
# Milvus環境とMkDocsドキュメントを停止するスクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通関数を読み込み
# shellcheck source=../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

# ヘッダー表示
log_header "Vector Search ハンズオン環境を停止中..."

# Container runtimeを検出
if ! detect_container_runtime; then
    exit 1
fi

echo ""

# Milvus環境とMkDocsを停止
echo "Milvus環境とMkDocsドキュメントを停止中..."
$COMPOSE_CMD --profile all down

if [ $? -eq 0 ]; then
    log_info "Dockerコンテナが停止しました"
    echo "  - etcd, minio, milvus"
    echo "  - mkdocs (コンテナ版、ポート8001)"
else
    log_error "Dockerコンテナの停止に失敗しました"
    exit 1
fi

echo ""

# ポート8000で動作しているmkdocsプロセスを停止
echo "ポート8000のmkdocs開発サーバーを確認中..."
MKDOCS_PID=$(lsof -ti:8000 2>/dev/null || true)

if [ -n "$MKDOCS_PID" ]; then
    echo "ポート8000で動作中のプロセス (PID: $MKDOCS_PID) を停止中..."
    kill "$MKDOCS_PID" 2>/dev/null || true
    sleep 1
    
    # プロセスが残っている場合は強制終了
    if kill -0 "$MKDOCS_PID" 2>/dev/null; then
        echo "強制終了中..."
        kill -9 "$MKDOCS_PID" 2>/dev/null || true
    fi
    
    log_info "mkdocs開発サーバー (ポート8000) を停止しました"
else
    echo "ポート8000で動作中のプロセスはありません"
fi

echo ""
log_header "✓ すべてのサービスが停止しました"

