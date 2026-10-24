from pathlib import Path
from uuid import UUID
import os


STORAGE_DIR = Path(
    os.getenv("SIGNED_PDF_DIR", "/app/storage")
)


def save_signed_pdf(document_id: str, pdf_data: bytes) -> str:
    """
    Lưu PDF đã ký vào volume Docker.

    document_id phải là UUID hợp lệ.
    """

    safe_id = str(UUID(document_id))

    STORAGE_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    file_path = STORAGE_DIR / f"{safe_id}.pdf"

    if file_path.exists():
        raise FileExistsError(
            "Document already exists"
        )

    # Tạo file mới, không ghi đè file đã có.
    with file_path.open("xb") as file:
        file.write(pdf_data)
        file.flush()
        os.fsync(file.fileno())

    return str(file_path)


def read_signed_pdf(document_id: str) -> bytes:
    """
    Đọc PDF đã ký từ volume.
    """

    safe_id = str(UUID(document_id))

    file_path = STORAGE_DIR / f"{safe_id}.pdf"

    return file_path.read_bytes()