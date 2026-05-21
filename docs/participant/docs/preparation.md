# 事前準備

ハンズオンをスムーズに進めるために、以下の準備を完了してください。

## 前提条件

!!! info "前提条件"
    IBM Bobが既にインストールされ、使用できる状況を前提としています。

## 必要なもの

### 1. Vector Search Builder モード

Vector Search Builderは、ベクトル検索機能を簡単に構築できるIBM Bobの専用モードです。

#### ステップ1: プロジェクトフォルダを作成

デスクトップに新しいフォルダを作成します。

- **フォルダ名**: `vector-search-handson`
- **場所**: デスクトップ推奨

#### ステップ2: Vector Search Builderをインストール

1. 配布された`vector-search-builder.zip`をプロジェクトフォルダにコピー
2. zipファイルを解凍

    === ":fontawesome-brands-windows: Windows"
        右クリック → 「すべて展開」
    
    === ":fontawesome-brands-apple: Mac"
        ダブルクリック

3. `.bob`フォルダが作成されていることを確認

#### ステップ3: IBM Bobでプロジェクトを開く

1. IBM Bobを起動
2. ++file++ → ++open-folder++ でプロジェクトフォルダを選択
3. IBM Bobをリロード
    
    === ":fontawesome-brands-apple: Mac"
        ++cmd+shift+p++ → 「Reload Window」
    
    === ":fontawesome-brands-windows: Windows"
        ++ctrl+shift+p++ → 「Reload Window」

4. 画面右下の「Mode」セレクターに「Vector Search Builder」が表示されることを確認

### 2. 接続情報

#### Milvus（ベクトルデータベース）

講師から配布されたIPアドレスを設定します。

!!! example "接続情報の設定"
    
    1. `setup/participant`フォルダを開く
    2. `.env.example`を`.env`にコピー
        
        === ":fontawesome-brands-windows: Windows"
            ファイルをコピーして名前を変更
        
        === ":fontawesome-brands-apple: Mac"
            ```bash
            cd setup/participant
            cp .env.example .env
            ```

    3. `.env`ファイルを開き、`MILVUS_HOST`に講師から配布されたIPアドレスを入力
       
        ```env hl_lines="2"
        # Milvus接続情報
        MILVUS_HOST=192.168.1.100  # ← 講師から配布されたIPアドレスに変更
        
        # 以下は変更不要
        MILVUS_PORT=19530
        MILVUS_USER=root
        MILVUS_PASSWORD=Milvus
        EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
        EMBEDDING_DIMENSION=384
        COLLECTION_NAME=knowledge_base
        ```

    4. ファイルを保存（++cmd+s++ / ++ctrl+s++）
    5. IBM Bobをリロード（++cmd+shift+p++ / ++ctrl+shift+p++ → 「Reload Window」）

#### 埋め込みモデル

Hugging Face Transformersを使用します（APIキー不要、無料）。

- モデル: `paraphrase-multilingual-MiniLM-L12-v2`
- 次元数: 384
- 特徴: 多言語対応

### 3. Webブラウザ

APIテスト用にWebブラウザを使用します。

- :fontawesome-brands-chrome: Google Chrome（推奨）
- :fontawesome-brands-firefox: Mozilla Firefox
- :fontawesome-brands-edge: Microsoft Edge
- :fontawesome-brands-safari: Safari

## 準備完了チェックリスト

- [ ] IBM Bobがインストールされ、使用できる
- [ ] プロジェクトフォルダを作成した
- [ ] `vector-search-builder.zip`を解凍した
- [ ] `.bob`フォルダが存在する
- [ ] IBM Bobでプロジェクトフォルダを開いた
- [ ] 「Vector Search Builder」モードが表示される
- [ ] `setup/participant/.env`ファイルに接続情報を入力した
- [ ] Webブラウザが使用できる

## 困ったときは

??? question "Q1: Vector Search Builderモードが表示されない"
    
    **対処法**:
    
    1. `.bob`フォルダが存在するか確認
    2. IBM Bobをリロード（++cmd+shift+p++ / ++ctrl+shift+p++ → 「Reload Window」）
    3. プロジェクトフォルダを開き直す
    4. 講師に相談

??? question "Q2: 接続情報をどこに入力すればいいか分からない"
    
    **対処法**:
    
    1. プロジェクトフォルダ内の`setup/participant`フォルダを開く
    2. `.env`ファイルを探す（見つからない場合は`.env.example`をコピー）
    3. 講師に画面を見せて確認してもらう

## 次のステップ

準備が完了したら、[Part 1: 環境確認とデモ](part1.md)に進みましょう！

Part 1では、実際にVector Searchがどのように動作するかを体験します。
