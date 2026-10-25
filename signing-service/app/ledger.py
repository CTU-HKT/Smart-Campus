import hashlib
import json
import os
from datetime import datetime, timezone
from threading import Lock

from immudb.client import (
    ImmudbClient,
    PersistentRootService,
)

IMMUDB_HOST = os.getenv("IMMUDB_HOST", "immudb")
IMMUDB_PORT = os.getenv("IMMUDB_PORT", "3322")
IMMUDB_USERNAME = os.environ["IMMUDB_USERNAME"]
IMMUDB_PASSWORD = os.environ["IMMUDB_PASSWORD"]

ROOT_FILE = "/var/lib/signing-ledger/immudb.root"

# MVP: chỉ sử dụng một tiến trình Signing Service.
# Lock bảo vệ các thao tác dùng chung trạng thái xác minh.
ledger_lock = Lock()


def calculate_sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def get_client():
    root_service = PersistentRootService(ROOT_FILE)

    client = ImmudbClient(
        f"{IMMUDB_HOST}:{IMMUDB_PORT}",
        rs=root_service,
    )

    client.login(
        IMMUDB_USERNAME,
        IMMUDB_PASSWORD,
    )

    return client


def store_document_hash(
    document_id: str,
    pdf_data: bytes,
) -> dict:

    record = {
        "document_id": document_id,
        "sha256": calculate_sha256(pdf_data),
        "algorithm": "SHA-256",
        "created_at": datetime.now(
            timezone.utc
        ).isoformat(),
    }

    key = f"document:{document_id}".encode()
    value = json.dumps(
        record,
        sort_keys=True,
    ).encode()

    with ledger_lock:
        client = get_client()

        try:
            client.verifiedSet(key, value)
        finally:
            client.shutdown()

    return record


def verify_document_hash(
    document_id: str,
    pdf_data: bytes,
) -> dict:

    key = f"document:{document_id}".encode()

    with ledger_lock:
        client = get_client()

        try:
            result = client.verifiedGet(key)
        finally:
            client.shutdown()

    stored_record = json.loads(
        result.value.decode()
    )

    expected_hash = stored_record["sha256"]
    actual_hash = calculate_sha256(pdf_data)

    return {
        "document_id": document_id,
        "verified": expected_hash == actual_hash,
        "ledger_proof_verified": True,
        "expected_sha256": expected_hash,
        "actual_sha256": actual_hash,
    }