#!/bin/bash
# MkDocsドキュメントサーバーを起動するスクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通関数を読み込み
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

# ヘッダー表示
log_header "Vector Search ハンズオン\nドキュメントサーバーを起動中..."

# MkDocsがインストールされているか確認
if ! check_command mkdocs "インストール方法:\n  pip install mkdocs mkdocs-material"; then
    exit 1
fi

log_info "MkDocsが見つかりました"
echo ""
echo "ドキュメントサーバーを起動しています..."
echo "ブラウザで http://localhost:8000 にアクセスしてください"
echo ""
echo "終了するには Ctrl+C を押してください"
echo ""

# MkDocs 2.0 に関する Material の将来互換性警告を抑止して起動
NO_MKDOCS_2_WARNING=true mkdocs serve

# Made with Bob
