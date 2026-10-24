<!--
  SPDX-License-Identifier: MIT
  Copyright (c) 2026 CTU-HKT. All rights reserved.
-->
<template>
  <div class="admin-wrapper">
    <!-- ================= NAVBAR (ĐỒNG BỘ 100% PHONG CÁCH VÀ THEME CỦA INDEX.VUE) ================= -->
    <header class="navbar">
      <div class="nav-container">
        <!-- Logo SmartCampus (Phong cách index.vue) -->
        <div class="nav-brand">
          <NuxtLink to="/" class="logo">
            <span class="logo-bold">Smart</span><span>Campus</span>
          </NuxtLink>
          <span class="brand-badge">Teacher</span>
        </div>

        <!-- Thông tin cán bộ & trạng thái chữ ký số -->
        <NuxtLink to="/info" class="officer-info" title="Xem thông tin cá nhân">
          <span class="officer-label">Cán bộ thẩm định:</span>
          <span class="officer-name">{{ user?.name || 'Cán bộ' }}</span>
          <span class="status-dot-separator">·</span>
          <span class="signature-tag">
            <span class="green-dot"></span>
            Hồ sơ & Chữ ký số
          </span>
        </NuxtLink>

        <!-- Menu chuyển đổi 2 chế độ xem (Hàng đợi & SLA) + Nút Đăng xuất -->
        <div class="nav-actions">
          <div class="tab-control">
            <button 
              type="button"
              class="tab-item" 
              :class="{ active: activeTab === 'queue' }"
              @click="activeTab = 'queue'"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
              </svg>
              <span>Hàng đợi Thẩm định</span>
              <span class="badge-count">{{ pendingCount }}</span>
            </button>

            <button 
              type="button"
              class="tab-item" 
              :class="{ active: activeTab === 'sla' }"
              @click="activeTab = 'sla'"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="18" y1="20" x2="18" y2="10"/>
                <line x1="12" y1="20" x2="12" y2="4"/>
                <line x1="6" y1="20" x2="6" y2="14"/>
              </svg>
              <span>Thống kê & SLA Đơn vị</span>
            </button>
          </div>

          <button @click="logout" class="btn-logout" title="Đăng xuất">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
              <polyline points="16 17 21 12 16 7"/>
              <line x1="21" y1="12" x2="9" y2="12"/>
            </svg>
          </button>
        </div>
      </div>
    </header>

    <!-- ================= TIÊU ĐỀ TRANG ================= -->
    <section class="page-title-section">
      <div class="main-container">
        <h1 class="page-main-heading">Bàn làm việc Số & Hệ thống Thống kê Giáo viên</h1>
        <p class="page-sub-heading">Hệ thống tiếp nhận, thẩm định và cấp phát giấy tờ số hóa trường học</p>
      </div>
    </section>

    <!-- ================= NỘI DUNG 2 CHẾ ĐỘ XEM ================= -->
    <main class="main-content">
      <div class="main-container">

        <!-- ================= CHẾ ĐỘ 1: HÀNG ĐỢI THẨM ĐỊNH (THEO THEME INDEX.VUE) ================= -->
        <div v-if="activeTab === 'queue'" class="tab-view">
          <!-- 4 Thẻ chỉ số trạng thái (Hiện để 0 vì chưa có dữ liệu) -->
          <div class="stats-grid">
            <div class="stat-box">
              <div class="stat-title">Chờ duyệt (Pending Backlog)</div>
              <div class="stat-number text-emerald">{{ pendingCount }}</div>
            </div>

            <div class="stat-box">
              <div class="stat-title">Đã phê duyệt & Ký số</div>
              <div class="stat-number">{{ approvedCount }}</div>
            </div>

            <div class="stat-box">
              <div class="stat-title">Yêu cầu bổ sung</div>
              <div class="stat-number text-amber">{{ needMoreCount }}</div>
            </div>

            <div class="stat-box">
              <div class="stat-title">Đã từ chối</div>
              <div class="stat-number text-rose">{{ rejectedCount }}</div>
            </div>
          </div>

          <!-- Thanh tìm kiếm và bộ lọc -->
          <div class="filter-bar">
            <!-- Ô tìm kiếm -->
            <div class="search-box">
              <span class="search-icon">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="11" cy="11" r="8"/>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
              </span>
              <input 
                v-model="searchQuery" 
                type="text" 
                placeholder="Tìm theo mã đơn (REQ-...), tên sinh viên, MSSV..." 
                class="search-input"
              />
            </div>

            <!-- Phân hệ -->
            <div class="filter-dropdown">
              <span class="dropdown-label">Phân hệ:</span>
              <select v-model="filterDomain" class="dropdown-select">
                <option value="all">Tất cả phân hệ (2 mục)</option>
                <option value="Dịch vụ đơn từ">Dịch vụ đơn từ</option>
                <option value="Hành chính số">Hành chính số</option>
              </select>
            </div>

            <!-- Loại thủ tục -->
            <div class="filter-dropdown">
              <span class="dropdown-label">Loại:</span>
              <select v-model="filterDocType" class="dropdown-select">
                <option value="all">Tất cả thủ tục (9)</option>
                <option value="Giấy xác nhận tạm hoãn NVQS">Giấy xác nhận tạm hoãn NVQS</option>
                <option value="Giấy xác nhận vay vốn NHCSXH">Giấy xác nhận vay vốn NHCSXH</option>
                <option value="Giấy giới thiệu thực tập">Giấy giới thiệu thực tập</option>
              </select>
            </div>

            <!-- Trạng thái -->
            <div class="filter-dropdown">
              <span class="dropdown-label">Trạng thái:</span>
              <select v-model="filterStatus" class="dropdown-select">
                <option value="all">Tất cả trạng thái</option>
                <option value="Chờ duyệt">Chờ duyệt</option>
                <option value="Đã ký số">Đã ký số</option>
                <option value="Cần bổ sung">Cần bổ sung</option>
                <option value="Đã từ chối">Đã từ chối</option>
              </select>
            </div>
          </div>

          <!-- Bảng danh sách hồ sơ thẩm định (ĐỂ TRỐNG KHI CHƯA CÓ DỮ LIỆU) -->
          <div class="table-card">
            <table class="data-table">
              <thead>
                <tr>
                  <th>MÃ HỒ SƠ</th>
                  <th>SINH VIÊN</th>
                  <th>LOẠI TÀI LIỆU</th>
                  <th>THỜI GIAN NỘP</th>
                  <th>TRẠNG THÁI</th>
                  <th class="text-right">THAO TÁC</th>
                </tr>
              </thead>
              <tbody>
                <!-- Nếu có dữ liệu trong mảng applications -->
                <tr v-for="item in filteredApplications" :key="item.id" class="table-row">
                  <td class="code-col">{{ item.code }}</td>
                  <td>
                    <div class="student-name">{{ item.studentName }}</div>
                    <div class="student-meta">{{ item.mssv }} · {{ item.cohort }}</div>
                  </td>
                  <td>
                    <div class="doc-name">{{ item.docTitle }}</div>
                    <span class="doc-badge">{{ item.docTag }}</span>
                  </td>
                  <td class="time-col">{{ item.submittedAt }}</td>
                  <td>
                    <span class="status-tag" :class="'status-' + item.statusCode">
                      {{ item.status }}
                    </span>
                  </td>
                  <td class="text-right">
                    <button class="btn btn-black-sm">Thẩm định</button>
                  </td>
                </tr>

                <!-- TRẠNG THÁI TRỐNG (EMPTY STATE CHUẨN PHONG CÁCH TỐI GIẢN CỦA INDEX.VUE) -->
                <tr v-if="filteredApplications.length === 0">
                  <td colspan="6" class="empty-cell">
                    <div class="empty-wrapper">
                      <div class="empty-icon-circle">
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="1.75">
                          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                          <polyline points="14 2 14 8 20 8"/>
                          <line x1="16" y1="13" x2="8" y2="13"/>
                          <line x1="16" y1="17" x2="8" y2="17"/>
                          <line x1="10" y1="9" x2="8" y2="9"/>
                        </svg>
                      </div>
                      <h3 class="empty-headline">Hiện chưa có hồ sơ nào trong hàng đợi</h3>
                      <p class="empty-subtext">
                        Khi sinh viên nộp hồ sơ hoặc đăng ký nhận giấy tờ qua Cổng Smart Campus, danh sách cần thẩm định sẽ tự động xuất hiện tại đây theo thời gian thực.
                      </p>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>


        <!-- ================= CHẾ ĐỘ 2: THỐNG KÊ & SLA ĐƠN VỊ (THEO THEME INDEX.VUE) ================= -->
        <div v-else-if="activeTab === 'sla'" class="tab-view">
          <!-- 3 Thẻ chỉ số SLA (Hiện để 0 vì chưa có dữ liệu) -->
          <div class="sla-metrics-grid">
            <div class="sla-box">
              <div class="sla-header">
                <span class="sla-label">Thời gian xử lý trung bình (SLA)</span>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2">
                  <circle cx="12" cy="12" r="10"/>
                  <polyline points="12 6 12 12 16 14"/>
                </svg>
              </div>
              <div class="sla-value-wrap">
                <span class="sla-big-num">0</span>
                <span class="sla-unit">giờ / hồ sơ</span>
              </div>
              <div class="sla-note text-muted">Chưa phát sinh dữ liệu thời gian giải quyết</div>
            </div>

            <div class="sla-box">
              <div class="sla-header">
                <span class="sla-label">Tỷ lệ hoàn thành đúng hạn SLA</span>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2">
                  <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/>
                  <polyline points="17 6 23 6 23 12"/>
                </svg>
              </div>
              <div class="sla-value-wrap">
                <span class="sla-big-num">0%</span>
              </div>
              <div class="sla-note text-muted">Tổng số hồ sơ trễ hạn: 0</div>
            </div>

            <div class="sla-box">
              <div class="sla-header">
                <span class="sla-label">Tổng lượt giải quyết thành công</span>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2">
                  <circle cx="12" cy="12" r="10"/>
                  <path d="M8 12l2.5 2.5L16 9"/>
                </svg>
              </div>
              <div class="sla-value-wrap">
                <span class="sla-big-num">0</span>
                <span class="sla-unit">/ 0 hồ sơ</span>
              </div>
              <div class="sla-note text-muted">Tỷ lệ phê duyệt: 0%</div>
            </div>
          </div>

          <!-- Khung biểu đồ số lượng hồ sơ (Trạng thái chưa có dữ liệu) -->
          <div class="chart-container-card">
            <div class="chart-head">
              <div>
                <h3 class="chart-title">Số lượng Hồ sơ Xử lý theo Chuỗi Thời gian</h3>
                <p class="chart-subtitle">Theo dõi lưu lượng tiếp nhận và giải quyết hồ sơ sinh viên</p>
              </div>

              <div class="timeframe-buttons">
                <button 
                  type="button" 
                  class="btn-tf" 
                  :class="{ active: timeFrame === 'day' }"
                  @click="timeFrame = 'day'"
                >
                  Theo Ngày
                </button>
                <button 
                  type="button" 
                  class="btn-tf" 
                  :class="{ active: timeFrame === 'week' }"
                  @click="timeFrame = 'week'"
                >
                  Theo Tuần
                </button>
                <button 
                  type="button" 
                  class="btn-tf" 
                  :class="{ active: timeFrame === 'month' }"
                  @click="timeFrame = 'month'"
                >
                  Theo Tháng
                </button>
              </div>
            </div>

            <!-- Thân biểu đồ để trống vạch 0 sạch sẽ -->
            <div class="chart-body-empty">
              <div class="empty-chart-track">
                <div v-for="day in daysList" :key="day" class="empty-bar-col">
                  <div class="bar-zero-line"></div>
                  <span class="bar-label">{{ day }}</span>
                </div>
              </div>
              <div class="chart-empty-message">
                Chưa có lưu lượng hồ sơ nào được ghi nhận trong chu kỳ này
              </div>
            </div>

            <div class="chart-foot">
              <div class="legend-wrap">
                <span class="legend-indicator dot-black"></span>
                <span class="legend-name">Đã phê duyệt thành công</span>
                <span class="legend-indicator dot-gray"></span>
                <span class="legend-name">Tổng hồ sơ nộp</span>
              </div>
              <div class="summary-total">Tổng tuần: <strong>0 hồ sơ</strong></div>
            </div>
          </div>
        </div>

      </div>
    </main>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const { $keycloak } = useNuxtApp()

const user = ref({ name: '...' })
const applications = ref([])
const activeTab = ref('queue')

// Gọi API lấy toàn bộ đơn từ (Dành cho Admin/Cán bộ)
const fetchAllApplications = async () => {
  if (!$keycloak.authenticated) return
  try {
    // Gọi bảng app.ho_so qua APISIX PostgREST kèm thông tin sinh viên và loại hồ sơ
    const data = await $fetch('http://localhost:9080/api/postgrest/ho_so?select=id,ma_hs,ma_sv,ma_loai,ngay_nop,trang_thai,ly_do,sinh_vien(ho_ten,ma_sv,lop),loai_ho_so(ten_loai)', {
      headers: { Authorization: `Bearer ${$keycloak.token}` }
    })
    
    applications.value = data.map(item => {
      let statusCode = 'pending'
      let statusLabel = 'Chờ duyệt'
      if (item.trang_thai === 'Đã duyệt') {
        statusCode = 'completed'
        statusLabel = 'Đã ký số'
      } else if (item.trang_thai === 'Từ chối') {
        statusCode = 'rejected'
        statusLabel = 'Từ chối'
      } else if (item.trang_thai === 'Đang duyệt') {
        statusCode = 'processing'
        statusLabel = 'Đang duyệt'
      }

      return {
        id: String(item.id),
        code: item.ma_hs || `REQ-${item.id}`,
        studentName: item.sinh_vien?.ho_ten || item.ma_sv,
        mssv: item.sinh_vien?.ma_sv || item.ma_sv,
        docTitle: item.loai_ho_so?.ten_loai || item.ma_loai,
        submittedAt: new Date(item.ngay_nop).toLocaleDateString('vi-VN'),
        status: statusLabel,
        statusCode: statusCode,
        domain: 'Hành chính số',
        docTag: item.loai_ho_so?.ten_loai || 'Dịch vụ đơn từ'
      }
    })
  } catch (error) {
    console.error('Lỗi Admin lấy dữ liệu:', error)
  }
}

onMounted(async () => {
  if ($keycloak.authenticated) {
    const roles = $keycloak.tokenParsed?.realm_access?.roles || []
    // Bảo vệ trang Admin: Nếu không phải cán bộ/trưởng khoa thì đuổi về
    if (!roles.includes('teacher') && !roles.includes('dean')) {
      navigateTo('/user/homepageuser')
      return
    }

    const sub = $keycloak.tokenParsed?.sub
    // Lấy tên thật từ database
    try {
      const profileData = await $fetch(`http://localhost:9080/api/postgrest/can_bo?keycloak_sub=eq.${sub}`, {
        headers: { Authorization: `Bearer ${$keycloak.token}` }
      })
      if (profileData?.[0]?.ho_ten) {
        user.value = { name: profileData[0].ho_ten }
      } else {
        user.value = { name: $keycloak.tokenParsed?.name || $keycloak.tokenParsed?.preferred_username || 'Cán bộ' }
      }
    } catch {
      user.value = { name: $keycloak.tokenParsed?.name || $keycloak.tokenParsed?.preferred_username || 'Cán bộ' }
    }

    await fetchAllApplications()
  } else {
    navigateTo('/')
  }
})

// Các hàm UI khác giữ nguyên
const logout = () => $keycloak.logout({ redirectUri: window.location.origin })
const searchQuery = ref('')
const filterDomain = ref('all')
const filterDocType = ref('all')
const filterStatus = ref('all')
const pendingCount = computed(() => applications.value.filter(a => a.status === 'Chờ duyệt' || a.status === 'Đang duyệt').length)
const approvedCount = computed(() => applications.value.filter(a => a.status === 'Đã ký số').length)
const needMoreCount = computed(() => 0)
const rejectedCount = computed(() => applications.value.filter(a => a.status === 'Từ chối').length)
const filteredApplications = computed(() => {
  return applications.value.filter(item => {
    if (searchQuery.value && !item.code.toLowerCase().includes(searchQuery.value.toLowerCase()) && !item.studentName.toLowerCase().includes(searchQuery.value.toLowerCase())) return false
    if (filterDomain.value !== 'all' && item.domain !== filterDomain.value) return false
    if (filterDocType.value !== 'all' && item.docTitle !== filterDocType.value) return false
    if (filterStatus.value !== 'all' && item.status !== filterStatus.value) return false
    return true
  })
})
const timeFrame = ref('day')
const daysList = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');
.admin-wrapper { min-height: 100vh; background-color: #ffffff; color: #0f172a; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; padding-bottom: 80px; }
.navbar { width: 100%; padding: 20px 0; border-bottom: 1px solid #e2e8f0; background-color: #ffffff; position: sticky; top: 0; z-index: 30; }
.nav-container { max-width: 1240px; margin: 0 auto; padding: 0 32px; display: flex; align-items: center; justify-content: space-between; gap: 20px; }
.nav-brand { display: flex; align-items: center; gap: 10px; }
.logo { font-size: 1.25rem; font-weight: 500; color: #000000; text-decoration: none; letter-spacing: -0.02em; }
.logo-bold { font-weight: 800; }
.brand-badge { font-size: 0.75rem; font-weight: 700; background-color: #f1f5f9; color: #0f172a; padding: 2px 8px; border-radius: 4px; text-transform: uppercase; }
.officer-info { display: flex; align-items: center; gap: 8px; font-size: 0.9rem; color: #64748b; text-decoration: none; cursor: pointer; transition: opacity 0.15s ease; }
.officer-info:hover { opacity: 0.8; }
.officer-name { font-weight: 600; color: #000000; }
.status-dot-separator { color: #cbd5e1; }
.signature-tag { display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem; font-weight: 500; color: #059669; background-color: #ecfdf5; padding: 3px 10px; border-radius: 20px; border: 1px solid #a7f3d0; }
.green-dot { width: 6px; height: 6px; background-color: #10b981; border-radius: 50%; display: inline-block; }
.nav-actions { display: flex; align-items: center; gap: 12px; }
.tab-control { display: flex; align-items: center; background-color: #f1f5f9; padding: 4px; border-radius: 8px; gap: 4px; }
.tab-item { display: flex; align-items: center; gap: 8px; padding: 7px 14px; border-radius: 6px; border: none; background: transparent; color: #64748b; font-size: 0.88rem; font-weight: 600; font-family: inherit; cursor: pointer; transition: all 0.15s ease; }
.tab-item:hover { color: #000000; }
.tab-item.active { background-color: #000000; color: #ffffff; }
.badge-count { font-size: 0.72rem; font-weight: 700; background-color: #e2e8f0; color: #0f172a; padding: 1px 6px; border-radius: 10px; }
.tab-item.active .badge-count { background-color: #334155; color: #ffffff; }
.btn-logout { background-color: #ffffff; border: 1.5px solid #e2e8f0; color: #475569; padding: 8px 10px; border-radius: 6px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.15s ease; }
.btn-logout:hover { border-color: #000000; color: #000000; }
.page-title-section { padding: 36px 0 24px; }
.main-container { max-width: 1240px; margin: 0 auto; padding: 0 32px; }
.page-main-heading { font-size: 2.2rem; font-weight: 800; letter-spacing: -0.035em; color: #000000; line-height: 1.2; }
.page-sub-heading { font-size: 1rem; color: #64748b; margin-top: 6px; }
.stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
.stat-box { background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px 24px; transition: border-color 0.15s ease; }
.stat-box:hover { border-color: #cbd5e1; }
.stat-title { font-size: 0.88rem; color: #64748b; font-weight: 500; margin-bottom: 10px; }
.stat-number { font-size: 2.2rem; font-weight: 800; line-height: 1; color: #000000; }
.text-emerald { color: #059669; }
.text-amber { color: #d97706; }
.text-rose { color: #e11d48; }
.filter-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
.search-box { flex: 1; min-width: 280px; position: relative; display: flex; align-items: center; }
.search-icon { position: absolute; left: 14px; color: #94a3b8; display: flex; }
.search-input { width: 100%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 6px; padding: 10px 14px 10px 38px; font-size: 0.92rem; color: #0f172a; outline: none; font-family: inherit; transition: border-color 0.15s ease; }
.search-input:focus { border-color: #000000; }
.filter-dropdown { display: flex; align-items: center; gap: 8px; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 6px; padding: 4px 12px; }
.dropdown-label { font-size: 0.86rem; color: #64748b; }
.dropdown-select { border: none; background: transparent; color: #0f172a; font-size: 0.9rem; font-weight: 500; font-family: inherit; outline: none; cursor: pointer; padding: 6px 0; }
.table-card { background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; }
.data-table { width: 100%; border-collapse: collapse; text-align: left; }
.data-table thead th { padding: 16px 20px; font-size: 0.78rem; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.04em; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; }
.data-table tbody td { padding: 18px 20px; border-bottom: 1px solid #f1f5f9; font-size: 0.92rem; }
.code-col { font-weight: 700; color: #000000; }
.student-name { font-weight: 600; color: #000000; }
.student-meta { font-size: 0.8rem; color: #64748b; }
.doc-name { font-weight: 500; color: #0f172a; }
.doc-badge { display: inline-block; font-size: 0.72rem; font-weight: 600; background-color: #f1f5f9; color: #475569; padding: 2px 8px; border-radius: 4px; margin-top: 4px; }
.time-col { color: #64748b; font-size: 0.88rem; }
.text-right { text-align: right; }
.btn-black-sm { background-color: #000000; color: #ffffff; padding: 7px 14px; border-radius: 6px; font-size: 0.86rem; font-weight: 600; border: none; cursor: pointer; }
.empty-cell { text-align: center; padding: 70px 24px !important; }
.empty-wrapper { max-width: 480px; margin: 0 auto; display: flex; flex-direction: column; align-items: center; }
.empty-icon-circle { width: 56px; height: 56px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-bottom: 18px; }
.empty-headline { font-size: 1.15rem; font-weight: 700; color: #000000; margin-bottom: 8px; }
.empty-subtext { font-size: 0.92rem; color: #64748b; line-height: 1.6; }
.sla-metrics-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px; }
.sla-box { background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; }
.sla-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.sla-label { font-size: 0.9rem; font-weight: 600; color: #64748b; }
.sla-value-wrap { display: flex; align-items: baseline; gap: 8px; margin-bottom: 8px; }
.sla-big-num { font-size: 2.4rem; font-weight: 800; color: #000000; line-height: 1; }
.sla-unit { font-size: 0.92rem; color: #64748b; }
.sla-note { font-size: 0.86rem; }
.text-muted { color: #94a3b8; }
.chart-container-card { background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 28px; }
.chart-head { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 30px; }
.chart-title { font-size: 1.15rem; font-weight: 700; color: #000000; }
.chart-subtitle { font-size: 0.88rem; color: #64748b; margin-top: 4px; }
.timeframe-buttons { display: flex; background-color: #f1f5f9; padding: 3px; border-radius: 6px; }
.btn-tf { background: transparent; border: none; padding: 6px 14px; border-radius: 4px; font-size: 0.84rem; font-weight: 600; font-family: inherit; color: #64748b; cursor: pointer; }
.btn-tf.active { background-color: #000000; color: #ffffff; }
.chart-body-empty { padding: 50px 0; border-bottom: 1px solid #e2e8f0; margin-bottom: 20px; text-align: center; }
.empty-chart-track { display: flex; justify-content: space-around; align-items: flex-end; height: 120px; padding: 0 40px; margin-bottom: 24px; }
.empty-bar-col { display: flex; flex-direction: column; align-items: center; gap: 10px; }
.bar-zero-line { width: 36px; height: 3px; background-color: #e2e8f0; border-radius: 2px; }
.bar-label { font-size: 0.82rem; font-weight: 600; color: #94a3b8; }
.chart-empty-message { font-size: 0.92rem; color: #94a3b8; }
.chart-foot { display: flex; align-items: center; justify-content: space-between; }
.legend-wrap { display: flex; align-items: center; gap: 16px; }
.legend-indicator { width: 12px; height: 12px; border-radius: 2px; display: inline-block; }
.dot-black { background-color: #000000; }
.dot-gray { background-color: #e2e8f0; }
.legend-name { font-size: 0.86rem; color: #64748b; margin-left: 6px; }
.summary-total { font-size: 0.88rem; color: #64748b; }
.summary-total strong { color: #000000; }
@media (max-width: 992px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } .sla-metrics-grid { grid-template-columns: 1fr; } }
@media (max-width: 680px) { .nav-container { flex-direction: column; align-items: flex-start; } .officer-info { flex-wrap: wrap; } .filter-bar { flex-direction: column; align-items: stretch; } .stats-grid { grid-template-columns: 1fr; } }
</style>
