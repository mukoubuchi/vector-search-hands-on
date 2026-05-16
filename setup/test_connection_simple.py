#!/usr/bin/env python3
"""
Milvus と Watsonx.ai の接続テストスクリプト（簡易版）
プロジェクトIDなしでも動作します
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

def test_watsonx_simple():
    """Watsonx.ai接続テスト（簡易版 - API keyのみ）"""
    print("\n=== Watsonx.ai 接続テスト（簡易版） ===")
    
    try:
        import requests
        
        api_key = os.getenv("WATSONX_API_KEY")
        url = os.getenv("WATSONX_URL", "https://us-south.ml.cloud.ibm.com")
        
        if not api_key or api_key == "YOUR_WATSONX_API_KEY_HERE":
            print("✗ WATSONX_API_KEYが設定されていません")
            return False
        
        print(f"接続先: {url}")
        print(f"API Key: {api_key[:8]}...")
        
        # IAM トークン取得
        print("\nIAMトークンを取得中...")
        token_url = "https://iam.cloud.ibm.com/identity/token"
        token_data = {
            "grant_type": "urn:ibm:params:oauth:grant-type:apikey",
            "apikey": api_key
        }
        
        token_response = requests.post(token_url, data=token_data)
        
        if token_response.status_code != 200:
            print(f"✗ トークン取得失敗: {token_response.status_code}")
            print(f"  レスポンス: {token_response.text}")
            return False
        
        access_token = token_response.json()["access_token"]
        print("✓ IAMトークン取得成功")
        
        # Embeddings API テスト（プロジェクトIDなし）
        print("\nEmbeddings APIをテスト中...")
        embed_url = f"{url}/ml/v1/text/embeddings?version=2023-05-29"
        
        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
            "Accept": "application/json"
        }
        
        # プロジェクトIDとモデルIDを取得
        project_id = os.getenv("WATSONX_PROJECT_ID")
        model_id = os.getenv("EMBEDDING_MODEL", "ibm/slate-125m-english-rtrvr")
        
        payload = {
            "model_id": model_id,
            "inputs": ["これはテストです"],
            "parameters": {}
        }
        
        # プロジェクトIDがある場合は追加
        if project_id and project_id != "YOUR_PROJECT_ID_HERE":
            payload["project_id"] = project_id
        
        embed_response = requests.post(embed_url, json=payload, headers=headers)
        
        if embed_response.status_code == 200:
            result = embed_response.json()
            if "results" in result and len(result["results"]) > 0:
                vector = result["results"][0]["embedding"]
                print("✓ 埋め込みベクトル生成成功")
                print(f"  次元数: {len(vector)}")
                print(f"  最初の5要素: {vector[:5]}")
                return True
            else:
                print("✗ レスポンスに埋め込みベクトルが含まれていません")
                return False
        else:
            print(f"✗ Embeddings API エラー: {embed_response.status_code}")
            print(f"  レスポンス: {embed_response.text}")
            return False
        
    except ImportError:
        print("✗ requestsがインストールされていません")
        print("  インストール: pip install requests")
        return False
    except Exception as e:
        print(f"✗ Watsonx.ai接続エラー: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """メイン処理"""
    print("=" * 50)
    print("Milvus & Watsonx.ai 接続テスト（簡易版）")
    print("=" * 50)
    
    # 環境変数確認
    print("\n=== 環境変数確認 ===")
    required_vars = [
        "MILVUS_HOST",
        "MILVUS_PORT",
        "WATSONX_API_KEY",
        "WATSONX_URL"
    ]
    
    missing_vars = []
    for var in required_vars:
        value = os.getenv(var)
        if value:
            if "KEY" in var:
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
    watsonx_ok = test_watsonx_simple()
    
    # 結果サマリー
    print("\n" + "=" * 50)
    print("テスト結果サマリー")
    print("=" * 50)
    print(f"Milvus接続:     {'✓ 成功' if milvus_ok else '✗ 失敗'}")
    print(f"Watsonx.ai接続: {'✓ 成功' if watsonx_ok else '✗ 失敗'}")
    
    if milvus_ok and watsonx_ok:
        print("\n✓ すべての接続テストが成功しました！")
        print("  次のステップ: ベクトルコレクションの作成")
        print("\n注意: プロジェクトIDなしで動作しています")
        print("      一部の機能が制限される可能性があります")
        return 0
    else:
        print("\n✗ 一部の接続テストが失敗しました")
        print("  エラーメッセージを確認して設定を見直してください")
        return 1

if __name__ == "__main__":
    sys.exit(main())

# Made with Bob
