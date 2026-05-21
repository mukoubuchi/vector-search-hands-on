#!/bin/bash
# Milvus環境とMkDocsドキュメントサーバーを一括停止するスクリプト

echo "=========================================="
echo "Vector Search ハンズオン環境を停止中..."
echo "=========================================="
echo ""

# DockerまたはPodmanを検出
CONTAINER_CMD=""
COMPOSE_CMD=""
if command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
    # docker composeとdocker-composeの両方をチェック
    if docker compose version &> /dev/null 2>&1; then
        COMPOSE_CMD="docker compose"
    elif command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        COMPOSE_CMD="docker-compose"  # デフォルトで試す
    fi
elif command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
    # Podman 4.0以降はpodman composeをサポート
    if podman compose version &> /dev/null 2>&1; then
        COMPOSE_CMD="podman compose"
    elif command -v podman-compose &> /dev/null; then
        COMPOSE_CMD="podman-compose"
    else
        COMPOSE_CMD="podman compose"  # デフォルトで試す
    fi
else
    echo "❌ DockerまたはPodmanが見つかりません"
    exit 1
fi

# Milvus環境を停止
echo "1. Milvus環境を停止中..."
$COMPOSE_CMD -f docker-compose.yml down

if [ $? -eq 0 ]; then
    echo "✓ Milvus環境が停止しました"
else
    echo "❌ Milvus環境の停止に失敗しました"
fi

echo ""

# MkDocsドキュメントサーバーを停止
echo "2. MkDocsドキュメントサーバーを停止中..."
$COMPOSE_CMD -f docker-compose-docs.yml down

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
