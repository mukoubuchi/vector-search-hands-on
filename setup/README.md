# Vector Search ハンズオン セットアップファイル

このディレクトリには、TechZone 環境が利用できない場合の代替セットアップで使用するファイルが含まれています。

## 📋 ファイル一覧

### `docker-compose.yml`

講師が自身の PC で Milvus 環境を起動するための Docker Compose 設定ファイルです。

**含まれるサービス**:
- **Milvus**: ベクトルデータベース（ポート 19530）
- **etcd**: Milvus のメタデータストア
- **MinIO**: Milvus のオブジェクトストレージ

**使用方法**:

```bash
# 起動
docker compose up -d

# 状態確認
docker compose ps

# 停止
docker compose down

# データも含めて削除
docker compose down -v
```

### `.env.example`

受講者が使用する環境変数のテンプレートファイルです。

**使用方法**:

1. このファイルを `.env` にコピー
2. 講師から配布された接続情報に置き換え
3. IBM Bob プロジェクトのルートディレクトリに配置

## 🐳 Docker / Docker Compose のセットアップ

### 前提条件

- macOS 10.15 以降、または Windows 10/11 Pro/Enterprise
- 管理者権限

### Docker Desktop のインストール

#### macOS の場合

**方法1: Homebrew を使用（推奨）**

```bash
# Homebrew がインストールされていない場合
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Docker Desktop をインストール
brew install --cask docker

# Docker Desktop を起動
open -a Docker
```

**方法2: 公式サイトからダウンロード**

1. [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop) にアクセス
2. お使いの Mac に合わせて選択:
   - **Apple Silicon (M1/M2/M3)**: "Mac with Apple chip" をダウンロード
   - **Intel Mac**: "Mac with Intel chip" をダウンロード
3. ダウンロードした `Docker.dmg` を開く
4. Docker アイコンを Applications フォルダにドラッグ
5. Applications フォルダから Docker を起動

#### Windows の場合

**前提条件**:
- Windows 10/11 Pro, Enterprise, または Education（64-bit）
- WSL 2 が有効化されていること

**インストール手順**:

1. [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop) からインストーラーをダウンロード
2. `Docker Desktop Installer.exe` を実行
3. インストールウィザードに従う
   - "Use WSL 2 instead of Hyper-V" にチェック（推奨）
4. インストール完了後、再起動
5. Docker Desktop を起動

### Docker の動作確認

```bash
# Docker のバージョン確認
docker --version
# 期待される出力例: Docker version 24.0.0, build xxxxx

# Docker が正常に動作しているか確認
docker info

# テストコンテナを実行
docker run hello-world
# "Hello from Docker!" が表示されれば成功
```

### Docker Compose のセットアップ

Docker Desktop には Docker Compose V2 が含まれていますが、正しく動作しない場合は以下の手順でインストールします。

#### Docker Compose の確認

```bash
# Docker Compose V2 の確認（推奨）
docker compose version
# 期待される出力例: Docker Compose version v2.20.0

# 古い V1 の確認
docker-compose --version
```

#### Docker Compose V2 のインストール（必要な場合）

**macOS の場合**:

```bash
# Homebrew でインストール
brew install docker-compose

# または手動インストール（Apple Silicon）
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-darwin-aarch64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

# または手動インストール（Intel Mac）
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-darwin-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

# インストール確認
docker compose version
```

**Windows の場合**:

Docker Desktop に含まれているため、通常は追加インストール不要です。動作しない場合：

```powershell
# PowerShell を管理者権限で実行
mkdir -p $Env:USERPROFILE\.docker\cli-plugins
Invoke-WebRequest "https://github.com/docker/compose/releases/latest/download/docker-compose-windows-x86_64.exe" -OutFile "$Env:USERPROFILE\.docker\cli-plugins\docker-compose.exe"

# インストール確認
docker compose version
```

### トラブルシューティング

#### Docker Desktop が起動しない

**macOS**:
```bash
# Docker Desktop のプロセスを確認
ps aux | grep -i docker

# Docker Desktop を再起動
killall Docker && open -a Docker

# ログを確認
tail -f ~/Library/Containers/com.docker.docker/Data/log/vm/dockerd.log
```

**Windows**:
- タスクマネージャーで Docker Desktop を終了
- Docker Desktop を管理者権限で再起動
- WSL 2 が正しくインストールされているか確認: `wsl --list --verbose`

#### "docker: command not found" エラー

```bash
# Docker Desktop が起動しているか確認
# macOS: メニューバーに Docker アイコンがあるか確認
# Windows: システムトレイに Docker アイコンがあるか確認

# PATH の確認
echo $PATH | grep docker

# シェルを再起動
exec $SHELL -l
```

#### "Cannot connect to the Docker daemon" エラー

```bash
# Docker デーモンの状態確認
docker info

# Docker Desktop を再起動
# macOS: メニューバーの Docker アイコン → Restart
# Windows: システムトレイの Docker アイコン → Restart

# それでも解決しない場合
# macOS:
rm -rf ~/Library/Containers/com.docker.docker/Data/vms
open -a Docker

# Windows: Docker Desktop を再インストール
```

## 詳細なセットアップ手順

詳細な手順は [`alternative-setup.md`](../docs/alternative-setup.md) を参照してください。

## トラブルシューティング

### Docker Compose が起動しない

```bash
# ログ確認
docker compose logs

# 特定のサービスのログ
docker compose logs milvus

# 再起動
docker compose restart
```

### ポートが既に使用されている

```bash
# ポート使用状況の確認
lsof -i :19530
lsof -i :9091

# 使用中のプロセスを停止してから再起動
docker compose down
docker compose up -d
```

### Milvus が起動しない

```bash
# すべてのログを確認
docker compose logs

# Milvus のヘルスチェック
curl http://localhost:9091/healthz

# 完全にクリーンアップして再起動
docker compose down -v
docker compose up -d
```

## 参考資料

- [Milvus 公式ドキュメント](https://milvus.io/docs)
- [Docker 公式ドキュメント](https://docs.docker.com/)
- [Docker Compose 公式ドキュメント](https://docs.docker.com/compose/)