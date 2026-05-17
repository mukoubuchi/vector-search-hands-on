# ベクトル検索ハンズオン 接続情報（受講者配布用）

## ⚠️ 重要：IPアドレスの確認

**毎回ハンズオン開始前に、講師のIPアドレスを確認してください！**

```bash
cd setup/instructor
./start-all.sh
# 出力される「受講者に共有: http://xxx.xxx.xxx.xxx:8001」のIPアドレスを確認
```

または手動で確認：
```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1
# 最初に表示されるIPアドレスを使用
```

## 📋 接続情報

**重要**: 受講者に共有するのは**IPアドレスだけ**です！

### 受講者に共有する情報

```
MILVUS_HOST=【講師のIPアドレス】  # 例: 10.0.1.5
```

### ドキュメントURL

**ローカル参加者（同じWiFi/ネットワーク）**:
```
http://【講師のIPアドレス】:8001  # 例: http://10.0.1.5:8001
```

**リモート参加者（異なるWiFi/ネットワーク）**:
```
https://mkdocs-docs.xxxxxxxxxx.us-south.codeengine.appdomain.cloud
```

!!! warning "リモート参加者向けURL"
    Code Engine URLは環境により異なります。
    [deploy-docs-to-cloud.md](./deploy-docs-to-cloud.md)を参照してデプロイ後、
    実際のURLを受講者に共有してください。
    
    TechZone環境を再予約した場合は、URLが変わるため再デプロイが必要です。

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

## 📝 受講者への案内テキスト

以下のテキストをコピーして受講者に送信してください。**【講師のIPアドレス】を実際のIPアドレスに置き換えてください。**

```
【ベクトル検索ハンズオン 接続情報】

■ Milvus接続情報（これだけ変更してください）
MILVUS_HOST=【講師のIPアドレス】  # 例: 10.0.1.5

■ ドキュメントURL（ローカル参加者）
http://【講師のIPアドレス】:8001  # 例: http://10.0.1.5:8001

■ ドキュメントURL（リモート参加者）
https://mkdocs-docs.xxxxxxxxxx.us-south.codeengine.appdomain.cloud
（講師から共有されたURLを使用してください）

【セットアップ手順】
1. プロジェクトフォルダに vector-search-builder.zip を配置
2. 解凍して .bob フォルダと setup フォルダを確認
3. IBM Bob IDE でプロジェクトフォルダを開く
4. setup/.env.example を setup/.env にコピー
5. setup/.env を開き、MILVUS_HOST だけを上記のIPアドレスに変更
   （その他の設定は変更不要です）
6. IBM Bob をリロード（Cmd + Shift + P → Developer: Reload Window）
7. setup/requirements.txt をインストール: pip install -r requirements.txt
8. 接続テスト実行: python setup/test_embeddings_hf.py

【重要】
- 変更が必要なのは MILVUS_HOST だけです
- その他の設定（PORT、USER、PASSWORD等）は既に正しい値が設定されています
```

---

## ✅ 講師側チェックリスト

### 事前準備
- [x] Docker Desktop起動
- [x] Milvus環境起動（./start-all.sh）
- [x] IPアドレス確認: 10.0.1.5
- [x] 接続テスト成功

### 受講者サポート
- [ ] vector-search-builder.zip を配布
- [ ] 接続情報を共有
- [ ] ドキュメントURLを案内
- [ ] 接続テストの実施を確認

### トラブルシューティング準備
- [ ] ファイアウォール設定確認
- [ ] ポート19530, 8001が開放されているか確認
- [ ] 受講者のネットワーク接続確認

---

## 🔧 トラブルシューティング

### 接続できない場合

1. **ファイアウォール確認**
   ```bash
   # macOS
   sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
   ```

2. **ポート確認**
   ```bash
   lsof -i :19530
   lsof -i :8001
   ```

3. **Docker確認**
   ```bash
   docker ps
   # milvus-standalone, vector-search-docs が Running であることを確認
   ```

### モデルダウンロードが遅い場合

初回実行時は Hugging Face からモデルをダウンロードするため時間がかかります（約200MB）。
- 受講者に事前にダウンロードを促す
- または講師側で事前にダウンロードしてキャッシュを共有

---

## 📊 環境情報

- **Milvus**: localhost:19530（講師側）
- **MkDocs**: http://localhost:8001（講師側）
- **受講者用URL**: http://【講師のIPアドレス】:8001（毎回確認必要）
- **埋め込みモデル**: paraphrase-multilingual-MiniLM-L12-v2 (384次元)
- **Python**: 3.11.0
- **sentence-transformers**: 5.5.0

### 固定される情報
- Milvusポート: 19530
- MkDocsポート: 8001
- 認証情報: root/Milvus
- 埋め込みモデル名と次元数

### 変更される可能性がある情報
- 講師のIPアドレス（ネットワーク環境による）
  - WiFi切り替え時
  - 有線/無線切り替え時
  - VPN接続時

---

**作成日**: 2026-05-17
**講師用**: このファイルは受講者には配布しないでください