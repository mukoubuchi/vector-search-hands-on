"""Shared helpers for the participant hands-on scripts."""

import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

# Checked before the third-party imports so that a too-old interpreter produces
# this clear message instead of ModuleNotFoundError (ibm-watsonx-ai declares
# Python >=3.11,<3.15, so the packages in requirements.txt cannot be installed
# on Python < 3.11)
if sys.version_info < (3, 11):
    raise RuntimeError(
        "Python 3.11 or higher is required for the hands-on scripts "
        f"(current: {sys.version.split()[0]}). / "
        "ハンズオンのスクリプトには Python 3.11 以上が必要です"
        f"（現在: {sys.version.split()[0]}）。"
    )

from dotenv import load_dotenv  # noqa: E402
from ibm_watsonx_ai import Credentials  # noqa: E402
from ibm_watsonx_ai.foundation_models import Embeddings  # noqa: E402
from opensearchpy import OpenSearch  # noqa: E402


PARTICIPANT_DIR = Path(__file__).resolve().parent
load_dotenv(PARTICIPANT_DIR / ".env")

DEFAULT_OPENSEARCH_HOST = "localhost"
DEFAULT_OPENSEARCH_PORT = "9200"
DEFAULT_OPENSEARCH_USER = "admin"
DEFAULT_WATSONX_URL = "https://us-south.ml.cloud.ibm.com"
DEFAULT_EMBEDDING_MODEL_ID = "ibm/granite-embedding-278m-multilingual"
DEFAULT_INDEX_NAME = "products"
DEFAULT_PARTICIPANT_LANGUAGE = "en"

PARTICIPANT_LANGUAGE = os.getenv("PARTICIPANT_LANGUAGE", DEFAULT_PARTICIPANT_LANGUAGE)
IS_JA = PARTICIPANT_LANGUAGE.strip().lower() == "ja"


def msg(en_text: str, ja_text: str) -> str:
    """Return text for the participant language."""
    return ja_text if IS_JA else en_text


def get_env(name: str, default: Optional[str] = None) -> Optional[str]:
    """Return an environment variable using a shared default."""
    return os.getenv(name, default)


def get_bool_env(name: str, default: bool) -> bool:
    """Return a boolean environment variable ("true"/"false", case-insensitive)."""
    raw = (os.getenv(name) or "").strip().lower()
    if not raw:
        return default
    if raw in ("true", "1", "yes", "on"):
        return True
    if raw in ("false", "0", "no", "off"):
        return False
    raise RuntimeError(msg(
        f"{name} must be true or false. Current value: {raw}",
        f"{name} には true または false を指定してください。現在の値: {raw}"
    ))


def reject_placeholder(name: str, value: str) -> str:
    """Raise a clear error when a .env value still contains a template placeholder."""
    if "<" in value or ">" in value or value.startswith("your_"):
        raise RuntimeError(msg(
            f"{name} still contains the placeholder '{value}' from .env.example. "
            "Replace it with the actual value in setup/participant/.env.",
            f"{name} に .env.example のプレースホルダ '{value}' が残っています。"
            "setup/participant/.env を実際の値に書き換えてください。"
        ))
    return value


def require_env(name: str) -> str:
    """Return a required environment variable or raise a clear error."""
    value = (os.getenv(name) or "").strip()
    if not value:
        raise RuntimeError(msg(
            f"{name} is not set. Please check the .env file.",
            f"{name} が設定されていません。.env ファイルを確認してください。"
        ))
    return value


def get_opensearch_connect_params() -> Dict[str, Any]:
    """Build OpenSearch connection parameters from environment variables."""
    host = (get_env("OPENSEARCH_HOST", DEFAULT_OPENSEARCH_HOST) or DEFAULT_OPENSEARCH_HOST).strip()
    port = (get_env("OPENSEARCH_PORT", DEFAULT_OPENSEARCH_PORT) or DEFAULT_OPENSEARCH_PORT).strip()
    reject_placeholder("OPENSEARCH_HOST", host)

    # Accept a host that carries a scheme or a port, so a pasted URL still works
    for scheme in ("https://", "http://"):
        if host.startswith(scheme):
            host = host[len(scheme):]
    host = host.rstrip("/")
    if ":" in host and host.rsplit(":", 1)[1].isdigit():
        host, detected_port = host.rsplit(":", 1)
        port = detected_port
    if not port.isdigit() or not 1 <= int(port) <= 65535:
        raise RuntimeError(msg(
            f"OPENSEARCH_PORT must be a number between 1 and 65535. Current value: {port}",
            f"OPENSEARCH_PORT は 1 から 65535 の数値で指定してください。現在の値: {port}"
        ))

    user = reject_placeholder(
        "OPENSEARCH_USER",
        (get_env("OPENSEARCH_USER", DEFAULT_OPENSEARCH_USER) or DEFAULT_OPENSEARCH_USER).strip(),
    )
    password = reject_placeholder("OPENSEARCH_PASSWORD", require_env("OPENSEARCH_PASSWORD"))

    return {
        "hosts": [{"host": host, "port": int(port)}],
        "http_auth": (user, password),
        "use_ssl": get_bool_env("OPENSEARCH_USE_SSL", True),
        # The hands-on cluster serves the security plugin's self-signed
        # certificate, so certificate verification is off by default
        "verify_certs": get_bool_env("OPENSEARCH_VERIFY_CERTS", False),
        "ssl_show_warn": False,
        "timeout": 30,
    }


def get_opensearch_client() -> OpenSearch:
    """Connect to OpenSearch using the shared connection settings."""
    connect_params = get_opensearch_connect_params()
    endpoint = connect_params["hosts"][0]
    print(f"\n{msg('Connecting to OpenSearch', 'OpenSearch に接続中')}: "
          f"{endpoint['host']}:{endpoint['port']}")
    client = OpenSearch(**connect_params)
    info = client.info()
    print(f"{msg('✓ Connected to OpenSearch successfully', '✓ OpenSearch に接続できました')} "
          f"({msg('version', 'バージョン')} {info['version']['number']})")
    return client


def get_embedding_model_id() -> str:
    """Return the configured watsonx.ai embedding model id."""
    model_id = (get_env("EMBEDDING_MODEL_ID", DEFAULT_EMBEDDING_MODEL_ID)
                or DEFAULT_EMBEDDING_MODEL_ID).strip()
    return reject_placeholder("EMBEDDING_MODEL_ID", model_id)


def get_embeddings() -> Embeddings:
    """Create the watsonx.ai embeddings client from environment variables."""
    url = (get_env("WATSONX_URL", DEFAULT_WATSONX_URL) or DEFAULT_WATSONX_URL).strip()
    reject_placeholder("WATSONX_URL", url)
    api_key = reject_placeholder("IBM_API_KEY", require_env("IBM_API_KEY"))
    project_id = reject_placeholder("WATSONX_PROJECT_ID", require_env("WATSONX_PROJECT_ID"))
    model_id = get_embedding_model_id()

    print(f"\n{msg('Connecting to watsonx.ai', 'watsonx.ai に接続中')}: {url}")
    print(f"{msg('Embedding model', '埋め込みモデル')}: {model_id}")
    embeddings = Embeddings(
        model_id=model_id,
        credentials=Credentials(url=url, api_key=api_key),
        project_id=project_id,
    )
    print(msg("✓ watsonx.ai embeddings client ready",
              "✓ watsonx.ai の埋め込みクライアントを準備しました"))
    return embeddings


def embed_documents(embeddings: Embeddings, texts: List[str]) -> List[List[float]]:
    """Embed documents with watsonx.ai."""
    return embeddings.embed_documents(texts=texts)


def embed_query(embeddings: Embeddings, text: str) -> List[float]:
    """Embed a single search query with watsonx.ai."""
    return embeddings.embed_query(text=text)
