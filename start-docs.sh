#!/bin/bash
# MkDocsドキュメントサーバーを起動するスクリプト

echo "=================================="
echo "Vector Search ハンズオン"
echo "ドキュメントサーバーを起動中..."
echo "=================================="
echo ""

# MkDocsがインストールされているか確認
if ! command -v mkdocs &> /dev/null; then
    echo "❌ MkDocsがインストールされていません"
    echo ""
    echo "インストール方法:"
    echo "  pip install mkdocs mkdocs-material"
    echo ""
    exit 1
fi

echo "✓ MkDocsが見つかりました"
echo ""
echo "ドキュメントサーバーを起動しています..."
echo "ブラウザで http://localhost:8000 にアクセスしてください"
echo ""
echo "終了するには Ctrl+C を押してください"
echo ""

# MkDocs 2.0 に関する Material の将来互換性警告を抑止して起動
NO_MKDOCS_2_WARNING=true mkdocs serve

# Made with Bob
