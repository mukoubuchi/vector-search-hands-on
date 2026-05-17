# 事前準備

ハンズオンをスムーズに進めるために、以下の準備を完了してください。

## 📋 必要なもの

このハンズオンを始める前に、以下を準備してください：

### 1. IBM Bob（必須）

IBM Bobは、AIがコーディングをサポートしてくれる開発ツールです。

#### ステップ1: IBM Bobアカウントを作成する

1. **ブラウザで以下のURLを開く**
   ```
   https://bob.ibm.com/trial
   ```

2. **「30日間無料トライアル」ボタンをクリック**

3. **必要な情報を入力**
   - メールアドレス
   - パスワード
   - 名前

4. **登録完了メールを確認**
   - 受信トレイをチェック
   - メール内のリンクをクリックして認証

#### ステップ2: IBM Bob IDEをインストールする

1. **ダウンロードページを開く**
   ```
   https://bob.ibm.com/download
   ```

2. **お使いのOSを選択**
   - Windows: 「Download for Windows」をクリック
   - Mac: 「Download for Mac」をクリック
   - Linux: 「Download for Linux」をクリック

3. **ダウンロードしたファイルを実行**
   - Windowsの場合: `.exe`ファイルをダブルクリック
   - Macの場合: `.dmg`ファイルを開いてアプリケーションフォルダにドラッグ
   - Linuxの場合: インストール手順に従う

4. **IBM Bob IDEを起動**
   - アプリケーションを開く
   - 初回起動時にアカウントでログイン

### 2. Vector Search Builder モード（必須）

Vector Search Builderは、ベクトル検索機能を簡単に構築できるIBM Bobの専用モードです。

#### ステップ1: プロジェクトフォルダを作成

1. **デスクトップに新しいフォルダを作成**
   - フォルダ名: `vector-search-handson`
   - 場所: どこでも構いませんが、デスクトップが分かりやすいです

2. **フォルダの場所を覚えておく**
   - 後でIBM Bobで開くため

#### ステップ2: Vector Search Builderをインストール

1. **配布されたzipファイルを確認**
   - ファイル名: `vector-search-builder.zip`
   - 講師から配布されたファイルです

2. **zipファイルをプロジェクトフォルダにコピー**
   - `vector-search-builder.zip`を`vector-search-handson`フォルダに移動

3. **zipファイルを解凍**
   - Windowsの場合: 右クリック → 「すべて展開」
   - Macの場合: ダブルクリック
   - Linuxの場合: `unzip vector-search-builder.zip`

4. **解凍結果を確認**
   - `.bob`フォルダが作成されていることを確認
   - このフォルダにVector Search Builderモードが含まれています

#### ステップ3: IBM BobでプロジェクトをOpen

1. **IBM Bob IDEを起動**

2. **プロジェクトフォルダを開く**
   - メニューバーから「File」→「Open Folder」をクリック
   - `vector-search-handson`フォルダを選択
   - 「開く」ボタンをクリック

3. **IBM Bobをリロード**
   - キーボードショートカット:
     - Mac: `Cmd + Shift + P`
     - Windows/Linux: `Ctrl + Shift + P`
   - 表示されたコマンドパレットに「Reload Window」と入力
   - 「Developer: Reload Window」を選択してEnter

4. **Vector Search Builderモードを確認**
   - IBM Bob画面の右下を確認
   - 「Mode」セレクターに「Vector Search Builder」が表示されていればOK

### 3. 接続情報（必須）

ハンズオンでは、以下のサービスに接続します：

#### Milvus（ベクトルデータベース）

- **役割**: ベクトルデータを保存・検索するデータベース
- **接続情報**: 講師から配布されます

#### 埋め込みモデル（Hugging Face Transformers）

- **役割**: テキストをベクトル（数値の配列）に変換
- **特徴**: APIキー不要、無料で使用可能
- **モデル**: paraphrase-multilingual-MiniLM-L12-v2（多言語対応、384次元）

#### 接続情報の設定方法

1. **プロジェクトフォルダ内の`setup/participant`フォルダを開く**

2. **`.env.example`ファイルを`.env`にコピー**
   - Windowsの場合: ファイルをコピーして名前を変更
   - Mac/Linuxの場合: ターミナルで`cp .env.example .env`

3. **`.env`ファイルを開く**
   - IBM Bob IDEで開く
   - または、テキストエディタで開く

4. **講師から配布されたホスト名を入力**
   
   **重要**: 変更が必要なのは`MILVUS_HOST`だけです！
   
   ```env
   # Milvus接続情報（講師から配布された情報に置き換え）
   MILVUS_HOST=192.168.1.100  ← ここだけ講師から配布されたIPアドレスに変更
   
   # 以下は変更不要（すでに正しい値が設定されています）
   MILVUS_PORT=19530
   MILVUS_USER=root
   MILVUS_PASSWORD=Milvus
   
   # Embedding モデル設定（変更不要）
   EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
   EMBEDDING_DIMENSION=384
   
   # コレクション設定（変更不要）
   COLLECTION_NAME=knowledge_base
   ```

5. **ファイルを保存**
   - `Cmd + S`（Mac）または`Ctrl + S`（Windows/Linux）

6. **IBM Bobをリロード**
   - `Cmd + Shift + P`（Mac）または`Ctrl + Shift + P`（Windows/Linux）
   - 「Reload Window」を実行

#### 📖 このドキュメントのURLを確認する（リモート参加者向け）

講師と異なるネットワーク環境（異なるWiFi、リモート参加など）の場合、Code EngineにデプロイされたドキュメントのURLを自分で確認できます。

**前提条件**:
- IBM Cloud CLIがインストールされていること
- IBM Cloudアカウントにログインしていること

**手順**:

1. **IBM Cloud CLIにログイン（初回のみ）**
   ```bash
   ibmcloud login --sso
   ```

2. **Code Engineプラグインをインストール（初回のみ）**
   ```bash
   ibmcloud plugin install code-engine
   ```

3. **ドキュメントURLを確認**
   ```bash
   cd setup/participant
   ./check_docs_url.sh
   ```

4. **表示されたURLをブラウザで開く**
   ```
   ==========================================
   ✅ ドキュメントURL確認完了
   ==========================================
   
   📖 ドキュメントURL:
   https://mkdocs-docs.xxxxxxxxxx.us-south.codeengine.appdomain.cloud
   
   このURLをブラウザで開いてください。
   ==========================================
   ```

!!! note "ローカル参加者の場合"
    講師と同じWiFi/ネットワークに接続している場合は、講師から共有されたローカルURL（`http://<IPアドレス>:8001`）を使用してください。

### 4. Webブラウザ（必須）

ハンズオンでは、Webブラウザを使ってAPIをテストします。

#### 推奨ブラウザ

以下のいずれかのブラウザを使用してください：

- Google Chrome（推奨）
- Mozilla Firefox
- Microsoft Edge
- Safari

#### ブラウザの確認

1. **ブラウザを起動**

2. **以下のURLにアクセスできることを確認**
   ```
   https://www.google.com
   ```

3. **正常に表示されればOK**

## ✅ 準備完了チェックリスト

すべての準備が完了したら、以下をチェックしてください：

- [ ] IBM Bobアカウントを作成した
- [ ] IBM Bob IDEをインストールした
- [ ] IBM Bob IDEを起動できる
- [ ] プロジェクトフォルダを作成した
- [ ] `vector-search-builder.zip`を解凍した
- [ ] `.bob`フォルダが存在する
- [ ] IBM BobでプロジェクトフォルダをOpenした
- [ ] 「Vector Search Builder」モードが表示される
- [ ] `.env`ファイルに接続情報を入力した
- [ ] Webブラウザが使用できる

## 🆘 困ったときは

### よくある質問

#### Q1: IBM Bobアカウントの登録メールが届かない

**対処法**:
1. 迷惑メールフォルダを確認
2. 数分待ってから再度確認
3. それでも届かない場合は、講師に相談

#### Q2: IBM Bob IDEがインストールできない

**対処法**:
1. OSのバージョンを確認（古すぎる場合は更新が必要）
2. 管理者権限でインストールを試す
3. セキュリティソフトが邪魔をしていないか確認
4. 講師に相談

#### Q3: Vector Search Builderモードが表示されない

**対処法**:
1. `.bob`フォルダが存在するか確認
2. IBM Bobをリロード（`Cmd/Ctrl + Shift + P` → 「Reload Window」）
3. プロジェクトフォルダを開き直す
4. 講師に相談

#### Q4: 接続情報をどこに入力すればいいか分からない

**対処法**:
1. プロジェクトフォルダ内の`setup/participant`フォルダを開く
2. `.env`ファイルを探す（見つからない場合は`.env.example`をコピー）
3. 講師に画面を見せて確認してもらう

## 🎯 次のステップ

準備が完了したら、[Part 1: 環境確認とデモ](part1.md)に進みましょう！

Part 1では、実際にVector Searchがどのように動作するかを体験します。
