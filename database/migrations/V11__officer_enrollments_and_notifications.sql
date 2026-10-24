-- V11: Quyền cho cán bộ xem và cập nhật môn học (khi phê duyệt điểm I) và phát thông báo
GRANT SELECT, UPDATE ON app.dang_ky_mon TO authenticated;

DROP POLICY IF EXISTS cb_read_enrollments ON app.dang_ky_mon;
CREATE POLICY cb_read_enrollments ON app.dang_ky_mon FOR SELECT TO authenticated
  USING (app.jwt_ma_cb() IS NOT NULL);

DROP POLICY IF EXISTS cb_update_enrollments ON app.dang_ky_mon;
CREATE POLICY cb_update_enrollments ON app.dang_ky_mon FOR UPDATE TO authenticated
  USING (app.jwt_ma_cb() IS NOT NULL)
  WITH CHECK (app.jwt_ma_cb() IS NOT NULL);

-- Cấp quyền phát thông báo cho sinh viên
GRANT INSERT ON app.thong_bao TO authenticated;
DROP POLICY IF EXISTS cb_insert_notifications ON app.thong_bao;
CREATE POLICY cb_insert_notifications ON app.thong_bao FOR INSERT TO authenticated
  WITH CHECK (true);

-- Đảm bảo mỗi môn học chỉ có duy nhất 1 hồ sơ đối với mỗi loại hồ sơ
CREATE UNIQUE INDEX IF NOT EXISTS uq_ho_so_ma_sv_ma_dk 
  ON app.ho_so(ma_sv, ma_loai, ma_dk) 
  WHERE ma_dk IS NOT NULL;
