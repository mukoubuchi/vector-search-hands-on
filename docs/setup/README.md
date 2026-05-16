# Vector Search ハンズオン セットアップファイル

このディレクトリには、TechZone 環境が利用できない場合の代替案（パターン B）で使用するセットアップファイルが含まれています。

## ファイル一覧

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

## 詳細なセットアップ手順

詳細な手順は [`alternative-setup-pattern-b.md`](../docs/alternative-setup-pattern-b.md) を参照してください。

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

## 参考資料

- [Milvus 公式ドキュメント](https://milvus.io/docs)
- [Docker Compose 公式ドキュメント](https://docs.docker.com/compose/)