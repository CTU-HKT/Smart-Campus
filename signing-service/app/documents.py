# ==========================================================
# DX-OS SMART CAMPUS
# File: signing-service/app/documents.py
# Purpose: Quản lý metadata tài liệu số trong PostgreSQL
# ==========================================================

from uuid import UUID

from .database import get_db
from .ledger import calculate_sha256

def get_approved_application(ho_so_id: int):
    """
    Kiểm tra hồ sơ sinh viên đã được phê duyệt hay chưa.

    Chỉ trả về hồ sơ có trạng thái 'Đã duyệt'.

    Phù hợp với quyền SELECT (id, trang_thai)
    của role signing_service trong Flyway V11.
    """

    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id, trang_thai
                FROM app.ho_so
                WHERE id = %s
                  AND trang_thai = %s
                """,
                (ho_so_id, "Đã duyệt"),
            )

            return cur.fetchone()


def get_document(document_id: str):
    """
    Truy xuất metadata tài liệu số từ PostgreSQL.

    document_id là UUID của tài liệu.
    """

    # Kiểm tra UUID hợp lệ trước khi truy vấn
    validated_id = UUID(document_id)

    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT *
                FROM app.tai_lieu_so
                WHERE id = %s
                """,
                (validated_id,),
            )

            return cur.fetchone()

def create_signed_document(
    ho_so_id: int,
    document_id: str,
    storage_path: str,
    signed_pdf: bytes,
):
    """
    Tạo metadata cho tài liệu đã ký.

    Chỉ thực hiện khi hồ sơ đã được duyệt.
    """

    pdf_hash = calculate_sha256(signed_pdf)

    with get_db() as conn:
        with conn.cursor() as cur:

            cur.execute(
                """
                SELECT id
                FROM app.ho_so
                WHERE id = %s
                  AND trang_thai = 'Đã duyệt'
                """,
                (ho_so_id,),
            )

            if cur.fetchone() is None:
                raise ValueError(
                    "Application is not approved"
                )

            cur.execute(
                """
                INSERT INTO app.tai_lieu_so (
                    id,
                    ho_so_id,
                    ten_tai_lieu,
                    loai_tai_lieu,
                    duong_dan_luu_tru,
                    sha256,
                    trang_thai
                )
                VALUES (
                    %s, %s, %s, %s, %s, %s, %s
                )
                RETURNING id
                """,
                (
                    UUID(document_id),
                    ho_so_id,
                    f"Smart Campus Document {document_id}",
                    "GIAY_XAC_NHAN",
                    storage_path,
                    pdf_hash,
                    "SIGNED",
                ),
            )

            result = cur.fetchone()

    return {
        "document_id": str(result["id"]),
        "ho_so_id": ho_so_id,
        "sha256": pdf_hash,
        "storage_path": storage_path,
        "status": "SIGNED",
    }
