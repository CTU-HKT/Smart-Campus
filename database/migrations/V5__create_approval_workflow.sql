CREATE TABLE app.buoc_duyet (
 id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 ma_hs BIGINT NOT NULL REFERENCES app.ho_so(id) ON DELETE CASCADE,
 so_thu_tu INTEGER NOT NULL CHECK (so_thu_tu >= 1),
 ten_buoc VARCHAR(100) NOT NULL,
 trang_thai_buoc VARCHAR(20) NOT NULL DEFAULT 'Chờ'
  CHECK (trang_thai_buoc IN ('Chờ','Đang xử lý','Hoàn thành')),
 ma_cb VARCHAR(20) REFERENCES app.can_bo(ma_cb),
 han_xu_ly TIMESTAMPTZ,
 CONSTRAINT uq_buoc_trong_hs UNIQUE(ma_hs,so_thu_tu),
 CONSTRAINT chk_buoc_co_nguoi_duyet CHECK (trang_thai_buoc = 'Chờ' OR ma_cb IS NOT NULL)
);
CREATE INDEX idx_buoc_duyet_ma_cb ON app.buoc_duyet(ma_cb,trang_thai_buoc);
CREATE INDEX idx_buoc_duyet_ma_hs ON app.buoc_duyet(ma_hs);
CREATE TABLE app.quyet_dinh_duyet (
 id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 ma_buoc BIGINT NOT NULL UNIQUE REFERENCES app.buoc_duyet(id) ON DELETE CASCADE,
 ket_qua VARCHAR(20) NOT NULL CHECK (ket_qua IN ('Đồng ý','Từ chối')),
 y_kien TEXT, thoi_diem TIMESTAMPTZ NOT NULL DEFAULT now()
);
