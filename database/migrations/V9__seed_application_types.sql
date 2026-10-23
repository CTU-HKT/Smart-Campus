INSERT INTO app.loai_ho_so(ma_loai,ten_loai,mo_ta)
VALUES ('XIN_DIEM_I','Đơn xin điểm I','Đề nghị xét điểm I cho môn học theo quy trình giảng viên và trưởng khoa')
ON CONFLICT (ma_loai) DO NOTHING;
