#!/bin/bash
# Milvus環境を停止するスクリプト

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

# Milvus環境を停止
echo "Milvus環境を停止中..."
$COMPOSE_CMD --profile milvus down

if [ $? -eq 0 ]; then
    log_info "Milvus環境が停止しました"
    echo "  - etcd, minio, milvus"
else
    log_error "サービスの停止に失敗しました"
    exit 1
fi

echo ""
log_header "✓ Milvus環境が停止しました"

# Made with Bob
