#!/bin/bash
set -euo pipefail

LOG_PREFIX="[DX-OS Init - Keycloak]"

echo "======================================================================"
echo " ${LOG_PREFIX} Bắt đầu khởi tạo CSDL & User cho Keycloak IAM..."
echo "======================================================================"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL

    -- 1. Tạo User 'keycloak' nếu chưa tồn tại
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'keycloak') THEN
            CREATE ROLE keycloak WITH LOGIN PASSWORD '1234';
            RAISE NOTICE 'Role "keycloak" đã được tạo thành công.';
        ELSE
            ALTER ROLE keycloak WITH PASSWORD '1234';
        END IF;
    END
    \$\$;

    -- 2. Tạo Database 'keycloak_db' gán Owner cho 'keycloak'
    SELECT 'CREATE DATABASE keycloak_db WITH OWNER = keycloak ENCODING = ''UTF8'';'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'keycloak_db')\gexec

    -- 3. Cấp quyền sở hữu CSDL
    GRANT ALL PRIVILEGES ON DATABASE keycloak_db TO keycloak;

EOSQL

# Cấu hình phân quyền Schema Public trên keycloak_db (Tương thích Postgres 15/16+)
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "keycloak_db" <<-EOSQL
    ALTER SCHEMA public OWNER TO keycloak;
    GRANT ALL ON SCHEMA public TO keycloak;
EOSQL

echo " ${LOG_PREFIX} Khởi tạo thành công database 'keycloak_db'!"