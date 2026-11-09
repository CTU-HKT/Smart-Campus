# Known Issues & Limitations (Phiên bản v0.1.0)

Chào mừng bạn đến với dự án **Smart-Campus (UniFlow)**. 

Phiên bản hiện tại (`v0.1.0`) là phiên bản **MVP (Minimum Viable Product)** được phát triển trong khuôn khổ cuộc thi OLP 2026. Mục tiêu của phiên bản này là chứng minh tính khả thi của kiến trúc Microservices, quy trình bảo mật Zero-Trust và quy trình nghiệp vụ tự động hóa.

Dưới đây là danh sách các vấn đề kỹ thuật (Technical Debt) và giới hạn tính năng (Feature Limitations) mà đội ngũ phát triển đã ghi nhận và sẽ tiếp tục xử lý trong các phiên bản tiếp theo.

---

## 1. Giới hạn về Tính năng (Feature Limitations)

Các tính năng sau đây đã có trong thiết kế kiến trúc nhưng **chưa được lập trình hoàn thiện** trong bản MVP này:

- **Chữ ký số (Digital Signature):** Hệ thống chưa tích hợp `pyHanko` và `SoftHSM` để tự động ký số lên file PDF giấy xác nhận. Hiện tại, quy trình mới chỉ dừng lại ở việc cập nhật trạng thái hồ sơ.
- **Sổ cái bất biến (Immutable Ledger):** Chưa tích hợp `ImmuDB` để lưu trữ mã hash và chống sửa đổi lịch sử duyệt hồ sơ.
- **Năng lực Dữ liệu (D):** Chưa có Dashboard phân tích SLA cho Ban giám hiệu (dự kiến dùng Parquet + DuckDB + Metabase).
- **Năng lực Trí tuệ (I):** Chưa có Trợ lý ảo AI (RAG) để tra cứu quy chế (dự kiến dùng Ollama + Qdrant).
- **Kiểm dịch Tập tin:** Chưa tích hợp ClamAV để quét virus đối với các file minh chứng do sinh viên tải lên.

---

## 2. Nợ kỹ thuật (Technical Debt)

Đây là các vấn đề trong mã nguồn và cấu hình cần được cải thiện:

### 2.1. Frontend (Nuxt 3)
- **Hardcoded API Endpoints:** Các đường dẫn API (`http://localhost:9080`) hiện đang được viết cứng trong các file Vue. Cần chuyển vào `runtimeConfig` trong `nuxt.config.ts` để dễ dàng thay đổi giữa các môi trường (Dev/Staging/Prod).
- **Xử lý Tệp đính kèm:** Giao diện sinh viên mới chỉ cho phép nhập tên/link file minh chứng dưới dạng chuỗi (String). Chưa có chức năng upload file thực tế lên Object Storage (như MinIO/S3) và lưu metadata.

### 2.2. Cấu hình Keycloak
- **Thiếu dữ liệu mẫu (Seed Users):** Vì lý do bảo mật, file `dxos-realm.json` đã được xoá toàn bộ user mẫu. Người dùng khi clone dự án cần phải vào Keycloak Admin để tự tạo tài khoản test theo hướng dẫn trong README.
- **Môi trường phát triển:** Keycloak hiện đang chạy ở chế độ `start-dev`. Khi triển khai thực tế cần chuyển sang chế độ `start` và cấu hình HTTPS.

### 2.3. Hạ tầng & Vận hành
- **Thiếu CI/CD:** Dự án chưa thiết lập GitHub Actions để tự động chạy test hoặc build Docker image.
- **Chưa tối ưu Image:** Các Dockerfile (đặc biệt là của Nuxt) chưa được tối ưu đa tầng (multi-stage build) để giảm dung lượng image.

---

## 3. Các vấn đề Bảo mật (Security Notes)

Mặc dù dự án áp dụng tư duy Zero-Trust, nhưng trong môi trường phát triển (Local), có một số điểm cần lưu ý:

- **Môi trường HTTP:** Toàn bộ hệ thống đang chạy trên giao thức HTTP (không mã hóa). Trong môi trường Production, bắt buộc phải cấu hình TLS/SSL (thông qua Reverse Proxy như Nginx/Caddy).
- **Mật khẩu mặc định (dev):** `.env.example` và realm `dxos` chứa mật khẩu mặc định cho môi trường dev (ví dụ tài khoản test `Dev@123456`). Phải đổi trước khi triển khai thật.
- **Thông tin đăng nhập Flowable:** Flowable REST chỉ hỗ trợ Basic auth. APISIX kiểm tra JWT rồi gắn thông tin Basic lấy từ `.env` khi khởi động, tức là mọi người dùng đã qua Gateway đều dùng chung một tài khoản dịch vụ ở phía Flowable.
- **Phân quyền cập nhật hồ sơ:** policy `cb_update_applications` cho phép mọi cán bộ cập nhật mọi hồ sơ (`ho_so`). Chưa giới hạn theo giảng viên phụ trách hoặc theo bước duyệt.
- **Cổng dev:** PostgREST (`3000`) và PostgreSQL (`5432`) đang mở ra máy chủ để tiện phát triển, cần đóng khi triển khai thật.
- **Chưa cài đặt:** chữ ký số (pyHanko + SoftHSM) và nhật ký bất biến (immudb) nằm trong Roadmap, chưa có trong bản 0.1.0.
- **JWKS Caching:** APISIX hiện đang cache JWKS. Nếu Keycloak thay đổi Key đột ngột, cần restart APISIX hoặc đợi cache hết hạn.

---

## 4. Hướng Khắc Phục

Đội ngũ phát triển đã có kế hoạch xử lý các vấn đề trên trong file [README.md](./README.md) ở mục **"Định Hướng Phát Triển (Roadmap)"**. Các đóng góp (Pull Requests) từ cộng đồng để giải quyết các Known Issues này luôn được hoan nghênh!

---
*Cập nhật lần cuối: Tháng 11/2026.*