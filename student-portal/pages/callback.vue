<!--
  SPDX-License-Identifier: MIT
  Copyright (c) 2026 CTU-HKT. All rights reserved.
-->
<template>
  <div class="callback-container">
    <div class="callback-card">
      <!-- Trạng thái 1: Đang xử lý đổi mã token -->
      <div v-if="loading" class="state-box">
        <div class="spinner"></div>
        <h2 class="title">Đang xác thực tài khoản</h2>
        <p class="subtitle">Đang trao đổi mã bảo mật và đồng bộ phiên đăng nhập từ Keycloak, vui lòng chờ trong giây lát...</p>
      </div>

      <!-- Trạng thái 2: Xảy ra lỗi -->
      <div v-else-if="errorMessage" class="state-box">
        <div class="error-icon">✕</div>
        <h2 class="title error-title">Xác thực không thành công</h2>
        <p class="subtitle">{{ errorMessage }}</p>
        <button @click="goHome" class="btn-home">Quay về trang chủ</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const route = useRoute()
const { user, token } = useAuth()

const loading = ref(true)
const errorMessage = ref('')

const goHome = () => {
  navigateTo('/')
}

onMounted(async () => {
  const code = route.query.code
  const error = route.query.error
  const errorDescription = route.query.error_description

  // 1. Kiểm tra nếu người dùng bấm hủy hoặc Keycloak trả về lỗi
  if (error) {
    loading.value = false
    errorMessage.value = (errorDescription || error).toString()
    return
  }

  // 2. Kiểm tra mã Authorization Code
  if (!code) {
    loading.value = false
    errorMessage.value = 'Không tìm thấy mã xác thực (code) trong đường dẫn trả về.'
    return
  }

  try {
    // Lấy redirect_uri hiện tại để khớp chính xác với uri gửi lúc đăng nhập
    const redirectUri = window.location.origin + '/callback'

    // 3. GỌI REST API KEYCLOAK ĐỂ ĐỔI CODE LẤY JWT ACCESS TOKEN
    const params = new URLSearchParams()
    params.append('grant_type', 'authorization_code')
    params.append('client_id', 'student-portal')
    params.append('code', code.toString())
    params.append('redirect_uri', redirectUri)

    const tokenRes = await $fetch('http://localhost:8080/realms/smartcampus/protocol/openid-connect/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: params.toString()
    })

    const accessToken = tokenRes.access_token
    token.value = accessToken

    // 4. GIẢI MÃ PAYLOAD JWT ĐỂ LẤY ROLE VÀ THÔNG TIN TÀI KHOẢN
    const base64Url = accessToken.split('.')[1]
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
    const payload = JSON.parse(decodeURIComponent(escape(atob(base64))))

    // Đọc vai trò (roles) trong token
    const realmRoles = payload.realm_access?.roles || []
    const clientRoles = payload.resource_access?.['student-portal']?.roles || []
    const allRoles = [...realmRoles, ...clientRoles]

    let assignedRole = 'student'
    if (allRoles.includes('admin')) {
      assignedRole = 'admin'
    } else if (allRoles.includes('teacher') || allRoles.includes('giaovien')) {
      assignedRole = 'teacher'
    }

    // 5. LƯU THÔNG TIN VÀO USECOOKIE THÔNG QUA USEAUTH
    user.value = {
      id: payload.sub,
      name: payload.name || payload.preferred_username || 'Người dùng',
      username: payload.preferred_username || payload.sub,
      email: payload.email || '',
      role: assignedRole
    }

    // 6. ĐIỀU HƯỚNG TRANG THEO VAI TRÒ
    if (assignedRole === 'admin' || assignedRole === 'teacher') {
      navigateTo('/admin/homepageadmin')
    } else {
      navigateTo('/user/homepageuser')
    }
  } catch (err) {
    loading.value = false
    const detail = err?.data?.error_description || err?.data?.error || err?.message
    errorMessage.value = `Lỗi trao đổi token: ${detail || 'Không thể kết nối đến Keycloak'}`
  }
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

.callback-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f8fafc;
  color: #0f172a;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  padding: 24px;
}

.callback-card {
  width: 100%;
  max-width: 460px;
  background-color: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 48px 36px;
  text-align: center;
  box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.06);
}

.spinner {
  width: 46px;
  height: 46px;
  border: 4px solid #f1f5f9;
  border-top: 4px solid #000000;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 24px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-icon {
  width: 52px;
  height: 52px;
  background-color: #fee2e2;
  color: #dc2626;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  font-weight: 700;
  margin: 0 auto 20px;
}

.title {
  font-size: 1.35rem;
  font-weight: 700;
  color: #000000;
  margin-bottom: 8px;
}

.error-title {
  color: #991b1b;
}

.subtitle {
  font-size: 0.95rem;
  color: #64748b;
  line-height: 1.5;
  margin-bottom: 28px;
  word-break: break-word;
}

.btn-home {
  display: inline-block;
  background-color: #000000;
  color: #ffffff;
  padding: 11px 24px;
  font-size: 0.95rem;
  font-weight: 600;
  border-radius: 6px;
  border: none;
  cursor: pointer;
  transition: opacity 0.15s ease;
}

.btn-home:hover {
  opacity: 0.85;
}
</style>
