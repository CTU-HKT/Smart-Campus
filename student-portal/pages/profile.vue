<template>
  <div style="padding: 50px;">
    <h1>Trang Cá Nhân</h1>
    
    <div v-if="!isAuthenticated">
      <p>Bạn chưa đăng nhập. <NuxtLink to="/login">Quay lại Login</NuxtLink></p>
    </div>
    
    <div v-else>
      <p style="color: green; font-weight: bold;">Đăng nhập thành công!</p>
      <p><strong>Tên:</strong> {{ userName }}</p>
      <p><strong>Token (JWT):</strong> {{ tokenPreview }}...</p>
      <button @click="logout" style="margin-top: 20px;">Đăng xuất</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const { $keycloak } = useNuxtApp()
const isAuthenticated = ref(false)
const userName = ref('')
const tokenPreview = ref('')

onMounted(() => {
  // Kiểm tra trạng thái đăng nhập sau khi Keycloak khởi tạo xong
  isAuthenticated.value = $keycloak.authenticated || false
  if (isAuthenticated.value) {
    userName.value = $keycloak.tokenParsed?.preferred_username || 'User'
    tokenPreview.value = $keycloak.token?.substring(0, 50)
  }
})

const logout = async () => {
  await $keycloak.logout({ redirectUri: window.location.origin })
}
</script>