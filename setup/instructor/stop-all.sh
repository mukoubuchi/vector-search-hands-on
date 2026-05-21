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

# すべてのサービスを停止（プロファイル機能を使用）
echo "すべてのサービスを停止中..."
$COMPOSE_CMD --profile all down

if [ $? -eq 0 ]; then
    echo "✓ すべてのサービスが停止しました"
    echo "  - Milvus環境（etcd, minio, milvus）"
    echo "  - MkDocsドキュメントサーバー"
else
    echo "❌ サービスの停止に失敗しました"
fi

echo ""
echo "=========================================="
echo "✓ すべてのサービスが停止しました"
echo "=========================================="
echo ""

# Made with Bob
