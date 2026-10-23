CREATE TABLE app.sinh_vien (
 ma_sv VARCHAR(20) PRIMARY KEY, keycloak_sub UUID UNIQUE,
 ho_ten VARCHAR(100) NOT NULL, ngay_sinh DATE NOT NULL,
 lop VARCHAR(20) NOT NULL, khoa VARCHAR(100) NOT NULL,
 email VARCHAR(120) NOT NULL UNIQUE, sdt VARCHAR(20)
);
CREATE TABLE app.can_bo (
 ma_cb VARCHAR(20) PRIMARY KEY, keycloak_sub UUID UNIQUE,
 ho_ten VARCHAR(100) NOT NULL,
 chuc_vu VARCHAR(30) NOT NULL CHECK (chuc_vu IN ('Giảng viên','Trưởng khoa','Chuyên viên PĐT')),
 don_vi VARCHAR(100) NOT NULL, email VARCHAR(120) NOT NULL UNIQUE
);
CREATE TABLE app.loai_ho_so (
 ma_loai VARCHAR(20) PRIMARY KEY, ten_loai VARCHAR(100) NOT NULL, mo_ta TEXT
);
CREATE TABLE app.mon_hoc (
 ma_mon VARCHAR(20) PRIMARY KEY, ten_mon VARCHAR(150) NOT NULL,
 so_tc INTEGER NOT NULL CHECK (so_tc > 0),
 ma_cb_phu_trach VARCHAR(20) REFERENCES app.can_bo(ma_cb)
);
CREATE TABLE app.dang_ky_mon (
 id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 ma_sv VARCHAR(20) NOT NULL REFERENCES app.sinh_vien(ma_sv),
 ma_mon VARCHAR(20) NOT NULL REFERENCES app.mon_hoc(ma_mon),
 hoc_ky VARCHAR(20) NOT NULL,
 ngay_dang_ky TIMESTAMPTZ NOT NULL DEFAULT now(),
 trang_thai_dk VARCHAR(20) NOT NULL DEFAULT 'Đang học'
  CHECK (trang_thai_dk IN ('Đang học','Đã học','Rút')),
 diem_chu VARCHAR(5) CHECK (diem_chu IS NULL OR diem_chu IN ('A','B+','B','C+','C','D+','D','F','I')),
 diem_so NUMERIC(3,1) CHECK (diem_so IS NULL OR diem_so BETWEEN 0 AND 10),
 ngay_cap_nhat_diem TIMESTAMPTZ,
 CONSTRAINT uq_dang_ky UNIQUE (ma_sv,ma_mon,hoc_ky),
 CONSTRAINT uq_dang_ky_id_hocky UNIQUE (id,hoc_ky),
 CONSTRAINT uq_dang_ky_id_sv_hocky UNIQUE (id,ma_sv,hoc_ky)
);
CREATE INDEX idx_dkm_ma_sv ON app.dang_ky_mon(ma_sv);
CREATE INDEX idx_dkm_ma_mon ON app.dang_ky_mon(ma_mon);
