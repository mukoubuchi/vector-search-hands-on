# ベクトル検索ハンズオン - 受講者用手順書

## 概要

このハンズオンでは、IBM Watsonx.aiの埋め込みモデルとMilvusベクトルデータベースを使用して、セマンティック検索システムを構築します。

## 前提条件

- **IBM Bob IDE** - コード実行環境
- **インターネット接続** - Milvus/Watsonx.aiへの接続用
- **ブラウザ** - ドキュメント閲覧用（オプション）
- **講師から提供される接続情報**

**重要**: このハンズオンは**IBM Bob IDE**と**ネット環境**があれば完結できます。ローカルへのPythonインストールは不要です。

## 事前準備

### 1. ドキュメントへのアクセス

講師から提供されるURLにブラウザでアクセスしてください：

```
http://<講師のIPアドレス>:8001
```

このドキュメントサイトには以下の情報が含まれています：
- 準備（Preparation）
- Part 1: 環境セットアップと接続確認
- Part 2: データの投入とベクトル化
- Part 3: セマンティック検索の実装
- まとめ（Summary）

### 2. 必要な情報の確認

講師から以下の情報を受け取ってください：

**Milvus接続情報:**
- ホスト: `<講師のIPアドレス>`
- ポート: `19530`
- ユーザー名: （講師から提供）
- パスワード: （講師から提供）

**IBM Watsonx.ai認証情報:**
- API Key: （講師から提供）
- Project ID: （講師から提供）
- URL: `https://us-south.ml.cloud.ibm.com`

### 3. IBM Bob IDEでの準備

IBM Bob IDEを開き、新しいチャットを開始します。以下のように依頼してください：

```
ベクトル検索ハンズオン用の作業環境を準備してください。
以下のパッケージをインストールしてください：
- pymilvus==2.3.4
- ibm-watsonx-ai==0.2.6
- python-dotenv==1.0.0
```

Bobが自動的に環境をセットアップします。

## Part 1: 環境セットアップと接続確認

### 1.1 環境変数の設定

IBM Bob IDEで`.env`ファイルを作成します。Bobに以下のように依頼：

```
.envファイルを作成して、以下の内容を記入してください：

# Milvus接続情報
MILVUS_HOST=<講師のIPアドレス>
MILVUS_PORT=19530
MILVUS_USER=<講師から提供>
MILVUS_PASSWORD=<講師から提供>

# IBM Watsonx.ai認証情報
WATSONX_URL=https://us-south.ml.cloud.ibm.com
WATSONX_API_KEY=<講師から提供>
WATSONX_PROJECT_ID=<講師から提供>

# コレクション設定
COLLECTION_NAME=knowledge_base
EMBEDDING_DIMENSION=768
```

**注意**: `<講師のIPアドレス>`などの部分は、講師から提供された実際の値に置き換えてください。

### 1.2 Milvus接続テスト

IBM Bob IDEで`test_milvus_connection.py`を作成します。Bobに以下のように依頼：

```
test_milvus_connection.pyというファイルを作成して、以下のコードを記入してください：
```

コード内容：

```python
from pymilvus import connections, utility
from dotenv import load_dotenv
import os

# 環境変数を読み込み
load_dotenv()

def test_connection():
    """Milvus接続をテスト"""
    try:
        # 接続
        connections.connect(
            alias="default",
            host=os.getenv("MILVUS_HOST"),
            port=os.getenv("MILVUS_PORT"),
            user=os.getenv("MILVUS_USER"),
            password=os.getenv("MILVUS_PASSWORD"),
            secure=True
        )
        
        print("✓ Milvusへの接続に成功しました")
        
        # 既存のコレクションを確認
        collections = utility.list_collections()
        print(f"✓ 既存のコレクション: {collections}")
        
        return True
        
    except Exception as e:
        print(f"✗ 接続に失敗しました: {e}")
        return False
    finally:
        connections.disconnect("default")

if __name__ == "__main__":
    test_connection()
```

実行：

Bobに以下のように依頼：
```
test_milvus_connection.pyを実行してください
```

**期待される出力:**
```
✓ Milvusへの接続に成功しました
✓ 既存のコレクション: []
```

### 1.3 Watsonx.ai接続テスト

IBM Bob IDEで`test_watsonx_connection.py`を作成します。Bobに以下のように依頼：

```
test_watsonx_connection.pyというファイルを作成して、以下のコードを記入してください：
```

コード内容：

```python
from ibm_watsonx_ai import Credentials
from ibm_watsonx_ai.foundation_models import Embeddings
from ibm_watsonx_ai.foundation_models.utils.enums import EmbeddingTypes
from dotenv import load_dotenv
import os

load_dotenv()

def test_embeddings():
    """Watsonx.ai埋め込みモデルをテスト"""
    try:
        # 認証情報を設定
        credentials = Credentials(
            url=os.getenv("WATSONX_URL"),
            api_key=os.getenv("WATSONX_API_KEY")
        )
        
        # 埋め込みモデルを初期化
        embeddings = Embeddings(
            model_id=EmbeddingTypes.IBM_SLATE_125M_ENG,
            credentials=credentials,
            project_id=os.getenv("WATSONX_PROJECT_ID")
        )
        
        # テストテキストで埋め込みを生成
        test_text = "これはテストです"
        vector = embeddings.embed_query(test_text)
        
        print(f"✓ Watsonx.aiへの接続に成功しました")
        print(f"✓ 埋め込みベクトルの次元数: {len(vector)}")
        print(f"✓ ベクトルの最初の5要素: {vector[:5]}")
        
        return True
        
    except Exception as e:
        print(f"✗ 接続に失敗しました: {e}")
        return False

if __name__ == "__main__":
    test_embeddings()
```

実行：

Bobに以下のように依頼：
```
test_watsonx_connection.pyを実行してください
```

**期待される出力:**
```
✓ Watsonx.aiへの接続に成功しました
✓ 埋め込みベクトルの次元数: 768
✓ ベクトルの最初の5要素: [0.123, -0.456, 0.789, ...]
```

## Part 2: データの投入とベクトル化

### 2.1 Milvusコレクションの作成

IBM Bob IDEで`create_collection.py`を作成します。Bobに以下のように依頼：

```
create_collection.pyというファイルを作成して、以下のコードを記入してください：
```

コード内容：

```python
from pymilvus import connections, Collection, CollectionSchema, FieldSchema, DataType
from dotenv import load_dotenv
import os

load_dotenv()

def create_collection():
    """ベクトル検索用のコレクションを作成"""
    
    # Milvusに接続
    connections.connect(
        alias="default",
        host=os.getenv("MILVUS_HOST"),
        port=os.getenv("MILVUS_PORT"),
        user=os.getenv("MILVUS_USER"),
        password=os.getenv("MILVUS_PASSWORD"),
        secure=True
    )
    
    # スキーマを定義
    fields = [
        FieldSchema(name="id", dtype=DataType.INT64, is_primary=True, auto_id=True),
        FieldSchema(name="embedding", dtype=DataType.FLOAT_VECTOR, dim=768),
        FieldSchema(name="text", dtype=DataType.VARCHAR, max_length=65535),
        FieldSchema(name="source", dtype=DataType.VARCHAR, max_length=512),
        FieldSchema(name="metadata", dtype=DataType.JSON)
    ]
    
    schema = CollectionSchema(
        fields=fields,
        description="ナレッジベース用ベクトル検索コレクション"
    )
    
    # コレクションを作成
    collection_name = os.getenv("COLLECTION_NAME")
    collection = Collection(name=collection_name, schema=schema)
    
    print(f"✓ コレクション '{collection_name}' を作成しました")
    
    # HNSWインデックスを作成
    index_params = {
        "metric_type": "COSINE",
        "index_type": "HNSW",
        "params": {
            "M": 16,
            "efConstruction": 256
        }
    }
    
    collection.create_index(
        field_name="embedding",
        index_params=index_params
    )
    
    print("✓ HNSWインデックスを作成しました")
    
    # コレクションをロード
    collection.load()
    print("✓ コレクションをロードしました")
    
    connections.disconnect("default")

if __name__ == "__main__":
    create_collection()
```

実行：

Bobに以下のように依頼：
```
create_collection.pyを実行してください
```

### 2.2 サンプルデータの準備

IBM Bob IDEで`sample_data.txt`を作成します。Bobに以下のように依頼：

```
sample_data.txtというファイルを作成して、以下の内容を記入してください：
```

内容：

```text
機械学習は、コンピュータがデータから学習し、明示的にプログラムされることなくタスクを実行できるようにする人工知能の一分野です。

深層学習は、人工ニューラルネットワークを使用した機械学習の手法で、画像認識や自然言語処理などの複雑なタスクに優れた性能を発揮します。

自然言語処理（NLP）は、コンピュータが人間の言語を理解、解釈、生成できるようにする技術です。

ベクトルデータベースは、高次元ベクトルを効率的に保存し、類似度検索を高速に実行できるデータベースシステムです。

埋め込みモデルは、テキストや画像などのデータを固定長のベクトル表現に変換する機械学習モデルです。

セマンティック検索は、キーワードマッチングではなく、意味的な類似性に基づいて情報を検索する技術です。

RAG（Retrieval-Augmented Generation）は、外部知識ベースから関連情報を取得し、それを基に回答を生成する手法です。

トランスフォーマーは、注意機構を使用した深層学習アーキテクチャで、現代の多くのNLPモデルの基盤となっています。

BERT（Bidirectional Encoder Representations from Transformers）は、双方向の文脈を考慮したテキスト表現を学習する事前学習モデルです。

GPTは、大規模なテキストデータで事前学習された生成型言語モデルで、様々な自然言語タスクに適用できます。
```

### 2.3 データの投入

IBM Bob IDEで`ingest_data.py`を作成します。Bobに以下のように依頼：

```
ingest_data.pyというファイルを作成して、以下のコードを記入してください：
```

コード内容：

```python
from pymilvus import connections, Collection
from ibm_watsonx_ai import Credentials
from ibm_watsonx_ai.foundation_models import Embeddings
from ibm_watsonx_ai.foundation_models.utils.enums import EmbeddingTypes
from dotenv import load_dotenv
import os

load_dotenv()

def ingest_documents(file_path: str):
    """ドキュメントをベクトル化してMilvusに投入"""
    
    # Milvusに接続
    connections.connect(
        alias="default",
        host=os.getenv("MILVUS_HOST"),
        port=os.getenv("MILVUS_PORT"),
        user=os.getenv("MILVUS_USER"),
        password=os.getenv("MILVUS_PASSWORD"),
        secure=True
    )
    
    # コレクションを取得
    collection = Collection(os.getenv("COLLECTION_NAME"))
    
    # Watsonx.ai埋め込みモデルを初期化
    credentials = Credentials(
        url=os.getenv("WATSONX_URL"),
        api_key=os.getenv("WATSONX_API_KEY")
    )
    
    embeddings = Embeddings(
        model_id=EmbeddingTypes.IBM_SLATE_125M_ENG,
        credentials=credentials,
        project_id=os.getenv("WATSONX_PROJECT_ID")
    )
    
    # ファイルを読み込み
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = [line.strip() for line in f if line.strip()]
    
    print(f"✓ {len(lines)}件のドキュメントを読み込みました")
    
    # 埋め込みを生成
    print("埋め込みを生成中...")
    vectors = embeddings.embed_documents(lines)
    print(f"✓ {len(vectors)}件の埋め込みを生成しました")
    
    # データを準備
    data = [
        {
            "embedding": vector,
            "text": text,
            "source": file_path,
            "metadata": {"line_number": i + 1}
        }
        for i, (text, vector) in enumerate(zip(lines, vectors))
    ]
    
    # Milvusに挿入
    collection.insert(data)
    collection.flush()
    
    print(f"✓ {len(data)}件のドキュメントをMilvusに投入しました")
    
    # 統計情報を表示
    print(f"✓ コレクション内のエンティティ数: {collection.num_entities}")
    
    connections.disconnect("default")

if __name__ == "__main__":
    ingest_documents("sample_data.txt")
```

実行：

Bobに以下のように依頼：
```
ingest_data.pyを実行してください
```

**期待される出力:**
```
✓ 10件のドキュメントを読み込みました
埋め込みを生成中...
✓ 10件の埋め込みを生成しました
✓ 10件のドキュメントをMilvusに投入しました
✓ コレクション内のエンティティ数: 10
```

## Part 3: セマンティック検索の実装

### 3.1 基本的な検索機能

IBM Bob IDEで`search.py`を作成します。Bobに以下のように依頼：

```
search.pyというファイルを作成して、以下のコードを記入してください：
```

コード内容：

```python
from pymilvus import connections, Collection
from ibm_watsonx_ai import Credentials
from ibm_watsonx_ai.foundation_models import Embeddings
from ibm_watsonx_ai.foundation_models.utils.enums import EmbeddingTypes
from dotenv import load_dotenv
import os

load_dotenv()

class VectorSearch:
    """ベクトル検索クラス"""
    
    def __init__(self):
        # Milvusに接続
        connections.connect(
            alias="default",
            host=os.getenv("MILVUS_HOST"),
            port=os.getenv("MILVUS_PORT"),
            user=os.getenv("MILVUS_USER"),
            password=os.getenv("MILVUS_PASSWORD"),
            secure=True
        )
        
        # コレクションを取得
        self.collection = Collection(os.getenv("COLLECTION_NAME"))
        self.collection.load()
        
        # 埋め込みモデルを初期化
        credentials = Credentials(
            url=os.getenv("WATSONX_URL"),
            api_key=os.getenv("WATSONX_API_KEY")
        )
        
        self.embeddings = Embeddings(
            model_id=EmbeddingTypes.IBM_SLATE_125M_ENG,
            credentials=credentials,
            project_id=os.getenv("WATSONX_PROJECT_ID")
        )
    
    def search(self, query: str, top_k: int = 5):
        """セマンティック検索を実行"""
        
        # クエリの埋め込みを生成
        query_vector = self.embeddings.embed_query(query)
        
        # 検索パラメータ
        search_params = {
            "metric_type": "COSINE",
            "params": {"ef": 100}
        }
        
        # 検索を実行
        results = self.collection.search(
            data=[query_vector],
            anns_field="embedding",
            param=search_params,
            limit=top_k,
            output_fields=["text", "source", "metadata"]
        )
        
        # 結果をフォーマット
        formatted_results = []
        for hits in results:
            for hit in hits:
                formatted_results.append({
                    "text": hit.entity.get("text"),
                    "source": hit.entity.get("source"),
                    "metadata": hit.entity.get("metadata"),
                    "score": hit.score
                })
        
        return formatted_results
    
    def close(self):
        """接続を閉じる"""
        connections.disconnect("default")

def main():
    """メイン関数"""
    
    # 検索システムを初期化
    search_system = VectorSearch()
    
    # 検索クエリ
    queries = [
        "ニューラルネットワークについて教えて",
        "テキストをベクトルに変換する方法",
        "意味で検索する技術"
    ]
    
    for query in queries:
        print(f"\n{'='*60}")
        print(f"クエリ: {query}")
        print('='*60)
        
        results = search_system.search(query, top_k=3)
        
        for i, result in enumerate(results, 1):
            print(f"\n{i}. スコア: {result['score']:.4f}")
            print(f"   テキスト: {result['text']}")
            print(f"   ソース: {result['source']}")
    
    # 接続を閉じる
    search_system.close()

if __name__ == "__main__":
    main()
```

実行：

Bobに以下のように依頼：
```
search.pyを実行してください
```

**期待される出力:**
```
============================================================
クエリ: ニューラルネットワークについて教えて
============================================================

1. スコア: 0.8523
   テキスト: 深層学習は、人工ニューラルネットワークを使用した機械学習の手法で...
   ソース: sample_data.txt

2. スコア: 0.7891
   テキスト: 機械学習は、コンピュータがデータから学習し...
   ソース: sample_data.txt

3. スコア: 0.7234
   テキスト: トランスフォーマーは、注意機構を使用した深層学習アーキテクチャで...
   ソース: sample_data.txt
```

### 3.2 対話型検索インターフェース

IBM Bob IDEで`interactive_search.py`を作成します。Bobに以下のように依頼：

```
interactive_search.pyというファイルを作成して、以下のコードを記入してください：
```

コード内容：

```python
from search import VectorSearch

def interactive_search():
    """対話型検索インターフェース"""
    
    print("="*60)
    print("ベクトル検索システム - 対話モード")
    print("="*60)
    print("終了するには 'quit' または 'exit' と入力してください\n")
    
    # 検索システムを初期化
    search_system = VectorSearch()
    
    try:
        while True:
            # ユーザー入力を取得
            query = input("\n検索クエリを入力してください: ").strip()
            
            # 終了コマンドをチェック
            if query.lower() in ['quit', 'exit', 'q']:
                print("\n検索システムを終了します")
                break
            
            if not query:
                print("クエリを入力してください")
                continue
            
            # 検索を実行
            print(f"\n検索中: '{query}'...")
            results = search_system.search(query, top_k=5)
            
            # 結果を表示
            print(f"\n{len(results)}件の結果が見つかりました:\n")
            
            for i, result in enumerate(results, 1):
                print(f"{i}. スコア: {result['score']:.4f}")
                print(f"   {result['text']}")
                print()
    
    except KeyboardInterrupt:
        print("\n\n検索システムを終了します")
    
    finally:
        search_system.close()

if __name__ == "__main__":
    interactive_search()
```

実行：

Bobに以下のように依頼：
```
interactive_search.pyを実行してください
```

## まとめ

### 学んだこと

1. **ベクトルデータベースの基礎**
   - Milvusへの接続とコレクション作成
   - HNSWインデックスの設定
   - ベクトルデータの投入

2. **埋め込みモデルの活用**
   - IBM Watsonx.aiの埋め込みモデル
   - テキストのベクトル化
   - バッチ処理による効率化

3. **セマンティック検索の実装**
   - コサイン類似度による検索
   - 検索パラメータのチューニング
   - 結果のフォーマットと表示

### 次のステップ

1. **データの拡張**
   - より大きなデータセットでの実験
   - 異なるドメインのデータの追加
   - メタデータフィルタリングの活用

2. **検索の改善**
   - ハイブリッド検索の実装
   - リランキングの追加
   - 検索パラメータの最適化

3. **本番環境への展開**
   - パフォーマンスモニタリング
   - スケーリング戦略
   - セキュリティ強化

### トラブルシューティング

**接続エラーが発生する場合:**
- `.env`ファイルの設定を確認
- 講師のIPアドレスが正しいか確認
- ファイアウォール設定を確認

**埋め込み生成が遅い場合:**
- バッチサイズを調整（100-500推奨）
- ネットワーク接続を確認
- API制限を確認

**検索結果が期待と異なる場合:**
- 検索パラメータ（ef値）を調整
- top_kの値を変更
- データの品質を確認

### リソース

- [Milvus公式ドキュメント](https://milvus.io/docs)
- [IBM Watsonx.ai ドキュメント](https://www.ibm.com/docs/en/watsonx-as-a-service)
- [ベクトル検索のベストプラクティス](https://milvus.io/docs/performance_faq.md)

## 質問とフィードバック

ハンズオン中に質問がある場合は、遠慮なく講師にお尋ねください。

---

**ハンズオン完了おめでとうございます！** 🎉