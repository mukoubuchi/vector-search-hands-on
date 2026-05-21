# Vector Search ハンズオン - 講師用セットアップガイド

このディレクトリには、講師がMilvus環境とMkDocsドキュメントサーバーを提供する際に使用するセットアップファイルが含まれています。

## 📋 ファイル一覧

### `docker-compose.yml`
Milvus 環境を起動するための Docker Compose 設定ファイルです。

**含まれるサービス**:
- **Milvus**: ベクトルデータベース（ポート 19530）
- **etcd**: Milvus のメタデータストア
- **MinIO**: Milvus のオブジェクトストレージ

### `docker-compose-docs.yml`
MkDocsドキュメントサーバーを起動するための Docker Compose 設定ファイルです。

**含まれるサービス**:
- **mkdocs**: ドキュメントサーバー（ポート 8001）

### `start-all.sh`
Milvus環境とMkDocsドキュメントサーバーを一括起動するスクリプトです。

### `stop-all.sh`
すべてのサービスを一括停止するスクリプトです。

### `instructor-share-info.md`
受講者への共有情報を準備するためのガイドです。

### `deploy-docs-to-cloud.md` ⭐ 新規
リモート参加者対応：IBM Cloud Code Engineへのドキュメントデプロイガイド（5分で完了）

### `check_docs_url.sh` ⭐ 新規
Code EngineにデプロイされたドキュメントのURLを確認するスクリプト（講師用）

### `techzone-code-engine-guide.md`
TechZone環境でのCode Engine利用ガイド

## 🚀 講師用クイックスタート

### 1. 環境の起動

```bash
# setup/instructor ディレクトリに移動
cd setup/instructor

# すべてのサービスを起動
./start-all.sh
```

起動後、以下のサービスが利用可能になります：
- **Milvus**: `localhost:19530`
- **MkDocs**: `http://localhost:8001`

### 2. IPアドレスの確認

受講者に共有するIPアドレスを確認します：

```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# または
hostname -I  # Linuxの場合
```

**重要**: IPアドレスはネットワーク環境（WiFi、VPN等）により変動します。ハンズオン開始前に必ず確認してください。

### 3. 受講者への情報共有

`instructor-share-info.md` を参照して、以下の情報を受講者に共有します：

```
Milvus接続情報:
- Host: <講師のIPアドレス>
- Port: 19530
- User: root
- Password: Milvus

MkDocsドキュメント（ローカル参加者）:
- URL: http://<講師のIPアドレス>:8001

MkDocsドキュメント（リモート参加者）:
- URL例: https://mkdocs-docs.**xxxxx**.us-south.codeengine.appdomain.cloud ※**xxxxx**は環境により異なります（あくまで例）
```

**リモート参加者がいる場合**:
異なるWiFi/ネットワークの受講者がいる場合は、[リモート参加者対応ガイド](deploy-docs-to-cloud.md)を参照してCode Engineにデプロイしてください（5分で完了）。

!!! warning "TechZone環境でのURL変更について"
    TechZone環境を再予約すると、新しいCode EngineプロジェクトのURLが変わります。
    新しい環境では、デプロイスクリプトを再実行して新しいURLを受講者に共有してください。

### 4. 接続テストの実施

講師側でも接続テストを実施して、環境が正常に動作していることを確認します：

```bash
# .envファイルを作成（初回のみ）
cd setup/instructor
cat > .env << EOF
MILVUS_HOST=localhost
MILVUS_PORT=19530
MILVUS_USER=root
MILVUS_PASSWORD=Milvus
EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
EMBEDDING_DIMENSION=384
EOF

# Pythonパッケージのインストール（初回のみ）
cd ../participant
pip install -r requirements.txt

# 接続テスト
python test_embeddings_hf.py
```

### 5. 環境の停止

ハンズオン終了後、環境を停止します：

```bash
cd setup/instructor
./stop-all.sh
```

## 🔧 個別起動（トラブルシューティング用）

### Milvusのみ起動

```bash
cd setup/instructor

# 起動
docker compose -f docker-compose.yml up -d

# 状態確認
docker compose -f docker-compose.yml ps

# ログ確認
docker compose -f docker-compose.yml logs -f

# 停止
docker compose -f docker-compose.yml down
```

### MkDocsドキュメントサーバーのみ起動

```bash
cd setup/instructor

# 起動
docker compose -f docker-compose-docs.yml up -d

# 状態確認
docker compose -f docker-compose-docs.yml ps

# ログ確認
docker compose -f docker-compose-docs.yml logs -f

# 停止
docker compose -f docker-compose-docs.yml down
```

## 🐛 トラブルシューティング

### Docker Compose が起動しない

```bash
# ログ確認
docker compose -f docker-compose.yml logs

# 特定のサービスのログ
docker compose -f docker-compose.yml logs milvus

# 再起動
docker compose -f docker-compose.yml restart
```

### ポートが既に使用されている

```bash
# ポート使用状況の確認
lsof -i :19530  # Milvus
lsof -i :8001   # MkDocs

# 使用中のプロセスを停止してから再起動
docker compose -f docker-compose.yml down
docker compose -f docker-compose.yml up -d
```

### Milvus が起動しない

```bash
# すべてのログを確認
docker compose -f docker-compose.yml logs

# Milvus のヘルスチェック
curl http://localhost:9091/healthz

# 完全にクリーンアップして再起動
docker compose -f docker-compose.yml down -v
docker compose -f docker-compose.yml up -d
```

### 受講者が接続できない

1. **ファイアウォール設定の確認**
   - ポート 19530（Milvus）が開放されているか
   - ポート 8001（MkDocs）が開放されているか

2. **IPアドレスの再確認**
   - 正しいIPアドレスを共有しているか
   - VPN接続により変わっていないか

3. **Milvusの動作確認**
   ```bash
   # 講師側で接続テスト
   python ../participant/test_connection_simple.py
   ```

## 📚 参考資料

- [Milvus 公式ドキュメント](https://milvus.io/docs)
- [Docker 公式ドキュメント](https://docs.docker.com/)
- [Docker Compose 公式ドキュメント](https://docs.docker.com/compose/)

## 📝 ハンズオン準備チェックリスト

- [ ] Docker Desktop が起動している
- [ ] `./start-all.sh` でサービスを起動
- [ ] IPアドレスを確認
- [ ] 講師側で接続テストを実施
- [ ] 受講者に接続情報を共有
- [ ] MkDocsドキュメントURLを共有
- [ ] 受講者の接続テストを確認