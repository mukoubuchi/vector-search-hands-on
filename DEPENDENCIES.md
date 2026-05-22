# 依存関係ドキュメント

このドキュメントでは、Vector Search ハンズオンプロジェクトの依存関係と必要なツールについて説明します。

## 📋 目次

- [講師向け依存関係](#講師向け依存関係)
- [受講者向け依存関係](#受講者向け依存関係)
- [開発者向け依存関係](#開発者向け依存関係)
- [オプション依存関係](#オプション依存関係)

## 講師向け依存関係

### 必須ツール

#### 1. Container Runtime（いずれか1つ）

**Docker**
- バージョン: 20.10+
- インストール: [Docker Desktop](https://docs.docker.com/get-docker/)
- 用途: Milvus環境の実行

**Podman**
- バージョン: 4.0+
- インストール: `brew install podman`
- 用途: Milvus環境の実行（Dockerの代替）

**Colima**
- バージョン: 0.5+
- インストール: `brew install colima`
- 用途: macOSでのDocker互換環境

#### 2. Docker Compose（いずれか1つ）

**docker compose**
- バージョン: 2.0+
- 含まれる: Docker Desktop
- コマンド: `docker compose`

**docker-compose**
- バージョン: 1.29+
- インストール: `brew install docker-compose`
- コマンド: `docker-compose`

**podman-compose**
- バージョン: 1.0+
- インストール: `brew install podman-compose`
- コマンド: `podman-compose`

#### 3. IBM Cloud CLI

- バージョン: 2.0+
- インストール: [IBM Cloud CLI](https://cloud.ibm.com/docs/cli)
- 用途: Code Engineへのデプロイ

**必須プラグイン:**
- `code-engine`: Code Engineプラグイン
- `container-registry`: Container Registryプラグイン

インストール:
```bash
ibmcloud plugin install code-engine
ibmcloud plugin install container-registry
```

#### 4. MkDocs（ローカルプレビュー用）

- バージョン: 1.5+
- インストール: `pip install mkdocs mkdocs-material`
- 用途: ドキュメントのローカルプレビュー

### 推奨ツール

#### ShellCheck
- バージョン: 0.9+
- インストール: `brew install shellcheck`
- 用途: Bashスクリプトの静的解析

#### jq
- バージョン: 1.6+
- インストール: `brew install jq`
- 用途: JSON解析（自動フォールバック機能あり）

## 受講者向け依存関係

### 必須ツール

#### 1. IBM Bob IDE
- 最新版を推奨
- ダウンロード: [IBM Bob IDE](https://www.ibm.com/products/watsonx-code-assistant)
- 用途: ハンズオン実施環境

#### 2. Python（接続テスト用）
- バージョン: 3.9+
- インストール: [Python公式サイト](https://www.python.org/downloads/)

**必須Pythonパッケージ:**
```bash
pip install -r setup/participant/requirements.txt
```

含まれるパッケージ:
- `pymilvus`: Milvus Python SDK
- `sentence-transformers`: Hugging Face埋め込みモデル
- `python-dotenv`: 環境変数管理
- `scikit-learn`: 類似度計算

### オプションツール

#### Milvus CLI
- インストール: `pip install milvus-cli`
- 用途: Milvusの直接操作

## 開発者向け依存関係

### 必須ツール

上記の講師向け依存関係に加えて:

#### 1. Git
- バージョン: 2.30+
- 用途: バージョン管理

#### 2. Python開発環境
- バージョン: 3.9+
- 仮想環境: `venv` または `virtualenv`

#### 3. Node.js（ドキュメント開発用）
- バージョン: 18+
- インストール: `brew install node`
- 用途: JavaScriptツールチェーン

### 開発ツール

#### 1. テストツール

**Bash テスト:**
- カスタムテストフレームワーク（`tests/test_common.sh`）

**Python テスト:**
- `unittest`: 標準ライブラリ
- 実行: `python tests/test_python_scripts.py`

**統合テスト:**
- 実行: `./tests/run_all_tests.sh`

#### 2. リンター・フォーマッター

**ShellCheck:**
```bash
brew install shellcheck
shellcheck lib/*.sh setup/instructor/*.sh
```

**markdownlint:**
```bash
npm install -g markdownlint-cli
markdownlint '**/*.md'
```

**Python linters:**
```bash
pip install pylint black mypy
pylint setup/participant/*.py
black setup/participant/*.py
mypy setup/participant/*.py
```

#### 3. CI/CD

**GitHub Actions:**
- 設定ファイル: `.github/workflows/test.yml`
- 自動実行: プッシュ・プルリクエスト時

## オプション依存関係

### パフォーマンス最適化

#### 1. Buildx（マルチアーキテクチャビルド）
- Docker Buildx: Docker Desktop に含まれる
- 用途: linux/amd64 イメージのビルド

#### 2. キャッシュツール
- Docker layer caching
- BuildKit

### 監視・デバッグ

#### 1. Docker Desktop Dashboard
- 用途: コンテナの監視

#### 2. Milvus Attu（GUI）
- インストール: Docker経由
- 用途: Milvusの可視化・管理

```bash
docker run -p 8000:3000 \
  -e MILVUS_URL=localhost:19530 \
  zilliz/attu:latest
```

## バージョン互換性マトリックス

| ツール | 最小バージョン | 推奨バージョン | テスト済み |
|--------|---------------|---------------|-----------|
| Docker | 20.10 | 24.0+ | ✓ |
| Podman | 4.0 | 4.8+ | ✓ |
| Python | 3.9 | 3.11+ | ✓ |
| IBM Cloud CLI | 2.0 | 2.20+ | ✓ |
| MkDocs | 1.5 | 1.5+ | ✓ |
| Node.js | 18 | 20+ | ✓ |

## プラットフォーム別インストールガイド

### macOS

```bash
# Homebrew経由
brew install podman colima shellcheck jq

# Python環境
python3 -m pip install --upgrade pip
pip3 install mkdocs mkdocs-material

# IBM Cloud CLI
curl -fsSL https://clis.cloud.ibm.com/install/osx | sh
```

### Linux (Ubuntu/Debian)

```bash
# パッケージマネージャー経由
sudo apt update
sudo apt install docker.io shellcheck jq python3-pip

# Python環境
pip3 install mkdocs mkdocs-material

# IBM Cloud CLI
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
```

### Windows

```powershell
# Chocolatey経由
choco install docker-desktop python shellcheck jq

# Python環境
pip install mkdocs mkdocs-material

# IBM Cloud CLI
# インストーラーをダウンロード: https://cloud.ibm.com/docs/cli
```

## トラブルシューティング

### よくある問題

#### 1. Docker/Podman接続エラー

**症状:** `Cannot connect to the Docker daemon`

**解決策:**
```bash
# Docker Desktop を起動
# または Colima を起動
colima start --arch x86_64 --vm-type=vz --vz-rosetta
```

#### 2. IBM Cloud CLI ログインエラー

**症状:** `Not logged in`

**解決策:**
```bash
ibmcloud login --sso
```

#### 3. Python パッケージインストールエラー

**症状:** `pip install` が失敗

**解決策:**
```bash
# 仮想環境を使用
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# または
venv\Scripts\activate  # Windows

pip install -r setup/participant/requirements.txt
```

## 更新履歴

- 2024-01: 初版作成
- 2024-02: バリデーション機能追加に伴う更新
- 2024-03: CI/CD設定追加に伴う更新

## 関連ドキュメント

- [README.md](README.md) - プロジェクト概要
- [REFACTORING.md](REFACTORING.md) - リファクタリング履歴
- [setup/instructor/deploy-docs-to-cloud.md](setup/instructor/deploy-docs-to-cloud.md) - デプロイ手順

# Made with Bob