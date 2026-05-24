#!/bin/bash
# Milvus環境とMkDocsドキュメントを起動するスクリプト

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

# Milvus環境とMkDocsを起動
echo "Milvus環境とMkDocsドキュメントを起動中..."
$COMPOSE_CMD --profile all up -d

if [ $? -eq 0 ]; then
    log_info "すべてのサービスが起動しました"
    echo "  - etcd, minio, milvus"
    echo "  - mkdocs (ドキュメントサーバー)"
else
    log_error "サービスの起動に失敗しました"
    exit 1
fi

echo ""
log_header "✓ すべてのサービスが起動しました"
echo "📊 アクセス情報:"
echo ""
echo "  Milvus:"
echo "    - ホスト: localhost"
echo "    - ポート: 19530"
echo "    - 認証: root/Milvus"
echo ""
echo "  MkDocs:"
echo "    - コンテナ版 (ポート8001): http://localhost:8001 ✓ 起動済み"
echo "      └ 用途: 受講者への共有、安定配信"
echo "      └ 注意: ファイル変更の自動リロード不可（コンテナ再起動が必要）"
echo ""
echo "    - 開発版 (ポート8000): 未起動"
echo "      └ 起動方法: python -m mkdocs serve (プロジェクトルートで実行)"
echo "      └ 用途: ドキュメント編集作業（自動リロード対応）"
echo ""
echo "📝 次のステップ:"
echo ""
echo "  1. 受講者に共有する情報:"
echo "     - Milvusホスト: $(get_ip_address):19530"
echo "     - ドキュメント: http://$(get_ip_address):8001"
echo ""
echo "  2. ドキュメント編集が必要な場合:"
echo "     - プロジェクトルートに移動: cd ../.."
echo "     - 開発版を起動: python -m mkdocs serve"
echo "       (注: このコマンドはターミナルを占有します)"
echo "     - バックグラウンド実行: python -m mkdocs serve &"
echo "     - アクセス: http://localhost:8000 または http://$(get_ip_address):8000"
echo "     - 自動リロードでリアルタイムプレビュー可能"
echo ""
echo "     停止方法:"
echo "       - フォアグラウンド実行時: Ctrl+C"
echo "       - バックグラウンド実行時: cd setup/instructor && ./stop-all.sh"
echo "       - 手動停止: kill \$(lsof -ti:8000)"
echo ""
echo "  3. リモート参加者向けにCode Engineにデプロイ:"
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

