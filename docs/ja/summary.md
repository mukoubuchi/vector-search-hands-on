# まとめ

## 作ったもの

1 時間ほどで、空の OpenSearch ノードから次の検索 API まで進みました。

- 商品と、その **768 次元の watsonx.ai 埋め込み**を 1 つの k-NN インデックスに保存する
- 同じ質問に **BM25**、**k-NN**、またはその両方を正規化して合成した方法で答える
- この用途のために IBM が配布している Building Block を使って、**IBM Bob** に拡張させる

## 覚えておきたいこと

| 要点 | なぜ大事か |
|:---|:---|
| 1 つのインデックスに 2 種類の検索 | テキストフィールドと `knn_vector` フィールドが同じドキュメントにあることが、ハイブリッド検索を成り立たせている |
| 次元数は自分で決めるものではない | 埋め込みモデルが決める。モデルを変えたらインデックスを作り直す |
| 合成する前に正規化する | BM25 には上限が無く、k-NN の類似度には上限がある。そのまま足すと大きい側が勝ってしまう |
| どちらのモードも「上位互換」ではない | 語の一致にはキーワード、説明された意図にはベクトル。実運用ではたいてい両方が要る |

## watsonx.data へ持っていくとき

ハンズオンのクラスターは、誰かのノート PC の上のコンテナです。IBM watsonx.data は同じ k-NN プラグインを備えたマネージドの OpenSearch を提供します。参加者スクリプトは接続先がどちらかを前提にしていません。ホスト、ポート、ユーザー、パスワード、TLS の設定はすべて `setup/participant/.env` から読み、変数名は上流の Building Block の取り込みアセットと同じです。

```bash
OPENSEARCH_HOST=your-cluster.databases.appdomain.cloud
OPENSEARCH_PORT=30628
OPENSEARCH_USER=ibm_cloud_user
OPENSEARCH_PASSWORD=...
OPENSEARCH_USE_SSL=true
OPENSEARCH_VERIFY_CERTS=true
```

!!! note "ここでは検証していません"

    このハンズオンは、実際の watsonx.data OpenSearch クラスターに対しては実行していません。上に書いたのはコードの作りの話であって（コンテナに固有の記述はありません）、検証済みの移行手順ではありません。お客様に「設定を差し替えるだけ」と伝える前に、クラスターを用意して試してください。

このキットの外側で本番に必要になるもの: IBM Cloud Object Storage からのドキュメント取り込み、チャンク分割、API の前段に置く認証、インデックスのライフサイクル管理、そして RAG を作るなら検索の後段の生成です。Building Block のワークフローはこれらの工程も扱っています。

## 既存の DSCE アセットとの違い

実際に動かしたあとなので、もう一度書いておきます。

- **デモではなくキットです**。リポジトリ 1 つ、コンテナ 1 つ、資格情報 1 組で、誰でも再現できます。
- **Building Block そのものが主役です**。動かしたのは IBM が配布しているモードとスキルであって、書き換えた別物ではありません。
- **比較が学びの中身です**。同じインデックス・同じ質問に対するキーワード・ベクトル・ハイブリッド。
- **役に立つ最小の構成です**。検索の層だけに絞ったので、部品が最後まで見えていました。

Orbital Suppliers、NexusIQ、Maximo Knowledge Hub といったアセットは、特定の課題に対する完成した解を見せます。こちらは仕組みを見せ、そのまま手渡します。

## 片付け

自分のインデックスを削除します（共有クラスターです）。

```bash
curl -sk -u "admin:$OPENSEARCH_PASSWORD" -X DELETE \
  "https://$OPENSEARCH_HOST:$OPENSEARCH_PORT/$INDEX_NAME"
```

デモアプリケーションは ++ctrl+c++ で停止します。

自分でクラスターを起動した場合は次を実行します。

```bash
cd setup/instructor
./stop-all.sh
```

## 次に読むもの

- Building Block の出典: [ibm-self-serve-assets/building-blocks](https://github.com/ibm-self-serve-assets/building-blocks)
- [OpenSearch k-NN のドキュメント](https://docs.opensearch.org/latest/vector-search/)
- [watsonx.ai がサポートする埋め込みモデル](https://www.ibm.com/docs/en/watsonx/saas?topic=models-supported-embedding)

ご参加ありがとうございました。
