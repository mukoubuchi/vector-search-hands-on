"""
Vector Search Demo Application

This application compares keyword (BM25), vector (k-NN) and hybrid search
on the same OpenSearch index, using IBM watsonx.ai embeddings.
"""

from contextlib import asynccontextmanager
from typing import Any, Dict, List, Literal, Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from opensearchpy import OpenSearch
from pydantic import BaseModel, Field
import uvicorn

from common import embed_query, get_embeddings, get_opensearch_client, msg
from index_mapping import (
    KEYWORD_SEARCH_FIELDS,
    PRODUCT_SOURCE_FIELDS,
    VECTOR_FIELD,
    get_index_name,
)


INDEX_NAME = get_index_name()

# Hybrid search merges two ranked lists, so each side needs more candidates
# than the caller asked for
HYBRID_CANDIDATE_MULTIPLIER = 4
HYBRID_MIN_CANDIDATES = 20

# Global variables
embeddings = None
client: Optional[OpenSearch] = None


def index_exists() -> bool:
    """Return True when the configured index is present."""
    return client is not None and client.indices.exists(index=INDEX_NAME)


def keyword_body(query: str, size: int) -> Dict[str, Any]:
    """BM25 keyword search over the analysed text fields."""
    return {
        "size": size,
        "_source": PRODUCT_SOURCE_FIELDS,
        "query": {"multi_match": {"query": query, "fields": KEYWORD_SEARCH_FIELDS}},
    }


def vector_body(query_vector: List[float], size: int) -> Dict[str, Any]:
    """k-NN vector search over the embedding field."""
    return {
        "size": size,
        "_source": PRODUCT_SOURCE_FIELDS,
        "query": {"knn": {VECTOR_FIELD: {"vector": query_vector, "k": size}}},
    }


def run_search(body: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Run a search and return its raw hits."""
    if client is None:
        raise RuntimeError("OpenSearch client is not initialised")
    return client.search(index=INDEX_NAME, body=body)["hits"]["hits"]


def normalise_scores(hits: List[Dict[str, Any]]) -> Dict[str, float]:
    """Min-max normalise hit scores to 0-1, keyed by document id.

    The two rankings use different score scales (BM25 is unbounded, k-NN is
    a similarity), so they cannot be added until both are on one scale.
    """
    if not hits:
        return {}

    scores = [hit["_score"] for hit in hits]
    lowest, highest = min(scores), max(scores)
    span = highest - lowest
    if span == 0:
        # A single hit, or an exact tie: treat every hit as a full match
        return {hit["_id"]: 1.0 for hit in hits}

    return {hit["_id"]: (hit["_score"] - lowest) / span for hit in hits}


def hybrid_hits(query: str, query_vector: List[float], top_k: int,
                vector_weight: float) -> List[Dict[str, Any]]:
    """Combine BM25 and k-NN results with normalised scores."""
    candidates = max(top_k * HYBRID_CANDIDATE_MULTIPLIER, HYBRID_MIN_CANDIDATES)

    keyword_results = run_search(keyword_body(query, candidates))
    vector_results = run_search(vector_body(query_vector, candidates))

    keyword_scores = normalise_scores(keyword_results)
    vector_scores = normalise_scores(vector_results)

    sources = {hit["_id"]: hit for hit in keyword_results + vector_results}
    merged = []
    for document_id, hit in sources.items():
        keyword_score = keyword_scores.get(document_id, 0.0)
        vector_score = vector_scores.get(document_id, 0.0)
        combined = vector_weight * vector_score + (1 - vector_weight) * keyword_score
        merged.append({
            "hit": hit,
            "score": combined,
            "keyword_score": keyword_score,
            "vector_score": vector_score,
        })

    merged.sort(key=lambda item: item["score"], reverse=True)
    return merged[:top_k]


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown handler"""
    global embeddings, client

    print("=" * 50)
    print(msg("Starting Vector Search Demo Application...",
              "ベクトル検索デモアプリケーションを起動中..."))
    print("=" * 50)

    try:
        client = get_opensearch_client()
    except Exception as e:
        print(f"✗ {msg('Failed to connect to OpenSearch', 'OpenSearch への接続に失敗しました')}: {e}")
        raise

    try:
        embeddings = get_embeddings()
    except Exception as e:
        print(f"✗ {msg('Failed to prepare watsonx.ai embeddings', 'watsonx.ai の埋め込み準備に失敗しました')}: {e}")
        raise

    if index_exists():
        document_count = client.count(index=INDEX_NAME)["count"]
        print(f"✓ {msg('Index found', 'インデックスを確認しました')}: {INDEX_NAME} "
              f"({document_count} {msg('documents', '件')})")
    else:
        print(f"⚠ {msg('Index does not exist', 'インデックスが存在しません')}: {INDEX_NAME}")
        print(msg("  Please insert sample data", "  サンプルデータを投入してください"))

    print("\n" + "=" * 50)
    print(msg("✓ Application started successfully", "✓ アプリケーションを起動しました"))
    print("=" * 50)
    print("\nSwagger UI: http://localhost:8002/docs")
    print("=" * 50 + "\n")

    yield

    print(f"\n{msg('Shutting down application...', 'アプリケーションを停止中...')}")
    if client is not None:
        client.close()
        print(msg("✓ Disconnected from OpenSearch", "✓ OpenSearch から切断しました"))


# FastAPI application
app = FastAPI(
    title=msg("Vector Search Demo API", "ベクトル検索デモ API"),
    description=msg("Keyword, vector and hybrid search demo API using OpenSearch",
                    "OpenSearch を使ったキーワード・ベクトル・ハイブリッド検索のデモ API"),
    version="2.0.0",
    lifespan=lifespan
)

# CORS settings. The demo API carries no cookies or auth, and a browser
# ignores Access-Control-Allow-Credentials when the allowed origin is "*",
# so asking for credentials here would only be misleading.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


class SearchRequest(BaseModel):
    """Search request"""
    query: str = Field(min_length=1)
    mode: Literal["keyword", "vector", "hybrid"] = "hybrid"
    top_k: int = Field(default=5, ge=1, le=100)
    vector_weight: float = Field(
        default=0.5, ge=0.0, le=1.0,
        description="Weight of the vector side in hybrid mode (0 = keyword only, 1 = vector only)",
    )


class SearchResult(BaseModel):
    """Search result"""
    product_name: str
    score: float
    price: int
    category: str
    description: str
    keyword_score: Optional[float] = None
    vector_score: Optional[float] = None


class SearchResponse(BaseModel):
    """Search response"""
    mode: str
    results: List[SearchResult]


def to_result(source: Dict[str, Any], score: float,
              keyword_score: Optional[float] = None,
              vector_score: Optional[float] = None) -> SearchResult:
    """Build one API result from an OpenSearch hit."""
    return SearchResult(
        product_name=source["product_name"],
        score=round(score, 4),
        price=source["price"],
        category=source["category"],
        description=source["description"],
        keyword_score=None if keyword_score is None else round(keyword_score, 4),
        vector_score=None if vector_score is None else round(vector_score, 4),
    )


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
        if client is None:
            raise RuntimeError("OpenSearch client is not initialised")

        status = client.cluster.health()["status"]
        if not index_exists():
            return {
                "status": "warning",
                "message": msg("Index does not exist", "インデックスが存在しません"),
                "opensearch": status,
                "index": "not_found"
            }

        return {
            "status": "healthy",
            "opensearch": status,
            "index": INDEX_NAME,
            "documents": client.count(index=INDEX_NAME)["count"]
        }
    except Exception as e:
        raise HTTPException(
            status_code=503,
            detail=f"{msg('Service unavailable', 'サービスを利用できません')}: {str(e)}"
        )


@app.post(
    "/search",
    response_model=SearchResponse,
    summary=msg("Execute a search", "検索を実行"),
    description=msg(
        '- **query**: Search query (e.g. "red sneakers")\n'
        "- **mode**: keyword (BM25), vector (k-NN) or hybrid (both, default)\n"
        "- **top_k**: Number of results to return (default: 5, range: 1-100)\n"
        "- **vector_weight**: Weight of the vector side in hybrid mode (default: 0.5)",
        '- **query**: 検索クエリ（例: "赤いスニーカー"）\n'
        "- **mode**: keyword（BM25）、vector（k-NN）、hybrid（両方。既定）\n"
        "- **top_k**: 返す検索結果の件数（デフォルト: 5、範囲: 1-100）\n"
        "- **vector_weight**: hybrid でのベクトル側の重み（デフォルト: 0.5）",
    ),
)
def search(request: SearchRequest):
    """Execute a keyword, vector or hybrid search."""
    if client is None or embeddings is None:
        raise HTTPException(
            status_code=503,
            detail=msg("The application is not ready.", "アプリケーションの準備ができていません。")
        )

    if not index_exists():
        raise HTTPException(
            status_code=503,
            detail=msg(
                "Index does not exist. Please insert sample data.",
                "インデックスが存在しません。サンプルデータを投入してください。"
            )
        )

    try:
        if request.mode == "keyword":
            hits = run_search(keyword_body(request.query, request.top_k))
            results = [to_result(hit["_source"], hit["_score"], keyword_score=hit["_score"])
                       for hit in hits]
        else:
            query_vector = embed_query(embeddings, request.query)

            if request.mode == "vector":
                hits = run_search(vector_body(query_vector, request.top_k))
                results = [to_result(hit["_source"], hit["_score"], vector_score=hit["_score"])
                           for hit in hits]
            else:
                merged = hybrid_hits(request.query, query_vector,
                                     request.top_k, request.vector_weight)
                results = [
                    to_result(item["hit"]["_source"], item["score"],
                              keyword_score=item["keyword_score"],
                              vector_score=item["vector_score"])
                    for item in merged
                ]

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"{msg('Error during search', '検索中にエラーが発生しました')}: {str(e)}"
        )

    return SearchResponse(mode=request.mode, results=results)


if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8002,
        reload=True,
        log_level="info"
    )
