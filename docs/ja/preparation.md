# 事前準備

準備は 15 分です。キットを展開し、Python 環境を作り、`.env` を埋め、IBM Bob に Building Block を読み込ませます。

## 必要なもの

- [ ] **IBM Bob IDE 2.1.0** がインストールされていること
- [ ] **Python 3.11 〜 3.14**（`python --version` で確認）
- [ ] 講師から配布された参加者パッケージ（`opensearch-vector-search-ja.zip`）
- [ ] 講師から共有された OpenSearch の接続情報（ホスト、ポート、パスワード）
- [ ] **IBM Cloud の API キー**と **watsonx.ai のプロジェクト ID**

!!! warning "Python のバージョン"

    watsonx.ai のクライアント（`ibm-watsonx-ai`）は Python 3.11 以上を必要とし、3.15 にはまだ対応していません。3.10 では、パッケージが見つからないというエラーではなく、バージョンが合わないというエラーで install に失敗します。

!!! info "扱うのは 1 製品だけです"

    以下の手順はすべて **IBM Bob IDE** のバージョン **2.1.0** に対するものです。IBM は **Bob shell** というコマンドライン版も出していますが、別製品でリリース系列もバージョン番号も異なり、このハンズオンでは扱いません。

## Step 1: 参加者パッケージを展開する

作業用フォルダーを作り、その中に zip を置いて展開します。

=== ":fontawesome-brands-apple: Mac"

    ```bash
    mkdir -p ~/vector-search-hands-on
    cd ~/vector-search-hands-on
    unzip ~/Downloads/opensearch-vector-search-ja.zip
    ```

=== ":fontawesome-brands-windows: Windows"

    ```powershell
    mkdir $HOME\vector-search-hands-on
    cd $HOME\vector-search-hands-on
    Expand-Archive $HOME\Downloads\opensearch-vector-search-ja.zip -DestinationPath .
    ```

2 つのディレクトリができます。

```console
.bob/                                  ← Building Block: モード・ルール・スキル
  custom_modes.yaml
  rules-opensearch-builder/
  skills/opensearch-vector-search/
setup/participant/                     ← 実行するスクリプト
  app.py  common.py  index_mapping.py  insert_sample_data.py
  requirements.txt  sample_products*.py  test_connection.py
  .env.example
```

フォルダーの直下で展開することが、そのまま Building Block の導入になります。IBM Bob は開いているフォルダーの `.bob/custom_modes.yaml` を読むので、ファイルを置いた時点でモードが入ります。

## Step 2: Python 環境を作る

=== ":fontawesome-brands-apple: Mac"

    ```bash
    cd setup/participant
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```

=== ":fontawesome-brands-windows: Windows"

    ```powershell
    cd setup\participant
    python -m venv venv
    venv\Scripts\activate
    pip install -r requirements.txt
    ```

ダウンロード量は約 240 MB、所要時間は 2 分ほどです。実行時に追加のダウンロードは起きません。埋め込みモデルは手元ではなく watsonx.ai で動きます。

## Step 3: `.env` を埋める

```bash
cp .env.example .env
```

`.env` を開き、プレースホルダーをすべて置き換えます。

### OpenSearch（講師から）

```bash
OPENSEARCH_HOST=192.168.1.100          # 講師から共有されたアドレス
OPENSEARCH_PORT=9200
OPENSEARCH_USER=admin
OPENSEARCH_PASSWORD=...                # 講師から配布されたパスワード
OPENSEARCH_USE_SSL=true
OPENSEARCH_VERIFY_CERTS=false          # ハンズオン環境は自己署名証明書のため
```

### watsonx.ai（自分の資格情報）

```bash
IBM_API_KEY=...                        # IBM Cloud → 管理 → アクセス（IAM）→ API キー
WATSONX_URL=https://us-south.ml.cloud.ibm.com
WATSONX_PROJECT_ID=...                 # watsonx.ai のプロジェクト → 管理 → 一般 → プロジェクト ID
EMBEDDING_MODEL_ID=ibm/granite-embedding-278m-multilingual
```

講師から共有環境が提供される場合（予約の出力に API キーが含まれている場合など）は、自分で作らずに
その環境のキーとプロジェクトを使ってください。

### 自分のインデックス

```bash
INDEX_NAME=products_taro               # 自分だけの名前なら何でも構いません
PARTICIPANT_LANGUAGE=ja
```

!!! danger "クラスターは共有です"

    参加者全員が同じ OpenSearch ノードに書き込みます。自分のドキュメントを他の人と分けているのは `INDEX_NAME` だけです。既存のインデックスを消す前にスクリプトは確認を求めますが、ほかの人と重ならない名前を選んでください。

!!! info "`.env` はバージョン管理に入れない"

    `.env` には API キーが入ります。リポジトリでは無視される設定になっています。コミットしないでください。IBM Bob とのチャットに貼り付けるのも避けてください。

## Step 4: IBM Bob で Building Block のモードを選ぶ

展開したフォルダー（`.bob/` がある方）を **File → Open Folder…** で開きます。

### 先にフォルダーを信頼する

フォルダーは「制限モード」で開き、その旨のバナーが出ます。信頼するまで拡張機能は制限された状態で、**Bob はそもそも現れません**。Bob の項目も、パネルを開く手段もありません。

1. バナーの **［管理］** を選びます。
2. **［信頼済みフォルダー内］** の **［信頼する］** を選びます。
3. 信頼の画面を閉じます。

フォルダーを信頼した時点で **［Open Bob］** のボタンが現れます。

### モードを選ぶ

1. **［Open Bob］** をクリックして Bob のパネルを開きます。
2. チャット入力欄の下にあるモードセレクターを開きます。最初は **Agent** になっています。
3. **OpenSearch Vector Search Builder** を選びます。

![OpenSearch Vector Search Builder が並ぶ Bob のモードセレクター](images/preparation-mode-selector-ja.png)

並ぶモードは環境によって異なります。その PC に入っているモードがすべて出るためです。**OpenSearch Vector Search Builder** が含まれていれば問題ありません。それがキットで入ってきたモードです。見当たらない場合は、開いているフォルダーが `.bob/` のある場所ではありません。

選ぶと、チャット入力欄の下の表示が **Agent** からモード名に変わり、以降 Bob は Building Block のルールに沿って答えます。

## Step 5: すべてつながったことを確認する

```bash
python test_connection.py
```

k-NN プラグインの行とベクトルの次元数が出れば準備完了です。

```console
✓ OpenSearch に接続できました (バージョン 3.8.0)
✓ k-NN プラグインが利用できます (opensearch-knn)
✓ 埋め込みベクトルを生成しました: ibm/granite-embedding-278m-multilingual
✓ ベクトルの次元数: 768
```

## Building Block の中身

`.bob/` 配下はすべて IBM の Building Blocks リポジトリのもので、1 か所の例外を除いて無改変で同梱しています。

| 項目 | 出典 |
|:---|:---|
| リポジトリ | [ibm-self-serve-assets/building-blocks](https://github.com/ibm-self-serve-assets/building-blocks) |
| コミット | `4a2ee334bf0acb4a798dc197e6f63bde99b9a0d6` |
| モードの zip | `data/pipelines/rag/bob-modes/base-modes/opensearch-builder.zip`（blob `efa9473d0146246c08a3ef9351f882b0b7a58e02`） |
| スキルの zip | `data/pipelines/rag/bob-skills/opensearch-vector-search.zip`（blob `916e1f974f3a420006f76335bff14e5c3d64c9ae`） |

- `.bob/custom_modes.yaml`: **OpenSearch Vector Search Builder** のペルソナ（slug は `opensearch-builder`）
- `.bob/rules-opensearch-builder/1_opensearch_vector_workflow.xml`: クラスターの設定、インデックス作成、取り込み、ハイブリッド検索の手順
- `.bob/rules-opensearch-builder/2_best_practices.xml`: ペルソナが従う実践
- `.bob/skills/opensearch-vector-search/SKILL.md`: 埋め込みモデルと次元数を定め、存在しないエンドポイントを作り出さないことを求めるスキル

### 変更した 1 行

上流は、モードの名前を YAML のブロックスカラーとして書き、その指示子と同じ行に内容を続けています。

```yaml
    name: >- OpenSearch Vector Search Builder
```

ブロックスカラーの指示子は行末に置く必要があるため、このファイルは YAML として不正です。PyYAML、Ruby の Psych、npm の `yaml`、`js-yaml` の 4 実装がいずれも 3 行目で拒否します。上流のままのファイルを IBM Bob で試してはいないので、Bob のパーサーがこれをどう扱うかは分かりません。そこで、その点に左右されずにモードが読み込まれるよう、同梱している版は素直なスカラーにしてあります。

```yaml
    name: OpenSearch Vector Search Builder
```

差分はこの 1 行だけです。`lib/check_upstream_building_blocks.sh` が、固定したコミットから 2 つの zip を取り直し、blob の SHA を照合し、この 1 行を当てたうえで、同梱物と diff します。CI がビルドのたびに実行します。

[次へ →](part1.md){ .workshop-next }
