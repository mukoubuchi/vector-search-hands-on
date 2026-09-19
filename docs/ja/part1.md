# Part 1: ベクトル検索を体験する

この Part では、小さな商品カタログを OpenSearch に取り込み、同じ質問を 3 通りの方法で投げます。

## この Part の目標

- 埋め込みベクトルを実際に生成して、それが何かを確かめる
- 1 つのインデックスに対してキーワード・ベクトル・ハイブリッドの検索を実行する
- それぞれが失敗する質問を見つける

## Step 1: 接続テストを実行する

このハンズオンは 2 つのサービスと通信します。商品を保存する OpenSearch と、テキストをベクトルに変換する watsonx.ai です。先に進む前に両方を確認します。

```bash
cd setup/participant
python test_connection.py
```

### 結果を確認する

```text
==================================================
OpenSearch と watsonx.ai の接続テスト
==================================================

=== 環境変数チェック ===
✓ OPENSEARCH_HOST: ...
✓ OPENSEARCH_PASSWORD: ********
✓ IBM_API_KEY: ********

=== OpenSearch 接続テスト ===
✓ OpenSearch に接続できました (バージョン 3.8.0)
✓ k-NN プラグインが利用できます (opensearch-knn)
✓ クラスターの状態: green

=== watsonx.ai 埋め込みテスト ===
✓ 埋め込みベクトルを生成しました: ibm/granite-embedding-278m-multilingual
✓ ベクトルの次元数: 768
```

次の手順で効いてくるのは最後の行です。この埋め込みモデルは、どんなテキストに対しても **768 個の数値**を返します。インデックスはちょうどこの数に合わせて作る必要があります。

??? question "うまくいかないとき"

    - **OpenSearch の接続エラー**: `setup/participant/.env` の `OPENSEARCH_HOST`、`OPENSEARCH_PORT`、`OPENSEARCH_PASSWORD` が講師から共有された値と一致しているか確認してください。
    - **watsonx.ai のエラー**: `IBM_API_KEY` と `WATSONX_PROJECT_ID` を確認してください。API キーはアカウントに、プロジェクト ID はその中のプロジェクトに属します。両方が自分のものである必要があります。
    - **プレースホルダーが残っている**: `<...>` のままの値はスクリプトが受け付けず、どの変数かをエラーに出します。

## Step 2: インデックスを作って商品を投入する

```bash
python insert_sample_data.py
```

このスクリプトは、watsonx.ai に 1 回だけ埋め込みを求め、その長さでインデックスを作り、サンプル商品 12 件を埋め込んで一括投入します。

### 作られるもの

```json
{
  "product_name": { "type": "text" },
  "description":  { "type": "text" },
  "category":     { "type": "keyword" },
  "price":        { "type": "integer" },
  "embedding":    {
    "type": "knn_vector",
    "dimension": 768,
    "space_type": "cosinesimil",
    "method": { "name": "hnsw", "engine": "faiss",
                "parameters": { "ef_construction": 128, "m": 24 } }
  }
}
```

注目したい点が 2 つあります。

- **同じドキュメントが 2 種類のデータを持っています**。`product_name` と `description` は BM25 のために解析され、`embedding` はベクトルを保持します。1 つのインデックスが両方の検索に答えられることが、ハイブリッド検索が成り立つ理由です。
- **`dimension` はモデルに合わせます**。768 は `ibm/granite-embedding-278m-multilingual` が返す数です。`EMBEDDING_MODEL_ID` を変えたらインデックスを作り直す必要があります。

??? note "HNSW について簡単に"

    問い合わせベクトルを全件と比較すれば正確ですが遅くなります。HNSW はベクトルの上に辿りやすいグラフを作り、その上を歩いて近いものを探します。再現率を少し犠牲にして速度を大きく得る仕組みです。`m` は各ノードが保持する近傍の数、`ef_construction` は構築時にどれだけ探索するかです。Building Block のワークフローは `ef_construction=128, m=24` を釣り合いの取れた出発点として勧めており、キットもその値を使っています。

## Step 3: デモアプリケーションを起動する

```bash
python app.py
```

対話的な API ドキュメントが [http://localhost:8002/docs](http://localhost:8002/docs) で開きます。以下の検索はターミナルの代わりにこの画面からも実行できます。

## Step 4: 同じ質問を 3 通りで投げる

`/search` は `mode` を受け取ります。各質問を 3 つのモードで実行し、順位の動きを見てください。

```bash
curl -s -X POST http://localhost:8002/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "赤いスニーカー", "mode": "keyword", "top_k": 3}'
```

`"mode"` を `"vector"`、`"hybrid"` に変えて同じように実行します。

### 4 つの質問

最初の 2 つはカタログに出てくる語を使い、あとの 2 つは使いません。

| # | 質問 | 何を試しているか |
|:--|:---|:---|
| 1 | `赤いスニーカー` | データに出てくる語 |
| 2 | `安いランニングシューズ` | 出てくる語に加えて、判断（「安い」）を含む語 |
| 3 | `運動するときに履くもの` | トレーニングシューズという概念。その語は 1 つも含まない |
| 4 | `旅行の思い出を残す機器` | カメラを、買い手の言い方で説明したもの |

実行しながら次の表を埋めてください。

| 質問 | `keyword` の 1 位 | `vector` の 1 位 | `hybrid` の 1 位 |
|:---|:---|:---|:---|
| 赤いスニーカー | | | |
| 安いランニングシューズ | | | |
| 運動するときに履くもの | | | |
| 旅行の思い出を残す機器 | | | |

### 応答の読み方

```json
{
  "mode": "hybrid",
  "results": [
    {
      "product_name": "...",
      "score": 0.87,
      "price": 8900,
      "category": "スニーカー",
      "description": "...",
      "keyword_score": 0.74,
      "vector_score": 1.0
    }
  ]
}
```

`hybrid` では、各結果がどちら側から来たのかが分かります。`keyword_score` と `vector_score` は、それぞれの順位付けのスコアを 0 〜 1 に直したもので、`score` はその合成値です。`keyword_score` が `0.0` の結果は、ベクトル側だけが見つけたものです。語は一度も一致していません。

!!! info "スコアを正規化する理由"

    BM25 のスコアには上限が無く、コーパスによって大きさが変わります。k-NN の類似度はまた別の範囲に収まります。そのまま足すと、たまたま数値が大きい側が順位を決めてしまいます。先に各リストを min-max で 0 〜 1 に直すのが、Building Block のワークフローが「スコア正規化」と呼んでいる手順です。

### 重みを変えてみる

`vector_weight` は、`hybrid` でベクトル側をどれだけ重視するかです。既定は `0.5` です。

```bash
curl -s -X POST http://localhost:8002/search \
  -H 'Content-Type: application/json' \
  -d '{"query": "運動するときに履くもの", "mode": "hybrid", "vector_weight": 0.9}'
```

同じ質問を `0.1` と `0.9` で実行してみてください。`0.1` ではキーワード検索に近づき、`0.9` ではベクトル検索に近づきます。

## Step 5: いま見たこと

- **質問 1 と 2** は、キーワード検索が得意とする場合です。ベクトル検索も同じ商品を見つけることが多く、順位だけが変わることがあります。
- **質問 3 と 4** は、カタログと共通する語がありません。キーワード検索には照合する相手がなく、ベクトル側が結果を支えます。
- **ハイブリッド**は両方の性質を残します。実運用の検索エンジンがどちらか一方を選ばないのは、このためです。

!!! success "チェックポイント"

    語による検索と意味による検索の両方に答えるインデックスが 1 つでき、どちらの側がその結果を出したのかも分かるようになりました。Part 2 では、次の変更を IBM Bob に任せます。

[次へ →](part2.md){ .workshop-next }
