#!/bin/bash
# 生成済みのHTMLドキュメントをブラウザで開くスクリプト

echo "=================================="
echo "Vector Search ハンズオン"
echo "ドキュメントを開いています..."
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

# 現在のディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INDEX_PATH="$SCRIPT_DIR/site/index.html"

# ファイルが存在するか確認
if [ ! -f "$INDEX_PATH" ]; then
    echo "❌ index.htmlが見つかりません: $INDEX_PATH"
    exit 1
fi

# OSに応じてブラウザで開く
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "$INDEX_PATH"
    echo "✓ ブラウザでドキュメントを開きました（macOS）"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    xdg-open "$INDEX_PATH"
    echo "✓ ブラウザでドキュメントを開きました（Linux）"
else
    echo "⚠ 自動的に開けませんでした"
    echo ""
    echo "以下のファイルをブラウザで開いてください:"
    echo "file://$INDEX_PATH"
fi

echo ""
echo "ドキュメントの閲覧を開始できます！"

# Made with Bob
