#!/bin/bash
# Milvus環境を起動するスクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通関数を読み込み
# shellcheck source=../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

# ヘッダー表示
log_header "Vector Search ハンズオン環境を起動中..."

# Container runtimeを検出
if ! detect_container_runtime; then
    exit 1
fi

echo ""

# Milvus環境を起動
echo "Milvus環境を起動中..."
$COMPOSE_CMD --profile milvus up -d

if [ $? -eq 0 ]; then
    log_info "Milvus環境が起動しました"
    echo "  - etcd, minio, milvus"
else
    log_error "サービスの起動に失敗しました"
    exit 1
fi

echo ""
log_header "✓ Milvus環境が起動しました"
echo "📊 アクセス情報:"
echo ""
echo "  Milvus:"
echo "    - ホスト: localhost"
echo "    - ポート: 19530"
echo "    - 認証: root/Milvus"
echo ""
echo "📝 次のステップ:"
echo ""
echo "  1. 受講者に共有するMilvusホスト:"
echo "     $(get_ip_address)"
echo ""
echo "  2. ドキュメントをCode Engineにデプロイ:"
echo "     cd ../.."
echo "     ./deploy-to-code-engine.sh"
echo ""
echo "  詳細: setup/instructor/deploy-docs-to-cloud.md"
echo ""
echo "=========================================="
echo ""
echo "停止するには以下を実行してください:"
echo "  ./stop-all.sh"
echo ""

