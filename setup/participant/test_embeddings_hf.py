"""
Hugging Face Transformers embedding model test script
"""
from common import IS_JA, load_embedding_model, msg


def test_texts_for_language():
    """Return embedding test texts for the participant language."""
    if IS_JA:
        return [
            "これはテストです",
            "機械学習について",
            "ベクトル検索システム"
        ]
    return [
        "This is a test",
        "About machine learning",
        "Vector search system"
    ]


def test_embeddings():
    """Test Hugging Face embedding model"""
    try:
        model = load_embedding_model()

        # Generate embeddings with test texts
        test_texts = test_texts_for_language()

        print(f"\n{msg('Generating embeddings...', '埋め込みベクトルを生成中...')}")
        embeddings = model.encode(test_texts)

        print(f"✓ {msg('Generated', '生成した件数')}: {len(embeddings)}")
        print(f"✓ {msg('Embedding vector dimensions', '埋め込みベクトルの次元数')}: {len(embeddings[0])}")
        print(f"✓ {msg('First 5 elements of vector', 'ベクトルの先頭 5 要素')}: {embeddings[0][:5]}")

        # Similarity test
        from sklearn.metrics.pairwise import cosine_similarity
        import numpy as np

        similarity = cosine_similarity([embeddings[0]], [embeddings[1]])[0][0]
        print(f"\n✓ {msg('Similarity between texts', 'テキスト間の類似度')}: {similarity:.4f}")

        return True

    except Exception as e:
        print(f"✗ {msg('Error occurred', 'エラーが発生しました')}: {e}")
        return False


if __name__ == "__main__":
    test_embeddings()
