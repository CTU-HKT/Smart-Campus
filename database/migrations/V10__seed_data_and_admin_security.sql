-- V10: Seed demo data for students, teachers, courses, registrations, applications and configure admin RLS

-- 1. Seed Loai Ho So
INSERT INTO app.loai_ho_so(ma_loai, ten_loai, mo_ta) VALUES
  ('GIAY_XAC_NHAN', 'Giấy xác nhận sinh viên', 'Cấp giấy chứng nhận đang theo học tại trường'),
  ('GIAY_VAY_VON', 'Giấy xác nhận vay vốn', 'Xác nhận để làm thủ tục vay vốn sinh viên ngân hàng chính sách'),
  ('TAM_HOAN_NVQS', 'Tạm hoãn nghĩa vụ quân sự', 'Giấy xác nhận tạm hoãn nghĩa vụ quân sự theo luật định')
ON CONFLICT (ma_loai) DO NOTHING;

-- 2. Seed Can Bo / Giang Vien
INSERT INTO app.can_bo(ma_cb, keycloak_sub, ho_ten, chuc_vu, don_vi, email) VALUES
  ('CB001', 'a77c975b-0bf7-4ced-ba7a-21aa077778d8', 'Nguyễn Văn C', 'Giảng viên', 'Khoa Công nghệ Thông tin & Truyền thông', 'teacher1@example.com'),
  ('TK_KTPM', 'a57ad140-2913-4db6-9ae2-c314dcebdf1d', 'Nguyễn Trưởng Khoa', 'Trưởng khoa', 'Khoa Công nghệ Thông tin & Truyền thông', 'truongkhoaktpm@smartcampus.edu.vn')
ON CONFLICT (ma_cb) DO UPDATE SET
  keycloak_sub = EXCLUDED.keycloak_sub,
  ho_ten = EXCLUDED.ho_ten,
  chuc_vu = EXCLUDED.chuc_vu,
  don_vi = EXCLUDED.don_vi,
  email = EXCLUDED.email;

-- 3. Seed Sinh Vien
INSERT INTO app.sinh_vien(ma_sv, keycloak_sub, ho_ten, ngay_sinh, lop, khoa, email, sdt) VALUES
  ('B2100001', '0c38b276-3f90-48e5-bda4-c9b7e4e51faa', 'Nguyễn Văn A', '2003-01-15', 'DI21V7A1', 'Công nghệ Thông tin & Truyền thông', 'student1@example.com', '0912345678'),
  ('B2100002', 'cb6c42b6-2ea5-466b-8412-e99a67085959', 'Trần Thị B', '2003-05-20', 'DI21V7A2', 'Công nghệ Thông tin & Truyền thông', 'student2@example.com', '0987654321')
ON CONFLICT (ma_sv) DO UPDATE SET
  keycloak_sub = EXCLUDED.keycloak_sub,
  ho_ten = EXCLUDED.ho_ten,
  ngay_sinh = EXCLUDED.ngay_sinh,
  lop = EXCLUDED.lop,
  khoa = EXCLUDED.khoa,
  email = EXCLUDED.email,
  sdt = EXCLUDED.sdt;

-- 4. Seed Mon Hoc
INSERT INTO app.mon_hoc(ma_mon, ten_mon, so_tc, ma_cb_phu_trach) VALUES
  ('CT101', 'Lập trình Căn bản', 4, 'CB001'),
  ('CT176', 'Kiến trúc máy tính', 3, 'CB001'),
  ('CT177', 'Cấu trúc dữ liệu và giải thuật', 3, 'CB001'),
  ('CT202', 'Nguyên lý hệ điều hành', 3, 'TK_KTPM'),
  ('CT207', 'Phát triển ứng dụng Web', 3, 'CB001')
ON CONFLICT (ma_mon) DO UPDATE SET
  ten_mon = EXCLUDED.ten_mon,
  so_tc = EXCLUDED.so_tc,
  ma_cb_phu_trach = EXCLUDED.ma_cb_phu_trach;

-- 5. Seed Dang Ky Mon
INSERT INTO app.dang_ky_mon(ma_sv, ma_mon, hoc_ky, trang_thai_dk, diem_chu, diem_so, ngay_cap_nhat_diem) VALUES
  ('B2100001', 'CT101', 'HK1 2025-2026', 'Đã học', 'A', 9.0, now()),
  ('B2100001', 'CT176', 'HK1 2025-2026', 'Đã học', 'B+', 8.0, now()),
  ('B2100001', 'CT177', 'HK2 2025-2026', 'Đang học', 'A', 8.5, now()),
  ('B2100001', 'CT207', 'HK2 2025-2026', 'Đang học', NULL, NULL, NULL),
  ('B2100002', 'CT101', 'HK1 2025-2026', 'Đã học', 'B', 7.5, now()),
  ('B2100002', 'CT202', 'HK1 2025-2026', 'Đã học', 'A', 8.5, now()),
  ('B2100002', 'CT177', 'HK2 2025-2026', 'Đang học', NULL, NULL, NULL)
ON CONFLICT (ma_sv, ma_mon, hoc_ky) DO NOTHING;

-- 6. Configure Permissions and RLS for Admin / Staff & Profile Completion
-- Cho phép cán bộ xem tất cả sinh viên
DROP POLICY IF EXISTS cb_read_all_students ON app.sinh_vien;
CREATE POLICY cb_read_all_students ON app.sinh_vien FOR SELECT TO authenticated
  USING (app.jwt_ma_cb() IS NOT NULL);

-- Cho phép xem tất cả thông tin cán bộ (để hiển thị giảng viên môn học và danh bạ)
DROP POLICY IF EXISTS cb_read_self ON app.can_bo;
DROP POLICY IF EXISTS read_all_can_bo ON app.can_bo;
CREATE POLICY read_all_can_bo ON app.can_bo FOR SELECT TO authenticated
  USING (true);

-- Cho phép cán bộ xem toàn bộ hồ sơ
DROP POLICY IF EXISTS cb_read_applications ON app.ho_so;
CREATE POLICY cb_read_applications ON app.ho_so FOR SELECT TO authenticated
  USING (app.jwt_ma_cb() IS NOT NULL);

-- Cho phép cán bộ cập nhật trạng thái hồ sơ (duyệt/từ chối)
GRANT UPDATE ON app.ho_so TO authenticated;
DROP POLICY IF EXISTS cb_update_applications ON app.ho_so;
CREATE POLICY cb_update_applications ON app.ho_so FOR UPDATE TO authenticated
  USING (app.jwt_ma_cb() IS NOT NULL)
  WITH CHECK (app.jwt_ma_cb() IS NOT NULL);

-- Cho phép người dùng hoàn thiện thông tin (complete profile)
GRANT INSERT, UPDATE ON app.sinh_vien TO authenticated;
GRANT INSERT, UPDATE ON app.can_bo TO authenticated;

DROP POLICY IF EXISTS sv_insert_self ON app.sinh_vien;
CREATE POLICY sv_insert_self ON app.sinh_vien FOR INSERT TO authenticated
  WITH CHECK (keycloak_sub = app.jwt_sub());

DROP POLICY IF EXISTS sv_update_self ON app.sinh_vien;
CREATE POLICY sv_update_self ON app.sinh_vien FOR UPDATE TO authenticated
  USING (keycloak_sub = app.jwt_sub())
  WITH CHECK (keycloak_sub = app.jwt_sub());

DROP POLICY IF EXISTS cb_insert_self ON app.can_bo;
CREATE POLICY cb_insert_self ON app.can_bo FOR INSERT TO authenticated
  WITH CHECK (keycloak_sub = app.jwt_sub());

DROP POLICY IF EXISTS cb_update_self ON app.can_bo;
CREATE POLICY cb_update_self ON app.can_bo FOR UPDATE TO authenticated
  USING (keycloak_sub = app.jwt_sub())
  WITH CHECK (keycloak_sub = app.jwt_sub());
