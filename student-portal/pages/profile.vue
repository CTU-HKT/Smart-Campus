<!--
  SPDX-License-Identifier: MIT
  Copyright (c) 2026 CTU-HKT. All rights reserved.
-->

<template>
  <div class="redirect-container">
    <div class="redirect-card">
      <div v-if="!isAuthenticated && !isLoading" class="state-box">
        <h2>Bạn chưa đăng nhập</h2>
        <p>Vui lòng đăng nhập để tiếp tục.</p>
        <NuxtLink to="/" class="btn-home">Quay lại trang chủ</NuxtLink>
      </div>
      
      <div v-else class="state-box">
        <div class="spinner"></div>
        <h2>Đang đồng bộ phân quyền...</h2>
        <p v-if="userName">Xin chào <strong>{{ userName }}</strong>, hệ thống đang chuyển bạn về trang tương ứng.</p>
        <p v-else>Đang kiểm tra thông tin tài khoản từ Keycloak, vui lòng chờ trong giây lát...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const { $keycloak } = useNuxtApp()
const { user, token } = useAuth()

const isAuthenticated = ref(false)
const isLoading = ref(true)
const userName = ref('')

onMounted(async () => {
  // Chờ 1 chút để plugin $keycloak hoàn tất khởi tạo nếu cần
  let retries = 0
  while (!$keycloak && retries < 10) {
    await new Promise(r => setTimeout(r, 100))
    retries++
  }

  isAuthenticated.value = $keycloak?.authenticated || false

  if (isAuthenticated.value) {
    const parsed = $keycloak.tokenParsed || {}
    userName.value = parsed.preferred_username || parsed.name || 'Người dùng'

    // 1. Lưu token vào cookie thông qua useAuth()
    token.value = $keycloak.token

    // 2. Đọc role từ Keycloak Realm Roles
    const realmRoles = parsed.realm_access?.roles || []
    let assignedRole = 'student'

    if (realmRoles.includes('admin')) {
      assignedRole = 'admin'
    } else if (realmRoles.includes('teacher') || realmRoles.includes('giaovien')) {
      assignedRole = 'teacher'
    } else {
      assignedRole = 'student'
    }

    // 3. Lưu thông tin người dùng vào cookie auth_user để các trang Homepage dùng được
    user.value = {
      id: parsed.sub,
      name: parsed.name || parsed.preferred_username || 'Người dùng',
      username: parsed.preferred_username || parsed.sub,
      email: parsed.email || '',
      role: assignedRole
    }

    // 4. Chuyển hướng ngay về Homepage tương ứng
    setTimeout(() => {
      if (assignedRole === 'admin' || assignedRole === 'teacher') {
        navigateTo('/admin/homepageadmin')
      } else {
        navigateTo('/user/homepageuser')
      }
    }, 400)
  } else {
    isLoading.value = false
  }
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

.redirect-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f8fafc;
  color: #0f172a;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  padding: 24px;
}

.redirect-card {
  width: 100%;
  max-width: 440px;
  background-color: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 40px 32px;
  text-align: center;
  box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.06);
}

.spinner {
  width: 44px;
  height: 44px;
  border: 4px solid #f1f5f9;
  border-top: 4px solid #000000;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

h2 {
  font-size: 1.3rem;
  font-weight: 700;
  color: #000000;
  margin-bottom: 8px;
}

p {
  font-size: 0.95rem;
  color: #64748b;
  line-height: 1.5;
  margin-bottom: 20px;
}

.btn-home {
  display: inline-block;
  background-color: #000000;
  color: #ffffff;
  padding: 10px 20px;
  font-size: 0.9rem;
  font-weight: 600;
  border-radius: 6px;
  text-decoration: none;
  transition: opacity 0.15s ease;
}

.btn-home:hover {
  opacity: 0.85;
}
</style>