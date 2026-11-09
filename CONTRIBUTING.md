# Đóng góp cho Smart-Campus

Cảm ơn bạn đã quan tâm. Dự án đang ở phiên bản 0.1.0, nên mọi góp ý đều có giá trị.

## Trước khi bắt đầu

1. Đọc [KNOWN-ISSUES.md](KNOWN-ISSUES.md) để biết những phần đang thiếu hoặc chưa hoàn chỉnh.
2. Mở một issue để trao đổi nếu thay đổi lớn (kiến trúc, schema, quy trình BPMN).

## Quy trình

1. Fork repo và tạo nhánh từ `main`: `feat/<mô-tả>` hoặc `fix/<mô-tả>`.
2. Chạy stack trên máy sạch: `docker compose down -v && docker compose up -d --build`.
3. Viết commit ngắn gọn, mô tả việc đã làm. Ví dụ: `fix(apisix): bỏ header admin mặc định khỏi route flowable`.
4. Mở Pull Request nêu rõ thay đổi, cách kiểm tra và ảnh hưởng tới các service khác.

## Quy ước

- Thay đổi schema phải đi qua migration trong `database/migrations/`, không sửa trực tiếp `init-scripts`.
- Không commit file `.env`, khóa, chứng chỉ, hay mật khẩu thật.
- Mọi file mã mới phải có dòng `SPDX-License-Identifier: MIT`.

## Giấy phép

Đóng góp của bạn được cấp phép theo [MIT License](LICENSE).
