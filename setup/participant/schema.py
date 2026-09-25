"""Milvus collection schema shared by the demo app and data loader."""

from pymilvus import CollectionSchema, DataType, MilvusClient
from pymilvus.milvus_client import IndexParams

from common import DEFAULT_COLLECTION_NAME, get_env, msg, reject_placeholder


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
    name = get_env("COLLECTION_NAME", DEFAULT_COLLECTION_NAME) or DEFAULT_COLLECTION_NAME
    return reject_placeholder("COLLECTION_NAME", name.strip())


def build_collection_schema(embedding_dimension: int) -> CollectionSchema:
    """Build the product collection schema for the given embedding dimension."""
    schema = MilvusClient.create_schema(description=msg("Product database", "商品データベース"))
    schema.add_field(field_name="id", datatype=DataType.INT64, is_primary=True, auto_id=True)
    schema.add_field(field_name="product_name", datatype=DataType.VARCHAR, max_length=200)
    schema.add_field(field_name="price", datatype=DataType.INT64)
    schema.add_field(field_name="category", datatype=DataType.VARCHAR, max_length=100)
    schema.add_field(field_name="description", datatype=DataType.VARCHAR, max_length=500)
    schema.add_field(field_name=VECTOR_FIELD, datatype=DataType.FLOAT_VECTOR, dim=embedding_dimension)
    return schema


def build_index_params() -> IndexParams:
    """Build the vector index settings from INDEX_PARAMS."""
    index_params = MilvusClient.prepare_index_params()
    index_params.add_index(
        field_name=VECTOR_FIELD,
        index_type=INDEX_PARAMS["index_type"],
        metric_type=INDEX_PARAMS["metric_type"],
        params=INDEX_PARAMS["params"],
    )
    return index_params


def product_text(product: dict) -> str:
    """Return the text used to generate a product embedding."""
    return f"{product['product_name']} {product['description']}"
