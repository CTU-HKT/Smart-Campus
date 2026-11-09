```markdown
[![Github license](https://img.shields.io/github/license/CTU-HKT/Smart-Campus.svg "Github license")](https://github.com/CTU-HKT/Smart-Campus/blob/main/LICENSE)
[![Open issues](https://img.shields.io/github/issues/CTU-HKT/Smart-Campus.svg "Open issues")](https://github.com/CTU-HKT/Smart-Campus/issues)
[![Open Pull Requests](https://img.shields.io/github/issues-pr/CTU-HKT/Smart-Campus.svg "Open Pull Requests")](https://github.com/CTU-HKT/Smart-Campus/pulls)

# Smart-Campus (UniFlow)

Nền tảng quản trị và điều hành dịch vụ số trường học dựa trên kiến trúc Microservices, API Gateway và giải pháp xác thực tập trung.

Mục tiêu là phát triển một hệ thống tiếp nhận, xử lý và số hóa các thủ tục giấy tờ, hồ sơ hành chính dành cho sinh viên và cán bộ giảng viên đại học. Hệ sinh thái được thiết kế theo chuẩn hệ điều hành số (DX-OS) với cơ chế bảo mật đa tầng từ Gateway xuống cơ sở dữ liệu.

Dự án được thực hiện trong cuộc thi [Phần Mềm Nguồn Mở - Olympic Tin học Sinh viên Việt Nam 2026](https://www.olp.vn/). Được phát hành mã nguồn mở theo giấy phép [MIT License](LICENSE).


> **Trạng thái: 0.1.0 (thử nghiệm).** Chưa dùng cho môi trường thật. Xem [KNOWN-ISSUES.md](KNOWN-ISSUES.md) trước khi triển khai. Mọi mật khẩu trong repo là giá trị mặc định cho môi trường dev.

---

## 🔎 Danh Mục

1. [Chức Năng Chính](#chức-năng-chính)
2. [Tổng Quan Hệ Thống](#-tổng-quan-hệ-thống)
3. [Cấu Trúc Thư Mục](#-cấu-trúc-thư-mục)
4. [Hướng Dẫn Cài Đặt](#hướng-dẫn-cài-đặt)
5. [Kê Khai Thành Phần Bên Thứ Ba](#-kê-khai-thành-phần-bên-thứ-ba)
6. [Định Hướng Phát Triển (Roadmap)](#-định-hướng-phát-triển-roadmap)
7. [Hạn Chế Đã Biết](#-hạn-chế-đã-biết-known-issues)
8. [📝 License](#-license)

---

## Chức Năng Chính

Dự án tập trung vào việc số hóa quy trình nghiệp vụ cốt lõi sau:

1. **Xác thực & Phân quyền (SSO):** Đăng nhập một lần qua Keycloak, tự động phân quyền giao diện (Student, Teacher, Dean) dựa trên JWT.
2. **Nộp hồ sơ trực tuyến:** Sinh viên có thể xem danh sách môn học đủ điều kiện và nộp Đơn xin điểm I. Hệ thống tự động kiểm tra điều kiện điểm số (< 8.0) và ngăn chặn nộp trùng.
3. **Quy trình duyệt đa cấp (BPMN):** Tích hợp Flowable Engine quản lý quy trình: Giảng viên duyệt -> Trưởng khoa duyệt. Lưu vết toàn bộ lịch sử và ghi chú duyệt.
4. **Tra cứu & Thông báo:** Sinh viên theo dõi tiến trình xử lý hồ sơ theo thời gian thực và nhận thông báo hệ thống.
5. **Bảo mật dữ liệu:** Áp dụng Row Level Security (RLS) ở tầng Database, để hạn chế sinh viên A xem hồ sơ của sinh viên B.

---

## Tổng Quan Hệ Thống

Backend của hệ thống được thiết kế theo kiến trúc Microservices, với các công nghệ sử dụng như sau:

- [Nuxt 3](https://nuxt.com/): Cổng dịch vụ người dùng (Frontend).
- [Apache APISIX](https://apisix.apache.org/): Cổng API Gateway (Xác thực JWT qua JWKS).
- [Keycloak](https://www.keycloak.org/): Quản lý định danh và phân quyền truy cập tập trung (OIDC + PKCE).
- [PostgREST](https://postgrest.org/): Tự động chuyển đổi lược đồ PostgreSQL thành RESTful API.
- [PostgreSQL 18](https://www.postgresql.org/): Cơ sở dữ liệu quan hệ (Áp dụng RLS).
- [Flowable](https://www.flowable.com/): Workflow Engine (BPMN 2.0) xử lý quy trình duyệt đơn.
- [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/): Đóng gói và điều phối hệ thống.

### Kiến trúc hệ thống và Luồng dữ liệu

```text
            [ Sinh viên / Cán bộ ]
                     │
                     ▼
      ┌───────────────────────────────┐
      │    Nuxt 3 - Student Portal    │
      └──────────────┬────────────────┘
                     │
                     ▼
      ┌───────────────────────────────┐
      │    Apache APISIX (Gateway)    │
      │    - Plugin openid-connect    │
      │    - Xác thực JWT qua JWKS    │
      └──────────────┬────────────────┘
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
┌─────────────────┐   ┌───────────────────┐
│    PostgREST    │   │   Flowable REST   │
└────────┬────────┘   └─────────┬─────────┘
         │                      │
         ▼                      ▼
┌─────────────────────────────────────────┐
│           PostgreSQL Database           │
│  - Row Level Security (RLS)             │
│  - Ràng buộc user_id = sub              │
└─────────────────────────────────────────┘
```

---

## Cấu Trúc Thư Mục

```text
Smart-Campus/
├── student-portal/       # Mã nguồn Frontend (Nuxt 3 + Vue)
├── apisix_conf/          # Cấu hình API Gateway (APISIX)
├── keycloak/             # File cấu hình Realm (dxos-realm.json)
├── database/             # Script khởi tạo DB, migrations và RLS
├── flowableworkflow/     # File BPMN định nghĩa quy trình duyệt
├── .env.example          # File mẫu biến môi trường
├── docker-compose.yml    # File điều phối Docker
└── README.md             # Tài liệu dự án
```

---

## Hướng Dẫn Cài Đặt

### 📋 Yêu Cầu (Prerequisites)

- [Docker Engine](https://docs.docker.com/get-docker/) (phiên bản `>= 24.0.0`)
- [Docker Compose](https://docs.docker.com/compose/install/) (phiên bản `>= 2.20.0`)
- [Node.js](https://nodejs.org/) (phiên bản `>= 20.x` - Tùy chọn nếu phát triển Frontend)

### 🔨 Các Bước Cài Đặt

#### Bước 1: Chuẩn bị biến môi trường (`.env`)
1. Mở terminal tại thư mục gốc và tạo file `.env` từ file mẫu:
   ```bash
   cp .env.example .env
   ```
2. File mẫu đã có sẵn giá trị mặc định **dành cho môi trường dev**, chạy được ngay. Đổi toàn bộ mật khẩu trước khi triển khai thật. Không commit file `.env`.

#### Bước 2: Khởi động Database và Keycloak trước
Vì lý do bảo mật, file cấu hình Keycloak không chứa sẵn Private Key. Keycloak sẽ tự sinh Key mới khi khởi động lần đầu.
1. Khởi động Postgres và Keycloak:
   ```bash
   docker compose up -d postgres keycloak
   ```
2. Đợi khoảng 30-60 giây để Keycloak khởi động xong (có thể xem log bằng lệnh `docker compose logs -f keycloak`).

#### Bước 3: Lấy JWKS và cập nhật `.env` (Quan trọng)
Vì Keycloak đã sinh Key mới, PostgREST cần Public Key mới này để xác thực.
1. Mở trình duyệt, truy cập đường dẫn lấy JWKS:
   `http://localhost:8080/realms/dxos/protocol/openid-connect/certs`
2. Copy toàn bộ đoạn mã JSON trả về.
3. Mở file `.env`, tìm biến `PGRST_JWT_SECRET` và dán đoạn JSON đó vào trong dấu ngoặc kép:
   ```env
   PGRST_JWT_SECRET='{"keys":[...dán đoạn JSON vừa copy vào đây...]}'
   ```
   *(Lưu ý: Đảm bảo không có ký tự xuống dòng thừa bên trong chuỗi JSON).*
4. Áp dụng `.env` mới và xoá cache JWKS của Gateway:
   ```bash
   docker compose up -d postgrest
   ```
   Lưu ý: phải dùng `up -d` cho PostgREST, `restart` không nạp lại biến môi trường. Mỗi lần chạy `docker compose down -v` (xoá volume Keycloak), Keycloak sinh khoá mới và bạn phải làm lại Bước 3.

#### Bước 4: Khởi chạy toàn bộ hệ thống
```bash
docker compose up -d --build
```
Chờ cho đến khi lệnh `docker compose ps` báo tất cả các service đều `Up` hoặc `Exited (0)` (đối với flyway và flowable-init).

#### Bước 5: Tài khoản dùng thử có sẵn
Realm `dxos` đã có sẵn tài khoản và dữ liệu mẫu (Keycloak import + seed Postgres). Không cần tạo user thủ công.

| Tài khoản | Mật khẩu (dev) | Vai trò | Dữ liệu mẫu |
| :--- | :--- | :--- | :--- |
| `student1` | `Dev@123456` | student | Sinh viên B2100001 |
| `student2` | `Dev@123456` | student | Sinh viên B2100002 |
| `teacher1` | `Dev@123456` | teacher | Giảng viên CB001 |
| `teacher2` | `Dev@123456` | teacher | Giảng viên CB002 |
| `dean1` | `Dev@123456` | dean | Trưởng khoa TK_KTPM |

Mật khẩu chỉ dành cho môi trường thử nghiệm. Đổi trước khi triển khai thật. Lần khởi động đầu, Flowable cần 1-2 phút trước khi nhận yêu cầu.

---

## Vận Hành

### Cập nhật khi thay đổi mã nguồn hoặc cấu hình
- Sửa giao diện (`student-portal/`):
  ```bash
  docker compose up -d --build student-portal
  ```
- Sửa cấu hình APISIX (`apisix_conf/apisix.yaml.tmpl`; file này được render thành `apisix.yaml` mỗi lần container khởi động):
  ```bash
  docker compose restart apisix
  ```
- Sửa cấu hình Keycloak (`keycloak/dxos-realm.json`; chỉ được import khi database Keycloak còn trống, nên cần reset database):
  ```bash
  docker compose down -v && docker compose up -d
  ```

### Reset database
Xoá sạch dữ liệu, bao gồm cả tài khoản Keycloak, và nạp lại `database/init-scripts/` cùng migrations:
```bash
docker compose down -v
docker compose up -d --build
```
Sau đó làm lại Bước 3.

### Kiểm thử luồng đăng nhập
1. Mở `http://localhost:3001`.
2. Nhấn Đăng nhập, hệ thống chuyển sang Keycloak.
3. Đăng nhập bằng tài khoản ở Bước 5, hệ thống quay lại đúng giao diện theo quyền.

---

## PORT BINDING

Sau khi khởi chạy thành công, các dịch vụ sẽ hoạt động trên các cổng sau:

| Dịch vụ | PORT | Mô tả chức năng |
| :--- | :--- | :--- |
| **Student Portal** | `3001` | Giao diện Web Cổng dịch vụ sinh viên và Bàn làm việc cán bộ |
| **Keycloak IAM** | `8080` | Máy chủ quản trị định danh và phiên làm việc SSO |
| **APISIX Gateway** | `9080` | Cổng tiếp nhận API tập trung, xác thực JWT trước khi chuyển tiếp |
| **PostgREST** | `3000` | REST API trực tiếp, chỉ dành cho dev, nên đóng khi triển khai thật |
| **PostgreSQL** | `5432` | Cơ sở dữ liệu, chỉ dành cho dev |

---

## 📦 Kê Khai Thành Phần Bên Thứ Ba

Tuân thủ quy định phần mềm tự do nguồn mở OSI, dự án minh bạch toàn bộ các thành phần sử dụng:

| Thành phần | Phiên bản | Vai trò hệ thống | Giấy phép |
| :--- | :---: | :--- | :--- |
| **Nuxt 3** | 3.21.x | Framework ứng dụng Web | [MIT](https://opensource.org/licenses/MIT) |
| **Vue.js** | 3.5.x | Thư viện UI cốt lõi | [MIT](https://opensource.org/licenses/MIT) |
| **Keycloak JS** | 26.0.x | Thư viện OIDC Client phía Web | [Apache-2.0](https://opensource.org/licenses/Apache-2.0) |
| **Apache APISIX** | 3.13.0 | API Gateway điều phối | [Apache-2.0](https://opensource.org/licenses/Apache-2.0) |
| **Keycloak Server** | 26.8.0 | Máy chủ xác thực định danh | [Apache-2.0](https://opensource.org/licenses/Apache-2.0) |
| **PostgreSQL** | 18-alpine | Hệ quản trị cơ sở dữ liệu | [PostgreSQL](https://opensource.org/licenses/PostgreSQL) |
| **PostgREST** | Bản mới nhất khi build | REST API chuyển đổi tự động | [MIT](https://opensource.org/licenses/MIT) |
| **Flowable** | 6.8.0 | Workflow Engine BPMN | [Apache-2.0](https://opensource.org/licenses/Apache-2.0) |
| **Flyway** | 11 | Migration cơ sở dữ liệu | [Apache-2.0](https://opensource.org/licenses/Apache-2.0) |
| **etcd** | 3.5.11 | Lưu trữ cấu hình cho APISIX | [Apache-2.0](https://opensource.org/licenses/Apache-2.0) |

---

## 🚀 Định Hướng Phát Triển (Roadmap)

Phiên bản hiện tại (v0.1.0) tập trung vào việc hoàn thiện luồng nghiệp vụ cốt lõi (MVP). Trong các giai đoạn tiếp theo, dự án sẽ được mở rộng theo lộ trình sau:

### Giai đoạn 2: Nâng cấp Nghiệp vụ & Bảo mật Văn bản
- [ ] **Chữ ký số (Digital Signature):** Tích hợp `pyHanko` và `SoftHSM` để tự động ký số file PDF giấy xác nhận sinh viên. Đảm bảo tính toàn vẹn và giá trị pháp lý của văn bản.
- [ ] **Sổ cái bất biến (Immutable Ledger):** Tích hợp `ImmuDB` để lưu vết lịch sử phê duyệt và mã hash của văn bản, chống sửa đổi dữ liệu từ phía Admin.
- [ ] **Quy trình động (Dynamic Workflow):** Nâng cấp Flowable để hỗ trợ duyệt song song (nhiều người duyệt cùng lúc) và duyệt có điều kiện (dựa trên điểm số hoặc loại đơn).

### Giai đoạn 3: Năng lực Dữ liệu (D) & Trí tuệ (I)
- [ ] **Dashboard Phân tích (D):** Trích xuất dữ liệu từ PostgreSQL sang `Parquet`/`DuckDB`, sử dụng `dbt` để quản lý phả hệ dữ liệu (Data Lineage) và `Metabase` để xây dựng Dashboard theo dõi SLA cho Ban giám hiệu.
- [ ] **AI Assistant (I):** Tích hợp LLM chạy nội bộ (`Ollama` + `Qdrant`) để xây dựng trợ lý ảo RAG, giúp sinh viên tra cứu quy chế. Có cơ chế che giấu thông tin cá nhân (PII) trước khi đưa vào mô hình để bảo mật dữ liệu.

### Giai đoạn 4: Hoàn thiện Zero-Trust & Vận hành (Ops)
- [ ] **Kiểm dịch Tập tin (File Malware Scanning):** Tích hợp `ClamAV` vào APISIX để quét virus các file minh chứng do sinh viên upload lên.
- [ ] **GitOps & Tự phục hồi:** Đóng gói toàn bộ cấu hình hạ tầng bằng Helm Charts và triển khai qua `ArgoCD` trên Kubernetes, đảm bảo khả năng tự động phục hồi khi có sự cố.

---

## 🚧 Hạn Chế Đã Biết (Known Issues)

Dự án được phát triển trong khuôn khổ cuộc thi và chốt ở phiên bản MVP. Vui lòng xem chi tiết các hạn chế kỹ thuật và định hướng khắc phục tại file [KNOWN-ISSUES.md](KNOWN-ISSUES.md).

---

## 📝 License (Giấy Phép)

Dự án **Smart-Campus** là phần mềm nguồn mở được phát hành theo các điều khoản của giấy phép **[MIT License](LICENSE)**. Xem toàn văn nội dung giấy phép tại tệp [LICENSE](LICENSE).
```

