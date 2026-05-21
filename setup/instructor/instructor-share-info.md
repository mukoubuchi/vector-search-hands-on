# ベクトル検索ハンズオン 接続情報（受講者配布用）

## ⚠️ 重要：IP アドレスの確認

**毎回ハンズオン開始前に、講師の IP アドレスを確認してください！**

```bash
cd setup/instructor
./start-all.sh
# 出力される「受講者に共有: http://xxx.xxx.xxx.xxx:8001」の IP アドレスを確認
```

または手動で確認：

```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1
# 最初に表示される IP アドレスを使用
```

## 📋 接続情報

**重要**: 受講者に共有するのは**IP アドレスだけ**です！

### 受講者に共有する情報

```
MILVUS_HOST=【講師の IP アドレス】  # 例: 10.0.1.5
```

### ドキュメント URL

```
https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud
```

> **注意**: **xxxxx**の部分は環境により異なります（あくまで例）。必ず講師から共有された最新の URL を使用してください。

!!! warning "Code Engine URL"
    Code Engine URL は環境により異なります。
    [deploy-docs-to-cloud.md](./deploy-docs-to-cloud.md)を参照してデプロイ後、
    実際の URL を受講者に共有してください。

    **TechZone 環境を再予約した場合は、URL が変わるため再デプロイが必要です。**

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

以下のテキストをコピーして受講者に送信してください。**【講師の IP アドレス】と【ドキュメント URL】を実際の値に置き換えてください。**

```
【ベクトル検索ハンズオン 接続情報】

■ Milvus 接続情報（これだけ変更してください）
MILVUS_HOST=【講師の IP アドレス】  # 例: 10.0.1.5

■ ドキュメント URL
【ドキュメント URL】  # 例: https://mkdocs-docs.xxxxx.us-south.codeengine.appdomain.cloud

【セットアップ手順】
1. プロジェクトフォルダに vector-search-builder.zip を配置
2. 解凍して .bob フォルダと setup フォルダを確認
3. IBM Bob IDE でプロジェクトフォルダを開く
4. setup/.env.example を setup/.env にコピー
5. setup/.env を開き、MILVUS_HOST だけを上記の IP アドレスに変更
   （その他の設定は変更不要です）
6. IBM Bob をリロード（Cmd + Shift + P → Developer: Reload Window）
7. setup/requirements.txt をインストール: pip install -r requirements.txt
8. 接続テスト実行: python setup/test_embeddings_hf.py

【重要】
- 変更が必要なのは MILVUS_HOST だけです
- その他の設定（PORT、USER、PASSWORD 等）は既に正しい値が設定されています
```

---

## ✅ 講師側チェックリスト

### 事前準備

- [x] Docker Desktop 起動
- [x] Milvus 環境起動（./start-all.sh）
- [x] IP アドレス確認: 10.0.1.5
- [x] 接続テスト成功

### 受講者サポート

- [ ] vector-search-builder.zip を配布
- [ ] 接続情報を共有
- [ ] ドキュメント URL を案内
- [ ] 接続テストの実施を確認

### トラブルシューティング準備

- [ ] ファイアウォール設定確認
- [ ] ポート 19530, 8001 が開放されているか確認
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

3. **Docker 確認**

   ```bash
   docker ps
   # milvus-standalone, vector-search-docs が Running であることを確認
   ```

### モデルダウンロードが遅い場合

初回実行時は Hugging Face からモデルをダウンロードするため時間がかかります（約 200MB）。

- 受講者に事前にダウンロードを促す
- または講師側で事前にダウンロードしてキャッシュを共有

---

## 📊 環境情報

- **Milvus**: localhost:19530（講師側）
- **MkDocs**: <http://localhost:8001（講師側）>
- **受講者用 URL**: http://【講師の IP アドレス】:8001（毎回確認必要）
- **埋め込みモデル**: paraphrase-multilingual-MiniLM-L12-v2 (384 次元)
- **Python**: 3.11.0
- **sentence-transformers**: 5.5.0

### 固定される情報

- Milvus ポート: 19530
- MkDocs ポート: 8001
- 認証情報: root/Milvus
- 埋め込みモデル名と次元数

### 変更される可能性がある情報

- 講師の IP アドレス（ネットワーク環境による）
  - WiFi 切り替え時
  - 有線/無線切り替え時
  - VPN 接続時

---

**作成日**: 2026-05-17
**講師用**: このファイルは受講者には配布しないでください
