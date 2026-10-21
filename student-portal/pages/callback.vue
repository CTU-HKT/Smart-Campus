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
const isAuthenticated = ref(false)
const isLoading = ref(true)
const userName = ref('')

onMounted(async () => {
  if ($keycloak.authenticated) {
    isAuthenticated.value = true
    const parsed = $keycloak.tokenParsed || {}
    userName.value = parsed.preferred_username || parsed.name || 'Người dùng'
    const sub = parsed.sub
    const token = $keycloak.token
    const realmRoles = parsed.realm_access?.roles || []
    const isTeacher = realmRoles.includes('teacher')

    try {
      // Kiểm tra hồ sơ trong Database (Áp dụng cho CẢ Giáo viên và Sinh viên)
      const data = await $fetch(`http://localhost:9080/api/profiles?user_id=eq.${sub}`, {
        headers: {
          Authorization: `Bearer ${token}`
        }
      })

      const profile = Array.isArray(data) ? data[0] : null
      // Nếu chưa có hồ sơ HOẶC thiếu các trường bắt buộc (mã định danh, họ tên, khoa/đơn vị)
      const isIncomplete = !profile || !profile.student_code || !profile.faculty || !profile.major || !profile.date_of_birth || !profile.phone || !profile.full_name

      if (isIncomplete) {
        // Cả giáo viên lẫn sinh viên nếu chưa hoàn thiện hồ sơ đều phải qua bước này
        return navigateTo('/complete-profile')
      }

      // Đã đầy đủ hồ sơ -> Chuyển hướng về đúng giao diện theo Role
      setTimeout(() => {
        if (isTeacher) {
          navigateTo('/admin/homepageadmin')
        } else {
          navigateTo('/user/homepageuser')
        }
      }, 400)
    } catch (err) {
      console.error('Lỗi khi kiểm tra thông tin hồ sơ:', err)
      // Nếu có lỗi query (ví dụ chưa có profile), chuyển sang trang hoàn thiện hồ sơ
      navigateTo('/complete-profile')
    }
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