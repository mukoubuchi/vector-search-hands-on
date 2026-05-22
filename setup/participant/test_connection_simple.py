#!/usr/bin/env python3
"""
Milvus 接続テストスクリプト
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
        secure = os.getenv("MILVUS_SECURE", "false").lower() == "true"
        token = os.getenv("MILVUS_TOKEN") or os.getenv("IBM_CLOUD_API_KEY")
        
        print(f"接続先: {host}:{port}")
        print(f"SSL: {'有効' if secure else '無効'}")
        print(f"認証: {'トークン認証' if token else 'ユーザー/パスワード認証'}")
        
        # 接続パラメータ
        connect_params = {
            "alias": "default",
            "host": host,
            "port": port
        }
        
        # SSL接続の場合
        if secure:
            connect_params["secure"] = True
        
        # IBM Cloud認証の場合
        if token:
            # IBM Cloud APIキーをusernameとして使用
            connect_params["user"] = token
            connect_params["password"] = ""
        else:
            # ユーザー/パスワード認証
            user = os.getenv("MILVUS_USER", "root")
            password = os.getenv("MILVUS_PASSWORD", "Milvus")
            connect_params["user"] = user
            connect_params["password"] = password
        
        # 接続
        connections.connect(**connect_params)
        
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


def main():
    """メイン処理"""
    print("=" * 50)
    print("Milvus 接続テスト")
    print("=" * 50)
    
    # 環境変数確認
    print("\n=== 環境変数確認 ===")
    required_vars = [
        "MILVUS_HOST",
        "MILVUS_PORT"
    ]
    
    missing_vars = []
    for var in required_vars:
        value = os.getenv(var)
        if value:
            print(f"✓ {var}: {value}")
        else:
            print(f"✗ {var}: 未設定")
            missing_vars.append(var)
    
    if missing_vars:
        print(f"\n警告: {len(missing_vars)}個の環境変数が未設定です")
        print("setup/.env ファイルを確認してください")
    
    # 接続テスト実行
    milvus_ok = test_milvus_connection()
    
    # 結果サマリー
    print("\n" + "=" * 50)
    print("テスト結果")
    print("=" * 50)
    print(f"Milvus接続: {'✓ 成功' if milvus_ok else '✗ 失敗'}")
    
    if milvus_ok:
        print("\n✓ Milvus接続テストが成功しました！")
        print("  次のステップ: ベクトルコレクションの作成")
        return 0
    else:
        print("\n✗ Milvus接続テストが失敗しました")
        print("  エラーメッセージを確認して設定を見直してください")
        return 1

if __name__ == "__main__":
    sys.exit(main())

