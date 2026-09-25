# Part 1: Vector Search を体験しよう

このパートでは、Vector Search（ベクトル検索）がどのように動作するかを実際に体験します。

## このパートのゴール

- Vector Search とは何かを理解する
- 実際に Vector Search を動かしてみる
- 「意味で検索」の便利さを体感する

## ステップ 1: Vector Search とは？

### 従来の検索の問題点

#### 例: EC サイトで商品を探す場合

**あなたの検索**: 「赤いスニーカー」

**従来の検索結果**:

- 「赤いスニーカー」→ 見つかる
- 「赤色のランニングシューズ」→ 見つからない
- 「レッドのスポーツシューズ」→ 見つからない

**なぜ見つからない？**

- 従来の検索は「文字」を探すだけ
- 「赤い」と「赤色」は違う文字として扱われる

### Vector Search の仕組み

Vector Search は「意味」を理解して検索します。以下の図は、このハンズオンで作成するデモアプリにおいて、ユーザー入力をベクトルに変換し、Milvus で類似商品を検索する流れを説明したものです。

<div class="vector-flow" role="group" aria-label="Vector Search の流れ" tabindex="0">
  <div class="admonition vector-flow-step" style="--flow-tint: #f0f1f9">
    <p class="admonition-title">ステップ 1: テキスト入力</p>
    <p class="vector-flow-content"><strong>ユーザー入力</strong><br/>「赤いスニーカー」</p>
  </div>
  <div class="vector-flow-edge"><span>テキスト</span><span aria-hidden="true">⟶</span></div>
  <div class="admonition vector-flow-step" style="--flow-tint: #f8f5f1">
    <p class="admonition-title">ステップ 2: ベクトル変換</p>
    <p class="vector-flow-content"><strong>埋め込みモデル</strong><br/>テキスト → ベクトル</p>
  </div>
  <div class="vector-flow-edge"><span>変換</span><span aria-hidden="true">⟶</span></div>
  <div class="admonition vector-flow-step" style="--flow-tint: #f6f4f7">
    <p class="admonition-title">ステップ 3: ベクトル表現</p>
    <p class="vector-flow-content"><strong>ベクトル（384 次元）</strong><br/>[0.2, 0.8, 0.1, 0.5, ...]</p>
  </div>
  <div class="vector-flow-edge"><span>検索クエリ</span><span aria-hidden="true">⟶</span></div>
  <div class="admonition vector-flow-step" style="--flow-tint: #f5f9f7">
    <p class="admonition-title">ステップ 4: 類似検索</p>
    <p class="vector-flow-content"><strong>Milvus</strong><br/>ベクトル DB</p>
  </div>
  <div class="vector-flow-edge"><span>類似ベクトル</span><span aria-hidden="true">⟶</span></div>
  <div class="admonition vector-flow-step" style="--flow-tint: #f8f5f6">
    <p class="admonition-title">ステップ 5: 検索結果</p>
    <p class="vector-flow-content"><strong>類似商品リスト</strong><br/>・赤いランニングシューズ（0.5621）<br/>・赤いスポーツシューズ（0.5474）<br/>・赤いトレーニングシューズ（0.4517）</p>
  </div>
</div>

!!! info "ポイント"
    - 意味が似ていると、ベクトルも似る
    - コンピュータは数値の類似度を高速計算

**あなたの検索**: 「赤いスニーカー」

**Vector Search の結果**:

- 「赤いスニーカー」→ 見つかる
- 「赤色のランニングシューズ」→ 見つかる（意味が似ている）
- 「レッドのスポーツシューズ」→ 見つかる（意味が似ている）

**なぜ見つかる？**

- Vector Search は「意味」を理解する
- 「赤い」「赤色」「レッド」→ 同じ意味と理解
- 「スニーカー」「ランニングシューズ」「スポーツシューズ」→ 似た意味と理解

### Vector Search の動作

```
ステップ 1: テキストを数値に変換
「赤いスニーカー」→ [0.2, 0.8, 0.1, 0.5, ...] （ベクトル）

ステップ 2: 似た数値を探す
データベースから似た数値のパターンを検索

ステップ 3: 結果を返す
似た意味の商品を返す
```

**ポイント**:

- 「ベクトル」= 数値の配列
- 意味が似ていると、数値のパターンも似る
- コンピュータは数値の類似度を高速に計算できる

## ステップ 2: 接続テストを実行

!!! example "実践: ここから手を動かします"
    
    実際に Vector Search を動かす前に、必要なサービスに接続できるか確認します。

IBM Bob のチャット画面で以下を入力:

```text
setup/participant/venv の Python で setup/participant/test_connection.py を実行して
```

IBM Bob が接続テストのスクリプトを実行します。コマンドの実行の承認を求められたら、承認します。

??? tip "手動で実行する場合"
    ターミナルに以下を入力:
    
    ```bash
    cd setup/participant
    python test_connection.py
    ```

### 結果を確認

#### 成功の場合

```
==================================================
Milvus 接続テスト
==================================================

=== 環境変数チェック ===
✓ MILVUS_HOST: 192.168.1.100
✓ MILVUS_PORT: 19530
✓ MILVUS_USER: root
✓ MILVUS_PASSWORD: ********

=== Milvus 接続テスト ===
接続先: 192.168.1.100:19530
認証: ユーザー名/パスワード認証
✓ Milvus に接続できました
✓ 既存のコレクション数: 0

==================================================
テスト結果
==================================================
Milvus 接続: ✓ 成功

✓ Milvus 接続テストに成功しました
  次のステップ: ベクトル用コレクションを作成
```

接続テスト、サンプルデータ投入スクリプト、デモアプリケーションは同じ `.env` の接続設定を使用します。このテストが成功していれば、以降の手順でも同じ Milvus のホスト、ポート、認証方式が使われます。

#### 失敗の場合

```
✗ Milvus 接続エラー: Connection refused
```

**対処法**:

1. **`.env`** ファイルを確認
    - `MILVUS_HOST` に講師から配布された IP アドレスが正しく入力されているか確認（[:material-cog: 設定方法](preparation.md#milvus_host)）
    - `MILVUS_PASSWORD` が講師から配布されたパスワードになっているか確認 — "auth check failure" などの認証エラーは、パスワードの誤りかテンプレートのままになっていることが原因です
2. インターネット接続を確認
3. その他のエラーについては、[FAQ](#faq) を参照してください

## ステップ 3: サンプルデータを投入

!!! example "実践: Milvus にサンプルデータを投入"
    
    Vector Search を体験するために、まずサンプル商品データを投入します。

IBM Bob のチャット画面で以下を入力:

```text
setup/participant/insert_sample_data.py を実行して
```

IBM Bob がスクリプトを実行し、サンプルデータを投入します。

??? tip "手動で実行する場合"
    ターミナルに以下を入力:
    
    ```bash
    # プロジェクトのルートフォルダにいる場合
    cd setup/participant
    python insert_sample_data.py
    ```

    既に `setup/participant` フォルダにいる場合は、`cd setup/participant` は不要です。

### 投入結果を確認

以下のような表示が出れば成功:

```
==================================================
✓ サンプルデータの挿入が完了しました
==================================================

コレクション名: products_taro  # .env で設定した自分専用の名前
エンティティ数: 12

デモアプリケーションを起動できます:
  venv/bin/python app.py
==================================================
```

**投入されたデータ**:

- 商品数: 12 件
- カテゴリ: スニーカー、カメラ、パソコン、バッグ
- 各商品に商品名、価格、説明、埋め込みベクトルが含まれる
- コレクション定義と検索対象フィールドはデモアプリケーションと共通化されているため、投入後すぐに検索できます

## ステップ 4: Vector Search を体験

!!! example "実践: Vector Search を動かしてみよう"
    
    サンプルデータの投入が成功したら、実際に Vector Search を体験しましょう。

### デモアプリケーションを起動 {#app-restart}

この手順はターミナルで実行します。事前準備で作成した仮想環境を有効化し、`requirements.txt` のパッケージがインストールされている状態で実行してください。

=== ":fontawesome-brands-apple: Mac"
    ```bash
    cd ~/Desktop/vector-search-builder-ja/setup/participant
    venv/bin/python app.py
    ```

=== ":fontawesome-brands-windows: Windows"
    ```cmd
    cd %USERPROFILE%\Desktop\vector-search-builder-ja\setup\participant
    venv\Scripts\python app.py
    ```

既に `setup/participant` フォルダにいる場合は、`cd ...` の行は不要です。`venv/bin/python app.py` または `venv\Scripts\python app.py` を実行しても、すぐに反応がないように見える場合があります。起動処理に少し時間がかかるため、ターミナルに実行結果が表示されるまでそのまま待ってください。

#### 起動に成功した場合

次のような表示が出れば、アプリケーションは起動しています。

```text
==================================================
✓ アプリケーションを起動しました
==================================================

検索画面: http://localhost:8002
==================================================

INFO:     Application startup complete.
```

!!! warning "注意"
    ターミナルを閉じるとアプリケーションが停止します。注意してください。

#### 起動に失敗した場合

`ModuleNotFoundError: No module named 'fastapi'` が表示された場合は、仮想環境に必要なパッケージがインストールされていません。必要なパッケージをインストールしてから（[:material-package-variant-closed: インストール方法](preparation.md#install-packages)）、もう一度デモアプリケーションを起動してください（[:material-play-circle: 起動方法](#app-restart)）。

### 起動を確認

Web ブラウザで以下の URL にアクセスして、検索画面（**商品検索デモ**）が表示されることを確認:

```text
http://localhost:8002
```

!!! success "起動成功"
    
    検索画面が表示されれば、アプリケーションは正常に起動しています。

### 検索を試してみる

#### ステップ 1: 検索語を入力

画面上部の検索欄に以下を入力:

```text
赤いスニーカー
```

#### ステップ 2: 「検索」をクリック

**検索**ボタンをクリック（または ++enter++ を押す）

#### ステップ 3: 結果を確認

意味の近い商品が、似ている順にカードで表示されます。上位 3 件は赤い靴 3 種で、赤いランニングシューズ（0.5621）、赤いスポーツシューズ（0.5474）、赤いトレーニングシューズ（0.4517）の順です。その次が青いカジュアルスニーカーです。スコアは環境やモデルのバージョンによって多少変わります。

![検索画面で「赤いスニーカー」を検索した結果](images/search-screen-results-ja.png)

**結果の見方**:

- **順位**（`#1`、`#2`、…）: 似ている順
- **カテゴリ**（`category`）: 商品のカテゴリ
- **商品名**（`product_name`）: 商品名
- **価格**（`price`）: 価格（円）
- **説明**（`description`）: 説明
- **類似度**（`similarity_score`）: 類似度（0.0〜1.0、高いほど似ている）。バーの色は 0.7 以上が緑、0.4〜0.7 が青、0.4 未満が灰色

**表示件数**（`top_k`）で、返す商品の件数を変えられます（デフォルト: 5）。価格フィルターは、Part 2 で追加するまで使えません。

??? note "任意: API の生のレスポンスを見る"
    検索画面は、入力した検索語をデモアプリケーションの **`/search`** API に送り、返ってきた JSON を表示しています。生の JSON を見たい場合は、FastAPI が生成する API のページである Swagger UI（**`http://localhost:8002/docs`**）を開きます。**`/search`** を開いて「Try it out」をクリックし、以下のリクエストボディを入力して「Execute」をクリックします。Swagger UI はファイルをインターネットから読み込みますが、検索画面はオフラインでも動きます。

    ```json
    {
      "query": "赤いスニーカー",
      "top_k": 3
    }
    ```

    レスポンス（スコアは多少変わります）:

    ```json
    {
      "results": [
        {
          "product_name": "赤いランニングシューズ",
          "similarity_score": 0.5621,
          "price": 8900,
          "category": "スニーカー",
          "description": "軽量で通気性のよいランニングシューズ。"
        },
        {
          "product_name": "赤いスポーツシューズ",
          "similarity_score": 0.5474,
          "price": 7500,
          "category": "スニーカー",
          "description": "普段使いにもスポーツにも使える万能シューズ。クッション性に優れています。"
        },
        {
          "product_name": "赤いトレーニングシューズ",
          "similarity_score": 0.4517,
          "price": 9800,
          "category": "スニーカー",
          "description": "ジムでのトレーニングに最適。安定感とグリップ力が特徴です。"
        }
      ]
    }
    ```

### 色々な検索を試してみる

以下の検索も試してみましょう。入力するか、検索欄の下にある例をクリックします。

#### 例 1: 初心者向けの商品を探す

```text
初心者向けのカメラ
```

#### 例 2: ビジネス向けの商品を探す

```text
ビジネス向けのノートパソコン
```

#### 例 3: 高性能な商品を探す

```text
高性能なゲーミング PC
```

### Vector Search の凄さを実感

色々な検索を試すと、以下のことに気づくはずです:

**気づき 1: 言い方が違っても見つかる**

- 「初心者向け」→「入門用」「初心者におすすめ」も見つかる

**気づき 2: 類似度スコアが便利**

- スコアが高い = より似ている
- 結果の信頼度が分かる

**気づき 3: 説明文も考慮される**

- 商品名だけでなく、説明文の意味も理解
- 「ビジネス向けのノートパソコン」で、説明文に「ノートパソコンが入る」とある軽量ビジネスバッグも見つかる

## Part 1 完了チェック

- [ ] Vector Search とは何かを理解した
- [ ] 従来の検索との違いを理解した
- [ ] 接続テストが成功した
- [ ] サンプルデータを投入できた
- [ ] デモアプリケーションを起動できた
- [ ] 検索画面を開けた
- [ ] 検索を実行できた
- [ ] 色々な検索を試した

## FAQ

??? question "検索画面が開けない"

    対処法:
    
    1. アプリケーションが起動しているか確認
    2. URL が正しいか確認（**`http://localhost:8002`**）
    3. ブラウザを変えてみる

??? question "検索結果が 0 件"

    対処法:
    
    1. サンプルデータが投入されているか確認
    2. 検索クエリを変えてみる

??? question "類似度スコアが極端に低い"

    対処法:

    1. 最新の `insert_sample_data.py` でサンプルデータを再投入
    2. デモアプリケーションを手動で再起動
        1. アプリケーションを起動しているターミナルで ++ctrl+c++ （停止）
        2. **`python app.py`** を実行（[:material-play-circle: 起動方法](#app-restart)）
    3. 検索画面で再度検索

    既存データが古い検索メトリックで作成されている場合、スコアが 0.06 のように低く表示されることがあります。

[次へ →](part2.md){ .workshop-next }
