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
    log_info "すべてのサービスが停止しました"
    echo "  - etcd, minio, milvus"
    echo "  - mkdocs (ドキュメントサーバー)"
else
    log_error "サービスの停止に失敗しました"
    exit 1
fi

echo ""
log_header "✓ すべてのサービスが停止しました"

