#!/bin/bash
# ==============================================================================
# DX-OS SMARTCAMPUS - Flowable Engine Database Initialization Script (Production / OLP 2026)
# File: database/init-scripts/00_init_flowable.sh
# Framework: DX-OS Open-Core (OLP 2026 - Open Source Software)
# Purpose: Khởi tạo CSDL & Role riêng cho Flowable Engine (BPMN 2.0 PaaS)
# Standards: Idempotent, Zero-Trust Config, Postgres 16+ Compliant, Fully Logged
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# 1. Cấu hình biến môi trường linh hoạt (Bảo mật Zero-Trust / Open Source Best Practice)
# ------------------------------------------------------------------------------
FLOWABLE_USER="${FLOWABLE_DB_USER:-flowable}"
FLOWABLE_PASS="${FLOWABLE_DB_PASSWORD:-flowable}"
FLOWABLE_DB="${FLOWABLE_DB_NAME:-flowable}"

LOG_PREFIX="[DX-OS Init - Flowable]"

echo "======================================================================"
echo " ${LOG_PREFIX} Bắt đầu tiến trình khởi tạo CSDL cho Flowable Engine..."
echo "======================================================================"

# ------------------------------------------------------------------------------
# 2. Thực thi SQL Khởi tạo User & Database trên PostgreSQL Instance
# ------------------------------------------------------------------------------
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL

    -- 2.1. Tạo Role/User cho Flowable Engine (Idempotent Check)
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${FLOWABLE_USER}') THEN
            CREATE ROLE ${FLOWABLE_USER} WITH LOGIN PASSWORD '${FLOWABLE_PASS}';
            RAISE NOTICE 'Role "${FLOWABLE_USER}" đã được khởi tạo thành công.';
        ELSE
            -- Cập nhật lại mật khẩu để đảm bảo đồng bộ biến môi trường nếu có thay đổi
            ALTER ROLE ${FLOWABLE_USER} WITH PASSWORD '${FLOWABLE_PASS}';
            RAISE NOTICE 'Role "${FLOWABLE_USER}" đã tồn tại. Đã đồng bộ lại mật khẩu.';
        END IF;
    END
    \$\$;

    -- 2.2. Tạo Database riêng cho Flowable Engine gán Owner
    SELECT 'CREATE DATABASE ${FLOWABLE_DB} WITH OWNER = ${FLOWABLE_USER} ENCODING = ''UTF8'' TEMPLATE = template1;'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${FLOWABLE_DB}')\gexec

    -- 2.3. Cấp quyền cấp CSDL
    GRANT ALL PRIVILEGES ON DATABASE ${FLOWABLE_DB} TO ${FLOWABLE_USER};

EOSQL

# ------------------------------------------------------------------------------
# 3. Phân quyền chi tiết trên Schema Public của flowable_db (Tương thích Postgres 15/16+)
# Trong Postgres 15+, schema public bị thắt chặt quyền nên cần cấp GRANT CREATE rõ ràng
# ------------------------------------------------------------------------------
echo "${LOG_PREFIX} Cấu hình phân quyền Schema Public trên database '${FLOWABLE_DB}'..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${FLOWABLE_DB}" <<-EOSQL

    -- Đảm bảo user flowable làm chủ sở hữu schema public trong flowable_db
    ALTER SCHEMA public OWNER TO ${FLOWABLE_USER};
    GRANT ALL ON SCHEMA public TO ${FLOWABLE_USER};
    
    -- Cấp quyền mặc định cho các bảng/sequence sinh ra sau này bởi Liquibase
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${FLOWABLE_USER};
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${FLOWABLE_USER};

EOSQL

# ------------------------------------------------------------------------------
# 4. Kiểm tra & Xác nhận Trạng thái Hoàn tất
# ------------------------------------------------------------------------------
echo "======================================================================"
echo " ${LOG_PREFIX} Khởi tạo thành công!"
echo "   - Database: ${FLOWABLE_DB}"
echo "   - User:     ${FLOWABLE_USER}"
echo "   - Status:   Sẵn sàng kết nối cho Flowable REST Service (Liquibase)"
echo "======================================================================"