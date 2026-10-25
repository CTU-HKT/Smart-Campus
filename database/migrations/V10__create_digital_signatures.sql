-- Smart Campus DX-OS | Flyway V10 | Digital documents and signatures
-- PostgreSQL 16+; depends on app.ho_so(id BIGINT).
-- Run using a dedicated migration owner. Never expose migration-owner credentials to clients.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Enum-like CHECK constraints are intentionally used to simplify future migrations.
CREATE TABLE app.tai_lieu_so (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ho_so_id BIGINT NOT NULL REFERENCES app.ho_so(id) ON DELETE RESTRICT,
    ma_tai_lieu VARCHAR(64) NOT NULL UNIQUE,
    loai_tai_lieu VARCHAR(60) NOT NULL,
    ten_tai_lieu VARCHAR(255) NOT NULL,
    phien_ban INTEGER NOT NULL DEFAULT 1 CHECK (phien_ban > 0),
    storage_provider VARCHAR(30),
    storage_bucket VARCHAR(255),
    storage_object_key TEXT,
    mime_type VARCHAR(100) NOT NULL DEFAULT 'application/pdf' CHECK (mime_type = 'application/pdf'),
    kich_thuoc_bytes BIGINT CHECK (kich_thuoc_bytes > 0),
    sha256 CHAR(64),
    trang_thai VARCHAR(24) NOT NULL DEFAULT 'PENDING',
    ly_do_thu_hoi TEXT,
    ngay_ky TIMESTAMPTZ,
    ngay_thu_hoi TIMESTAMPTZ,
    ngay_tao TIMESTAMPTZ NOT NULL DEFAULT now(),
    ngay_cap_nhat TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_tl_status CHECK (trang_thai IN ('PENDING','SIGNING','SIGNED','FAILED','REVOKED')),
    CONSTRAINT ck_tl_hash CHECK (sha256 IS NULL OR sha256 ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_tl_storage CHECK (
        (storage_provider IS NULL AND storage_bucket IS NULL AND storage_object_key IS NULL)
        OR (storage_provider IS NOT NULL AND storage_object_key IS NOT NULL)
    ),
    CONSTRAINT ck_tl_signed CHECK (trang_thai NOT IN ('SIGNED','REVOKED') OR (sha256 IS NOT NULL AND ngay_ky IS NOT NULL AND storage_object_key IS NOT NULL)),
    CONSTRAINT ck_tl_revoked CHECK (trang_thai <> 'REVOKED' OR (ngay_thu_hoi IS NOT NULL AND NULLIF(btrim(ly_do_thu_hoi),'') IS NOT NULL)),
    CONSTRAINT uq_tl_ho_so_type_version UNIQUE (ho_so_id, loai_tai_lieu, phien_ban)
);

COMMENT ON TABLE app.tai_lieu_so IS 'Metadata of signed PDFs; PDF bytes and private keys are not stored in PostgreSQL.';
COMMENT ON COLUMN app.tai_lieu_so.storage_object_key IS 'Opaque private object-storage key; never a public URL or signed URL.';

CREATE TABLE app.chu_ky_so (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tai_lieu_id UUID NOT NULL REFERENCES app.tai_lieu_so(id) ON DELETE RESTRICT,
    signature_field VARCHAR(128) NOT NULL,
    signer_subject TEXT NOT NULL,
    signer_issuer TEXT,
    signer_certificate_sha256 CHAR(64) NOT NULL,
    certificate_serial_number VARCHAR(128),
    signature_algorithm VARCHAR(80) NOT NULL,
    digest_algorithm VARCHAR(40) NOT NULL,
    signed_at TIMESTAMPTZ NOT NULL,
    certificate_not_before TIMESTAMPTZ,
    certificate_not_after TIMESTAMPTZ,
    signing_key_reference VARCHAR(255),
    signature_validation_status VARCHAR(24) NOT NULL DEFAULT 'NOT_CHECKED',
    signature_validation_checked_at TIMESTAMPTZ,
    validation_details JSONB,
    ngay_tao TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_ck_fingerprint CHECK (signer_certificate_sha256 ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_ck_status CHECK (signature_validation_status IN ('NOT_CHECKED','VALID','INVALID','INDETERMINATE')),
    CONSTRAINT ck_ck_cert_dates CHECK (certificate_not_before IS NULL OR certificate_not_after IS NULL OR certificate_not_after >= certificate_not_before),
    CONSTRAINT uq_ck_field UNIQUE (tai_lieu_id, signature_field)
);

COMMENT ON COLUMN app.chu_ky_so.signing_key_reference IS 'Non-secret HSM key label/identifier; never PIN, private key or token secret.';

CREATE TABLE app.bang_chung_immudb (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tai_lieu_id UUID NOT NULL REFERENCES app.tai_lieu_so(id) ON DELETE RESTRICT,
    immudb_database VARCHAR(100) NOT NULL DEFAULT 'defaultdb',
    immudb_key VARCHAR(255) NOT NULL,
    immudb_transaction_id BIGINT CHECK (immudb_transaction_id IS NULL OR immudb_transaction_id > 0),
    document_sha256 CHAR(64) NOT NULL,
    proof_status VARCHAR(24) NOT NULL DEFAULT 'NOT_CHECKED',
    proof_verified_at TIMESTAMPTZ,
    proof_metadata JSONB,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_bc_hash CHECK (document_sha256 ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ck_bc_status CHECK (proof_status IN ('NOT_CHECKED','VERIFIED','FAILED','INDETERMINATE')),
    CONSTRAINT uq_bc_immudb_key UNIQUE (immudb_database, immudb_key),
    CONSTRAINT uq_bc_document UNIQUE (tai_lieu_id, immudb_database, immudb_key)
);

COMMENT ON COLUMN app.bang_chung_immudb.proof_status IS 'VERIFIED only after immudb verifiedGet/Merkle verification; plain hash equality is insufficient.';

CREATE TABLE app.nhat_ky_xac_thuc (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tai_lieu_id UUID NOT NULL REFERENCES app.tai_lieu_so(id) ON DELETE RESTRICT,
    chu_ky_id UUID REFERENCES app.chu_ky_so(id) ON DELETE SET NULL,
    ket_qua_hash VARCHAR(24) NOT NULL,
    ket_qua_chu_ky VARCHAR(24) NOT NULL,
    ket_qua_ledger VARCHAR(24) NOT NULL,
    ket_luan VARCHAR(24) NOT NULL,
    verification_source VARCHAR(30) NOT NULL DEFAULT 'API',
    correlation_id UUID,
    details JSONB,
    checked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_nk_hash CHECK (ket_qua_hash IN ('MATCH','MISMATCH','NOT_CHECKED','ERROR')),
    CONSTRAINT ck_nk_signature CHECK (ket_qua_chu_ky IN ('VALID','INVALID','INDETERMINATE','NOT_CHECKED','ERROR')),
    CONSTRAINT ck_nk_ledger CHECK (ket_qua_ledger IN ('VERIFIED','FAILED','INDETERMINATE','NOT_CHECKED','ERROR')),
    CONSTRAINT ck_nk_result CHECK (ket_luan IN ('VALID','INVALID','INDETERMINATE','ERROR')),
    CONSTRAINT ck_nk_source CHECK (verification_source IN ('API','WORKFLOW','ADMIN','SCHEDULED')),
    CONSTRAINT ck_nk_valid CHECK (ket_luan <> 'VALID' OR (ket_qua_hash='MATCH' AND ket_qua_chu_ky='VALID' AND ket_qua_ledger='VERIFIED'))
);

CREATE TABLE app.lich_su_trang_thai_tai_lieu (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tai_lieu_id UUID NOT NULL REFERENCES app.tai_lieu_so(id) ON DELETE RESTRICT,
    trang_thai_cu VARCHAR(24),
    trang_thai_moi VARCHAR(24) NOT NULL,
    actor_subject VARCHAR(255),
    actor_type VARCHAR(24) NOT NULL DEFAULT 'SYSTEM',
    ly_do TEXT,
    correlation_id UUID,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT ck_ls_old CHECK (trang_thai_cu IS NULL OR trang_thai_cu IN ('PENDING','SIGNING','SIGNED','FAILED','REVOKED')),
    CONSTRAINT ck_ls_new CHECK (trang_thai_moi IN ('PENDING','SIGNING','SIGNED','FAILED','REVOKED')),
    CONSTRAINT ck_ls_actor CHECK (actor_type IN ('SYSTEM','STAFF','ADMIN','SERVICE')),
    CONSTRAINT ck_ls_change CHECK (trang_thai_cu IS DISTINCT FROM trang_thai_moi)
);

CREATE INDEX idx_tl_ho_so ON app.tai_lieu_so(ho_so_id, ngay_tao DESC);
CREATE INDEX idx_tl_status ON app.tai_lieu_so(trang_thai, ngay_tao DESC);
CREATE INDEX idx_ck_tai_lieu ON app.chu_ky_so(tai_lieu_id);
CREATE INDEX idx_bc_tai_lieu ON app.bang_chung_immudb(tai_lieu_id);
CREATE INDEX idx_nk_tai_lieu_checked ON app.nhat_ky_xac_thuc(tai_lieu_id, checked_at DESC);
CREATE INDEX idx_ls_tai_lieu_changed ON app.lich_su_trang_thai_tai_lieu(tai_lieu_id, changed_at DESC);

-- RLS is enabled and FORCEd so application connections cannot accidentally bypass it
-- by being the table owner. Superusers and BYPASSRLS roles still bypass RLS.
ALTER TABLE app.tai_lieu_so ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.tai_lieu_so FORCE ROW LEVEL SECURITY;
ALTER TABLE app.chu_ky_so ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.chu_ky_so FORCE ROW LEVEL SECURITY;
ALTER TABLE app.bang_chung_immudb ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.bang_chung_immudb FORCE ROW LEVEL SECURITY;
ALTER TABLE app.nhat_ky_xac_thuc ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.nhat_ky_xac_thuc FORCE ROW LEVEL SECURITY;
ALTER TABLE app.lich_su_trang_thai_tai_lieu ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.lich_su_trang_thai_tai_lieu FORCE ROW LEVEL SECURITY;

-- Students may read metadata for their own applications only.
-- app.jwt_ma_sv() is an existing function used by app.ho_so policies.
CREATE POLICY tl_student_select ON app.tai_lieu_so
    FOR SELECT TO authenticated
    USING (EXISTS (
        SELECT 1 FROM app.ho_so h
        WHERE h.id = ho_so_id AND h.ma_sv = app.jwt_ma_sv()
    ));

CREATE POLICY ck_student_select ON app.chu_ky_so
    FOR SELECT TO authenticated
    USING (EXISTS (
        SELECT 1 FROM app.tai_lieu_so t WHERE t.id = tai_lieu_id
    ));

CREATE POLICY bc_student_select ON app.bang_chung_immudb
    FOR SELECT TO authenticated
    USING (EXISTS (
        SELECT 1 FROM app.tai_lieu_so t WHERE t.id = tai_lieu_id
    ));

-- No student policies for verification logs or status history by default.
-- No INSERT/UPDATE/DELETE policies for authenticated: writes are backend-only.
-- Backend service roles, least-privilege GRANTs, and their policies must be added
-- in a separate reviewed migration after the actual DB role model is confirmed.
-- No GRANT statements here: existing default privileges may vary by deployment.
