# 事前準備

ハンズオンをスムーズに進めるために、以下の準備を完了してください。

## 前提条件

!!! info "前提条件"
    IBM Bob が既にインストールされ、使用できる状況を前提としています。

## 必要なもの

### 1. Vector Search Builder モード

Vector Search Builder は、ベクトル検索機能を簡単に構築できる IBM Bob の専用モードです。

#### ステップ 1: プロジェクトフォルダを作成

デスクトップに新しいフォルダを作成します。

- **フォルダ名**: **`vector-search-handson`**
- **場所**: デスクトップ推奨

#### ステップ 2: Vector Search Builder をインストール

1. 配布された **`vector-search-builder.zip`** をプロジェクトフォルダにコピー

2. zip ファイルを解凍

    === ":fontawesome-brands-apple: Mac"
        ダブルクリック

    === ":fontawesome-brands-windows: Windows"
        右クリック → 「すべて展開」

3. **`.bob`** フォルダが作成されていることを確認

#### ステップ 3: IBM Bob でプロジェクトを開く

1. IBM Bob を起動

2. ++file++ → ++open-folder++ でプロジェクトフォルダを選択

3. IBM Bob をリロード

    === ":fontawesome-brands-apple: Mac"
        ++cmd+shift+p++ → 「Reload Window」

    === ":fontawesome-brands-windows: Windows"
        ++ctrl+shift+p++ → 「Reload Window」

4. 画面右下の「Mode」セレクターに「Vector Search Builder」が表示されることを確認

### 2. 接続情報

#### Milvus（ベクトルデータベース）

講師から配布された IP アドレスを設定します。

!!! example "接続情報の設定"

    1. **`setup/participant`** フォルダを開く
    2. **`.env.example`** を **`.env`** にコピー
        
        === ":fontawesome-brands-apple: Mac"
            ```bash
            cd setup/participant
            cp .env.example .env
            ```

        === ":fontawesome-brands-windows: Windows"
            ファイルをコピーして名前を変更

    3. **`.env`** ファイルを開き、**`MILVUS_HOST`** に講師から配布された IP アドレスを入力
       
        ```properties
        # Milvus 接続情報
        MILVUS_HOST=192.168.1.100  # ← 講師から配布された IP アドレスに変更
        
        # 以下は変更不要
        MILVUS_PORT=19530
        MILVUS_USER=root
        MILVUS_PASSWORD=Milvus
        EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
        EMBEDDING_DIMENSION=384
        COLLECTION_NAME=knowledge_base
        ```

    4. ファイルを保存（++cmd+s++ / ++ctrl+s++）
    5. IBM Bob をリロード（++cmd+shift+p++ / ++ctrl+shift+p++ → 「Reload Window」）

#### 埋め込みモデル

Hugging Face Transformers を使用します（API キー不要、無料）。

- モデル: **`paraphrase-multilingual-MiniLM-L12-v2`**
- 次元数: **384**
- 特徴: 多言語対応

### 3. Web ブラウザ

API テスト用に Web ブラウザを使用します。

- :fontawesome-brands-chrome: Google Chrome（推奨）
- :fontawesome-brands-firefox: Mozilla Firefox
- :fontawesome-brands-edge: Microsoft Edge
- :fontawesome-brands-safari: Safari

## 準備完了チェックリスト

- [ ] IBM Bob がインストールされ、使用できる
- [ ] プロジェクトフォルダを作成した
- [ ] **`vector-search-builder.zip`** を解凍した
- [ ] **`.bob`** フォルダが存在する
- [ ] IBM Bob でプロジェクトフォルダを開いた
- [ ] 「Vector Search Builder」モードが表示される
- [ ] **`setup/participant/.env`** ファイルに接続情報を入力した
- [ ] Web ブラウザが使用できる

## 困ったときは

??? question "Q1: Vector Search Builder モードが表示されない"

    **対処法**:
    
    1. **`.bob`** フォルダが存在するか確認
    2. IBM Bob をリロード（**Cmd+Shift+P** / **Ctrl+Shift+P** → 「Reload Window」）
    3. プロジェクトフォルダを開き直す
    4. 講師に相談

??? question "Q2: 接続情報をどこに入力すればいいか分からない"

    **対処法**:
    
    1. プロジェクトフォルダ内の **`setup/participant`** フォルダを開く
    2. **`.env`** ファイルを探す（見つからない場合は **`.env.example`** をコピー）
    3. 講師に画面を見せて確認してもらう

## 次のステップ

準備が完了したら、[Part 1: 環境確認とデモ](part1.md)に進みましょう！

Part 1 では、実際に Vector Search がどのように動作するかを体験します。
