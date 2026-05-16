# 代替案 B: 講師が共有環境を提供

TechZone 環境が予約できない場合の代替案として、講師が自身の PC で Milvus 環境を起動し、受講者に共有する方法を説明します。

## 概要

**構成**:
- **Milvus**: 講師の PC で Docker Compose を起動
- **watsonx.ai**: 講師の API キーを共有
- **受講者**: IBM Bob IDE のみインストール

**メリット**:
- ✅ 受講者の準備が最小限（IBM Bob のみ）
- ✅ 全員が同じ環境を使用（トラブルシューティングが容易）
- ✅ ハンズオンの本質（Bob Mode の使い方）に集中できる

**デメリット**:
- ⚠️ 講師の PC に負荷が集中（5-10 人程度なら問題なし）
- ⚠️ ネットワーク接続が必要

**推奨受講者数**: 5-10 人

---

## 講師側の準備（ハンズオン前日まで）

### 1. 必要なソフトウェアのインストール

#### ⚠️ 重要: Docker Desktop のライセンスについて

**Docker Desktop の商用利用には有料ライセンスが必要です**（2021年8月以降）

- **無料利用可能**: 個人利用、小規模企業（従業員250人未満 かつ 年間売上1,000万ドル未満）、教育機関
- **有料ライセンス必要**: 大企業での業務利用、**社内勉強会も含む**

IBM等の大企業で使用する場合は、以下の**無料代替案を強く推奨**します。

#### 推奨: Podman Desktop のインストール（完全無料）

**macOS の場合**:

```bash
# Homebrew でインストール
brew install podman podman-compose podman-desktop

# Podman マシンの初期化
podman machine init
podman machine start

# Docker互換エイリアスの設定（オプション）
echo 'alias docker=podman' >> ~/.zshrc
echo 'alias docker-compose=podman-compose' >> ~/.zshrc
source ~/.zshrc
```

**Windows の場合**:

1. [Podman Desktop](https://podman-desktop.io/) からインストーラーをダウンロード
2. インストール後、Podman マシンを初期化

**Linux の場合**:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y podman podman-compose

# Fedora/RHEL
sudo dnf install -y podman podman-compose
```

#### その他の無料代替案

**Rancher Desktop**:
```bash
# macOS
brew install --cask rancher

# Windows: https://rancherdesktop.io/ からダウンロード
```

**Colima** (macOS/Linux):
```bash
# macOS
brew install colima docker docker-compose
colima start
```

#### Docker Desktop を使用する場合（参考）

⚠️ ライセンス確認が必要です

**macOS の場合**:
```bash
brew install --cask docker
```

**Windows の場合**:
- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop) からダウンロード
- WSL 2 バックエンドを有効化

#### コンテナ環境の動作確認

**Podman を使用する場合**:

```bash
# Podman のバージョン確認
podman --version
podman-compose --version

# 動作確認
podman run hello-world

# Docker互換モードの確認（エイリアス設定済みの場合）
docker --version
docker compose version
```

**Docker Desktop を使用する場合**:

```bash
# Docker のバージョン確認
docker --version
docker compose version

# 動作確認
docker run hello-world
```

### 2. Milvus 環境のセットアップ

#### Docker Compose ファイルの準備

`docker-compose.yml` を作成：

```yaml
version: '3.8'

services:
  etcd:
    image: quay.io/coreos/etcd:v3.5.5
    environment:
      - ETCD_AUTO_COMPACTION_MODE=revision
      - ETCD_AUTO_COMPACTION_RETENTION=1000
      - ETCD_QUOTA_BACKEND_BYTES=4294967296
      - ETCD_SNAPSHOT_COUNT=50000
    volumes:
      - etcd_data:/etcd
    command: etcd -advertise-client-urls=http://127.0.0.1:2379 -listen-client-urls http://0.0.0.0:2379 --data-dir /etcd
    healthcheck:
      test: ["CMD", "etcdctl", "endpoint", "health"]
      interval: 30s
      timeout: 20s
      retries: 3

  minio:
    image: minio/minio:RELEASE.2023-03-20T20-16-18Z
    environment:
      MINIO_ACCESS_KEY: minioadmin
      MINIO_SECRET_KEY: minioadmin
    ports:
      - "9001:9001"
      - "9000:9000"
    volumes:
      - minio_data:/minio_data
    command: minio server /minio_data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

  milvus:
    image: milvusdb/milvus:v2.3.3
    command: ["milvus", "run", "standalone"]
    environment:
      ETCD_ENDPOINTS: etcd:2379
      MINIO_ADDRESS: minio:9000
    volumes:
      - milvus_data:/var/lib/milvus
    ports:
      - "19530:19530"
      - "9091:9091"
    depends_on:
      - "etcd"
      - "minio"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9091/healthz"]
      interval: 30s
      start_period: 90s
      timeout: 20s
      retries: 3

volumes:
  etcd_data:
  minio_data:
  milvus_data:
```

#### Milvus の起動

**Podman を使用する場合**:

```bash
# Podman Compose で起動
podman-compose up -d

# または Docker互換エイリアスを使用
docker compose up -d

# 起動確認（すべてのサービスが healthy になるまで待つ）
podman-compose ps
# または: docker compose ps

# ログ確認
podman-compose logs -f milvus
# または: docker compose logs -f milvus
```

**Docker Desktop を使用する場合**:

```bash
# Docker Compose で起動
docker compose up -d

# 起動確認
docker compose ps

# ログ確認
docker compose logs -f milvus
```

#### 接続確認

```bash
# Milvus の Health Check
curl http://localhost:9091/healthz

# 期待される出力: OK
```

### 3. watsonx.ai API キーの取得

#### IBM Cloud アカウントの準備

1. [IBM Cloud](https://cloud.ibm.com/) にログイン
2. watsonx.ai サービスを作成（まだ作成していない場合）

#### API キーの作成

1. IBM Cloud ダッシュボードで「Manage」→「Access (IAM)」を選択
2. 左メニューから「API keys」を選択
3. 「Create」ボタンをクリック
4. 名前を入力（例: `vector-search-handson`）
5. 「Create」をクリック
6. **API キーをコピーして安全に保存**（再表示できません）

#### watsonx.ai プロジェクト ID の取得

1. [watsonx.ai](https://dataplatform.cloud.ibm.com/wx/home) にアクセス
2. プロジェクトを選択（または新規作成）
3. 「Manage」タブ → 「General」
4. **Project ID** をコピー

### 4. ローカル IP アドレスの確認

受講者が講師の PC に接続するため、ローカル IP アドレスを確認します。

**macOS / Linux の場合**:

```bash
# Wi-Fi 接続の場合
ipconfig getifaddr en0

# 有線接続の場合
ipconfig getifaddr en1

# または
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows の場合**:

```bash
ipconfig

# IPv4 Address を確認
```

例: `192.168.1.100`

### 5. ファイアウォール設定

受講者が Milvus に接続できるよう、ファイアウォールでポート `19530` を開放します。

**macOS の場合**:

1. システム設定 → ネットワーク → ファイアウォール
2. ファイアウォールオプション
3. 「Docker」または「Milvus」の接続を許可

**Windows の場合**:

1. Windows Defender ファイアウォール → 詳細設定
2. 受信の規則 → 新しい規則
3. ポート → TCP → 特定のローカルポート: `19530`
4. 接続を許可する

### 6. 接続情報の準備

受講者に配布する接続情報をまとめます：

```text
=== Vector Search ハンズオン 接続情報 ===

【Milvus 接続情報】
- Host: 192.168.1.100  ← 講師の IP アドレス
- Port: 19530
- Username: （なし）
- Password: （なし）

【watsonx.ai 接続情報】
- API Key: YOUR_WATSONX_API_KEY_HERE
- Project ID: YOUR_PROJECT_ID_HERE
- URL: https://us-south.ml.cloud.ibm.com

【動作確認】
以下のコマンドで接続確認できます：
curl http://192.168.1.100:9091/healthz
```

---

## 受講者側の準備（ハンズオン当日）

### 1. IBM Bob IDE のインストール

- [ダウンロードページ](https://bob.ibm.com/download)からインストーラーを取得
- お使いの OS に合わせてインストール

### 2. Vector Search Builder モードのインストール

1. ハンズオン用プロジェクトフォルダを作成（例: `vector-search-handson/`）
2. 配布された `vector-search-builder.zip` をプロジェクトフォルダに配置
3. zip ファイルを解凍
4. `.bob/` フォルダがプロジェクトルートに作成されることを確認
5. IBM Bob でプロジェクトフォルダを開く（File → Open Folder）
6. **Cmd + Shift + P** → 「Reload Window」を実行
7. 右下の「Mode」セレクターに「Vector Search Builder」が表示されることを確認

### 3. 接続情報の設定

プロジェクトフォルダに `.env` ファイルを作成：

```bash
# Milvus 接続情報（講師から配布）
MILVUS_HOST=192.168.1.100
MILVUS_PORT=19530

# watsonx.ai 接続情報（講師から配布）
WATSONX_API_KEY=YOUR_WATSONX_API_KEY_HERE
WATSONX_PROJECT_ID=YOUR_PROJECT_ID_HERE
WATSONX_URL=https://us-south.ml.cloud.ibm.com
```

### 4. 接続確認

ターミナルで以下のコマンドを実行：

```bash
# Milvus への接続確認
curl http://192.168.1.100:9091/healthz

# 期待される出力: OK
```

---

## トラブルシューティング

### 講師側

#### Milvus が起動しない

```bash
# ログ確認
docker compose logs milvus

# 再起動
docker compose restart milvus

# 完全にクリーンアップして再起動
docker compose down -v
docker compose up -d
```

#### 受講者が接続できない

1. **ファイアウォール確認**:
   ```bash
   # macOS: ファイアウォールの状態確認
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
   ```

2. **IP アドレス確認**:
   ```bash
   # 現在の IP アドレスを再確認
   ipconfig getifaddr en0
   ```

3. **Milvus の状態確認**:
   ```bash
   # Health Check
   curl http://localhost:9091/healthz
   
   # ポート確認
   lsof -i :19530
   ```

### 受講者側

#### Milvus に接続できない

1. **接続確認**:
   ```bash
   # 講師の IP アドレスに ping
   ping 192.168.1.100
   
   # Milvus Health Check
   curl http://192.168.1.100:9091/healthz
   ```

2. **`.env` ファイル確認**:
   - IP アドレスが正しいか
   - ポート番号が `19530` か

3. **ネットワーク確認**:
   - 講師と同じ Wi-Fi ネットワークに接続しているか
   - VPN を使用している場合は切断してみる

---

## ハンズオン終了後

### 講師側

```bash
# Milvus 環境の停止
docker compose down

# データも含めて完全削除（次回のために）
docker compose down -v
```

---

## TechZone 環境への切り替え

TechZone 環境が利用可能になった場合、以下の手順で切り替えできます：

### 講師側

1. TechZone で環境を予約
2. 新しい接続情報を受講者に配布
3. ローカルの Milvus 環境を停止

### 受講者側

1. `.env` ファイルの接続情報を TechZone の情報に更新
2. IBM Bob をリロード

**切り替えは数分で完了**し、ハンズオンの内容は変更不要です。