# 事前準備

それでは、ハンズオンの準備から行っていきます。

まずは、ターミナル / コマンドプロンプトの開き方を確認してください。

!!! tip "ターミナル / コマンドプロンプトの開き方"
    
    **IBM Bob でターミナル / コマンドプロンプトを開く**:
    
    次のいずれかの方法で開くことができます:
    
    - メニューバーから <kbd>ターミナル</kbd> → <kbd>新しいターミナル</kbd>
    - <kbd>Ctrl</kbd> + <kbd>`</kbd>（バッククォート）
    - 右上のアイコンをクリック、または <kbd>Cmd</kbd> + <kbd>J</kbd>（パネルの切り替え）
    
    画面下部に黒い画面（ターミナル / コマンドプロンプト）が表示されます。
    
    ---
    
    **システムのターミナル / コマンドプロンプトを開く**:
    
    === ":fontawesome-brands-apple: Mac"
        1. <kbd>Cmd</kbd> + <kbd>Space</kbd> で Spotlight を開く
        2. 「ターミナル」と入力
        3. <kbd>Enter</kbd> を押す
        
        **または**:
        
        - アプリケーション → ユーティリティ → ターミナル
    
    === ":fontawesome-brands-windows: Windows"
        1. <kbd>Win</kbd> + <kbd>R</kbd> を押す
        2. 「cmd」と入力
        3. <kbd>Enter</kbd> を押す
        
        **または**:
        
        - スタートメニュー → 「コマンドプロンプト」を検索

## 必要なもの

### 1. Vector Search Builder モード

**Vector Search Builder** は、Building Blocks の一部として提供される、ベクトル検索機能を簡単に構築できる IBM Bob のカスタムモードです。

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

#### ステップ 1: Vector Search Builder（Building Block）をインストール

1. 配布された **`vector-search-builder.zip`** をデスクトップにコピー

2. zip ファイルを解凍

    === ":fontawesome-brands-apple: Mac"
        **GUI**: ダブルクリック
        
        **ターミナル / コマンドプロンプト**:
        ```bash
        cd ~/Desktop
        unzip vector-search-builder.zip
        ```

    === ":fontawesome-brands-windows: Windows"
        **GUI**: 右クリック →「すべて展開」

        ※ ダブルクリックで開いただけでは展開されないため、「すべて展開」を実行してください
        
        **ターミナル / コマンドプロンプト**:
        ```bash
        cd %USERPROFILE%\Desktop
        tar -xf vector-search-builder.zip
        ```

3. **`vector-search-builder`** フォルダが作成され、その中に **`.bob`** フォルダがあることを確認

!!! warning "重要"
    `.bob` フォルダはプロジェクトフォルダ（このハンズオンでは `vector-search-builder`）の直下に配置する必要があります。

??? info "vector-search-builder.zip の内容"
    **`vector-search-builder.zip`** には、以下が含まれています:

    **Building Blocks**:

    - **`.bob/`**: Vector Search Builder モード定義

    **このハンズオンで追加したもの**:

    - **`setup/instructor/`**: 講師用 Milvus 環境（Docker Compose）
    - **`setup/participant/`**: 受講者用接続テストスクリプト
    - **`.env.example`**: 接続情報設定テンプレート
    - **`docs/`**: ハンズオン用ドキュメント

??? tip "Building Blocks のインストール方法"
    通常、Building Blocks は以下の方法でインストールします:

    - **グローバルインストール**: `~/.config/IBM Bob/User/globalStorage/ibm.bob-code/`
    - **プロジェクトローカル**: `.bob/`（このハンズオンの方法）

    このハンズオンでは、プロジェクトローカルにインストールすることで、環境を汚さず、簡単にクリーンアップできます。

#### ステップ 2: IBM Bob で `vector-search-builder` フォルダを開く

1. IBM Bob を起動

2. `vector-search-builder` フォルダを開く

    === ":fontawesome-brands-apple: Mac"
        **GUI**: <kbd>ファイル</kbd> → <kbd>開く...</kbd> で `vector-search-builder` フォルダを選択、または <kbd>⌘</kbd> + <kbd>O</kbd> でフォルダ選択ダイアログを開く。

    === ":fontawesome-brands-windows: Windows"
        **GUI**: <kbd>ファイル</kbd> → <kbd>開く...</kbd> で `vector-search-builder` フォルダを選択、または <kbd>Ctrl</kbd> + <kbd>O</kbd> でフォルダ選択ダイアログを開く。

3. 画面右下の「Mode」セレクターに「Vector Search Builder」が表示されることを確認し、選択

!!! success "Building Blocks 専用カスタムモードの認識"
    IBM Bob が `.bob/` フォルダを検出し、Building Blocks 専用カスタムモード（このハンズオンでは Vector Search Builder モード）を自動的に読み込みます。

    このモードにより、IBM Bob は以下を理解します:

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
            **GUI**: Finder で `.env.example` を右クリック →「複製」→ ファイル名を `.env` に変更
            
            **ターミナル / コマンドプロンプト**:
            ```bash
            cd setup/participant
            cp .env.example .env
            ```

        === ":fontawesome-brands-windows: Windows"
            **GUI**: エクスプローラーで `.env.example` を右クリック →「コピー」→「貼り付け」→ ファイル名を `.env` に変更
            
            **ターミナル / コマンドプロンプト**:
            ```bash
            cd setup\participant
            copy .env.example .env
            ```

    3. **`.env`** ファイルを開き、**`MILVUS_HOST`** に講師から配布された IP アドレスを入力
       
        #### MILVUS_HOST の設定
       
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

    4. ファイルを保存
    
        === ":fontawesome-brands-apple: Mac"
            <kbd>Cmd</kbd> + <kbd>S</kbd>

        === ":fontawesome-brands-windows: Windows"
            <kbd>Ctrl</kbd> + <kbd>S</kbd>


#### 埋め込みモデル（テキストを数値に変換する AI）

Hugging Face Transformers を使用します（API キー不要、無料）。

**埋め込みモデルとは**: テキストの「意味」を数値（ベクトル）に変換する AI モデルです。

- モデル: **`paraphrase-multilingual-MiniLM-L12-v2`**
- 次元数: **384**（384 個の数値で意味を表現）
- 特徴: 多言語対応

### 3. Python 環境のセットアップ

#### ステップ 1: Python のインストール確認

まず、Python がインストールされているか確認します。

=== ":fontawesome-brands-apple: Mac"
    **ターミナル / コマンドプロンプト**:
    ```bash
    python3 --version
    ```

=== ":fontawesome-brands-windows: Windows"
    **ターミナル / コマンドプロンプト**:
    ```bash
    python --version
    ```

**期待される出力**:

```
Python 3.8.x 以上
```

!!! warning "Python がインストールされていない場合"
    Python 3.8 以上がインストールされていない場合は、以下からインストールしてください:
    
    **公式サイト**: [https://www.python.org/downloads/](https://www.python.org/downloads/)
    
    === ":fontawesome-brands-apple: Mac"
        Homebrew を使用する場合:
        ```bash
        brew install python3
        ```
    
    === ":fontawesome-brands-windows: Windows"
        Microsoft Store からインストールすることも可能です。

#### ステップ 2: 必要なパッケージのインストール

Python パッケージのインストールは、IBM Bob に依頼して実行します。

!!! example "IBM Bob にパッケージインストールを依頼"
    
    1. IBM Bob のチャット入力欄に以下を入力:
    
        ```text
        requirements.txt に記載されているパッケージをインストールして
        ```
    
    2. インストールが完了するまで待ちます（数分かかる場合があります）

??? info "インストールされるパッケージ"
    以下のパッケージがインストールされます:
    
    - **pymilvus**: Milvus データベースクライアント
    - **sentence-transformers**: 埋め込みモデル
    - **torch**: 機械学習フレームワーク
    - **python-dotenv**: 環境変数管理
    - その他の依存パッケージ

??? tip "手動でインストールする場合"
    IBM Bob を使わずに手動でインストールする場合は、ターミナルで以下を実行:
    
    === ":fontawesome-brands-apple: Mac"
        ```bash
        cd ~/Desktop/vector-search-builder
        pip3 install -r setup/participant/requirements.txt
        ```
    
    === ":fontawesome-brands-windows: Windows"
        ```bash
        cd %USERPROFILE%\Desktop\vector-search-builder
        pip install -r setup\participant\requirements.txt
        ```

## 準備完了チェックリスト

- [ ] IBM Bob がインストールされ、使用できる
- [ ] Python 3.8 以上がインストールされている
- [ ] **`vector-search-builder.zip`** を解凍した
- [ ] **`.bob`** フォルダが存在する
- [ ] IBM Bob で `vector-search-builder` フォルダを開いた
- [ ] 「Vector Search Builder」モードが表示される
- [ ] **`setup/participant/.env`** ファイルに接続情報を入力した
- [ ] IBM Bob に依頼して Python パッケージをインストールした

## FAQ

??? question "Q1: Vector Search Builder モードが表示されない"

    対処法:
    
    1. **`.bob`** フォルダが存在するか確認
    2. IBM Bob をリロード（:fontawesome-brands-apple: <kbd>⌘</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> / :fontawesome-brands-windows: <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> →「Reload Window」）
    3. プロジェクトフォルダを開き直す

??? question "Q2: 接続情報をどこに入力すればいいか分からない"

    対処法:
    
    1. プロジェクトフォルダ内の **`setup/participant`** フォルダを開く
    2. **`.env`** ファイルを探す（見つからない場合は **`.env.example`** をコピー）


## 次のステップ

準備が完了したら、[Part 1: 環境確認とデモ](part1.md)に進みましょう！

Part 1 では、実際に Vector Search がどのように動作するかを体験します。
