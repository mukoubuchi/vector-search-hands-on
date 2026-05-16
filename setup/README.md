# Vector Search ハンズオン セットアップファイル

このディレクトリには、講師が Milvus 環境とMkDocsドキュメントサーバーを提供する際に使用するセットアップファイルと、受講者が接続テストを行うためのスクリプトが含まれています。

## 📋 ファイル一覧

### 講師向けファイル

#### `docker-compose.yml`
Milvus 環境を起動するための Docker Compose 設定ファイルです。

**含まれるサービス**:
- **Milvus**: ベクトルデータベース（ポート 19530）
- **etcd**: Milvus のメタデータストア
- **MinIO**: Milvus のオブジェクトストレージ

#### `docker-compose-docs.yml` ★NEW
MkDocsドキュメントサーバーを起動するための Docker Compose 設定ファイルです。

**含まれるサービス**:
- **mkdocs**: ドキュメントサーバー（ポート 8001）

#### `start-all.sh` / `start-all.bat` ★NEW
Milvus環境とMkDocsドキュメントサーバーを一括起動するスクリプトです。

**使用方法**:

```bash
# すべてのサービスを起動
cd setup
./start-all.sh

# 受講者に以下のURLを共有
# http://<講師のIPアドレス>:8001
```

#### `stop-all.sh` / `stop-all.bat` ★NEW
すべてのサービスを一括停止するスクリプトです。

```bash
# すべてのサービスを停止
cd setup
./stop-all.sh
```

### 個別起動（従来の方法）

#### Milvusのみ起動
```bash
# 起動
docker compose -f docker-compose.yml up -d

# 状態確認
docker compose -f docker-compose.yml ps

# 停止
docker compose -f docker-compose.yml down
```

#### MkDocsドキュメントサーバーのみ起動
```bash
# 起動
docker compose -f docker-compose-docs.yml up -d

# 状態確認
docker compose -f docker-compose-docs.yml ps

# 停止
docker compose -f docker-compose-docs.yml down
```

### `.env.example`

受講者が使用する環境変数のテンプレートファイルです。

**使用方法**:

1. このファイルを `.env` にコピー
2. 講師から配布された接続情報に置き換え
3. IBM Bob をリロード

### `requirements.txt`

接続テストに必要な Python パッケージのリストです。

### `test_connection.py`

Milvus と埋め込みモデルへの接続をテストするスクリプトです。

## 🚀 クイックスタート（受講者向け）

### 1. 環境変数の設定

```bash
# setup ディレクトリに移動
cd setup

# .env ファイルを作成（既に作成済みの場合はスキップ）
cp .env.example .env

# .env ファイルを編集して、講師から配布された情報を入力
# - MILVUS_HOST: Milvus サーバーのIPアドレス
# - MILVUS_USER: Milvusユーザー名
# - MILVUS_PASSWORD: Milvusパスワード
```

### 2. Python パッケージのインストール

```bash
# 仮想環境の作成（推奨）
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# パッケージのインストール
pip install -r requirements.txt
```

### 3. 接続テストの実行

```bash
# 接続テストスクリプトを実行
python test_connection.py
```

**期待される出力**:

```
==================================================
Milvus & 埋め込みモデル 接続テスト
==================================================

=== 環境変数確認 ===
✓ MILVUS_HOST: 192.168.1.100
✓ MILVUS_PORT: 19530
✓ EMBEDDING_MODEL: paraphrase-multilingual-MiniLM-L12-v2
✓ EMBEDDING_DIMENSION: 384

=== Milvus 接続テスト ===
接続先: 192.168.1.100:19530
✓ Milvusに接続成功
✓ 既存コレクション数: 0

=== 埋め込みモデル テスト ===
モデル: paraphrase-multilingual-MiniLM-L12-v2
モデルをロード中...
✓ モデルのロードに成功しました

テスト埋め込み生成: 'これはテストです'
✓ 埋め込みベクトル生成成功
  次元数: 384
  最初の5要素: [0.123, -0.456, 0.789, ...]

==================================================
テスト結果サマリー
==================================================
Milvus接続:        ✓ 成功
埋め込みモデル:    ✓ 成功

✓ すべての接続テストが成功しました！
  次のステップ: ベクトルコレクションの作成
```

### トラブルシューティング

#### Milvus 接続エラー

```
✗ Milvus接続エラー: [Errno 61] Connection refused
```

**原因と対処法**:
- Milvus サーバーが起動していない → 講師に確認
- MILVUS_HOST が間違っている → `.env` ファイルを確認
- ファイアウォールでブロックされている → ネットワーク設定を確認

#### 埋め込みモデル エラー

```
✗ モデルのロードに失敗しました
```

**原因と対処法**:
- API キーが間違っている → IBM Cloud で API キーを再確認
- プロジェクト ID が間違っている → Watsonx プロジェクト設定を確認
- API キーの権限が不足 → IBM Cloud IAM で権限を確認

#### パッケージインストールエラー

```bash
# pip を最新版にアップグレード
pip install --upgrade pip

# 個別にインストールを試す
pip install pymilvus
pip install ibm-watsonx-ai
pip install python-dotenv
```

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

詳細な手順は [`setup-guide.md`](../docs/setup-guide.md) を参照してください。

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