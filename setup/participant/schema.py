"""Milvus collection schema shared by the demo app and data loader."""

from pymilvus import CollectionSchema, DataType, FieldSchema

from common import DEFAULT_COLLECTION_NAME, DEFAULT_EMBEDDING_DIMENSION, get_int_env, msg


VECTOR_FIELD = "embedding"
PRODUCT_OUTPUT_FIELDS = ["product_name", "price", "category", "description"]

INDEX_PARAMS = {
    "metric_type": "COSINE",
    "index_type": "IVF_FLAT",
    "params": {"nlist": 128},
}

SEARCH_PARAMS = {
    "metric_type": "COSINE",
    "params": {"nprobe": 10},
}


def get_collection_name() -> str:
    """Return the configured collection name."""
    from common import get_env

    return get_env("COLLECTION_NAME", DEFAULT_COLLECTION_NAME) or DEFAULT_COLLECTION_NAME


def get_embedding_dimension() -> int:
    """Return the configured embedding dimension."""
    return get_int_env("EMBEDDING_DIMENSION", DEFAULT_EMBEDDING_DIMENSION)


def build_collection_schema() -> CollectionSchema:
    """Build the product collection schema."""
    fields = [
        FieldSchema(name="id", dtype=DataType.INT64, is_primary=True, auto_id=True),
        FieldSchema(name="product_name", dtype=DataType.VARCHAR, max_length=200),
        FieldSchema(name="price", dtype=DataType.INT64),
        FieldSchema(name="category", dtype=DataType.VARCHAR, max_length=100),
        FieldSchema(name="description", dtype=DataType.VARCHAR, max_length=500),
        FieldSchema(name=VECTOR_FIELD, dtype=DataType.FLOAT_VECTOR, dim=get_embedding_dimension()),
    ]

    return CollectionSchema(fields=fields, description=msg("Product database", "商品データベース"))


def product_text(product: dict) -> str:
    """Return the text used to generate a product embedding."""
    return f"{product['product_name']} {product['description']}"
