import os
from contextlib import contextmanager

import psycopg
from psycopg.rows import dict_row


DB_CONFIG = {
    "host": os.environ["SIGNING_DB_HOST"],
    "port": int(os.getenv("SIGNING_DB_PORT", "5432")),
    "dbname": os.environ["SIGNING_DB_NAME"],
    "user": os.environ["SIGNING_DB_USER"],
    "password": os.environ["SIGNING_DB_PASSWORD"],
    "connect_timeout": 5,
    "row_factory": dict_row,
}


@contextmanager
def get_db():
    """
    Mở kết nối PostgreSQL.

    Thành công: COMMIT.
    Có lỗi: ROLLBACK.
    Luôn đóng kết nối.
    """

    with psycopg.connect(**DB_CONFIG) as conn:
        yield conn


def check_database():
    """Kiểm tra kết nối và tài khoản PostgreSQL."""

    with get_db() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT
                    current_user AS db_user,
                    current_database() AS db_name,
                    current_timestamp AS server_time
            """)

            return cur.fetchone()