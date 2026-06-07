"""Shared helpers for the participant hands-on scripts."""

import os
from pathlib import Path
from typing import Any, Dict, Optional

from dotenv import load_dotenv
from pymilvus import connections
from sentence_transformers import SentenceTransformer


PARTICIPANT_DIR = Path(__file__).resolve().parent
load_dotenv(PARTICIPANT_DIR / ".env")

DEFAULT_MILVUS_HOST = "localhost"
DEFAULT_MILVUS_PORT = "19530"
DEFAULT_EMBEDDING_MODEL = "paraphrase-multilingual-MiniLM-L12-v2"
DEFAULT_EMBEDDING_DIMENSION = 384
DEFAULT_COLLECTION_NAME = "knowledge_base"
DEFAULT_PARTICIPANT_LANGUAGE = "en"

PARTICIPANT_LANGUAGE = os.getenv("PARTICIPANT_LANGUAGE", DEFAULT_PARTICIPANT_LANGUAGE)
IS_JA = PARTICIPANT_LANGUAGE.strip().lower() == "ja"


def msg(en_text: str, ja_text: str) -> str:
    """Return text for the participant language."""
    return ja_text if IS_JA else en_text


def get_env(name: str, default: Optional[str] = None) -> Optional[str]:
    """Return an environment variable using a shared default."""
    return os.getenv(name, default)


def get_int_env(name: str, default: int) -> int:
    """Return an integer environment variable."""
    value = os.getenv(name)
    if value is None or value == "":
        return default

    try:
        return int(value)
    except ValueError as exc:
        raise RuntimeError(msg(
            f"{name} must be an integer. Current value: {value}",
            f"{name} は整数で指定してください。現在の値: {value}"
        )) from exc


def require_env(name: str) -> str:
    """Return a required environment variable or raise a clear error."""
    value = (os.getenv(name) or "").strip()
    if not value:
        raise RuntimeError(msg(
            f"{name} is not set. Please check the .env file.",
            f"{name} が設定されていません。.env ファイルを確認してください。"
        ))
    return value


def get_milvus_connect_params() -> Dict[str, Any]:
    """Build Milvus connection parameters from environment variables."""
    host = (get_env("MILVUS_HOST", DEFAULT_MILVUS_HOST) or DEFAULT_MILVUS_HOST).strip()
    port = (get_env("MILVUS_PORT", DEFAULT_MILVUS_PORT) or DEFAULT_MILVUS_PORT).strip()

    if host.startswith("tcp://"):
        host = host.replace("tcp://", "", 1)
    if ":" in host and host.rsplit(":", 1)[1].isdigit():
        host, detected_port = host.rsplit(":", 1)
        port = detected_port
    if not port.isdigit() or not 1 <= int(port) <= 65535:
        raise RuntimeError(msg(
            f"MILVUS_PORT must be a number between 1 and 65535. Current value: {port}",
            f"MILVUS_PORT は 1 から 65535 の数値で指定してください。現在の値: {port}"
        ))

    connect_params: Dict[str, Any] = {
        "alias": "default",
        "host": host,
        "port": port,
        "user": require_env("MILVUS_USER"),
        "password": require_env("MILVUS_PASSWORD"),
    }

    return connect_params


def connect_to_milvus() -> None:
    """Connect to Milvus using the shared connection settings."""
    connect_params = get_milvus_connect_params()
    print(f"\n{msg('Connecting to Milvus', 'Milvus に接続中')}: {connect_params['host']}:{connect_params['port']}")
    connections.connect(**connect_params)
    print(msg("✓ Connected to Milvus successfully", "✓ Milvus に接続できました"))


def load_embedding_model(model_name: Optional[str] = None) -> SentenceTransformer:
    """Load an embedding model by name."""
    selected_model = model_name or get_env("EMBEDDING_MODEL", DEFAULT_EMBEDDING_MODEL)
    print(f"\n{msg('Loading embedding model', '埋め込みモデルを読み込み中')}: {selected_model}")
    model = SentenceTransformer(selected_model)
    print(msg("✓ Embedding model loaded successfully", "✓ 埋め込みモデルを読み込みました"))
    return model
