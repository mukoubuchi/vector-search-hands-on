# ベクトル検索ハンズオン 講師用ガイド

## 🚀 クイックスタート

### 1. 環境起動

```bash
cd setup/instructor
./start-all.sh
```

これにより以下が起動します：
- **Milvus環境**（etcd, MinIO, Milvus）
- **ローカルドキュメントサーバー**（http://localhost:8001）

> [!NOTE]
> **ポート8001を使用する理由**
> - docker-composeのポートマッピング（`8001:8000`）により、講師側は8001でアクセス
> - **同じネットワーク内の受講者全員が`講師のIP:8001`でドキュメントにアクセス可能**
> - ポート8000は受講者のFastAPIアプリと競合する可能性があるため、8001を使用
> - これにより、各受講者が個別にドキュメントサーバーを起動する必要がなくなります

### 2. 講師のIPアドレス確認

```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1
# 最初に表示されるIPアドレスを使用（例: 10.0.1.5）
```

### 3. ドキュメントをクラウドにデプロイ

リモート参加者用に、ドキュメントをCode Engineにデプロイします：

```bash
cd /path/to/vector-search-handson
./deploy-to-code-engine.sh
```

詳細は[deploy-docs-to-cloud.md](./deploy-docs-to-cloud.md)を参照。

---

## 📋 受講者に共有する情報

### 必須情報

```
MILVUS_HOST=【講師のIPアドレス】  # 例: 10.0.1.5
```

### ドキュメントURL（開催形式により選択）

#### オプション1: ローカルネットワーク共有（オンサイト開催向け）

**適用シーン**: 同じWiFi/ネットワーク内で開催（オフィス、会議室など）

```
http://【講師のIPアドレス】:8001  # 例: http://10.0.1.5:8001
```

**メリット**:
- Code Engineのデプロイ不要
- セットアップが簡単（`./start-all.sh`のみ）
- ネットワーク内で高速アクセス

**制約**:
- 同じネットワーク内の受講者のみアクセス可能

#### オプション2: Code Engine（リモート/ハイブリッド開催向け）

**適用シーン**: リモート参加者がいる、または異なるネットワークからの参加

```
https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud
```

> [!IMPORTANT]
> `xxxxx`は環境により異なります。デプロイ後の実際のURLを共有してください。

**メリット**:
- インターネット経由でどこからでもアクセス可能（万能）
- ネットワーク環境に依存しない
- 複数の開催場所に対応可能

**制約**:
- 事前にCode Engineへのデプロイが必要（[deploy-docs-to-cloud.md](./deploy-docs-to-cloud.md)参照）

> [!IMPORTANT]
> **重要**
> - 受講者に共有するのは**IPアドレスとドキュメントURL**のみ
> - その他の設定（PORT、USER、PASSWORD等）は`.env.example`に設定済み
> - TechZone環境を再予約した場合、URLが変わるため再デプロイが必要

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

以下をコピーして、**【講師のIPアドレス】**を実際の値に置き換えて送信してください。

```text
【ベクトル検索ハンズオン 接続情報】

■ Milvus接続情報
MILVUS_HOST=【講師のIPアドレス】  # 例: 10.0.1.5

■ ドキュメントURL
http://【講師のIPアドレス】:8001  # 例: http://10.0.1.5:8001

【セットアップ手順】
1. vector-search-builder.zipを解凍
2. IBM Bob IDEでプロジェクトフォルダを開く
3. setup/participant/.env.exampleをsetup/participant/.envにコピー
4. setup/participant/.envを開き、MILVUS_HOSTだけを上記のIPアドレスに変更
5. IBM Bobをリロード（Cmd+Shift+P → Developer: Reload Window）
6. 依存関係をインストール: pip install -r setup/participant/requirements.txt
7. 接続テスト実行: python setup/participant/test_embeddings_hf.py

【重要】
- 変更が必要なのはMILVUS_HOSTのみ
- その他の設定は変更不要（既に正しい値が設定済み）
```

### リモート/ハイブリッド開催の場合

以下をコピーして、**【講師のIPアドレス】**と**【Code Engine URL】**を実際の値に置き換えて送信してください。

```text
【ベクトル検索ハンズオン 接続情報】

■ Milvus接続情報
MILVUS_HOST=【講師のIPアドレス】  # 例: 10.0.1.5

■ ドキュメントURL
【Code Engine URL】  # 例: https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud

【セットアップ手順】
1. vector-search-builder.zipを解凍
2. IBM Bob IDEでプロジェクトフォルダを開く
3. setup/participant/.env.exampleをsetup/participant/.envにコピー
4. setup/participant/.envを開き、MILVUS_HOSTだけを上記のIPアドレスに変更
5. IBM Bobをリロード（Cmd+Shift+P → Developer: Reload Window）
6. 依存関係をインストール: pip install -r setup/participant/requirements.txt
7. 接続テスト実行: python setup/participant/test_embeddings_hf.py

【重要】
- 変更が必要なのはMILVUS_HOSTのみ
- その他の設定は変更不要（既に正しい値が設定済み）
```

---

## ✅ 講師チェックリスト

### 事前準備
- [ ] Docker Desktop起動
- [ ] Milvus環境起動（`./start-all.sh`）
- [ ] IPアドレス確認
- [ ] ドキュメントをCode Engineにデプロイ
- [ ] 接続テスト成功

### 受講者サポート
- [ ] `vector-search-builder.zip`を配布
- [ ] 接続情報（IPアドレス + ドキュメントURL）を共有
- [ ] 受講者の接続テスト実施を確認

### トラブルシューティング準備
- [ ] ファイアウォール設定確認（ポート19530開放）
- [ ] 受講者のネットワーク接続確認

---

## 🔧 トラブルシューティング

### 接続できない

**1. ファイアウォール確認**
```bash
# macOS
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

**2. ポート確認**
```bash
lsof -i :19530
```

**3. Docker確認**
```bash
docker ps
# milvus-standalone, vector-search-docsがRunningであることを確認
```

### モデルダウンロードが遅い

初回実行時、Hugging Faceからモデルをダウンロード（約200MB）するため時間がかかります。

**対策**:
- 受講者に事前ダウンロードを促す
- 講師側で事前ダウンロードしてキャッシュを共有

---

## 📊 環境情報

### 固定設定（`.env.example`に設定済み）
- Milvusポート: `19530`
- 認証情報: `root/Milvus`
- 埋め込みモデル: `paraphrase-multilingual-MiniLM-L12-v2` (384次元)
- Python: `3.11.0`
- sentence-transformers: `5.5.0`

### 環境依存（毎回確認が必要）
- **講師のIPアドレス**（WiFi切り替え、有線/無線切り替え、VPN接続時に変わる）
- **Code Engine URL**（TechZone環境再予約時に変わる）

### ローカル環境（講師側のみ）
- Milvus: `localhost:19530`
- ドキュメント: `http://localhost:8001`（docker-composeのポートマッピング）
  - 受講者が各自で起動する場合: `http://localhost:8000`

---

**注意**: このファイルは講師用です。受講者には配布しないでください。
