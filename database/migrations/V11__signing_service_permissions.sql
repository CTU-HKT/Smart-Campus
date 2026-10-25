-- =========================================================
-- DX-OS SMART CAMPUS
-- V11 - Signing Service Permissions
-- =========================================================

-- 1. Tạo role riêng cho Signing Service.
-- Mật khẩu được thiết lập riêng, không lưu trong migration.

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'signing_service'
    ) THEN
        CREATE ROLE signing_service LOGIN;
    END IF;
END
$$;

-- 2. Bảo đảm role không có quyền quản trị đặc biệt.

ALTER ROLE signing_service
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
    NOBYPASSRLS;

-- 3. Quyền sử dụng schema.

GRANT USAGE ON SCHEMA app TO signing_service;

-- 4. Chỉ được đọc ID và trạng thái hồ sơ.

GRANT SELECT (id, trang_thai)
ON app.ho_so
TO signing_service;

-- 5. Quyền truy cập metadata chữ ký số.

GRANT SELECT, INSERT, UPDATE
ON app.tai_lieu_so
TO signing_service;

GRANT SELECT, INSERT
ON app.chu_ky_so
TO signing_service;

GRANT SELECT, INSERT, UPDATE
ON app.bang_chung_immudb
TO signing_service;

GRANT SELECT, INSERT
ON app.nhat_ky_xac_thuc
TO signing_service;

GRANT SELECT, INSERT
ON app.lich_su_trang_thai_tai_lieu
TO signing_service;

-- 6. Quyền sử dụng sequence cho các bảng identity.

GRANT USAGE
ON SEQUENCE app.nhat_ky_xac_thuc_id_seq
TO signing_service;

GRANT USAGE
ON SEQUENCE app.lich_su_trang_thai_tai_lieu_id_seq
TO signing_service;

-- 7. Cho phép Signing Service đọc hồ sơ.
-- Chỉ truy vấn các cột đã được GRANT.

CREATE POLICY ho_so_signing_select
ON app.ho_so
FOR SELECT
TO signing_service
USING (true);

-- 8. RLS cho tài liệu số.

CREATE POLICY tl_signing_select
ON app.tai_lieu_so
FOR SELECT
TO signing_service
USING (true);

CREATE POLICY tl_signing_insert
ON app.tai_lieu_so
FOR INSERT
TO signing_service
WITH CHECK (true);

CREATE POLICY tl_signing_update
ON app.tai_lieu_so
FOR UPDATE
TO signing_service
USING (true)
WITH CHECK (true);

-- 9. RLS cho chữ ký số.

CREATE POLICY ck_signing_select
ON app.chu_ky_so
FOR SELECT
TO signing_service
USING (true);

CREATE POLICY ck_signing_insert
ON app.chu_ky_so
FOR INSERT
TO signing_service
WITH CHECK (true);

-- 10. RLS cho bằng chứng immudb.

CREATE POLICY bc_signing_select
ON app.bang_chung_immudb
FOR SELECT
TO signing_service
USING (true);

CREATE POLICY bc_signing_insert
ON app.bang_chung_immudb
FOR INSERT
TO signing_service
WITH CHECK (true);

CREATE POLICY bc_signing_update
ON app.bang_chung_immudb
FOR UPDATE
TO signing_service
USING (true)
WITH CHECK (true);

-- 11. RLS cho nhật ký xác thực.

CREATE POLICY nk_signing_select
ON app.nhat_ky_xac_thuc
FOR SELECT
TO signing_service
USING (true);

CREATE POLICY nk_signing_insert
ON app.nhat_ky_xac_thuc
FOR INSERT
TO signing_service
WITH CHECK (true);

-- 12. RLS cho lịch sử trạng thái.

CREATE POLICY ls_signing_select
ON app.lich_su_trang_thai_tai_lieu
FOR SELECT
TO signing_service
USING (true);

CREATE POLICY ls_signing_insert
ON app.lich_su_trang_thai_tai_lieu
FOR INSERT
TO signing_service
WITH CHECK (true);