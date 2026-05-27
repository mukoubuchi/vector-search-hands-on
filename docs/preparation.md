# 事前準備

ハンズオンをスムーズに進めるために、以下の準備を完了してください。

## 前提条件

!!! info "前提条件"
    IBM Bob が既にインストールされ、使用できる状況を前提としています（プラン：IBM Internal Version）。

## 必要なもの

### 1. Vector Search Builder モード

**Vector Search Builder** は、IBM Building Blocks の一部として提供される、ベクトル検索機能を簡単に構築できる IBM Bob のカスタムモードです。

#### Building Blocks としての Vector Search Builder

**提供元**: IBM Build Engineering Team

**含まれる機能**:

- Milvus データベースのセットアップと管理
- 埋め込みモデルの統合（watsonx、HuggingFace、ローカル）
- データ取り込みパイプラインの構築
- ベクトル検索の最適化
- IBM Cloud Object Storage との連携

**IBM Bob との連携**:

- Vector Search に特化した AI アシスタント
- Building Blocks の機能を理解した上でコード生成
- ベストプラクティスに基づいた実装支援

!!! info "Building Blocks の利点"
    **通常の開発**: Milvus のドキュメントを読み、SDK を学習し、コードを一から書く（数日）

    **Building Blocks 使用**: Vector Search Builder をインストールし、IBM Bob に自然言語で指示（数分）

    **このハンズオンでの工夫**: 講師が Milvus 環境を提供、受講者は IBM Bob のみで参加（環境構築不要）

#### ステップ 1: プロジェクトフォルダを作成

デスクトップに新しいフォルダを作成します。

- **フォルダ名**: **`vector-search-handson`**
- **場所**: デスクトップ推奨

#### ステップ 2: Vector Search Builder（Building Block）をインストール

**`vector-search-builder.zip`** には、以下が含まれています：

**Building Blocks**:

- **`.bob/modes/`**: Vector Search Builder モード定義（IBM 提供）

**このハンズオンで追加したもの**:

- **`setup/instructor/`**: 講師用 Milvus 環境（Docker Compose）
- **`setup/participant/`**: 受講者用接続テストスクリプト
- **`.env.example`**: 接続情報設定テンプレート
- **`docs/`**: ハンズオン用ドキュメント

1. 配布された **`vector-search-builder.zip`** をプロジェクトフォルダにコピー

2. zip ファイルを解凍

    === ":fontawesome-brands-apple: Mac"
        ダブルクリック

    === ":fontawesome-brands-windows: Windows"
        右クリック → 「すべて展開」

        ※ ダブルクリックで開いただけでは展開されないため、「すべて展開」を実行してください

3. **`.bob`** フォルダが作成されていることを確認

!!! tip "Building Blocks のインストール"
    通常、Building Blocks は以下の方法でインストールします：

    - **グローバルインストール**: `~/.config/IBM Bob/User/globalStorage/ibm.bob-code/modes/`
    - **プロジェクトローカル**: `.bob/modes/`（このハンズオンの方法）

    このハンズオンでは、プロジェクトローカルにインストールすることで、環境を汚さず、簡単にクリーンアップできます。

#### ステップ 3: IBM Bob でプロジェクトを開く

1. IBM Bob を起動

2. <kbd>File</kbd> → <kbd>Open Folder</kbd> でプロジェクトフォルダを選択

3. IBM Bob をリロード

    === ":fontawesome-brands-apple: Mac"
        <kbd>Cmd</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> → 「Reload Window」

    === ":fontawesome-brands-windows: Windows"
        <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd> → 「Reload Window」

4. 画面右下の「Mode」セレクターに「Vector Search Builder」が表示されることを確認

!!! success "Building Blocks モードの認識"
    IBM Bob が `.bob/modes/` フォルダを検出し、Vector Search Builder モードを自動的に読み込みます。

    このモードにより、IBM Bob は以下を理解します：

    - Milvus データベースの操作方法
    - ベクトル検索のベストプラクティス
    - 埋め込みモデルの統合方法
    - Building Blocks の機能と制約

### 2. 接続情報

#### Milvus（ベクトルデータベース）

講師から配布された IP アドレスを設定します。

!!! example "接続情報の設定"

    1. **`setup/participant`** フォルダを開く
    2. **`.env.example`** をコピーし、コピーしたファイル名を **`.env`** に変更
        
        === ":fontawesome-brands-apple: Mac"
            ```bash
            cd setup/participant
            cp .env.example .env
            ```

        === ":fontawesome-brands-windows: Windows"
            ```bash
            cd setup/participant
            copy .env.example .env
            ```

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

#### 埋め込みモデル（テキストを数値に変換する AI）

Hugging Face Transformers を使用します（API キー不要、無料）。

**埋め込みモデルとは**: テキストの「意味」を数値（ベクトル）に変換する AI モデルです。

- モデル: **`paraphrase-multilingual-MiniLM-L12-v2`**
- 次元数: **384**（384 個の数値で意味を表現）
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
