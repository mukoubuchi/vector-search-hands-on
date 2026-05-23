# ベクトル検索ハンズオン 講師用ガイド

## 🚀 クイックスタート

### 1. 環境起動

```bash
cd setup/instructor
./start-all.sh
```

これにより以下が起動します：
- **Milvus 環境**（etcd, MinIO, Milvus）
- **ローカルドキュメントサーバー**（http://localhost:8001）

> [!NOTE]
> **ポート 8001 を使用する理由**
> - docker-compose のポートマッピング（`8001:8000`）により、講師側は 8001 でアクセス
> - **同じネットワーク内の受講者全員が`講師の IP:8001`でドキュメントにアクセス可能**
> - ポート 8000 は受講者の FastAPI アプリと競合する可能性があるため、8001 を使用
> - これにより、各受講者が個別にドキュメントサーバーを起動する必要がなくなります

### 2. 講師の IP アドレス確認

```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1
# 最初に表示される IP アドレスを使用（例: 10.0.1.5）
```

### 3. ドキュメントをクラウドにデプロイ

リモート参加者用に、ドキュメントを Code Engine にデプロイします：

```bash
cd /path/to/vector-search-handson
./deploy-to-code-engine.sh
```

詳細は[deploy-docs-to-cloud.md](./deploy-docs-to-cloud.md)を参照。

---

## 📋 受講者に共有する情報

### 必須情報

```
MILVUS_HOST=【講師の IP アドレス】  # 例: 10.0.1.5
```

### ドキュメント URL（開催形式により選択）

#### オプション 1: ローカルネットワーク共有（オンサイト開催向け）

##### 適用シーン
同じ WiFi/ネットワーク内で開催（オフィス、会議室など）

```
http://【講師の IP アドレス】:8001  # 例: http://10.0.1.5:8001
```

##### メリット
- Code Engine のデプロイ不要
- セットアップが簡単（`./start-all.sh`のみ）
- ネットワーク内で高速アクセス

##### 制約
- 同じネットワーク内の受講者のみアクセス可能

#### オプション 2: Code Engine（リモート/ハイブリッド開催向け）

##### 適用シーン
リモート参加者がいる、または異なるネットワークからの参加

```
https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud
```

> [!IMPORTANT]
> `xxxxx`は環境により異なります。デプロイ後の実際の URL を共有してください。

##### メリット
- インターネット経由でどこからでもアクセス可能（万能）
- ネットワーク環境に依存しない
- 複数の開催場所に対応可能

##### 制約
- 事前に Code Engine へのデプロイが必要（[deploy-docs-to-cloud.md](./deploy-docs-to-cloud.md)参照）

> [!IMPORTANT]
> **重要**
> - 受講者に共有するのは**IP アドレスとドキュメント URL**のみ
> - その他の設定（PORT、USER、PASSWORD 等）は`.env.example`に設定済み
> - TechZone 環境を再予約した場合、URL が変わるため再デプロイが必要

### 補足：その他の設定値（共有不要）

以下の設定は`.env.example`に既に設定されているため、受講者に共有する必要はありません：

```env
MILVUS_PORT=19530
MILVUS_USER=root
MILVUS_PASSWORD=Milvus
EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
EMBEDDING_DIMENSION=384
COLLECTION_NAME=knowledge_base
```

---

## 📝 受講者への案内文（コピー用）

### オンサイト開催の場合

以下をコピーして、**【講師の IP アドレス】**を実際の値に置き換えて送信してください。

```text
【ベクトル検索ハンズオン 接続情報】

■ Milvus 接続情報
MILVUS_HOST=【講師の IP アドレス】  # 例: 10.0.1.5

■ ドキュメント URL
http://【講師の IP アドレス】:8001  # 例: http://10.0.1.5:8001

【セットアップ手順】
1. vector-search-builder.zip を解凍
2. IBM Bob IDE でプロジェクトフォルダを開く
3. setup/participant/.env.example を setup/participant/.env にコピー
4. setup/participant/.env を開き、MILVUS_HOST だけを上記の IP アドレスに変更
5. IBM Bob をリロード（Cmd+Shift+P → Developer: Reload Window）
6. 依存関係をインストール: pip install -r setup/participant/requirements.txt
7. 接続テスト実行: python setup/participant/test_embeddings_hf.py

【重要】
- 変更が必要なのは MILVUS_HOST のみ
- その他の設定は変更不要（既に正しい値が設定済み）
```

### リモート/ハイブリッド開催の場合

以下をコピーして、**【講師の IP アドレス】**と**【Code Engine URL】**を実際の値に置き換えて送信してください。

```text
【ベクトル検索ハンズオン 接続情報】

■ Milvus 接続情報
MILVUS_HOST=【講師の IP アドレス】  # 例: 10.0.1.5

■ ドキュメント URL
【Code Engine URL】  # 例: https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud

【セットアップ手順】
1. vector-search-builder.zip を解凍
2. IBM Bob IDE でプロジェクトフォルダを開く
3. setup/participant/.env.example を setup/participant/.env にコピー
4. setup/participant/.env を開き、MILVUS_HOST だけを上記の IP アドレスに変更
5. IBM Bob をリロード（Cmd+Shift+P → Developer: Reload Window）
6. 依存関係をインストール: pip install -r setup/participant/requirements.txt
7. 接続テスト実行: python setup/participant/test_embeddings_hf.py

【重要】
- 変更が必要なのは MILVUS_HOST のみ
- その他の設定は変更不要（既に正しい値が設定済み）
```

---

## ✅ 講師チェックリスト

### 事前準備
- [ ] コンテナランタイム起動（Docker Desktop または `colima start`）
- [ ] Milvus 環境起動（`./start-all.sh`）
- [ ] IP アドレス確認
- [ ] ドキュメントを Code Engine にデプロイ
- [ ] 接続テスト成功

### 受講者サポート
- [ ] `vector-search-builder.zip`を配布
- [ ] 接続情報（IP アドレス + ドキュメント URL）を共有
- [ ] 受講者の接続テスト実施を確認

### トラブルシューティング準備
- [ ] ファイアウォール設定確認（ポート 19530 開放）
- [ ] 受講者のネットワーク接続確認

---

## 🔧 トラブルシューティング

### 接続できない

#### 1. ファイアウォール確認
```bash
# macOS
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

#### 2. ポート確認
```bash
lsof -i :19530
```

#### 3. Docker 確認
```bash
docker ps
# milvus-standalone, vector-search-docs が Running であることを確認
```

### モデルダウンロードが遅い

初回実行時、Hugging Face からモデルをダウンロード（約 200MB）するため時間がかかります。

#### 対策
- 受講者に事前ダウンロードを促す
- 講師側で事前ダウンロードしてキャッシュを共有

---

## 📊 環境情報

### 固定設定（`.env.example`に設定済み）
- Milvus ポート: `19530`
- 認証情報: `root/Milvus`
- 埋め込みモデル: `paraphrase-multilingual-MiniLM-L12-v2` (384 次元)
- Python: `3.11.0`
- sentence-transformers: `5.5.0`

### 環境依存（毎回確認が必要）
- **講師の IP アドレス**（WiFi 切り替え、有線/無線切り替え、VPN 接続時に変わる）
- **Code Engine URL**（TechZone 環境再予約時に変わる）

### ローカル環境（講師側のみ）
- Milvus: `localhost:19530`
- ドキュメント: `http://localhost:8001`（docker-compose のポートマッピング）
  - 受講者が各自で起動する場合: `http://localhost:8000`

---

**注意**: このファイルは講師用です。受講者には配布しないでください。
