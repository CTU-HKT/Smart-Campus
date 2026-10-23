<!--
  SPDX-License-Identifier: MIT
  Copyright (c) 2026 CTU-HKT. All rights reserved.
-->
<template>
  <div class="info-page-wrapper">
    <!-- ================= NAVBAR ================= -->
    <header class="navbar">
      <div class="nav-container">
        <!-- Logo -->
        <NuxtLink :to="dashboardRoute" class="logo">
          <span class="logo-bold">Smart</span><span>Campus</span>
        </NuxtLink>

        <!-- Right actions -->
        <div class="nav-actions">
          <NuxtLink :to="dashboardRoute" class="btn-dashboard">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M19 12H5M12 19l-7-7 7-7"/>
            </svg>
            <span>Về Bảng điều khiển</span>
          </NuxtLink>

          <button @click="logout" class="btn-logout" title="Đăng xuất">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
              <polyline points="16 17 21 12 16 7"/>
              <line x1="21" y1="12" x2="9" y2="12"/>
            </svg>
            <span>Đăng xuất</span>
          </button>
        </div>
      </div>
    </header>

    <!-- ================= MAIN CONTENT ================= -->
    <main class="info-container">
      <div v-if="isLoading" class="loading-box">
        <div class="spinner"></div>
        <p>Đang tải thông tin hồ sơ...</p>
      </div>

      <div v-else class="profile-card">
        <!-- Profile Banner & Header -->
        <div class="profile-header">
          <div class="avatar-wrapper">
            <div class="avatar-circle">
              {{ userInitial }}
            </div>
          </div>
          <div class="header-details">
            <div class="name-row">
              <h1 class="user-display-name">{{ profile.full_name || 'Chưa đặt tên' }}</h1>
              <span class="role-badge" :class="{ 'teacher-badge': isTeacher }">
                {{ isTeacher ? 'Giảng viên' : 'Sinh viên' }}
              </span>
            </div>
            <p class="user-subtext">
              <span>{{ isTeacher ? 'Mã cán bộ:' : 'MSSV:' }} <strong>{{ profile.student_code || '---' }}</strong></span>
              <span class="dot-sep">·</span>
              <span>{{ profile.faculty || 'Chưa cập nhật đơn vị' }}</span>
            </p>
          </div>

          <div class="header-action">
            <NuxtLink to="/complete-profile" class="btn-edit">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
              </svg>
              <span>Chỉnh sửa hồ sơ</span>
            </NuxtLink>
          </div>
        </div>

        <!-- Info Grid -->
        <div class="info-section">
          <h2 class="section-title">Thông tin chi tiết</h2>
          <div class="info-grid">
            <!-- Họ và tên (Lấy tên đã đặt) -->
            <div class="info-item">
              <div class="info-label">Họ và tên</div>
              <div class="info-value highlight">{{ profile.full_name || '---' }}</div>
            </div>

            <!-- Phân quyền -->
            <div class="info-item">
              <div class="info-label">Phân quyền hệ thống</div>
              <div class="info-value">
                <span class="pill-badge" :class="{ 'pill-teacher': isTeacher }">
                  {{ isTeacher ? 'Giảng viên' : 'Sinh viên' }}
                </span>
              </div>
            </div>

            <!-- Mã định danh (MSSV / MSCB) -->
            <div class="info-item">
              <div class="info-label">{{ isTeacher ? 'Mã số cán bộ' : 'Mã số sinh viên' }}</div>
              <div class="info-value font-mono">{{ profile.student_code || '---' }}</div>
            </div>

            <!-- Ngày sinh -->
            <div class="info-item">
              <div class="info-label">Ngày sinh</div>
              <div class="info-value">{{ formattedDateOfBirth }}</div>
            </div>

            <!-- Email -->
            <div class="info-item">
              <div class="info-label">Email tài khoản</div>
              <div class="info-value">{{ profile.email || '---' }}</div>
            </div>

            <!-- Số điện thoại -->
            <div class="info-item">
              <div class="info-label">Số điện thoại liên hệ</div>
              <div class="info-value">{{ profile.phone || 'Chưa cập nhật' }}</div>
            </div>

            <!-- Khoa -->
            <div class="info-item">
              <div class="info-label">{{ isTeacher ? 'Khoa / Đơn vị công tác' : 'Khoa quản lý' }}</div>
              <div class="info-value">{{ profile.faculty || 'Chưa cập nhật' }}</div>
            </div>

            <!-- Ngành / Chuyên môn -->
            <div class="info-item">
              <div class="info-label">{{ isTeacher ? 'Bộ môn / Chuyên môn' : 'Ngành học' }}</div>
              <div class="info-value">{{ profile.major || 'Chưa cập nhật' }}</div>
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

const isLoading = ref(true)
const isTeacher = ref(false)
const profile = ref({
  user_id: '',
  student_code: '',
  full_name: '',
  email: '',
  phone: '',
  date_of_birth: '',
  faculty: '',
  major: '',
  updated_at: ''
})

// Chữ cái đại diện Avatar (Lấy từ Họ và tên thật)
const userInitial = computed(() => {
  const name = profile.value.full_name?.trim() || ''
  if (!name) return 'U'
  const parts = name.split(' ')
  return parts[parts.length - 1].charAt(0).toUpperCase()
})

// Định dạng ngày sinh sang DD/MM/YYYY
const formattedDateOfBirth = computed(() => {
  if (!profile.value.date_of_birth) return 'Chưa cập nhật'
  const [year, month, day] = profile.value.date_of_birth.split('-')
  if (year && month && day) {
    return `${day}/${month}/${year}`
  }
  return profile.value.date_of_birth
})

// Đường dẫn quay lại Dashboard tương ứng
const dashboardRoute = computed(() => {
  return isTeacher.value ? '/admin/homepageadmin' : '/user/homepageuser'
})

// Đăng xuất
const logout = () => {
  $keycloak.logout({ redirectUri: window.location.origin })
}

onMounted(async () => {
  if (!$keycloak.authenticated) {
    return navigateTo('/')
  }

  const parsed = $keycloak.tokenParsed || {}
  const roles = parsed.realm_access?.roles || []
  isTeacher.value = roles.includes('teacher')
  const sub = parsed.sub
  const token = $keycloak.token

  try {
    // Lấy thông tin từ bảng public.profiles trong PostgreSQL
    const res = await $fetch(`http://localhost:9080/api/postgrest/profiles?user_id=eq.${sub}`, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })

    const data = res?.[0]
    if (data) {
      profile.value = data
    } else {
      // Nếu chưa có profile trong database, chuyển ngay sang hoàn thiện hồ sơ
      navigateTo('/complete-profile')
      return
    }
  } catch (error) {
    console.error('Lỗi khi tải thông tin hồ sơ:', error)
  } finally {
    isLoading.value = false
  }
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

.info-page-wrapper {
  min-height: 100vh;
  background-color: #f8fafc;
  color: #0f172a;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  padding-bottom: 60px;
}

/* ================= NAVBAR ================= */
.navbar {
  width: 100%;
  background-color: #ffffff;
  border-bottom: 1px solid #e2e8f0;
  padding: 18px 0;
  position: sticky;
  top: 0;
  z-index: 20;
}

.nav-container {
  max-width: 1080px;
  margin: 0 auto;
  padding: 0 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
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

.nav-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.btn-dashboard {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-radius: 6px;
  background-color: #ffffff;
  border: 1px solid #e2e8f0;
  color: #0f172a;
  font-size: 0.88rem;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.15s ease;
}

.btn-dashboard:hover {
  background-color: #f1f5f9;
  border-color: #cbd5e1;
}

.btn-logout {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 14px;
  border-radius: 6px;
  background-color: transparent;
  border: 1px solid transparent;
  color: #64748b;
  font-size: 0.88rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s ease;
}

.btn-logout:hover {
  background-color: #fee2e2;
  color: #dc2626;
}

/* ================= CONTAINER ================= */
.info-container {
  max-width: 1080px;
  margin: 40px auto 0;
  padding: 0 24px;
}

.loading-box {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 60px;
  text-align: center;
  color: #64748b;
}

.spinner {
  width: 36px;
  height: 36px;
  border: 3px solid #f1f5f9;
  border-top-color: #000000;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* ================= PROFILE CARD ================= */
.profile-card {
  background: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 14px;
  box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.04);
  overflow: hidden;
}

.profile-header {
  padding: 36px 36px 30px;
  border-bottom: 1px solid #f1f5f9;
  display: flex;
  align-items: center;
  gap: 24px;
  flex-wrap: wrap;
}

.avatar-circle {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background-color: #0f172a;
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  font-weight: 700;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.header-details {
  flex: 1;
  min-width: 260px;
}

.name-row {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  margin-bottom: 6px;
}

.user-display-name {
  font-size: 1.65rem;
  font-weight: 800;
  color: #000000;
  letter-spacing: -0.02em;
}

.role-badge {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 999px;
  background-color: #f1f5f9;
  color: #475569;
}

.role-badge.teacher-badge {
  background-color: #000000;
  color: #ffffff;
}

.user-subtext {
  font-size: 0.95rem;
  color: #64748b;
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.user-subtext strong {
  color: #0f172a;
}

.dot-sep {
  color: #cbd5e1;
}

.header-action {
  display: flex;
  align-items: center;
}

.btn-edit {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 18px;
  border-radius: 6px;
  background-color: #000000;
  color: #ffffff;
  font-size: 0.9rem;
  font-weight: 600;
  text-decoration: none;
  transition: opacity 0.15s ease;
}

.btn-edit:hover {
  opacity: 0.85;
}

/* ================= INFO GRID ================= */
.info-section {
  padding: 36px;
}

.section-title {
  font-size: 1.1rem;
  font-weight: 700;
  color: #0f172a;
  margin-bottom: 24px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px 32px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f8fafc;
}

.info-label {
  font-size: 0.82rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: #64748b;
}

.info-value {
  font-size: 1rem;
  font-weight: 500;
  color: #0f172a;
}

.info-value.highlight {
  font-weight: 700;
  color: #000000;
}

.font-mono {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  font-weight: 600;
  letter-spacing: 0.05em;
}

.pill-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 6px;
  background-color: #eff6ff;
  color: #1d4ed8;
  font-size: 0.85rem;
  font-weight: 600;
}

.pill-badge.pill-teacher {
  background-color: #f1f5f9;
  color: #0f172a;
}

/* ================= FOOTER ================= */
.info-footer {
  padding: 18px 36px;
  background-color: #fafbfd;
  border-top: 1px solid #f1f5f9;
  font-size: 0.82rem;
  color: #94a3b8;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
}

.info-footer code {
  background: #f1f5f9;
  padding: 2px 6px;
  border-radius: 4px;
  color: #475569;
}

@media (max-width: 768px) {
  .profile-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }
}
</style>
