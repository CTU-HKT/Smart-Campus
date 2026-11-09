#!/bin/bash
set -euo pipefail

if [ -z "${AUTHENTICATOR_PASSWORD:-}" ]; then
    echo "[DX-OS Init - Authenticator] LỖI: AUTHENTICATOR_PASSWORD chưa được đặt trong .env"
    exit 1
fi

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authenticator') THEN
            CREATE ROLE authenticator NOINHERIT LOGIN PASSWORD '${AUTHENTICATOR_PASSWORD}';
        ELSE
            ALTER ROLE authenticator WITH PASSWORD '${AUTHENTICATOR_PASSWORD}';
        END IF;
    END
    \$\$;
EOSQL