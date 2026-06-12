# 事前準備

それでは、ハンズオンの準備から行っていきます。まずは、ターミナル / コマンドプロンプトの開き方を確認してください。

!!! tip "ターミナル / コマンドプロンプトの開き方"
    
    この後の手順では、IBM Bob 内蔵のターミナル、またはシステムのターミナル / コマンドプロンプトを使用します。

**IBM Bob でターミナル / コマンドプロンプトを開く**:

次のいずれかの方法で開くことができます:

- メニューバーから <kbd>ターミナル</kbd> → <kbd>新しいターミナル</kbd>
- <kbd>Ctrl</kbd> + <kbd>`</kbd>（バッククォート）
- 右上のアイコンをクリック、または <kbd>Cmd</kbd> + <kbd>J</kbd>（パネルの切り替え）

画面下部に黒い画面（ターミナル / コマンドプロンプト）が表示されます。

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

**Vector Search Builder** は、Building Blocks の一部として提供される、ベクトル検索機能を簡単に構築できる IBM Bob の Custom モードです。

**Custom モード** = 特定の技術や用途に合わせてカスタマイズされた専用モード

#### Vector Search Builder の概要

**提供元**: IBM Build Engineering Team

**含まれる機能**:

- Milvus データベースのセットアップと管理
- Hugging Face Transformers によるローカル埋め込みモデルの統合
- データ取り込みパイプラインの構築
- ベクトル検索の最適化
- サンプル商品データの投入ワークフロー

**IBM Bob との連携**:

- Vector Search に特化した AI アシスタント
- Building Blocks の機能を理解した上でコード生成
- ベストプラクティスに基づいた実装支援

!!! info "Building Blocks の利点"
    
    **通常の開発**: Milvus のドキュメントを読み、SDK を学習し、コードを一から書く（数日）

    **Building Blocks 使用**: Vector Search Builder をインストールし、IBM Bob に自然言語で指示（数分）

    **このハンズオンでの工夫**: 講師が Milvus 環境を提供、受講者は IBM Bob のみで参加（環境構築不要）

#### ステップ 1: Vector Search Builder をインストール

1. 配布された **`vector-search-builder-ja.zip`** をデスクトップにコピー

2. zip ファイルを解凍

    === ":fontawesome-brands-apple: Mac"
        **GUI**: ダブルクリック
        
        **ターミナル / コマンドプロンプト**:
        ```bash
        cd ~/Desktop
        mkdir -p vector-search-builder-ja
        unzip vector-search-builder-ja.zip -d vector-search-builder-ja
        ```

    === ":fontawesome-brands-windows: Windows"
        **GUI**: 右クリック →「すべて展開」

        ※ ダブルクリックで開いただけでは展開されないため、「すべて展開」を実行してください
        
        **ターミナル / コマンドプロンプト**:
        ```bash
        cd %USERPROFILE%\Desktop
        mkdir vector-search-builder-ja
        tar -xf vector-search-builder-ja.zip -C vector-search-builder-ja
        ```

3. **`vector-search-builder-ja`** フォルダが作成され、その中に **`.bob`** フォルダがあることを確認

!!! warning "重要"
    
    `.bob` フォルダはプロジェクトフォルダ（このハンズオンでは `vector-search-builder-ja`）の直下に配置する必要があります。

??? info "vector-search-builder-ja.zip の内容"
    **`vector-search-builder-ja.zip`** には、以下が含まれています:

    **Building Blocks**:

    - **`.bob/`**: Vector Search Builder モード定義

    **受講者用セットアップファイル**:

    - **`setup/participant/`**: 受講者用スクリプト、FastAPI デモアプリ、言語別サンプルデータ
    - **`setup/participant/.env.example`**: 接続情報設定テンプレート
    - **`setup/participant/sample_products.py`**: 使用するサンプル商品データの選択
    - **`setup/participant/sample_products_ja.py`**: 日本語のサンプル商品データ
    - **`PARTICIPANT_LANGUAGE=ja`**: 日本語の商品データと実行時メッセージが使用されます

??? tip "Building Blocks のインストール方法"
    通常、Building Blocks は以下の方法でインストールします:

    - **グローバルインストール**: `~/.config/IBM Bob/User/globalStorage/ibm.bob-code/`
    - **プロジェクトローカル**: `.bob/`（このハンズオンの方法）

    このハンズオンでは、プロジェクトローカルにインストールすることで、環境を汚さず、簡単にクリーンアップできます。

#### ステップ 2: IBM Bob で `vector-search-builder-ja` フォルダを開く

!!! info "使用する IBM Bob のバージョン"
    
    このハンズオンでは **IBM Bob 1.0.3** を使用します。バージョンが異なる場合、画面表示やコマンドの挙動が一部異なることがあります。

1. IBM Bob を起動

2. `vector-search-builder-ja` フォルダを開く

    === ":fontawesome-brands-apple: Mac"
        **GUI**: <kbd>ファイル</kbd> → <kbd>開く...</kbd> で `vector-search-builder-ja` フォルダを選択、または <kbd>⌘</kbd> + <kbd>O</kbd> でフォルダ選択ダイアログを開く。

    === ":fontawesome-brands-windows: Windows"
        **GUI**: <kbd>ファイル</kbd> → <kbd>開く...</kbd> で `vector-search-builder-ja` フォルダを選択、または <kbd>Ctrl</kbd> + <kbd>O</kbd> でフォルダ選択ダイアログを開く。

3. 画面右下の「Mode」セレクターに「Vector Search Builder」が表示されることを確認し、選択

!!! success "Vector Search Builder モード"
    
    「Mode」セレクターで Vector Search Builder モードを選択すると、Building Blocks 専用 Custom モードが有効になります。

    このモードにより、IBM Bob は以下を理解します:

    - Milvus データベースの操作方法
    - ベクトル検索のベストプラクティス
    - 埋め込みモデルの統合方法
    - Building Blocks の機能と制約

### 2. 接続情報

#### Milvus（ベクトルデータベース）

講師から配布された IP アドレスを設定します。

!!! example "実践: 接続情報を設定します"
    
    Milvus に接続するための設定ファイルを作成し、講師から配布された IP アドレスを入力します。

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

3. **`.env`** ファイルを開き、講師から配布された接続情報を入力
   
    #### Milvus 接続情報の設定 {#milvus_host}

    === "同一ネットワーク（会場内）"

        ```properties
        # Milvus 接続情報
        MILVUS_HOST=192.168.1.100  # ← 講師から配布された IP アドレスに変更
        MILVUS_PASSWORD=AbCd123XyZ # ← 講師から配布されたパスワードに変更
        
        # コレクション名（Milvus は全参加者で共有されています）
        COLLECTION_NAME=products_taro  # ← 自分専用の一意な名前に変更
        
        # 以下は変更不要
        MILVUS_PORT=19530
        MILVUS_USER=root
        EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
        PARTICIPANT_LANGUAGE=ja
        ```

    === "リモート（ngrok）"

        ```properties
        # Milvus 接続情報
        MILVUS_HOST=0.tcp.jp.ngrok.io  # ← 講師から配布されたホスト名に変更
        MILVUS_PORT=24051              # ← 講師から配布されたポート番号に変更
        MILVUS_PASSWORD=AbCd123XyZ     # ← 講師から配布されたパスワードに変更
        
        # コレクション名（Milvus は全参加者で共有されています）
        COLLECTION_NAME=products_taro  # ← 自分専用の一意な名前に変更
        
        # 以下は変更不要
        MILVUS_USER=root
        EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
        PARTICIPANT_LANGUAGE=ja
        ```

    !!! warning "一意なコレクション名を設定してください"
        
        全参加者が講師の管理する同じ Milvus サーバーに接続します。
        **`COLLECTION_NAME`** には自分専用の一意な名前（例: **`products_taro`**、英数字とアンダースコア）を設定してください。
        他の参加者と同じ名前を使うと、サンプルデータ投入時にお互いのコレクションを上書きしてしまいます。

    !!! warning "ngrok 接続時の注意"
        
        ngrok を使用する場合、企業 VPN や Cisco Umbrella などの DNS セキュリティ製品により、ngrok の TCP トンネルへの接続がブロックされたり、ホスト名が正しく解決されなかったりすることがあります。VPN を切断しても Cisco Umbrella などが有効なままの場合は、接続できないことがあります。接続できない場合は、所属組織のルールに従い、同一ネットワークでの接続など講師から案内された代替方法を使用してください。

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
Python 3.10.x 以上（3.11 / 3.12 推奨）
```

Python 3.10 以上がインストールされていない場合は、インストールしてから次へ進んでください。ハンズオンで使用するパッケージ（torch、sentence-transformers、FastAPI）は Python 3.10 以上を必要とします。

=== ":fontawesome-brands-apple: Mac"
    公式サイトからインストーラーをダウンロードしてインストールします。

    **公式サイト**: [https://www.python.org/downloads/](https://www.python.org/downloads/)

    Homebrew を使用している場合は、以下でもインストールできます。

    ```bash
    brew install python3
    ```

=== ":fontawesome-brands-windows: Windows"
    公式サイトからインストーラーをダウンロードして実行します。

    **公式サイト**: [https://www.python.org/downloads/](https://www.python.org/downloads/)

    !!! warning "インストール時の注意"
        インストーラー最初の画面で **Add python.exe to PATH** にチェックを入れてから、**Install Now** をクリックしてください。チェックを入れないと、コマンドプロンプトから `python` や `pip` を実行できない場合があります。

#### ステップ 2: 仮想環境の作成（重要）

!!! danger "グローバル環境を破壊しないために"
    
    **必ず仮想環境を使用してください**。グローバル環境に直接インストールすると、他のプロジェクトに影響を与える可能性があります。

仮想環境を作成し、その中でパッケージをインストールします。

=== ":fontawesome-brands-apple: Mac"
    **ターミナル / コマンドプロンプト**:
    ```bash
    cd ~/Desktop/vector-search-builder-ja/setup/participant
    python3 -m venv venv
    source venv/bin/activate
    ```

=== ":fontawesome-brands-windows: Windows"
    **ターミナル / コマンドプロンプト**:
    ```bash
    cd %USERPROFILE%\Desktop\vector-search-builder-ja\setup\participant
    python -m venv venv
    venv\Scripts\activate
    ```

!!! note "プロンプト表示について"

    仮想環境を有効化すると、環境によってはプロンプトの先頭に `(venv)` が表示されることがあります。ただし、ターミナルやシェルの設定によって表示されない場合もあります。

!!! success "仮想環境の利点"
    
    - **隔離**: このプロジェクト専用の環境
    - **安全**: グローバル環境を破壊しない
    - **クリーンアップ**: `venv` フォルダを削除するだけで完全に削除可能
    - **再現性**: 他の環境でも同じ構成を再現可能

#### ステップ 3: 必要なパッケージのインストール {#install-packages}

`venv` 内の Python を直接指定して、Python パッケージをインストールします。

1. **`venv` フォルダが作成されていることを確認**

2. ターミナルで以下を実行:

    === ":fontawesome-brands-apple: Mac"
        ```bash
        cd ~/Desktop/vector-search-builder-ja/setup/participant
        venv/bin/python -m pip install -r requirements.txt
        ```

    === ":fontawesome-brands-windows: Windows"
        ```cmd
        cd %USERPROFILE%\Desktop\vector-search-builder-ja\setup\participant
        venv\Scripts\python -m pip install -r requirements.txt
        ```

3. インストールが完了するまで待ちます（数分かかる場合があります）

!!! tip "Linux の方: CPU 版 torch を先にインストール"

    Linux ではデフォルトの `torch` ホイールに CUDA ライブラリが含まれるため数 GB になります。`pip install -r requirements.txt` の**前に**以下を実行すると、大幅に小さく高速にインストールできます:

    ```bash
    venv/bin/python -m pip install torch==2.12.0 --index-url https://download.pytorch.org/whl/cpu
    ```

??? note "venv 内の Python を直接指定する理由"

    仮想環境を有効化していても、別のターミナルや AI ツールが実行するコマンドにはその状態が引き継がれない場合があります。`venv/bin/python` または `venv\Scripts\python` を直接指定すると、確実に `venv` にインストールできます。

??? info "インストールされるパッケージ"
    以下のパッケージがインストールされます:
    
    **主要パッケージ**:

    - **pymilvus**: Milvus データベースクライアント
    - **sentence-transformers**: 埋め込みモデル
    - **torch**: 機械学習フレームワーク
    - **fastapi**: Web フレームワーク
    - **uvicorn**: ASGI サーバー
    - **python-dotenv**: 環境変数管理
    
    **依存パッケージ（自動インストール）**:

    - transformers, huggingface-hub
    - pydantic, starlette
    - scikit-learn, marshmallow
    - その他

??? warning "仮想環境の無効化"
    作業が終わったら、仮想環境を無効化できます:
    
    ```bash
    deactivate
    ```
    
    次回作業時は、再度有効化してください:
    
    === ":fontawesome-brands-apple: Mac"
        ```bash
        cd ~/Desktop/vector-search-builder-ja/setup/participant
        source venv/bin/activate
        ```
    
    === ":fontawesome-brands-windows: Windows"
        ```bash
        cd %USERPROFILE%\Desktop\vector-search-builder-ja\setup\participant
        venv\Scripts\activate
        ```

## 準備完了チェックリスト

- [ ] IBM Bob がインストールされ、使用できる
- [ ] Python 3.10 以上がインストールされている
- [ ] **`vector-search-builder-ja.zip`** を解凍した
- [ ] **`.bob`** フォルダが存在する
- [ ] IBM Bob で `vector-search-builder-ja` フォルダを開いた
- [ ] 「Vector Search Builder」モードが表示される
- [ ] **`setup/participant/.env`** ファイルに接続情報を入力した
- [ ] **仮想環境を作成し、有効化した**（`venv` フォルダが作成されている）
- [ ] 仮想環境内で Python パッケージをインストールした

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

準備が完了したら、[Part 1: 環境確認とデモ](part1.md) に進みましょう！
