"""OpenSearch index definition shared by the demo app and the data loader."""

from common import (
    DEFAULT_INDEX_NAME,
    IS_JA,
    get_env,
    reject_placeholder,
)


VECTOR_FIELD = "embedding"
# Fields the BM25 keyword search looks at, and the fields returned to the caller
KEYWORD_SEARCH_FIELDS = ["product_name^2", "description"]
PRODUCT_SOURCE_FIELDS = ["product_name", "price", "category", "description"]

# HNSW build parameters. The upstream Building Block workflow recommends these
# as the balanced starting point for recall against latency.
HNSW_PARAMETERS = {"ef_construction": 128, "m": 24}
EF_SEARCH = 100

# The standard analyzer splits Japanese text into single characters, which makes
# BM25 keyword hits noisy. The built-in CJK analyzer (bigrams) needs no plugin.
TEXT_ANALYZER = "cjk" if IS_JA else "standard"


def get_index_name() -> str:
    """Return the configured index name."""
    name = get_env("INDEX_NAME", DEFAULT_INDEX_NAME) or DEFAULT_INDEX_NAME
    return reject_placeholder("INDEX_NAME", name.strip())


def build_index_body(embedding_dimension: int) -> dict:
    """Build the index definition for the given embedding dimension."""
    return {
        "settings": {
            "index": {
                "knn": True,
                "knn.algo_param.ef_search": EF_SEARCH,
                # The hands-on cluster is a single node, so a replica would
                # stay unassigned and hold the cluster status at yellow
                "number_of_replicas": 0,
            }
        },
        "mappings": {
            "properties": {
                "product_name": {
                    "type": "text",
                    "analyzer": TEXT_ANALYZER,
                    "fields": {"keyword": {"type": "keyword"}},
                },
                "description": {"type": "text", "analyzer": TEXT_ANALYZER},
                "category": {"type": "keyword"},
                "price": {"type": "integer"},
                VECTOR_FIELD: {
                    "type": "knn_vector",
                    "dimension": embedding_dimension,
                    "space_type": "cosinesimil",
                    "method": {
                        "name": "hnsw",
                        "engine": "faiss",
                        "parameters": HNSW_PARAMETERS,
                    },
                },
            }
        },
    }


def product_text(product: dict) -> str:
    """Return the text used to generate a product embedding."""
    return f"{product['product_name']} {product['description']}"
