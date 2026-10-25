import os
import subprocess
import tempfile
from pathlib import Path

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.responses import Response
from uuid import uuid4
from .database import check_database
from .ledger import (
    store_document_hash,
    verify_document_hash,
)
from .signing_workflow import router as signing_router
app = FastAPI(
    title="Smart Campus Signing Service",
    version="0.1.0",
    description="DX-OS PDF Digital Signature Service (Demo)",
)
app.include_router(signing_router)
PKCS11_MODULE = (
    "/usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so"
)

TOKEN_LABEL = os.getenv(
    "SOFTHSM_TOKEN_LABEL", "smartcampus-demo"
)

KEY_LABEL = os.getenv(
    "SOFTHSM_KEY_LABEL", "smartcampus-signer"
)

MAX_PDF_SIZE = 10 * 1024 * 1024


@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "smart-campus-signing",
    }


@app.post("/sign")
async def sign_document(
    file: UploadFile = File(...)
):
    # Endpoint demo. Chưa có xác thực người gọi.
    pin = os.getenv("SOFTHSM_USER_PIN")

    if not pin:
        raise HTTPException(
            status_code=503,
            detail="Signing token is not configured",
        )

    pdf_data = await file.read(MAX_PDF_SIZE + 1)

    if len(pdf_data) > MAX_PDF_SIZE:
        raise HTTPException(
            status_code=413,
            detail="PDF exceeds 10 MB",
        )

    if not pdf_data.startswith(b"%PDF-"):
        raise HTTPException(
            status_code=400,
            detail="Only PDF files are accepted",
        )

    with tempfile.TemporaryDirectory() as temp_dir:
        input_path = Path(temp_dir) / "input.pdf"
        output_path = Path(temp_dir) / "signed.pdf"

        input_path.write_bytes(pdf_data)

        command = [
            "pyhanko",
            "sign",
            "addsig",
            "--field",
            "Signature1",
            "pkcs11",
            "--lib",
            PKCS11_MODULE,
            "--token-label",
            TOKEN_LABEL,
            "--cert-label",
            KEY_LABEL,
            str(input_path),
            str(output_path),
        ]

        try:
            # PIN được truyền qua stdin, không đặt trong
            # command line để tránh xuất hiện trong argv.
            result = subprocess.run(
                command,
                input=pin + "\n",
                text=True,
                capture_output=True,
                timeout=60,
                check=False,
            )

        except subprocess.TimeoutExpired:
            raise HTTPException(
                status_code=504,
                detail="Signing operation timed out",
            )

        if result.returncode != 0:
            # Không trả stderr trực tiếp cho client.
            raise HTTPException(
                status_code=500,
                detail="PDF signing failed",
            )

        if not output_path.exists():
            raise HTTPException(
                status_code=500,
                detail="Signed PDF was not generated",
            )

        signed_pdf = output_path.read_bytes()

    return Response(
        content=signed_pdf,
        media_type="application/pdf",
        headers={
            "Content-Disposition":
                'attachment; filename="signed.pdf"',
            "Cache-Control": "no-store",
        },
    )
@app.post("/ledger/register")
async def register_document(file: UploadFile = File(...)):
    """
    Đăng ký PDF đã ký vào immudb và xác minh bằng chứng.
    """

    pdf_data = await file.read(MAX_PDF_SIZE + 1)

    if len(pdf_data) > MAX_PDF_SIZE:
        raise HTTPException(
            status_code=413,
            detail="PDF exceeds 10 MB",
        )

    if not pdf_data.startswith(b"%PDF-"):
        raise HTTPException(
            status_code=400,
            detail="Only PDF files are accepted",
        )

    document_id = str(uuid4())

    try:
        # 1. Ghi SHA-256 vào immudb bằng verifiedSet
        record = store_document_hash(
            document_id,
            pdf_data,
        )

        # 2. Đọc lại bằng verifiedGet và so sánh SHA-256
        verification = verify_document_hash(
            document_id,
            pdf_data,
        )

        # 3. Chỉ chấp nhận khi xác minh thành công
        if (
            verification.get("verified") is not True
            or verification.get("ledger_proof_verified") is not True
        ):
            raise RuntimeError(
                "immudb verification failed"
            )

    except Exception:
        raise HTTPException(
            status_code=503,
            detail="Ledger registration or verification failed",
        )

    return {
        "status": "registered",
        **record,
        "immudb_key": f"document:{document_id}",
        "verified": verification["verified"],
        "ledger_proof_verified": verification["ledger_proof_verified"],
    }
    """
    Đăng ký PDF đã ký vào immudb.
    Chỉ sử dụng cho môi trường demo nội bộ.
    """

    pdf_data = await file.read(MAX_PDF_SIZE + 1)

    if len(pdf_data) > MAX_PDF_SIZE:
        raise HTTPException(
            status_code=413,
            detail="PDF exceeds 10 MB",
        )

    if not pdf_data.startswith(b"%PDF-"):
        raise HTTPException(
            status_code=400,
            detail="Only PDF files are accepted",
        )

    document_id = str(uuid4())

    try:
        record = store_document_hash(
            document_id,
            pdf_data,
        )
    except Exception:
        raise HTTPException(
            status_code=503,
            detail="Ledger registration failed",
        )

    return {
        "status": "registered",
        **record,
    }


@app.post("/ledger/verify/{document_id}")
async def verify_document(
    document_id: str,
    file: UploadFile = File(...)
):
    """
    Kiểm tra PDF có khớp với bản ghi immudb không.
    """

    pdf_data = await file.read(MAX_PDF_SIZE + 1)

    if len(pdf_data) > MAX_PDF_SIZE:
        raise HTTPException(
            status_code=413,
            detail="PDF exceeds 10 MB",
        )

    if not pdf_data.startswith(b"%PDF-"):
        raise HTTPException(
            status_code=400,
            detail="Only PDF files are accepted",
        )

    try:
        result = verify_document_hash(
            document_id,
            pdf_data,
        )
    except Exception:
        raise HTTPException(
            status_code=503,
            detail="Ledger verification failed",
        )

    return result

@app.get("/health/database")
def database_health():
    try:
        result = check_database()

        return {
            "status": "ok",
            "database": result["db_name"],
            "user": result["db_user"],
            "server_time": result["server_time"].isoformat(),
        }

    except Exception:
        raise HTTPException(
            status_code=503,
            detail="Database connection failed",
        )