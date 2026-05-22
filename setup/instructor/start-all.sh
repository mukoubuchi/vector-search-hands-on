#!/bin/bash
# Milvus環境を起動するスクリプト

echo "=========================================="
echo "Vector Search ハンズオン環境を起動中..."
echo "=========================================="
echo ""

# DockerまたはPodmanがインストールされているか確認
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
        echo "❌ docker-composeがインストールされていません"
        echo ""
        echo "インストール方法:"
        echo "  brew install docker-compose"
        echo ""
        exit 1
    fi
    
    # Podmanのdockerエイリアスを使用している場合、DOCKER_HOSTを設定
    if docker version 2>&1 | grep -q "podman"; then
        # macOSのPodman machine socketパスを取得
        PODMAN_SOCK=$(podman machine inspect podman-machine-default 2>/dev/null | grep -o '"Path": "[^"]*"' | head -1 | cut -d'"' -f4)
        if [ -n "$PODMAN_SOCK" ]; then
            export DOCKER_HOST="unix://$PODMAN_SOCK"
            echo "✓ Podman（dockerエイリアス経由）が見つかりました"
        else
            echo "✓ Dockerが見つかりました"
        fi
    else
        echo "✓ Dockerが見つかりました"
    fi
elif command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
    # Podman 4.0以降はpodman composeをサポート
    if podman compose version &> /dev/null 2>&1; then
        COMPOSE_CMD="podman compose"
    elif command -v podman-compose &> /dev/null; then
        COMPOSE_CMD="podman-compose"
    else
        echo "❌ podman-composeがインストールされていません"
        echo ""
        echo "インストール方法:"
        echo "  brew install podman-compose"
        echo ""
        exit 1
    fi
    echo "✓ Podmanが見つかりました"
else
    echo "❌ DockerまたはPodmanがインストールされていません"
    echo ""
    echo "インストール方法:"
    echo "  Docker: https://docs.docker.com/get-docker/"
    echo "  Podman: https://podman.io/getting-started/installation"
    echo ""
    echo "macOSの場合（Homebrew）:"
    echo "  brew install podman"
    echo "  podman machine init"
    echo "  podman machine start"
    echo ""
    exit 1
fi

echo ""

# Milvus環境を起動
echo "Milvus環境を起動中..."
$COMPOSE_CMD --profile milvus up -d

if [ $? -eq 0 ]; then
    echo "✓ Milvus環境が起動しました"
    echo "  - etcd, minio, milvus"
else
    echo "❌ サービスの起動に失敗しました"
    exit 1
fi

echo ""
echo "=========================================="
echo "✓ Milvus環境が起動しました"
echo "=========================================="
echo ""
echo "📊 アクセス情報:"
echo ""
echo "  Milvus:"
echo "    - ホスト: localhost"
echo "    - ポート: 19530"
echo "    - 認証: root/Milvus"
echo ""
echo "📝 次のステップ:"
echo ""
echo "  1. 受講者に共有するMilvusホスト:"
echo "     $(hostname -I | awk '{print $1}' || ipconfig getifaddr en0 || echo 'IPアドレスを手動で確認してください')"
echo ""
echo "  2. ドキュメントをCode Engineにデプロイ:"
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

# Made with Bob
