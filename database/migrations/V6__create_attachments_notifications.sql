CREATE TABLE app.tep_dinh_kem (
 id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 ma_hs BIGINT NOT NULL REFERENCES app.ho_so(id) ON DELETE CASCADE,
 ten_tep VARCHAR(255) NOT NULL, loai_tep VARCHAR(50) NOT NULL,
 dung_luong INTEGER NOT NULL CHECK (dung_luong > 0),
 ngay_tai_len TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_tep_ma_hs ON app.tep_dinh_kem(ma_hs);
CREATE TABLE app.thong_bao (
 id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 ma_hs BIGINT NOT NULL REFERENCES app.ho_so(id) ON DELETE CASCADE,
 ma_sv VARCHAR(20) REFERENCES app.sinh_vien(ma_sv),
 ma_cb VARCHAR(20) REFERENCES app.can_bo(ma_cb),
 noi_dung TEXT NOT NULL,
 thoi_diem_gui TIMESTAMPTZ NOT NULL DEFAULT now(),
 trang_thai_doc BOOLEAN NOT NULL DEFAULT false,
 CONSTRAINT chk_thong_bao_1_nguoi_nhan CHECK ((ma_sv IS NOT NULL) <> (ma_cb IS NOT NULL))
);
CREATE INDEX idx_tb_sv ON app.thong_bao(ma_sv,trang_thai_doc);
CREATE INDEX idx_tb_cb ON app.thong_bao(ma_cb,trang_thai_doc);
