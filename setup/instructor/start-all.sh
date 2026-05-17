#!/bin/bash
# Milvus環境とMkDocsドキュメントサーバーを一括起動するスクリプト

echo "=========================================="
echo "Vector Search ハンズオン環境を起動中..."
echo "=========================================="
echo ""

# Docker Composeがインストールされているか確認
if ! command -v docker &> /dev/null; then
    echo "❌ Dockerがインストールされていません"
    echo ""
    echo "インストール方法:"
    echo "  https://docs.docker.com/get-docker/"
    echo ""
    exit 1
fi

echo "✓ Dockerが見つかりました"
echo ""

# Milvus環境を起動
echo "1. Milvus環境を起動中..."
docker compose -f docker-compose.yml up -d

if [ $? -eq 0 ]; then
    echo "✓ Milvus環境が起動しました"
else
    echo "❌ Milvus環境の起動に失敗しました"
    exit 1
fi

echo ""

# MkDocsドキュメントサーバーを起動
echo "2. MkDocsドキュメントサーバーを起動中..."
docker compose -f docker-compose-docs.yml up -d

if [ $? -eq 0 ]; then
    echo "✓ MkDocsドキュメントサーバーが起動しました"
else
    echo "❌ MkDocsドキュメントサーバーの起動に失敗しました"
    exit 1
fi

echo ""
echo "=========================================="
echo "✓ すべてのサービスが起動しました"
echo "=========================================="
echo ""
echo "📊 アクセス情報:"
echo ""
echo "  Milvus:"
echo "    - ホスト: localhost"
echo "    - ポート: 19530"
echo ""
echo "  MkDocsドキュメント:"
echo "    - URL: http://localhost:8001"
echo "    - 受講者に共有: http://$(hostname -I | awk '{print $1}'):8001"
echo ""
echo "📝 受講者への案内:"
echo ""
echo "  1. ブラウザで以下のURLにアクセスしてください:"
echo "     http://$(hostname -I | awk '{print $1}'):8001"
echo ""
echo "  2. 左側のメニューから「事前準備」を選択してください"
echo ""
echo "=========================================="
echo ""
echo "停止するには以下を実行してください:"
echo "  ./stop-all.sh"
echo ""

# Made with Bob
