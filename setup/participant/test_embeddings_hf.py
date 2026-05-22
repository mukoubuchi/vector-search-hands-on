"""
Hugging Face Transformers埋め込みモデルのテストスクリプト
"""
from sentence_transformers import SentenceTransformer
from dotenv import load_dotenv
import os

load_dotenv()

def test_embeddings():
    """Hugging Face埋め込みモデルをテスト"""
    try:
        # モデル名を取得
        model_name = os.getenv("EMBEDDING_MODEL", "paraphrase-multilingual-MiniLM-L12-v2")
        
        print(f"モデルをロード中: {model_name}")
        model = SentenceTransformer(model_name)
        
        print("✓ モデルのロードに成功しました")
        
        # テストテキストで埋め込みを生成
        test_texts = [
            "これはテストです",
            "機械学習について",
            "ベクトル検索システム"
        ]
        
        print("\n埋め込みを生成中...")
        embeddings = model.encode(test_texts)
        
        print(f"✓ {len(embeddings)}件の埋め込みを生成しました")
        print(f"✓ 埋め込みベクトルの次元数: {len(embeddings[0])}")
        print(f"✓ ベクトルの最初の5要素: {embeddings[0][:5]}")
        
        # 類似度テスト
        from sklearn.metrics.pairwise import cosine_similarity
        import numpy as np
        
        similarity = cosine_similarity([embeddings[0]], [embeddings[1]])[0][0]
        print(f"\n✓ テキスト間の類似度: {similarity:.4f}")
        
        return True
        
    except Exception as e:
        print(f"✗ エラーが発生しました: {e}")
        return False

if __name__ == "__main__":
    test_embeddings()

