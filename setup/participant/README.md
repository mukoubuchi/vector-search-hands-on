# Vector Search ハンズオン - 受講者用セットアップガイド

このディレクトリには、受講者がMilvus環境への接続テストを行うためのファイルが含まれています。

## 📋 ファイル一覧

### `.env.example`
環境変数のテンプレートファイルです。講師から配布された接続情報を入力して使用します。

### `requirements.txt`
接続テストに必要な Python パッケージのリストです。

### `test_embeddings_hf.py`
Hugging Face Transformersを使用した埋め込みモデルのテストスクリプトです。

### `test_connection_simple.py`
Milvusへの基本的な接続テストスクリプトです。

### `test_connection.py`
Milvusと埋め込みモデルへの包括的な接続テストスクリプトです。

### `vector-search-builder.zip`
IBM Bob IDE用のVector Search Builderモード定義ファイルです。

### `check_docs_url.sh`
Code EngineにデプロイされたドキュメントのURLを確認するスクリプトです（リモート参加者向け）。

## 🚀 クイックスタート

### 前提条件

- Python 3.8 以上
- pip（Pythonパッケージマネージャー）
- IBM Bob IDE（推奨）

### 1. 環境変数の設定

```bash
# setup/participant ディレクトリに移動
cd setup/participant

# .env ファイルを作成
cp .env.example .env

# .env ファイルを編集して、講師から配布された情報を入力
# エディタで開く（例：VS Code）
code .env
```

**編集する項目**:
```bash
# 講師から配布されたIPアドレスに置き換え
MILVUS_HOST=<講師のIPアドレス>

# その他の設定（通常は変更不要）
MILVUS_PORT=19530
MILVUS_USER=root
MILVUS_PASSWORD=Milvus
EMBEDDING_MODEL=paraphrase-multilingual-MiniLM-L12-v2
EMBEDDING_DIMENSION=384
```

### 📖 ドキュメントURLの確認（リモート参加者向け）

リモート参加者（講師と異なるネットワーク環境）の場合、Code EngineにデプロイされたドキュメントのURLを確認できます：

```bash
# IBM Cloud CLIにログイン（初回のみ）
ibmcloud login --sso

# Code Engineプラグインのインストール（初回のみ）
ibmcloud plugin install code-engine

# ドキュメントURLを確認
./check_docs_url.sh
```

**期待される出力**:
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

### 2. Python パッケージのインストール

```bash
# 仮想環境の作成（推奨）
python3 -m venv venv

# 仮想環境の有効化
# macOS/Linux:
source venv/bin/activate

# Windows:
venv\Scripts\activate

# パッケージのインストール
pip install -r requirements.txt
```

### 3. 接続テストの実行

#### ステップ1: 埋め込みモデルのテスト

```bash
python test_embeddings_hf.py
```

**期待される出力**:
```
=== Hugging Face Transformers 埋め込みモデル テスト ===

モデル: paraphrase-multilingual-MiniLM-L12-v2
モデルをロード中...
✓ モデルのロードに成功しました

テスト文章:
1. これはテストです
2. This is a test
3. 機械学習は面白い

✓ 埋め込みベクトル生成成功
  生成数: 3
  次元数: 384

類似度計算:
  文1 vs 文2: 0.2869
  文1 vs 文3: 0.1234

✓ すべてのテストが成功しました！
```

#### ステップ2: Milvus接続テスト（シンプル版）

```bash
python test_connection_simple.py
```

**期待される出力**:
```
=== Milvus 接続テスト（シンプル版） ===

接続先: 192.168.1.100:19530
✓ Milvusに接続成功
✓ 既存コレクション数: 0

✓ 接続テストが成功しました！
```

#### ステップ3: 包括的な接続テスト

```bash
python test_connection.py
```

**期待される出力**:
```
==================================================
Milvus & 埋め込みモデル 接続テスト
==================================================

=== 環境変数確認 ===
✓ MILVUS_HOST: 192.168.1.100
✓ MILVUS_PORT: 19530
✓ EMBEDDING_MODEL: paraphrase-multilingual-MiniLM-L12-v2
✓ EMBEDDING_DIMENSION: 384

=== Milvus 接続テスト ===
接続先: 192.168.1.100:19530
✓ Milvusに接続成功
✓ 既存コレクション数: 0

=== 埋め込みモデル テスト ===
モデル: paraphrase-multilingual-MiniLM-L12-v2
モデルをロード中...
✓ モデルのロードに成功しました

テスト埋め込み生成: 'これはテストです'
✓ 埋め込みベクトル生成成功
  次元数: 384
  最初の5要素: [0.123, -0.456, 0.789, ...]

==================================================
テスト結果サマリー
==================================================
Milvus接続:        ✓ 成功
埋め込みモデル:    ✓ 成功

✓ すべての接続テストが成功しました！
  次のステップ: ベクトルコレクションの作成
```

### 4. IBM Bob IDEのセットアップ

```bash
# vector-search-builder.zipを展開
unzip vector-search-builder.zip

# .bobディレクトリをプロジェクトルートにコピー
# （IBM Bob IDEで開いているプロジェクトのルートディレクトリ）
cp -r .bob /path/to/your/project/

# setupディレクトリもコピー
cp -r . /path/to/your/project/setup/
```

IBM Bob IDEをリロードすると、Vector Search Builderモードが利用可能になります。

## 🐛 トラブルシューティング

### Milvus 接続エラー

```
✗ Milvus接続エラー: [Errno 61] Connection refused
```

**原因と対処法**:
1. **Milvus サーバーが起動していない**
   - 講師に確認してください

2. **MILVUS_HOST が間違っている**
   - `.env` ファイルのIPアドレスを確認
   - 講師から配布された情報と一致しているか確認

3. **ファイアウォールでブロックされている**
   - ネットワーク管理者に確認
   - 企業ネットワークの場合、ポート19530が開放されているか確認

4. **IBM Bob IDEが.envを読み込んでいない**
   - IBM Bob IDEをリロード（Cmd+R / Ctrl+R）
   - `.env`ファイルがプロジェクトルートにあるか確認

### 埋め込みモデル エラー

```
✗ モデルのロードに失敗しました
```

**原因と対処法**:
1. **インターネット接続の問題**
   - 初回実行時、モデルをダウンロードするためインターネット接続が必要
   - プロキシ設定が必要な場合は設定を確認

2. **ディスク容量不足**
   - モデルファイルは約500MB必要
   - `~/.cache/huggingface/` に十分な空き容量があるか確認

3. **パッケージのバージョン問題**
   ```bash
   # sentence-transformersを最新版にアップグレード
   pip install --upgrade sentence-transformers
   ```

### パッケージインストールエラー

```bash
# pip を最新版にアップグレード
pip install --upgrade pip

# 個別にインストールを試す
pip install pymilvus
pip install sentence-transformers
pip install python-dotenv
```

### 仮想環境の問題

```bash
# 仮想環境を削除して再作成
rm -rf venv
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## 📚 次のステップ

接続テストが成功したら、以下のステップに進みます：

1. **MkDocsドキュメントにアクセス**
   - URL: `http://<講師のIPアドレス>:8001`
   - ハンズオン手順を確認

2. **IBM Bob IDEでVector Search Builderモードを使用**
   - ベクトルコレクションの作成
   - データの投入
   - ベクトル検索の実装

3. **ハンズオン課題に取り組む**
   - Part 1: ベクトルデータベースのセットアップ
   - Part 2: データの投入とインデックス作成
   - Part 3: ベクトル検索の実装

## 💡 ヒント

- **IBM Bob IDEの活用**: Vector Search Builderモードを使用すると、コード生成が自動化されます
- **エラーメッセージの確認**: エラーが発生した場合、メッセージを注意深く読んでください
- **講師に質問**: わからないことがあれば、遠慮なく講師に質問してください

## 📖 参考資料

- [Milvus 公式ドキュメント](https://milvus.io/docs)
- [Sentence Transformers ドキュメント](https://www.sbert.net/)
- [IBM Bob IDE ドキュメント](https://ibm.github.io/bob/)