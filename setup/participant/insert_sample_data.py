"""
サンプルデータ投入スクリプト

Milvusにサンプル商品データを投入します。
"""

import os
from pymilvus import connections, Collection, FieldSchema, CollectionSchema, DataType, utility
from sentence_transformers import SentenceTransformer
from dotenv import load_dotenv

# 環境変数の読み込み
load_dotenv()

# 設定
MILVUS_HOST = os.getenv("MILVUS_HOST", "localhost")
MILVUS_PORT = int(os.getenv("MILVUS_PORT", "19530"))
MILVUS_USER = os.getenv("MILVUS_USER", "root")
MILVUS_PASSWORD = os.getenv("MILVUS_PASSWORD", "Milvus")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "paraphrase-multilingual-MiniLM-L12-v2")
EMBEDDING_DIMENSION = int(os.getenv("EMBEDDING_DIMENSION", "384"))
COLLECTION_NAME = os.getenv("COLLECTION_NAME", "knowledge_base")

# サンプル商品データ
SAMPLE_PRODUCTS = [
    {
        "product_name": "赤いランニングシューズ",
        "price": 8900,
        "category": "スニーカー",
        "description": "軽量で通気性の良いランニングシューズ。初心者から上級者まで幅広く対応。"
    },
    {
        "product_name": "レッドスポーツシューズ",
        "price": 7500,
        "category": "スニーカー",
        "description": "カジュアルにもスポーツにも使える万能シューズ。クッション性に優れています。"
    },
    {
        "product_name": "赤色のトレーニングシューズ",
        "price": 9800,
        "category": "スニーカー",
        "description": "ジムでのトレーニングに最適。安定性とグリップ力が特徴。"
    },
    {
        "product_name": "初心者向けデジタルカメラ",
        "price": 45000,
        "category": "カメラ",
        "description": "簡単操作で高画質。初めてのカメラに最適な入門モデル。"
    },
    {
        "product_name": "入門用ミラーレスカメラ",
        "price": 52000,
        "category": "カメラ",
        "description": "軽量コンパクトで持ち運びやすい。ビギナーにおすすめのミラーレス。"
    },
    {
        "product_name": "ビジネス向けノートパソコン",
        "price": 98000,
        "category": "パソコン",
        "description": "軽量で長時間バッテリー。ビジネスシーンに最適なノートPC。"
    },
    {
        "product_name": "オフィス用ノートPC",
        "price": 85000,
        "category": "パソコン",
        "description": "文書作成やWeb会議に十分な性能。コストパフォーマンスに優れています。"
    },
    {
        "product_name": "高性能ゲーミングPC",
        "price": 198000,
        "category": "パソコン",
        "description": "最新ゲームも快適にプレイ可能。高性能グラフィックカード搭載。"
    },
    {
        "product_name": "プロ向けゲーミングデスクトップ",
        "price": 250000,
        "category": "パソコン",
        "description": "eスポーツプレイヤー向けの最高性能モデル。4K解像度でも滑らか。"
    },
    {
        "product_name": "青いカジュアルスニーカー",
        "price": 6800,
        "category": "スニーカー",
        "description": "デイリーユースに最適なカジュアルシューズ。履き心地抜群。"
    },
    {
        "product_name": "プロ向け一眼レフカメラ",
        "price": 180000,
        "category": "カメラ",
        "description": "プロフェッショナル向けの高性能一眼レフ。あらゆるシーンに対応。"
    },
    {
        "product_name": "軽量ビジネスバッグ",
        "price": 12000,
        "category": "バッグ",
        "description": "ノートPCも収納可能な軽量ビジネスバッグ。防水加工済み。"
    }
]


def create_collection():
    """コレクションを作成"""
    print(f"\nコレクション '{COLLECTION_NAME}' を作成中...")
    
    # スキーマ定義
    fields = [
        FieldSchema(name="id", dtype=DataType.INT64, is_primary=True, auto_id=True),
        FieldSchema(name="product_name", dtype=DataType.VARCHAR, max_length=200),
        FieldSchema(name="price", dtype=DataType.INT64),
        FieldSchema(name="category", dtype=DataType.VARCHAR, max_length=100),
        FieldSchema(name="description", dtype=DataType.VARCHAR, max_length=500),
        FieldSchema(name="embedding", dtype=DataType.FLOAT_VECTOR, dim=EMBEDDING_DIMENSION)
    ]
    
    schema = CollectionSchema(fields=fields, description="商品データベース")
    collection = Collection(name=COLLECTION_NAME, schema=schema)
    
    print(f"✓ コレクション '{COLLECTION_NAME}' を作成しました")
    return collection


def create_index(collection):
    """インデックスを作成"""
    print("\nインデックスを作成中...")
    
    index_params = {
        "metric_type": "L2",
        "index_type": "IVF_FLAT",
        "params": {"nlist": 128}
    }
    
    collection.create_index(field_name="embedding", index_params=index_params)
    print("✓ インデックスを作成しました")


def insert_data(collection, embedding_model):
    """データを投入"""
    print(f"\nサンプルデータを投入中... ({len(SAMPLE_PRODUCTS)}件)")
    
    # 商品名と説明を結合してテキストを作成
    texts = [
        f"{p['product_name']} {p['description']}"
        for p in SAMPLE_PRODUCTS
    ]
    
    # テキストをベクトルに変換
    print("  埋め込みベクトルを生成中...")
    embeddings = embedding_model.encode(texts)
    
    # データを準備
    data = [
        [p["product_name"] for p in SAMPLE_PRODUCTS],
        [p["price"] for p in SAMPLE_PRODUCTS],
        [p["category"] for p in SAMPLE_PRODUCTS],
        [p["description"] for p in SAMPLE_PRODUCTS],
        embeddings.tolist()
    ]
    
    # データを投入
    collection.insert(data)
    collection.flush()
    
    print(f"✓ {len(SAMPLE_PRODUCTS)}件のデータを投入しました")


def main():
    """メイン処理"""
    print("=" * 50)
    print("サンプルデータ投入スクリプト")
    print("=" * 50)
    
    # Milvusに接続
    print(f"\nMilvusに接続中: {MILVUS_HOST}:{MILVUS_PORT}")
    try:
        connections.connect(
            alias="default",
            host=MILVUS_HOST,
            port=MILVUS_PORT,
            user=MILVUS_USER,
            password=MILVUS_PASSWORD
        )
        print("✓ Milvusへの接続に成功しました")
    except Exception as e:
        print(f"✗ Milvusへの接続に失敗しました: {e}")
        return
    
    # 埋め込みモデルのロード
    print(f"\n埋め込みモデルをロード中: {EMBEDDING_MODEL}")
    try:
        embedding_model = SentenceTransformer(EMBEDDING_MODEL)
        print("✓ 埋め込みモデルのロードに成功しました")
    except Exception as e:
        print(f"✗ 埋め込みモデルのロードに失敗しました: {e}")
        return
    
    # 既存のコレクションを削除（存在する場合）
    if utility.has_collection(COLLECTION_NAME):
        print(f"\n既存のコレクション '{COLLECTION_NAME}' を削除中...")
        utility.drop_collection(COLLECTION_NAME)
        print(f"✓ コレクション '{COLLECTION_NAME}' を削除しました")
    
    # コレクションを作成
    collection = create_collection()
    
    # データを投入
    insert_data(collection, embedding_model)
    
    # インデックスを作成
    create_index(collection)
    
    # コレクションをロード
    print("\nコレクションをロード中...")
    collection.load()
    print("✓ コレクションをロードしました")
    
    # 結果を表示
    print("\n" + "=" * 50)
    print("✓ サンプルデータの投入が完了しました")
    print("=" * 50)
    print(f"\nコレクション名: {COLLECTION_NAME}")
    print(f"エンティティ数: {collection.num_entities}")
    print(f"\nデモアプリケーションを起動できます:")
    print("  cd setup/participant")
    print("  python app.py")
    print("=" * 50 + "\n")
    
    # 接続を切断
    connections.disconnect("default")


if __name__ == "__main__":
    main()

# Made with Bob
