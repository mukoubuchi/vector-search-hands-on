"""
Vector Search Demo Application

This application provides a vector search demo using Milvus.
"""

from contextlib import asynccontextmanager
from typing import Any, List, Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from pymilvus import connections, Collection, utility
from sentence_transformers import SentenceTransformer
import uvicorn

from common import connect_to_milvus, load_embedding_model, msg
from schema import PRODUCT_OUTPUT_FIELDS, SEARCH_PARAMS, VECTOR_FIELD, get_collection_name


COLLECTION_NAME = get_collection_name()

# Global variables
embedding_model: Optional[SentenceTransformer] = None
collection: Optional[Collection] = None


def load_collection() -> Optional[Collection]:
    """Load Milvus collection"""
    print(f"\n{msg('Checking collection', 'コレクションを確認中')}: {COLLECTION_NAME}")

    if not utility.has_collection(COLLECTION_NAME):
        print(f"⚠ {msg('Collection does not exist', 'コレクションが存在しません')}: {COLLECTION_NAME}")
        print(msg("  Please insert sample data", "  サンプルデータを投入してください"))
        return None

    loaded_collection = Collection(COLLECTION_NAME)
    loaded_collection.load()
    print(f"✓ {msg('Collection loaded', 'コレクションを読み込みました')}: {COLLECTION_NAME}")
    print(f"  {msg('Entity count', 'エンティティ数')}: {loaded_collection.num_entities}")
    return loaded_collection


def get_collection() -> Optional[Collection]:
    """Return the cached collection, loading it lazily if data was inserted after startup."""
    global collection
    if collection is None:
        collection = load_collection()
    return collection


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown handler"""
    global embedding_model, collection

    print("=" * 50)
    print(msg("Starting Vector Search Demo Application...", "ベクトル検索デモアプリケーションを起動中..."))
    print("=" * 50)

    try:
        embedding_model = load_embedding_model()
    except Exception as e:
        print(f"✗ {msg('Failed to load embedding model', '埋め込みモデルの読み込みに失敗しました')}: {e}")
        raise

    try:
        connect_to_milvus()
    except Exception as e:
        print(f"✗ {msg('Failed to connect to Milvus', 'Milvus への接続に失敗しました')}: {e}")
        raise

    try:
        collection = load_collection()
    except Exception as e:
        print(f"✗ {msg('Failed to load collection', 'コレクションの読み込みに失敗しました')}: {e}")
        raise

    print("\n" + "=" * 50)
    print(msg("✓ Application started successfully", "✓ アプリケーションを起動しました"))
    print("=" * 50)
    print("\nSwagger UI: http://localhost:8002/docs")
    print("=" * 50 + "\n")

    yield

    print(f"\n{msg('Shutting down application...', 'アプリケーションを停止中...')}")
    try:
        connections.disconnect("default")
        print(msg("✓ Disconnected from Milvus", "✓ Milvus から切断しました"))
    except Exception as e:
        print(f"⚠ {msg('Error during disconnect', '切断中にエラーが発生しました')}: {e}")


# FastAPI application
app = FastAPI(
    title=msg("Vector Search Demo API", "ベクトル検索デモ API"),
    description=msg("Vector search demo API using Milvus", "Milvus を使ったベクトル検索のデモ API"),
    version="1.0.0",
    lifespan=lifespan
)

# CORS settings
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class SearchRequest(BaseModel):
    """Search request"""
    query: str = Field(min_length=1)
    top_k: int = Field(default=5, ge=1, le=100)


class SearchResult(BaseModel):
    """Search result"""
    product_name: str
    similarity_score: float
    price: int
    category: str
    description: str


class SearchResponse(BaseModel):
    """Search response"""
    results: List[SearchResult]


def to_similarity_score(score: float) -> float:
    """Convert cosine score to similarity score in range 0-1."""
    return round(max(0.0, min(1.0, score)), 4)


def format_search_results(results: Any) -> List[SearchResult]:
    """Format Milvus search results for API response"""
    search_results = []

    for hits in results:
        for hit in hits:
            search_results.append(SearchResult(
                product_name=hit.entity.get("product_name"),
                similarity_score=to_similarity_score(hit.distance),
                price=hit.entity.get("price"),
                category=hit.entity.get("category"),
                description=hit.entity.get("description")
            ))

    return search_results


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": msg("Vector Search Demo API", "ベクトル検索デモ API"),
        "docs": "/docs",
        "health": "/health"
    }


@app.get("/health")
def health_check():
    """Health check"""
    try:
        # Verify Milvus connection
        connections.get_connection_addr("default")

        # Verify collection
        current_collection = get_collection()
        if current_collection is None:
            return {
                "status": "warning",
                "message": msg("Collection does not exist", "コレクションが存在しません"),
                "milvus": "connected",
                "collection": "not_found"
            }

        return {
            "status": "healthy",
            "milvus": "connected",
            "collection": COLLECTION_NAME,
            "entities": current_collection.num_entities
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"{msg('Service unavailable', 'サービスを利用できません')}: {str(e)}")


@app.post(
    "/search",
    response_model=SearchResponse,
    summary=msg("Execute vector search", "ベクトル検索を実行"),
    description=msg(
        '- **query**: Search query (e.g. "red sneakers")\n'
        "- **top_k**: Number of results to return (default: 5, range: 1-100)",
        '- **query**: 検索クエリ（例: "赤いスニーカー"）\n'
        "- **top_k**: 返す検索結果の件数（デフォルト: 5、範囲: 1-100）",
    ),
)
def search(request: SearchRequest):
    """Execute vector search."""
    current_collection = get_collection()
    if current_collection is None:
        raise HTTPException(
            status_code=503,
            detail=msg(
                "Collection does not exist. Please insert sample data.",
                "コレクションが存在しません。サンプルデータを投入してください。"
            )
        )
    if embedding_model is None:
        raise HTTPException(
            status_code=503,
            detail=msg("Embedding model is not loaded.", "埋め込みモデルが読み込まれていません。")
        )

    try:
        # Convert query to vector
        query_vector = embedding_model.encode(
            [request.query],
            normalize_embeddings=True
        )[0].tolist()

        results = current_collection.search(
            data=[query_vector],
            anns_field=VECTOR_FIELD,
            param=SEARCH_PARAMS,
            limit=request.top_k,
            output_fields=PRODUCT_OUTPUT_FIELDS
        )

        return SearchResponse(results=format_search_results(results))

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"{msg('Error during search', '検索中にエラーが発生しました')}: {str(e)}")


if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8002,
        reload=True,
        log_level="info"
    )
