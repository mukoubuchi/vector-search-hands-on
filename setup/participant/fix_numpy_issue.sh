#!/bin/bash
# NumPyバージョン不整合エラーの修正スクリプト

set -e

echo "=================================================="
echo "NumPy バージョン不整合エラーの修正"
echo "=================================================="

# 現在のディレクトリを確認
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo ""
echo "=== ステップ1: 既存パッケージのアンインストール ==="
echo "pymilvus と numpy を削除します..."
pip uninstall -y pymilvus numpy 2>/dev/null || true

echo ""
echo "=== ステップ2: pipキャッシュのクリア ==="
pip cache purge

echo ""
echo "=== ステップ3: パッケージの再インストール ==="
echo "requirements.txt からパッケージをインストールします..."
pip install -r requirements.txt

echo ""
echo "=== ステップ4: インストール確認 ==="
echo "インストールされたパッケージのバージョン:"
pip list | grep -E "numpy|pymilvus|pandas|torch"

echo ""
echo "=================================================="
echo "修正完了"
echo "=================================================="
echo ""
echo "次のコマンドで接続テストを実行してください:"
echo "  python test_connection.py"
echo ""

# Made with Bob
