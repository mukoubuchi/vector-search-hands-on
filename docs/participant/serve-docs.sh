#!/bin/bash
# 生成済みのHTMLドキュメントをローカルサーバーで配信するスクリプト

echo "=================================="
echo "Vector Search ハンズオン"
echo "ドキュメントサーバーを起動中..."
echo "=================================="
echo ""

# siteディレクトリが存在するか確認
if [ ! -d "site" ]; then
    echo "❌ ドキュメントが見つかりません"
    echo ""
    echo "講師に連絡して、ドキュメントファイルを取得してください"
    echo ""
    exit 1
fi

echo "✓ ドキュメントが見つかりました"
echo ""

# Pythonのバージョンを確認
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo "❌ Pythonが見つかりません"
    echo ""
    echo "Pythonをインストールするか、open-docs.sh を使用してください"
    echo ""
    exit 1
fi

echo "✓ Pythonが見つかりました: $PYTHON_CMD"
echo ""
echo "ドキュメントサーバーを起動しています..."
echo "ブラウザで http://localhost:8000 にアクセスしてください"
echo ""
echo "終了するには Ctrl+C を押してください"
echo ""

# siteディレクトリに移動してHTTPサーバーを起動
cd site
$PYTHON_CMD -m http.server 8000

# Made with Bob
