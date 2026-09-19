#!/usr/bin/env python3
"""
OpenSearch and watsonx.ai connection test script
"""

import os
import sys

from common import (
    DEFAULT_EMBEDDING_MODEL_ID,
    DEFAULT_INDEX_NAME,
    DEFAULT_OPENSEARCH_PORT,
    DEFAULT_OPENSEARCH_USER,
    DEFAULT_WATSONX_URL,
    embed_query,
    get_embedding_model_id,
    get_embeddings,
    get_opensearch_client,
    get_opensearch_connect_params,
    get_env,
    msg,
)


SECRET_VARS = {"OPENSEARCH_PASSWORD", "IBM_API_KEY"}

# Only these have no fallback: without them the scripts cannot run at all
REQUIRED_VARS = [
    "OPENSEARCH_HOST",
    "OPENSEARCH_PASSWORD",
    "WATSONX_PROJECT_ID",
    "IBM_API_KEY",
]

# These fall back to a default, so report the value that will actually be used
# rather than calling an unset variable a problem
DEFAULTED_VARS = {
    "OPENSEARCH_PORT": DEFAULT_OPENSEARCH_PORT,
    "OPENSEARCH_USER": DEFAULT_OPENSEARCH_USER,
    "WATSONX_URL": DEFAULT_WATSONX_URL,
    "EMBEDDING_MODEL_ID": DEFAULT_EMBEDDING_MODEL_ID,
    "INDEX_NAME": DEFAULT_INDEX_NAME,
}
KNN_PLUGIN_NAME = "opensearch-knn"
PROBE_TEXT = "vector search connection test"


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


def print_defaulted_env_status(defaulted_vars):
    """Display the effective value of variables that have a default"""
    for var, fallback in defaulted_vars.items():
        value = get_env(var)
        if value:
            print(f"✓ {var}: {value}")
        else:
            print(f"· {var}: {fallback} ({msg('default', '既定値')})")


def test_opensearch_connection():
    """OpenSearch connection test"""
    print(f"\n=== {msg('OpenSearch Connection Test', 'OpenSearch 接続テスト')} ===")

    try:
        endpoint = get_opensearch_connect_params()["hosts"][0]
        print(f"{msg('Connecting to', '接続先')}: {endpoint['host']}:{endpoint['port']}")

        client = get_opensearch_client()

        # The k-NN plugin provides the knn_vector field type this hands-on needs
        plugins = client.cat.plugins(format="json")
        knn_installed = any(p.get("component") == KNN_PLUGIN_NAME for p in plugins)
        if knn_installed:
            print(f"✓ {msg('k-NN plugin is available', 'k-NN プラグインが利用できます')} "
                  f"({KNN_PLUGIN_NAME})")
        else:
            print(f"✗ {msg('k-NN plugin is missing', 'k-NN プラグインがありません')} "
                  f"({KNN_PLUGIN_NAME})")
            return False

        health = client.cluster.health()
        print(f"✓ {msg('Cluster status', 'クラスターの状態')}: {health['status']}")

        indices = client.cat.indices(format="json", index="*", h="index")
        visible = [i["index"] for i in indices if not i["index"].startswith(".")]
        print(f"✓ {msg('Existing indexes', '既存のインデックス数')}: {len(visible)}")
        if visible:
            print(f"  {msg('Indexes', 'インデックス')}: {', '.join(sorted(visible))}")

        return True

    except ImportError:
        print(msg("✗ opensearch-py is not installed",
                  "✗ opensearch-py がインストールされていません"))
        print(msg("  Install with: pip install -r requirements.txt",
                  "  インストールコマンド: pip install -r requirements.txt"))
        return False
    except Exception as e:
        print(f"✗ {msg('OpenSearch connection error', 'OpenSearch 接続エラー')}: {e}")
        return False


def test_watsonx_embeddings():
    """watsonx.ai embeddings test"""
    print(f"\n=== {msg('watsonx.ai Embeddings Test', 'watsonx.ai 埋め込みテスト')} ===")

    try:
        embeddings = get_embeddings()
        vector = embed_query(embeddings, PROBE_TEXT)
        print(f"✓ {msg('Embedding generated', '埋め込みベクトルを生成しました')}: "
              f"{get_embedding_model_id()}")
        print(f"✓ {msg('Vector dimension', 'ベクトルの次元数')}: {len(vector)}")
        return True

    except ImportError:
        print(msg("✗ ibm-watsonx-ai is not installed",
                  "✗ ibm-watsonx-ai がインストールされていません"))
        print(msg("  Install with: pip install -r requirements.txt",
                  "  インストールコマンド: pip install -r requirements.txt"))
        return False
    except Exception as e:
        print(f"✗ {msg('watsonx.ai error', 'watsonx.ai エラー')}: {e}")
        return False


def main():
    """Main process"""
    print("=" * 50)
    print(msg("OpenSearch and watsonx.ai Connection Test",
              "OpenSearch と watsonx.ai の接続テスト"))
    print("=" * 50)

    # Check environment variables
    print(f"\n=== {msg('Environment Variable Check', '環境変数チェック')} ===")
    missing_vars = print_env_status(REQUIRED_VARS)
    print_defaulted_env_status(DEFAULTED_VARS)

    if missing_vars:
        print(f"\n{msg('Warning', '警告')}: {len(missing_vars)} "
              f"{msg('environment variable(s) not set', '個の環境変数が未設定です')}")
        print(msg("Please check the setup/participant/.env file",
                  "setup/participant/.env ファイルを確認してください"))

    # Run connection tests
    opensearch_ok = test_opensearch_connection()
    watsonx_ok = test_watsonx_embeddings()

    # Results summary
    print("\n" + "=" * 50)
    print(msg("Test Results", "テスト結果"))
    print("=" * 50)
    print(f"{msg('OpenSearch connection', 'OpenSearch 接続')}: "
          f"{msg('✓ success', '✓ 成功') if opensearch_ok else msg('✗ failed', '✗ 失敗')}")
    print(f"{msg('watsonx.ai embeddings', 'watsonx.ai 埋め込み')}: "
          f"{msg('✓ success', '✓ 成功') if watsonx_ok else msg('✗ failed', '✗ 失敗')}")

    if opensearch_ok and watsonx_ok:
        print(msg("\n✓ All connection tests passed!", "\n✓ すべての接続テストに成功しました"))
        print(msg("  Next step: Create the vector index and insert sample data",
                  "  次のステップ: ベクトル用インデックスを作成してサンプルデータを投入"))
        return 0

    print(msg("\n✗ Connection test failed", "\n✗ 接続テストに失敗しました"))
    print(msg("  Check the error message and review your configuration",
              "  エラーメッセージと設定内容を確認してください"))
    return 1


if __name__ == "__main__":
    sys.exit(main())
