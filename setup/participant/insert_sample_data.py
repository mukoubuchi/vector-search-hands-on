"""
Sample data insertion script

Creates the k-NN index and inserts sample product data into OpenSearch,
using IBM watsonx.ai to generate the embeddings.
"""

import argparse
import os
import sys
from pathlib import Path

from opensearchpy import helpers

from common import (
    IS_JA,
    PARTICIPANT_LANGUAGE,
    embed_documents,
    embed_query,
    get_embeddings,
    get_opensearch_client,
    msg,
)
from index_mapping import (
    TEXT_ANALYZER,
    VECTOR_FIELD,
    build_index_body,
    get_index_name,
    product_text,
)
from sample_products import get_sample_products


SAMPLE_PRODUCTS = get_sample_products(PARTICIPANT_LANGUAGE)
INDEX_NAME = get_index_name()
DIMENSION_PROBE_TEXT = "dimension probe"


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description=msg("Insert sample product data into OpenSearch",
                        "OpenSearch にサンプル商品データを挿入します")
    )
    parser.add_argument(
        "-y", "--yes",
        action="store_true",
        help=msg(
            "Delete an existing index without asking for confirmation",
            "既存インデックスを確認なしで削除する"
        )
    )
    return parser.parse_args()


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


def confirm_delete(client, assume_yes: bool) -> bool:
    """Ask before deleting an existing index (it may belong to someone else)."""
    document_count = client.count(index=INDEX_NAME)["count"]
    print(f"\n⚠ {msg('Index already exists', 'インデックスは既に存在します')}: "
          f"{INDEX_NAME} ({document_count} {msg('documents', '件')})")
    print(msg(
        "  On a shared OpenSearch, deleting an index also deletes other participants' data.",
        "  共有 OpenSearch では、インデックスを削除すると他の参加者のデータも消えます。"
    ))

    if assume_yes:
        return True

    prompt = msg("Delete and recreate this index? [y/N]: ",
                 "このインデックスを削除して作り直しますか？ [y/N]: ")
    try:
        answer = input(prompt).strip().lower()
    except EOFError:
        answer = ""
    return answer in ("y", "yes")


def delete_existing_index(client, assume_yes: bool) -> bool:
    """Delete an existing index after confirmation. Return False when aborted."""
    if not client.indices.exists(index=INDEX_NAME):
        return True

    if not confirm_delete(client, assume_yes):
        print(f"\n{msg('Aborted. No data was changed.', '中止しました。データは変更されていません。')}")
        print(msg(
            "  To use your own index, set a unique INDEX_NAME in setup/participant/.env "
            "(e.g. products_taro).",
            "  自分専用のインデックスを使うには、setup/participant/.env の INDEX_NAME を"
            "一意な名前（例: products_taro）に変更してください。"
        ))
        return False

    print(f"\n{msg('Deleting existing index', '既存のインデックスを削除中')}: {INDEX_NAME}")
    client.indices.delete(index=INDEX_NAME)
    print(f"✓ {msg('Index deleted', 'インデックスを削除しました')}: {INDEX_NAME}")
    return True


def create_index(client, embedding_dimension: int) -> None:
    """Create the k-NN index"""
    print(f"\n{msg('Creating index', 'インデックスを作成中')}: {INDEX_NAME}")
    print(f"  {msg('Vector dimension', 'ベクトルの次元数')}: {embedding_dimension}")
    print(f"  {msg('Text analyzer', 'テキストアナライザー')}: {TEXT_ANALYZER}")

    client.indices.create(index=INDEX_NAME, body=build_index_body(embedding_dimension))
    print(f"✓ {msg('Index created', 'インデックスを作成しました')}: {INDEX_NAME}")


def insert_data(client, embeddings) -> None:
    """Embed the sample products and bulk index them"""
    item_unit = "件" if IS_JA else "items"
    print(f"\n{msg('Inserting sample data...', 'サンプルデータを挿入中...')} "
          f"({len(SAMPLE_PRODUCTS)} {item_unit})")

    # Combine product name and description into the text that gets embedded
    texts = [product_text(p) for p in SAMPLE_PRODUCTS]

    print(msg("  Generating embedding vectors with watsonx.ai...",
              "  watsonx.ai で埋め込みベクトルを生成中..."))
    vectors = embed_documents(embeddings, texts)

    actions = [
        {
            "_index": INDEX_NAME,
            "_source": {
                "product_name": product["product_name"],
                "price": product["price"],
                "category": product["category"],
                "description": product["description"],
                VECTOR_FIELD: vector,
            },
        }
        for product, vector in zip(SAMPLE_PRODUCTS, vectors)
    ]

    helpers.bulk(client, actions, refresh=True)
    print(f"✓ {len(SAMPLE_PRODUCTS)} {msg('items inserted', '件のデータを挿入しました')}")


def main() -> int:
    """Main process"""
    args = parse_args()

    print("=" * 50)
    print(msg("Sample Data Insertion Script", "サンプルデータ挿入スクリプト"))
    print("=" * 50)

    try:
        client = get_opensearch_client()
    except Exception as e:
        print(f"✗ {msg('Failed to connect to OpenSearch', 'OpenSearch への接続に失敗しました')}: {e}")
        return 1

    try:
        embeddings = get_embeddings()
        # The index needs the vector dimension up front, so ask the model for one
        embedding_dimension = len(embed_query(embeddings, DIMENSION_PROBE_TEXT))
    except Exception as e:
        print(f"✗ {msg('Failed to prepare watsonx.ai embeddings', 'watsonx.ai の埋め込み準備に失敗しました')}: {e}")
        return 1

    if not delete_existing_index(client, args.yes):
        return 1

    create_index(client, embedding_dimension)
    insert_data(client, embeddings)

    # Display results
    document_count = client.count(index=INDEX_NAME)["count"]
    print("\n" + "=" * 50)
    print(msg("✓ Sample data insertion completed", "✓ サンプルデータの挿入が完了しました"))
    print("=" * 50)
    print(f"\n{msg('Index name', 'インデックス名')}: {INDEX_NAME}")
    print(f"{msg('Document count', 'ドキュメント数')}: {document_count}")
    print(f"\n{msg('You can start the demo application', 'デモアプリケーションを起動できます')}:")
    print_start_commands()
    print("=" * 50 + "\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
