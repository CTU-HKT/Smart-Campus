[![Github license](https://img.shields.io/github/license/CTU-HKT/Smart-Campus.svg "Github license")](https://github.com/CTU-HKT/Smart-Campus/blob/main/LICENSE)
[![Open issues](https://img.shields.io/github/issues/CTU-HKT/Smart-Campus.svg "Open issues")](https://github.com/CTU-HKT/Smart-Campus/issues)
[![Open Pull Requests](https://img.shields.io/github/issues-pr/CTU-HKT/Smart-Campus.svg "Open Pull Requests")](https://github.com/CTU-HKT/Smart-Campus/pulls)
[![Commit activity](https://img.shields.io/github/commit-activity/m/CTU-HKT/Smart-Campus.svg "Commit activity")](https://github.com/CTU-HKT/Smart-Campus/graphs/commit-activity)
[![GitHub contributors](https://img.shields.io/github/contributors/CTU-HKT/Smart-Campus.svg "Github contributors")](https://github.com/CTU-HKT/Smart-Campus/graphs/contributors)

# Smart-Campus

Nền tảng quản trị và điều hành dịch vụ số trường học dựa trên kiến trúc Microservices, cổng API Gateway và giải pháp xác thực tập trung.

Mục tiêu là phát triển một hệ thống tiếp nhận, xử lý và số hóa các thủ tục giấy tờ, hồ sơ hành chính dành cho sinh viên và cán bộ giảng viên đại học. Hệ sinh thái được thiết kế theo chuẩn hệ điều hành số (DX-OS) với cơ chế bảo mật đa tầng từ Gateway xuống cơ sở dữ liệu.

Dự án được thực hiện trong cuộc thi [Phần Mềm Nguồn Mở - Olympic Tin học Sinh viên Việt Nam 2026](https://www.olp.vn/procon-pmmn/phần-mềm-nguồn-mở). Được phát hành mã nguồn mở theo giấy phép [MIT License](LICENSE) bởi đội tác giả **CTU-HKT**.

---

## 🔎 Danh Mục

1. [Giới Thiệu](#giới-thiệu)
2. [Chức Năng Chính](#chức-năng-chính)
3. [Tổng Quan Hệ Thống](#-tổng-quan-hệ-thống)
4. [Cấu Trúc Thư Mục](#cấu-trúc-thư-mục)
5. [Hướng Dẫn Cài Đặt](#hướng-dẫn-cài-đặt)
   - [📋 Yêu Cầu - Prerequisites](#yêu-cầu-)
   - [🔨 Cài Đặt](#-cài-đặt)
   - [PORT BINDING](#port-binding)
6. [Kê Khai Thành Phần Bên Thứ Ba](#-kê-khai-thành-phần-bên-thứ-ba)
7. [🙌 Đóng Góp Cho Dự Án](#-đóng-góp-cho-dự-án)
8. [📝 License](#-license)

---

## Giới Thiệu

- Trong các trường đại học hiện nay, quy trình nộp đơn, xin cấp giấy chứng nhận, giấy xác nhận sinh viên (tạm hoãn NVQS, vay vốn ngân hàng chính sách, giới thiệu thực tập) thường phải thực hiện thủ công hoặc qua nhiều hệ thống rời rạc, gây mất thời gian và khó khăn trong việc tra cứu trạng thái.
- **Smart-Campus** giải quyết triệt để vấn đề này bằng cách số hóa toàn diện quy trình tiếp nhận và thẩm định hồ sơ điện tử:
  - Cung cấp cổng trực tuyến giúp sinh viên theo dõi tiến độ xử lý hồ sơ minh bạch theo thời gian thực.
  - Cung cấp bàn làm việc số tập trung cho cán bộ thẩm định, hỗ trợ quản lý trạng thái hồ sơ và phân tích SLA giải quyết dịch vụ.
  - Triển khai kiến trúc định danh tập trung (SSO) và bảo mật cấp hàng (Row Level Security) đảm bảo tuyệt đối tính riêng tư và an toàn dữ liệu giữa các người dùng.

---

## Chức Năng Chính

Dự án tập trung vào các chức năng cốt lõi sau:

---

## Tổng Quan Hệ Thống

Backend của hệ thống được thiết kế theo kiến trúc Microservices, với các công nghệ sử dụng như sau:

- [Nuxt 3](https://nuxt.com/): Cổng dịch vụ người dùng.
- [Apache APISIX](https://apisix.apache.org/): Cổng API Gateway.
- [Keycloak](https://www.keycloak.org/): Quản lý định danh và phân quyền truy cập tập trung, tích hợp SSO.
- [etcd](https://etcd.io/): Lưu trữ phân tán dạng key-value.
- [PostgREST](https://postgrest.org/): chuyển đổi lược đồ cơ sở dữ liệu PostgreSQL thành RESTful API.
- [PostgreSQL 16](https://www.postgresql.org/): Cơ sở dữ liệu quan hệ.
- [Docker](https://www.docker.com/): Đóng gói các dịch vụ thành các container độc lập.
- [Docker Compose](https://docs.docker.com/compose/): Quản lý và điều phối toàn bộ cụm dịch vụ.

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
                     ▼
      ┌───────────────────────────────┐
      │           PostgREST           │
      └──────────────┬────────────────┘
                     │
                     ▼
      ┌───────────────────────────────┐
      │      PostgreSQL Database      │
      │  - Row Level Security (RLS)   │
      │  - Ràng buộc user_id = sub    │
      └───────────────────────────────┘
```

---

## Cấu Trúc Thư Mục

- [`student-portal/`](./student-portal) - Ứng dụng Web giao diện người dùng xây dựng bằng Nuxt 3 và TypeScript.
- [`apisix_conf/`](./apisix_conf) - Tệp cấu hình định tuyến tĩnh và plugin xác thực OIDC cho Apache APISIX.
- [`keycloak/`](./keycloak) - Tệp dữ liệu cấu hình Realm mẫu (`dxos-realm.json`) sẵn sàng import vào Keycloak.
- [`database/`](./database) - Các kịch bản SQL khởi tạo cấu trúc bảng, cấp quyền roles và thiết lập chính sách bảo mật RLS.
- [`docker-compose.yml`](./docker-compose.yml) - Kịch bản điều phối khởi chạy toàn bộ 5 dịch vụ hệ thống.

---

## Hướng Dẫn Cài Đặt

### Yêu Cầu 📋

Để cài đặt và chạy được dự án, bạn cần chuẩn bị môi trường cơ bản sau:

- [Docker Engine](https://docs.docker.com/get-docker/) (phiên bản `>= 24.0.0`)
- [Docker Compose](https://docs.docker.com/compose/install/) (phiên bản `>= 2.20.0` - Docker Compose V2)
- [Node.js](https://nodejs.org/) (phiên bản `>= 20.x` - Tùy chọn nếu cần phát triển trực tiếp Nuxt 3)

### 🔨 Cài Đặt

### Bước 1: Thiết lập biến môi trường (`.env`)

1. Mở terminal tại thư mục gốc của dự án (`Smart-Campus`) và tạo file `.env` từ file mẫu:

   ```bash
   cp .env.example .env
   ```

2. Tạo chuỗi khóa ngẫu nhiên 32-byte cho `ADMIN_KEY`:
   - **Windows (PowerShell):**
     ```powershell
     $bytes = New-Object byte[] 32; [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes); ($bytes | ForEach-Object { $_.ToString('x2') }) -join ''
     ```
   - **macOS / Linux:**
     ```bash
     openssl rand -hex 32
     ```

3. Mở file `.env` vừa tạo và dán chuỗi khóa vừa nhận được vào sau biến `ADMIN_KEY=`:
   ```env
   ADMIN_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

---

### Bước 2: Khởi chạy hệ thống

Chạy lệnh sau để build và khởi động ngầm 6 container dịch vụ của hệ thống:

```bash
docker compose up -d --build
```

---

### Bước 3: Kiểm tra trạng thái hoạt động

1. **Kiểm tra trạng thái các container** (Đảm bảo cả 6 container đều ở trạng thái `Up`):

   ```bash
   docker ps
   ```

2. **Kiểm tra quá trình khởi tạo dữ liệu của Keycloak**:
   ```bash
   docker compose logs -f keycloak
   ```
   > 💡 **Lưu ý:** Chờ đến khi màn hình xuất hiện dòng `Realm 'dxos' imported` và `Listening on: http://0.0.0.0:8080` thì nhấn `Ctrl + C` để thoát chế độ xem log.

---

#### PORT BINDING

Sau khi khởi chạy thành công, các dịch vụ sẽ hoạt động trên các cổng sau:

<table width="100%">
<thead>
<tr>
<th>Dịch vụ</th>
<th>PORT BINDING</th>
<th>Mô tả chức năng</th>
</tr>
</thead>
<tbody>
<tr>
<td><strong>Student Portal</strong></td>
<td><code>3001:3000</code></td>
<td>Giao diện Web Cổng dịch vụ sinh viên và Bàn làm việc cán bộ</td>
</tr>
<tr>
<td><strong>Keycloak IAM</strong></td>
<td><code>8080:8080</code></td>
<td>Máy chủ quản trị định danh và phiên làm việc SSO</td>
</tr>
<tr>
<td><strong>APISIX Gateway</strong></td>
<td><code>9080:9080</code></td>
<td>Cổng tiếp nhận API tập trung, xác thực JWT trước khi chuyển tiếp</td>
</tr>
</tbody>
</table>

---

## 📦 Kê Khai Thành Phần Bên Thứ Ba

Tuân thủ quy định phần mềm tự do nguồn mở OSI và tiêu chí PoF (_Principles of FOSS_), dự án minh bạch toàn bộ các thành phần sử dụng:

| Thành phần          | Phiên bản | Vai trò hệ thống              |                          Giấy phép                           |   Phương thức tích hợp    |   Tính tương thích với MIT   |
| :------------------ | :-------: | :---------------------------- | :----------------------------------------------------------: | :-----------------------: | :--------------------------: |
| **Nuxt 3**          |  3.21.x   | Framework ứng dụng Web        |          [MIT](https://opensource.org/licenses/MIT)          |    Quản lý gói (`npm`)    |    Tương thích hoàn toàn     |
| **Vue.js**          |   3.5.x   | Thư viện UI cốt lõi           |          [MIT](https://opensource.org/licenses/MIT)          |    Quản lý gói (`npm`)    |    Tương thích hoàn toàn     |
| **Vue Router**      |   5.2.x   | Điều hướng trang Web          |          [MIT](https://opensource.org/licenses/MIT)          |    Quản lý gói (`npm`)    |    Tương thích hoàn toàn     |
| **Keycloak JS**     |  26.0.x   | Thư viện OIDC Client phía Web |   [Apache-2.0](https://opensource.org/licenses/Apache-2.0)   |    Quản lý gói (`npm`)    |   Tương thích (Permissive)   |
| **Apache APISIX**   |  3.13.0   | API Gateway điều phối         |   [Apache-2.0](https://opensource.org/licenses/Apache-2.0)   | Dịch vụ Container độc lập | Tương thích (Giao tiếp mạng) |
| **Keycloak Server** |  26.8.0   | Máy chủ xác thực định danh    |   [Apache-2.0](https://opensource.org/licenses/Apache-2.0)   | Dịch vụ Container độc lập | Tương thích (Giao tiếp mạng) |
| **PostgreSQL**      | 16-alpine | Hệ quản trị cơ sở dữ liệu     |   [PostgreSQL](https://opensource.org/licenses/PostgreSQL)   | Dịch vụ Container độc lập |   Tương thích (Permissive)   |
| **PostgREST**       |  12.0.x   | REST API chuyển đổi tự động   | [BSD-3-Clause](https://opensource.org/licenses/BSD-3-Clause) | Dịch vụ Container độc lập | Tương thích (Giao tiếp mạng) |
| **etcd**            |  3.5.11   | Lưu trữ cấu hình phân tán     |   [Apache-2.0](https://opensource.org/licenses/Apache-2.0)   | Dịch vụ Container độc lập | Tương thích (Giao tiếp mạng) |

_Ghi chú:_ Toàn bộ các dịch vụ trên được cấu hình thông qua `docker-compose.yml` nguyên bản, kho mã nguồn không sao chép trực tiếp mã nguồn bên thứ ba vào repo (no bundling) và không chỉnh sửa mã nguồn gốc của bất kỳ dịch vụ nào.

---

## 🙌 Đóng góp cho dự án

Mọi đóng góp từ cộng đồng đều được trân trọng, đừng ngần ngại tạo Pull Request để giúp sản phẩm hoàn thiện hơn.

---

## 📝 License (Giấy Phép)

Dự án **Smart-Campus** là phần mềm nguồn mở được phát hành theo các điều khoản của giấy phép **[MIT License](LICENSE)** (được tổ chức [OSI phê duyệt](https://opensource.org/licenses/MIT)).

**Mục đích cấp phép:**
Giấy phép MIT cho phép bất kỳ cá nhân, tổ chức nào được quyền tự do tiếp cận, nghiên cứu, sao chép, sửa đổi, hợp nhất, xuất bản, phân phối và/hoặc thương mại hóa mã nguồn của phần mềm, với điều kiện duy nhất là phải giữ nguyên thông báo bản quyền gốc và toàn văn giấy phép MIT trong mọi bản sao hoặc phần trọng yếu của phần mềm.

Xem toàn văn nội dung giấy phép tại tệp [LICENSE](LICENSE).
