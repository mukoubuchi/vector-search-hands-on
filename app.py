"""
Vector Search デモアプリケーション

このアプリケーションは、Milvusを使用したベクトル検索のデモを提供します。
"""

import os
from typing import List, Optional
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from pymilvus import connections, Collection, utility
from sentence_transformers import SentenceTransformer
from dotenv import load_dotenv
import uvicorn

# 環境変数の読み込み
load_dotenv("setup/participant/.env")

# 設定
MILVUS_HOST = os.getenv("MILVUS_HOST", "localhost")
MILVUS_PORT = int(os.getenv("MILVUS_PORT", "19530"))
MILVUS_USER = os.getenv("MILVUS_USER", "root")
MILVUS_PASSWORD = os.getenv("MILVUS_PASSWORD", "Milvus")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "paraphrase-multilingual-MiniLM-L12-v2")
COLLECTION_NAME = os.getenv("COLLECTION_NAME", "knowledge_base")

# FastAPIアプリケーション
app = FastAPI(
    title="Vector Search Demo API",
    description="Milvusを使用したベクトル検索のデモAPI",
    version="1.0.0"
)

# CORS設定
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# グローバル変数
embedding_model = None
collection = None


class SearchRequest(BaseModel):
    """検索リクエスト"""
    query: str
    top_k: int = 5


class SearchResult(BaseModel):
    """検索結果"""
    product_name: str
    similarity_score: float
    price: int
    category: str
    description: str


class SearchResponse(BaseModel):
    """検索レスポンス"""
    results: List[SearchResult]


@app.on_event("startup")
async def startup_event():
    """アプリケーション起動時の処理"""
    global embedding_model, collection
    
    print("=" * 50)
    print("Vector Search デモアプリケーション起動中...")
    print("=" * 50)
    
    # 埋め込みモデルのロード
    print(f"\n埋め込みモデルをロード中: {EMBEDDING_MODEL}")
    try:
        embedding_model = SentenceTransformer(EMBEDDING_MODEL)
        print("✓ 埋め込みモデルのロードに成功しました")
    except Exception as e:
        print(f"✗ 埋め込みモデルのロードに失敗しました: {e}")
        raise
    
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
        raise
    
    # コレクションの確認
    print(f"\nコレクションを確認中: {COLLECTION_NAME}")
    try:
        if utility.has_collection(COLLECTION_NAME):
            collection = Collection(COLLECTION_NAME)
            collection.load()
            print(f"✓ コレクション '{COLLECTION_NAME}' をロードしました")
            print(f"  エンティティ数: {collection.num_entities}")
        else:
            print(f"⚠ コレクション '{COLLECTION_NAME}' が存在しません")
            print("  サンプルデータを投入してください")
    except Exception as e:
        print(f"✗ コレクションのロードに失敗しました: {e}")
        raise
    
    print("\n" + "=" * 50)
    print("✓ アプリケーションの起動が完了しました")
    print("=" * 50)
    print(f"\nSwagger UI: http://localhost:8000/docs")
    print("=" * 50 + "\n")


@app.on_event("shutdown")
async def shutdown_event():
    """アプリケーション終了時の処理"""
    print("\nアプリケーションを終了しています...")
    try:
        connections.disconnect("default")
        print("✓ Milvusから切断しました")
    except Exception as e:
        print(f"⚠ 切断時にエラーが発生しました: {e}")


@app.get("/")
async def root():
    """ルートエンドポイント"""
    return {
        "message": "Vector Search Demo API",
        "docs": "/docs",
        "health": "/health"
    }


@app.get("/health")
async def health_check():
    """ヘルスチェック"""
    try:
        # Milvus接続確認
        connections.get_connection_addr("default")
        
        # コレクション確認
        if collection is None:
            return {
                "status": "warning",
                "message": "コレクションが存在しません",
                "milvus": "connected",
                "collection": "not_found"
            }
        
        return {
            "status": "healthy",
            "milvus": "connected",
            "collection": COLLECTION_NAME,
            "entities": collection.num_entities
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"サービスが利用できません: {str(e)}")


@app.post("/search", response_model=SearchResponse)
async def search(request: SearchRequest):
    """
    ベクトル検索を実行
    
    - **query**: 検索クエリ（例: "赤いスニーカー"）
    - **top_k**: 返す結果の数（デフォルト: 5）
    """
    if collection is None:
        raise HTTPException(
            status_code=503,
            detail="コレクションが存在しません。サンプルデータを投入してください。"
        )
    
    try:
        # クエリをベクトルに変換
        query_vector = embedding_model.encode([request.query])[0].tolist()
        
        # ベクトル検索を実行
        search_params = {
            "metric_type": "L2",
            "params": {"nprobe": 10}
        }
        
        results = collection.search(
            data=[query_vector],
            anns_field="embedding",
            param=search_params,
            limit=request.top_k,
            output_fields=["product_name", "price", "category", "description"]
        )
        
        # 結果を整形
        search_results = []
        for hits in results:
            for hit in hits:
                # 距離を類似度スコアに変換（L2距離を0-1の範囲に正規化）
                # 距離が小さいほど類似度が高い
                similarity_score = 1.0 / (1.0 + hit.distance)
                
                search_results.append(SearchResult(
                    product_name=hit.entity.get("product_name"),
                    similarity_score=round(similarity_score, 4),
                    price=hit.entity.get("price"),
                    category=hit.entity.get("category"),
                    description=hit.entity.get("description")
                ))
        
        return SearchResponse(results=search_results)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"検索中にエラーが発生しました: {str(e)}")


if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )

# Made with Bob
