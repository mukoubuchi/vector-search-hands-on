#!/usr/bin/env python3
"""
Milvus と Watsonx.ai の接続テストスクリプト
"""

import os
import sys
from dotenv import load_dotenv

# .envファイルを読み込み
load_dotenv()

def test_milvus_connection():
    """Milvus接続テスト"""
    print("\n=== Milvus 接続テスト ===")
    
    try:
        from pymilvus import connections, utility
        
        host = os.getenv("MILVUS_HOST")
        port = os.getenv("MILVUS_PORT", "19530")
        
        print(f"接続先: {host}:{port}")
        
        # 接続
        connections.connect(
            alias="default",
            host=host,
            port=port
        )
        
        # 接続確認
        print("✓ Milvusに接続成功")
        
        # コレクション一覧取得
        collections = utility.list_collections()
        print(f"✓ 既存コレクション数: {len(collections)}")
        if collections:
            print(f"  コレクション: {', '.join(collections)}")
        
        return True
        
    except ImportError:
        print("✗ pymilvusがインストールされていません")
        print("  インストール: pip install pymilvus")
        return False
    except Exception as e:
        print(f"✗ Milvus接続エラー: {e}")
        return False

def test_watsonx_connection():
    """Watsonx.ai接続テスト"""
    print("\n=== Watsonx.ai 接続テスト ===")
    
    try:
        from ibm_watsonx_ai import Credentials
        from ibm_watsonx_ai.foundation_models import Embeddings
        from ibm_watsonx_ai.foundation_models.utils.enums import EmbeddingTypes
        
        api_key = os.getenv("WATSONX_API_KEY")
        project_id = os.getenv("WATSONX_PROJECT_ID")
        url = os.getenv("WATSONX_URL", "https://us-south.ml.cloud.ibm.com")
        model_id = os.getenv("EMBEDDING_MODEL", "ibm/granite-embedding-278m-multilingual")
        
        if not api_key or api_key == "YOUR_WATSONX_API_KEY_HERE":
            print("✗ WATSONX_API_KEYが設定されていません")
            return False
            
        if not project_id or project_id == "YOUR_PROJECT_ID_HERE":
            print("✗ WATSONX_PROJECT_IDが設定されていません")
            return False
        
        print(f"接続先: {url}")
        print(f"Project ID: {project_id[:8]}...")
        
        # 認証情報設定
        credentials = Credentials(
            url=url,
            api_key=api_key
        )
        
        # Embeddingsモデル初期化
        print(f"使用モデル: {model_id}")
        embeddings = Embeddings(
            model_id=model_id,
            credentials=credentials,
            project_id=project_id
        )
        
        print("✓ Watsonx.aiに接続成功")
        
        # テスト埋め込み生成
        test_text = "これはテストです"
        print(f"\nテスト埋め込み生成: '{test_text}'")
        vector = embeddings.embed_query(test_text)
        
        print(f"✓ 埋め込みベクトル生成成功")
        print(f"  次元数: {len(vector)}")
        print(f"  最初の5要素: {vector[:5]}")
        
        return True
        
    except ImportError:
        print("✗ ibm-watsonx-aiがインストールされていません")
        print("  インストール: pip install ibm-watsonx-ai")
        return False
    except Exception as e:
        print(f"✗ Watsonx.ai接続エラー: {e}")
        return False

def main():
    """メイン処理"""
    print("=" * 50)
    print("Milvus & Watsonx.ai 接続テスト")
    print("=" * 50)
    
    # 環境変数確認
    print("\n=== 環境変数確認 ===")
    required_vars = [
        "MILVUS_HOST",
        "MILVUS_PORT",
        "WATSONX_API_KEY",
        "WATSONX_PROJECT_ID",
        "WATSONX_URL"
    ]
    
    missing_vars = []
    for var in required_vars:
        value = os.getenv(var)
        if value:
            if "KEY" in var or "ID" in var:
                display_value = value[:8] + "..." if len(value) > 8 else value
            else:
                display_value = value
            print(f"✓ {var}: {display_value}")
        else:
            print(f"✗ {var}: 未設定")
            missing_vars.append(var)
    
    if missing_vars:
        print(f"\n警告: {len(missing_vars)}個の環境変数が未設定です")
        print("setup/.env ファイルを確認してください")
    
    # 接続テスト実行
    milvus_ok = test_milvus_connection()
    watsonx_ok = test_watsonx_connection()
    
    # 結果サマリー
    print("\n" + "=" * 50)
    print("テスト結果サマリー")
    print("=" * 50)
    print(f"Milvus接続:     {'✓ 成功' if milvus_ok else '✗ 失敗'}")
    print(f"Watsonx.ai接続: {'✓ 成功' if watsonx_ok else '✗ 失敗'}")
    
    if milvus_ok and watsonx_ok:
        print("\n✓ すべての接続テストが成功しました！")
        print("  次のステップ: ベクトルコレクションの作成")
        return 0
    else:
        print("\n✗ 一部の接続テストが失敗しました")
        print("  エラーメッセージを確認して設定を見直してください")
        return 1

if __name__ == "__main__":
    sys.exit(main())

