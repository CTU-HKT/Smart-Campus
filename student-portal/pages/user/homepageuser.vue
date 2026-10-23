<!--
  SPDX-License-Identifier: MIT
  Copyright (c) 2026 CTU-HKT. All rights reserved.
-->
<template>
  <div class="dashboard-layout">
    <!-- ================= SIDEBAR ================= -->
    <aside class="sidebar">
      <!-- 1. Góc trên cùng bên trái: Logo SmartCampus theo phong cách index.vue -->
      <div class="sidebar-header">
        <NuxtLink to="/" class="logo">
          <span class="logo-bold">Smart</span><span>Campus</span>
        </NuxtLink>
        <span class="portal-tag">Student</span>
      </div>

      <!-- 2. Menu Điều hướng Sidebar -->
      <nav class="sidebar-nav">
        <!-- Mục Home -->
        <button 
          type="button"
          class="nav-item" 
          :class="{ active: currentTab === 'home' }"
          @click="currentTab = 'home'"
        >
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
            <polyline points="9 22 9 12 15 12 15 22"/>
          </svg>
          <span class="nav-label">Home</span>
        </button>

        <!-- Mục Hồ sơ (Giữ theo yêu cầu) -->
        <button 
          type="button"
          class="nav-item" 
          :class="{ active: currentTab === 'records' }"
          @click="currentTab = 'records'"
        >
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
            <polyline points="10 9 9 9 8 9"/>
          </svg>
          <span class="nav-label">Hồ sơ</span>
          <span class="nav-badge"></span>
        </button>

        <!-- Mục Inbox đổi thành Notifications -->
        <button 
          type="button"
          class="nav-item" 
          :class="{ active: currentTab === 'notifications' }"
          @click="currentTab = 'notifications'"
        >
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
            <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
          </svg>
          <span class="nav-label">Notifications</span>
          <span class="nav-badge badge-unread"></span>
        </button>

        <!-- Mục Settings -->
        <button 
          type="button"
          class="nav-item" 
          :class="{ active: currentTab === 'settings' }"
          @click="currentTab = 'settings'"
        >
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="3"/>
            <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/>
          </svg>
          <span class="nav-label">Settings</span>
        </button>
      </nav>

      <!-- 3. Khu vực tài khoản Sinh viên ở đáy Sidebar -->
      <div class="sidebar-user">
        <NuxtLink to="/info" class="user-profile-click" title="Xem thông tin tài khoản">
          <div class="user-avatar">
            {{ userInitial }}
          </div>
          <div class="user-info">
            <div class="user-name">{{ user?.name || '...' }}</div>
            <div class="user-role">Sinh viên · Xem hồ sơ</div>
          </div>
        </NuxtLink>
        <button @click="logout" class="btn-logout" title="Đăng xuất">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
            <polyline points="16 17 21 12 16 7"/>
            <line x1="21" y1="12" x2="9" y2="12"/>
          </svg>
        </button>
      </div>
    </aside>

    <!-- ================= MAIN CONTENT ================= -->
    <main class="main-content">
      <!-- Header thanh điều hướng trên cùng -->
      <header class="content-header">
        <div class="breadcrumb">
          <span class="breadcrumb-root">Portal</span>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">{{ currentTabTitle }}</span>
        </div>

        <div class="header-right">
          <span class="current-date">{{ currentDateString }}</span>
          <div class="status-indicator">
            <span class="status-dot"></span>
            <span>Hệ thống trực tuyến</span>
          </div>
        </div>
      </header>

      <!-- NỘI DUNG TAB HOME (Bỏ hết biểu đồ, thay bằng 2 Box dịch vụ) -->
      <div v-if="currentTab === 'home'" class="tab-home">
        <!-- Tiêu đề chào mừng -->
        <div class="welcome-banner">
          <h1 class="welcome-title">Xin chào, {{ user?.name || 'Sinh viên' }} 👋</h1>
          <p class="welcome-subtitle">
            Chào mừng bạn đến với Cổng dịch vụ trực tuyến Smart Campus. Vui lòng chọn một trong các dịch vụ dưới đây để bắt đầu.
          </p>
        </div>

        <!-- 2 BOX NỘP HỒ SƠ VÀ ĐĂNG KÍ HỒ SƠ (Chuẩn nội dung hình 2, phong cách hình 1) -->
        <div class="service-boxes-grid">
          <!-- Box 1: Nộp Đơn Trực Tuyến -->
          <div class="service-box" @click="handleSelectService('nop-don')">
            <div class="service-header">
              <div class="service-icon-wrapper">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                  <polyline points="14 2 14 8 20 8"/>
                  <line x1="12" y1="18" x2="12" y2="12"/>
                  <line x1="9" y1="15" x2="15" y2="15"/>
                </svg>
              </div>
              <span class="badge-tag">Dịch vụ đơn từ</span>
            </div>

            <div class="service-body">
              <h2 class="service-title">
                <span>1. Nộp Đơn Trực Tuyến</span>
                <span class="arrow-chevron">›</span>
              </h2>
              <p class="service-description">
                Dành cho sinh viên gửi các loại đơn từ, đề xuất, xin phép hoặc khiếu nại tới Ban Giám hiệu, Phòng Đào tạo và Cố vấn học tập.
              </p>
            </div>

            <div class="service-footer">
              <span class="footer-action">Bắt đầu nộp đơn &rarr;</span>
            </div>
          </div>

          <!-- Box 2: Đăng Ký (Nhận giấy của trường) -->
          <div class="service-box" @click="handleSelectService('dang-ky-giay')">
            <div class="service-header">
              <div class="service-icon-wrapper">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="3" y="4" width="18" height="16" rx="2"/>
                  <line x1="7" y1="8" x2="17" y2="8"/>
                  <line x1="7" y1="12" x2="17" y2="12"/>
                  <line x1="7" y1="16" x2="13" y2="16"/>
                </svg>
              </div>
              <span class="badge-tag">Hành chính số</span>
            </div>

            <div class="service-body">
              <h2 class="service-title">
                <span>2. Đăng Ký (Nhận giấy của trường)</span>
                <span class="arrow-chevron">›</span>
              </h2>
              <p class="service-description">
                Dành cho sinh viên đăng ký nhận các loại giấy xác nhận, chứng nhận, bảng điểm do Nhà trường phát hành có giá trị pháp lý toàn quốc.
              </p>
            </div>

            <div class="service-footer">
              <span class="footer-action">Đăng ký giấy tờ &rarr;</span>
            </div>
          </div>
        </div>

        <!-- Danh sách hồ sơ gần đây của Sinh viên (Phục vụ tiêu chí kiểm thử OLP: User A thấy hồ sơ của mình) -->
        <section class="recent-records-section">
          <div class="section-header">
            <h3 class="section-title">Hồ sơ gần đây của bạn</h3>
            <button @click="currentTab = 'records'" class="btn-link">Xem tất cả hồ sơ</button>
          </div>

          <div class="records-table-container">
            <table class="records-table">
              <thead>
                <tr>
                  <th>Mã hồ sơ</th>
                  <th>Loại dịch vụ</th>
                  <th>Ngày gửi</th>
                  <th>Trạng thái</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="rec in userRecords" :key="rec.id">
                  <td class="font-mono">{{ rec.id }}</td>
                  <td><strong>{{ rec.title }}</strong></td>
                  <td>{{ rec.date }}</td>
                  <td>
                    <span class="status-badge" :class="rec.statusClass">
                      {{ rec.status }}
                    </span>
                  </td>
                  <td>
                    <button class="btn-table-action" @click="viewDetail(rec)">Chi tiết</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>

      <!-- NỘI DUNG TAB HỒ SƠ -->
      <div v-else-if="currentTab === 'records'" class="tab-content">
        <div class="tab-header">
          <h2>Danh sách tất cả hồ sơ của bạn</h2>
          <button @click="currentTab = 'home'" class="btn btn-black">+ Tạo hồ sơ mới</button>
        </div>
        <div class="records-table-container">
          <table class="records-table">
            <thead>
              <tr>
                <th>Mã hồ sơ</th>
                <th>Tên hồ sơ</th>
                <th>Phòng ban xử lý</th>
                <th>Ngày tạo</th>
                <th>Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="rec in userRecords" :key="rec.id">
                <td class="font-mono">{{ rec.id }}</td>
                <td>{{ rec.title }}</td>
                <td>{{ rec.department }}</td>
                <td>{{ rec.date }}</td>
                <td>
                  <span class="status-badge" :class="rec.statusClass">
                    {{ rec.status }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- NỘI DUNG TAB NOTIFICATIONS -->
      <div v-else-if="currentTab === 'notifications'" class="tab-content">
        <div class="tab-header">
          <h2>Thông báo hệ thống (Notifications)</h2>
          <span class="notifications-count">4 thông báo mới</span>
        </div>
        <div class="notifications-list">
          <div v-for="notif in notifications" :key="notif.id" class="notification-card">
            <div class="notif-dot"></div>
            <div class="notif-body">
              <div class="notif-title">{{ notif.title }}</div>
              <div class="notif-desc">{{ notif.desc }}</div>
              <div class="notif-time">{{ notif.time }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- NỘI DUNG TAB SETTINGS -->
      <div v-else-if="currentTab === 'settings'" class="tab-content">
        <div class="tab-header">
          <h2>Cài đặt ứng dụng (Settings)</h2>
        </div>
        <div class="settings-card">
          <div class="setting-item">
            <div>
              <strong>Thông báo xử lý đơn từ:</strong>
              <p>Nhận thông báo khi cán bộ thẩm định ký số hoặc phê duyệt đơn</p>
            </div>
            <span class="status-badge status-completed">Đang bật</span>
          </div>
          <div class="setting-item">
            <div>
              <strong>Ngôn ngữ hệ thống:</strong>
              <p>Tiếng Việt (Mặc định)</p>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal thông báo khi click vào box dịch vụ -->
    <div v-if="activeModal" class="modal-overlay" @click.self="activeModal = null">
      <div class="modal-box">
        <h3>{{ activeModal.title }}</h3>
        <p>{{ activeModal.desc }}</p>
        <div class="modal-actions">
          <button @click="activeModal = null" class="btn btn-outline">Đóng</button>
          <button @click="confirmCreateRecord" class="btn btn-black">Tiếp tục điền form</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const { $keycloak } = useNuxtApp()

// State
const user = ref({ name: '...' })
const userRecords = ref([])
const currentTab = ref('home')
const activeModal = ref(null)

// Gọi API lấy đơn từ (RLS bên DB sẽ tự lọc chỉ trả về đơn của user này)
const fetchMyRecords = async () => {
  if (!$keycloak.authenticated) return
  try {
    // Gọi qua APISIX cổng 9080
    const data = await $fetch('http://localhost:9080/api/postgrest/applications', {
      headers: { Authorization: `Bearer ${$keycloak.token}` }
    })
    
    // Chuyển đổi dữ liệu từ DB sang giao diện
    userRecords.value = data.map(item => ({
      id: item.id.substring(0, 8),
      title: item.application_type,
      date: new Date(item.created_at).toLocaleDateString('vi-VN'),
      status: item.status === 'pending' ? 'Đang xử lý' : 'Đã duyệt',
      statusClass: item.status === 'pending' ? 'status-pending' : 'status-completed',
      department: 'Phòng Đào tạo'
    }))
  } catch (error) {
    console.error('Lỗi lấy đơn từ:', error)
  }
}

onMounted(async () => {
  if ($keycloak.authenticated) {
    const parsed = $keycloak.tokenParsed || {}
    const sub = parsed.sub
    // Ưu tiên lấy tên đầy đủ từ database
    try {
      const profileData = await $fetch(`http://localhost:9080/api/postgrest/profiles?user_id=eq.${sub}`, {
        headers: { Authorization: `Bearer ${$keycloak.token}` }
      })
      if (profileData?.[0]?.full_name) {
        user.value = { name: profileData[0].full_name }
      } else {
        user.value = { name: parsed.name || parsed.preferred_username || 'Sinh viên' }
      }
    } catch {
      user.value = { name: parsed.name || parsed.preferred_username || 'Sinh viên' }
    }
    await fetchMyRecords()
  } else {
    navigateTo('/')
  }
})

// Các hàm UI giữ nguyên
const logout = () => $keycloak.logout({ redirectUri: window.location.origin })
const userInitial = computed(() => (user.value?.name || 'A').charAt(0).toUpperCase())
const currentDateString = computed(() => new Date().toLocaleDateString('vi-VN', { weekday: 'long', year: 'numeric', month: 'numeric', day: 'numeric' }))
const currentTabTitle = computed(() => {
  const titles = { home: 'Home / Dịch vụ sinh viên', records: 'Hồ sơ đã nộp', notifications: 'Thông báo', settings: 'Cài đặt' }
  return titles[currentTab.value] || 'Home'
})

const handleSelectService = (serviceType) => {
  activeModal.value = {
    title: serviceType === 'nop-don' ? '1. Nộp Đơn Trực Tuyến' : '2. Đăng Ký (Nhận giấy)',
    desc: 'Hệ thống sẽ chuyển bạn sang mẫu đơn điện tử.'
  }
}
const confirmCreateRecord = () => { activeModal.value = null; alert('Đang phát triển...') }
const viewDetail = (record) => alert(`Chi tiết: ${record.title} (${record.id}) - ${record.status}`)
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

.dashboard-layout {
  display: flex;
  min-height: 100vh;
  background-color: #f8fafc;
  color: #0f172a;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

/* ================= 1. SIDEBAR ================= */
.sidebar {
  width: 260px;
  background-color: #ffffff;
  border-right: 1px solid #e2e8f0;
  display: flex;
  flex-direction: column;
  position: sticky;
  top: 0;
  height: 100vh;
}

.sidebar-header {
  padding: 24px 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid #f1f5f9;
}

.logo {
  font-size: 1.25rem;
  font-weight: 500;
  color: #000000;
  text-decoration: none;
  letter-spacing: -0.02em;
}

.logo-bold {
  font-weight: 800;
}

.portal-tag {
  font-size: 0.75rem;
  font-weight: 700;
  background-color: #f1f5f9;
  color: #475569;
  padding: 2px 8px;
  border-radius: 4px;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

/* Menu Navigation */
.sidebar-nav {
  flex: 1;
  padding: 16px 12px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 11px 14px;
  border-radius: 8px;
  background: transparent;
  border: none;
  color: #475569;
  font-size: 0.95rem;
  font-weight: 500;
  font-family: inherit;
  cursor: pointer;
  width: 100%;
  text-align: left;
  transition: all 0.15s ease;
}

.nav-item:hover {
  background-color: #f1f5f9;
  color: #000000;
}

.nav-item.active {
  background-color: #000000;
  color: #ffffff;
}

.nav-icon {
  flex-shrink: 0;
}

.nav-label {
  flex: 1;
}

.nav-badge {
  font-size: 0.75rem;
  font-weight: 700;
  background-color: #f1f5f9;
  color: #334155;
  padding: 2px 7px;
  border-radius: 10px;
}

.nav-item.active .nav-badge {
  background-color: #334155;
  color: #ffffff;
}

.badge-unread {
  background-color: #ef4444;
  color: #ffffff;
}

/* User Profile ở đáy Sidebar */
.sidebar-user {
  padding: 16px;
  border-top: 1px solid #f1f5f9;
  display: flex;
  align-items: center;
  gap: 12px;
  background-color: #ffffff;
}

.user-profile-click {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  min-width: 0;
  text-decoration: none;
  cursor: pointer;
  transition: opacity 0.15s ease;
}

.user-profile-click:hover {
  opacity: 0.8;
}

.user-avatar {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  background-color: #000000;
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 0.95rem;
}

.user-info {
  flex: 1;
  min-width: 0;
}

.user-name {
  font-size: 0.9rem;
  font-weight: 600;
  color: #0f172a;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-role {
  font-size: 0.75rem;
  color: #64748b;
}

.btn-logout {
  background: transparent;
  border: none;
  color: #94a3b8;
  cursor: pointer;
  padding: 6px;
  border-radius: 6px;
  transition: color 0.15s, background-color 0.15s;
}

.btn-logout:hover {
  background-color: #fef2f2;
  color: #ef4444;
}

/* ================= 2. MAIN CONTENT ================= */
.main-content {
  flex: 1;
  padding: 32px 40px;
  max-width: 1280px;
}

.content-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 32px;
  padding-bottom: 16px;
  border-bottom: 1px solid #e2e8f0;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
}

.breadcrumb-root {
  color: #64748b;
}

.breadcrumb-separator {
  color: #cbd5e1;
}

.breadcrumb-current {
  color: #0f172a;
  font-weight: 600;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
  font-size: 0.85rem;
  color: #64748b;
}

.status-indicator {
  display: flex;
  align-items: center;
  gap: 6px;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #22c55e;
}

/* ================= 3. BANNER CHÀO MỪNG ================= */
.welcome-banner {
  margin-bottom: 32px;
}

.welcome-title {
  font-size: 2rem;
  font-weight: 800;
  letter-spacing: -0.03em;
  color: #000000;
  margin-bottom: 8px;
}

.welcome-subtitle {
  font-size: 1rem;
  color: #64748b;
  max-width: 700px;
  line-height: 1.5;
}

/* ================= 4. 2 BOX NỘP HỒ SƠ & ĐĂNG KÍ (CHÍNH) ================= */
.service-boxes-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  margin-bottom: 40px;
}

.service-box {
  background-color: #ffffff;
  border: 1.5px solid #e2e8f0;
  border-radius: 12px;
  padding: 32px 28px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
}

.service-box:hover {
  border-color: #000000;
  transform: translateY(-3px);
  box-shadow: 0 16px 28px -10px rgba(0, 0, 0, 0.08);
}

.service-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.service-icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  background-color: #f1f5f9;
  color: #000000;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.service-box:hover .service-icon-wrapper {
  background-color: #000000;
  color: #ffffff;
}

.badge-tag {
  font-size: 0.75rem;
  font-weight: 600;
  background-color: #f8fafc;
  border: 1px solid #e2e8f0;
  color: #475569;
  padding: 4px 10px;
  border-radius: 20px;
}

.service-title {
  font-size: 1.35rem;
  font-weight: 700;
  color: #000000;
  letter-spacing: -0.02em;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.arrow-chevron {
  font-size: 1.6rem;
  color: #94a3b8;
  transition: transform 0.2s ease, color 0.2s ease;
}

.service-box:hover .arrow-chevron {
  transform: translateX(4px);
  color: #000000;
}

.service-description {
  font-size: 0.92rem;
  line-height: 1.6;
  color: #64748b;
  margin-bottom: 24px;
}

.service-footer {
  padding-top: 16px;
  border-top: 1px solid #f1f5f9;
}

.footer-action {
  font-size: 0.9rem;
  font-weight: 600;
  color: #000000;
  transition: color 0.15s ease;
}

/* ================= 5. BẢNG HỒ SƠ GẦN ĐÂY ================= */
.recent-records-section {
  background-color: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 24px 28px;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.section-title {
  font-size: 1.15rem;
  font-weight: 700;
  color: #0f172a;
}

.btn-link {
  background: none;
  border: none;
  color: #0f172a;
  font-weight: 600;
  font-size: 0.85rem;
  cursor: pointer;
  text-decoration: underline;
}

.records-table-container {
  overflow-x: auto;
}

.records-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
  font-size: 0.9rem;
}

.records-table th {
  padding: 12px 14px;
  background-color: #f8fafc;
  color: #64748b;
  font-weight: 600;
  border-bottom: 1px solid #e2e8f0;
}

.records-table td {
  padding: 14px;
  border-bottom: 1px solid #f1f5f9;
  color: #334155;
}

.font-mono {
  font-family: monospace;
  font-weight: 600;
  color: #000000;
}

.status-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 0.78rem;
  font-weight: 600;
}

.status-pending {
  background-color: #fef3c7;
  color: #92400e;
}

.status-completed {
  background-color: #dcfce7;
  color: #166534;
}

.btn-table-action {
  padding: 4px 12px;
  font-size: 0.8rem;
  border: 1px solid #cbd5e1;
  background-color: #ffffff;
  border-radius: 4px;
  cursor: pointer;
}

.btn-table-action:hover {
  background-color: #000000;
  color: #ffffff;
  border-color: #000000;
}

/* ================= TAB KHÁC & MODAL ================= */
.tab-content {
  background-color: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 28px;
}

.tab-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}

.btn-black {
  background-color: #000000;
  color: #ffffff;
  border: none;
  padding: 8px 18px;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
}

.notifications-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.notification-card {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  padding: 16px;
  border: 1px solid #f1f5f9;
  border-radius: 8px;
}

.notif-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: #ef4444;
  margin-top: 6px;
}

.notif-title {
  font-weight: 600;
  font-size: 0.95rem;
  margin-bottom: 4px;
}

.notif-desc {
  font-size: 0.85rem;
  color: #64748b;
  margin-bottom: 6px;
}

.notif-time {
  font-size: 0.75rem;
  color: #94a3b8;
}

.settings-card {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.setting-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 0;
  border-bottom: 1px solid #f1f5f9;
}

.badge-role {
  background-color: #e2e8f0;
  padding: 2px 8px;
  border-radius: 4px;
  font-family: monospace;
  font-size: 0.8rem;
}

.btn-outline-sm {
  border: 1px solid #cbd5e1;
  background: transparent;
  padding: 4px 12px;
  border-radius: 4px;
  cursor: pointer;
}

/* Modal Popup */
.modal-overlay {
  position: fixed;
  inset: 0;
  background-color: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 50;
}

.modal-box {
  background-color: #ffffff;
  padding: 32px;
  border-radius: 12px;
  max-width: 460px;
  width: 90%;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.modal-box h3 {
  font-size: 1.25rem;
  font-weight: 700;
  margin-bottom: 12px;
}

.modal-box p {
  color: #64748b;
  line-height: 1.5;
  margin-bottom: 24px;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.btn-outline {
  background: transparent;
  border: 1.5px solid #cbd5e1;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
}

/* ================= RESPONSIVE ================= */
@media (max-width: 992px) {
  .service-boxes-grid {
    grid-template-columns: 1fr;
  }

  .sidebar {
    width: 220px;
  }
}

@media (max-width: 768px) {
  .dashboard-layout {
    flex-direction: column;
  }

  .sidebar {
    width: 100%;
    height: auto;
    position: relative;
  }

  .main-content {
    padding: 20px;
  }
}
</style>
