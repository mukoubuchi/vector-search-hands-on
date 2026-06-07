"""
Sample data insertion script

Inserts sample product data into Milvus.
"""

import os
from pathlib import Path
from pymilvus import connections, Collection, utility

from common import (
    IS_JA,
    PARTICIPANT_LANGUAGE,
    connect_to_milvus,
    load_embedding_model,
    msg,
)
from sample_products import get_sample_products
from schema import (
    INDEX_PARAMS,
    VECTOR_FIELD,
    build_collection_schema,
    get_collection_name,
    product_text,
)


SAMPLE_PRODUCTS = get_sample_products(PARTICIPANT_LANGUAGE)
COLLECTION_NAME = get_collection_name()


def print_start_commands():
    """Show commands that work from the current directory."""
    participant_dir = Path(__file__).resolve().parent
    current_dir = Path.cwd().resolve()
    venv_python = "venv\\Scripts\\python" if os.name == "nt" else "venv/bin/python"
    participant_cd = "setup\\participant" if os.name == "nt" else "setup/participant"
    python_command = f"{venv_python} app.py" if (participant_dir / "venv").exists() else "python app.py"

    if current_dir == participant_dir:
        print(f"  {python_command}")
    else:
        print(f"  cd {participant_cd}")
        print(f"  {python_command}")


def drop_existing_collection():
    """Drop existing collection"""
    if not utility.has_collection(COLLECTION_NAME):
        return

    print(f"\n{msg('Dropping existing collection', '既存のコレクションを削除中')}: {COLLECTION_NAME}")
    utility.drop_collection(COLLECTION_NAME)
    print(f"✓ {msg('Collection dropped', 'コレクションを削除しました')}: {COLLECTION_NAME}")


def create_collection():
    """Create collection"""
    print(f"\n{msg('Creating collection', 'コレクションを作成中')}: {COLLECTION_NAME}")

    collection = Collection(name=COLLECTION_NAME, schema=build_collection_schema())

    print(f"✓ {msg('Collection created', 'コレクションを作成しました')}: {COLLECTION_NAME}")
    return collection


def create_index(collection):
    """Create index"""
    print(f"\n{msg('Creating index...', 'インデックスを作成中...')}")

    collection.create_index(field_name=VECTOR_FIELD, index_params=INDEX_PARAMS)
    print(msg("✓ Index created", "✓ インデックスを作成しました"))


def insert_data(collection, embedding_model):
    """Insert data"""
    item_unit = "件" if IS_JA else "items"
    print(f"\n{msg('Inserting sample data...', 'サンプルデータを挿入中...')} ({len(SAMPLE_PRODUCTS)} {item_unit})")

    # Combine product name and description into text
    texts = [
        product_text(p)
        for p in SAMPLE_PRODUCTS
    ]

    # Convert text to vectors
    print(msg("  Generating embedding vectors...", "  埋め込みベクトルを生成中..."))
    embeddings = embedding_model.encode(texts, normalize_embeddings=True)

    # Prepare data
    data = [
        [p["product_name"] for p in SAMPLE_PRODUCTS],
        [p["price"] for p in SAMPLE_PRODUCTS],
        [p["category"] for p in SAMPLE_PRODUCTS],
        [p["description"] for p in SAMPLE_PRODUCTS],
        embeddings.tolist()
    ]

    # Insert data
    collection.insert(data)
    collection.flush()

    print(f"✓ {len(SAMPLE_PRODUCTS)} {msg('items inserted', '件のデータを挿入しました')}")


def main():
    """Main process"""
    print("=" * 50)
    print(msg("Sample Data Insertion Script", "サンプルデータ挿入スクリプト"))
    print("=" * 50)

    try:
        connect_to_milvus()
    except Exception as e:
        print(f"✗ {msg('Failed to connect to Milvus', 'Milvus への接続に失敗しました')}: {e}")
        return

    try:
        embedding_model = load_embedding_model()
    except Exception as e:
        print(f"✗ {msg('Failed to load embedding model', '埋め込みモデルの読み込みに失敗しました')}: {e}")
        return

    drop_existing_collection()

    # Create collection
    collection = create_collection()

    # Insert data
    insert_data(collection, embedding_model)

    # Create index
    create_index(collection)

    # Load collection
    print(f"\n{msg('Loading collection...', 'コレクションを読み込み中...')}")
    collection.load()
    print(msg("✓ Collection loaded", "✓ コレクションを読み込みました"))

    # Display results
    print("\n" + "=" * 50)
    print(msg("✓ Sample data insertion completed", "✓ サンプルデータの挿入が完了しました"))
    print("=" * 50)
    print(f"\n{msg('Collection name', 'コレクション名')}: {COLLECTION_NAME}")
    print(f"{msg('Entity count', 'エンティティ数')}: {collection.num_entities}")
    print(f"\n{msg('You can start the demo application', 'デモアプリケーションを起動できます')}:")
    print_start_commands()
    print("=" * 50 + "\n")

    # Disconnect
    connections.disconnect("default")


if __name__ == "__main__":
    main()
