CREATE TABLE app.ho_so (
 id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 ma_hs VARCHAR(20) NOT NULL UNIQUE,
 ma_sv VARCHAR(20) NOT NULL REFERENCES app.sinh_vien(ma_sv),
 ma_loai VARCHAR(20) NOT NULL REFERENCES app.loai_ho_so(ma_loai),
 ma_dk BIGINT,
 ngay_nop TIMESTAMPTZ NOT NULL DEFAULT now(),
 ly_do TEXT NOT NULL,
 hoc_ky VARCHAR(20) NOT NULL,
 trang_thai VARCHAR(20) NOT NULL DEFAULT 'Mới'
  CHECK (trang_thai IN ('Mới','Đang duyệt','Đã duyệt','Từ chối')),
 ghi_chu TEXT,
 CONSTRAINT chk_ho_so_diem_i CHECK (ma_loai <> 'XIN_DIEM_I' OR ma_dk IS NOT NULL),
 CONSTRAINT fk_ho_so_dkm FOREIGN KEY (ma_dk,ma_sv,hoc_ky)
  REFERENCES app.dang_ky_mon(id,ma_sv,hoc_ky)
);
CREATE INDEX idx_ho_so_ma_sv ON app.ho_so(ma_sv);
CREATE INDEX idx_ho_so_trang_thai ON app.ho_so(trang_thai);
CREATE INDEX idx_ho_so_ma_dk ON app.ho_so(ma_dk) WHERE ma_dk IS NOT NULL;
