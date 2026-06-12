#!/usr/bin/env python3
"""
Milvus connection test script
"""

import os
import sys
from common import get_milvus_connect_params, msg


SECRET_VARS = {"MILVUS_PASSWORD"}


def display_env_value(var, value):
    """Mask secret environment variables in terminal output."""
    if var in SECRET_VARS:
        return "********"
    return value


def print_env_status(required_vars):
    """Display status of required environment variables"""
    missing_vars = []

    for var in required_vars:
        value = os.getenv(var)
        if value:
            print(f"✓ {var}: {display_env_value(var, value)}")
        else:
            print(f"✗ {var}: {msg('not set', '未設定')}")
            missing_vars.append(var)

    return missing_vars


def test_milvus_connection():
    """Milvus connection test"""
    print(f"\n=== {msg('Milvus Connection Test', 'Milvus 接続テスト')} ===")

    try:
        from pymilvus import connections, utility

        connect_params = get_milvus_connect_params()

        print(f"{msg('Connecting to', '接続先')}: {connect_params['host']}:{connect_params['port']}")
        print(f"{msg('Auth', '認証')}: {msg('user/password auth', 'ユーザー名/パスワード認証')}")

        # Connect
        connections.connect(**connect_params)

        # Verify connection
        print(msg("✓ Connected to Milvus successfully", "✓ Milvus に接続できました"))

        # List collections
        collections = utility.list_collections()
        print(f"✓ {msg('Existing collections', '既存のコレクション数')}: {len(collections)}")
        if collections:
            print(f"  {msg('Collections', 'コレクション')}: {', '.join(collections)}")

        return True

    except ImportError:
        print(msg("✗ pymilvus is not installed", "✗ pymilvus がインストールされていません"))
        print(msg("  Install with: pip install pymilvus", "  インストールコマンド: pip install pymilvus"))
        return False
    except Exception as e:
        print(f"✗ {msg('Milvus connection error', 'Milvus 接続エラー')}: {e}")
        return False


def main():
    """Main process"""
    print("=" * 50)
    print(msg("Milvus Connection Test", "Milvus 接続テスト"))
    print("=" * 50)

    # Check environment variables
    print(f"\n=== {msg('Environment Variable Check', '環境変数チェック')} ===")
    required_vars = [
        "MILVUS_HOST",
        "MILVUS_PORT",
        "MILVUS_USER",
        "MILVUS_PASSWORD",
    ]

    missing_vars = print_env_status(required_vars)

    if missing_vars:
        print(f"\n{msg('Warning', '警告')}: {len(missing_vars)} {msg('environment variable(s) not set', '個の環境変数が未設定です')}")
        print(msg("Please check the setup/participant/.env file", "setup/participant/.env ファイルを確認してください"))

    # Run connection test
    milvus_ok = test_milvus_connection()

    # Results summary
    print("\n" + "=" * 50)
    print(msg("Test Results", "テスト結果"))
    print("=" * 50)
    print(f"{msg('Milvus connection', 'Milvus 接続')}: {msg('✓ success', '✓ 成功') if milvus_ok else msg('✗ failed', '✗ 失敗')}")

    if milvus_ok:
        print(msg("\n✓ Milvus connection test passed!", "\n✓ Milvus 接続テストに成功しました"))
        print(msg("  Next step: Create vector collection", "  次のステップ: ベクトル用コレクションを作成"))
        return 0
    else:
        print(msg("\n✗ Milvus connection test failed", "\n✗ Milvus 接続テストに失敗しました"))
        print(msg("  Check the error message and review your configuration", "  エラーメッセージと設定内容を確認してください"))
        return 1


if __name__ == "__main__":
    sys.exit(main())
