#!/bin/bash
# Milvus環境とMkDocsドキュメントサーバーを一括停止するスクリプト

echo "=========================================="
echo "Vector Search ハンズオン環境を停止中..."
echo "=========================================="
echo ""

# Milvus環境を停止
echo "1. Milvus環境を停止中..."
docker compose -f docker-compose.yml down

if [ $? -eq 0 ]; then
    echo "✓ Milvus環境が停止しました"
else
    echo "❌ Milvus環境の停止に失敗しました"
fi

echo ""

# MkDocsドキュメントサーバーを停止
echo "2. MkDocsドキュメントサーバーを停止中..."
docker compose -f docker-compose-docs.yml down

if [ $? -eq 0 ]; then
    echo "✓ MkDocsドキュメントサーバーが停止しました"
else
    echo "❌ MkDocsドキュメントサーバーの停止に失敗しました"
fi

echo ""
echo "=========================================="
echo "✓ すべてのサービスが停止しました"
echo "=========================================="
echo ""

# Made with Bob
