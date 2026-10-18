<template>
  <div style="padding: 50px;">
    <h1>Trang Cá Nhân</h1>
    
    <!-- Phần 1: Kiểm tra đăng nhập -->
    <div v-if="!isAuthenticated">
      <p>Bạn chưa đăng nhập. <NuxtLink to="/">Quay lại trang chủ</NuxtLink></p>
    </div>
    
    <div v-else>
      <p style="color: green; font-weight: bold;">Đăng nhập thành công!</p>
      <p><strong>Tên:</strong> {{ userName }}</p>
      
      <!-- Phần 2: Nút bấm gọi API -->
      <button @click="fetchData" style="padding: 10px; margin: 20px 0; background: blue; color: white;">
        Lấy danh sách Hồ sơ (Gọi API qua APISIX)
      </button>

      <!-- Phần 3: Hiển thị kết quả -->
      <div v-if="apiError" style="color: red;">
        Lỗi: {{ apiError }}
      </div>
      <div v-if="profiles.length > 0">
        <h3>Kết quả từ Database:</h3>
        <ul>
          <li v-for="p in profiles" :key="p.user_id">
            {{ p.full_name }} - {{ p.student_code }}
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const { $keycloak } = useNuxtApp()
const isAuthenticated = ref(false)
const userName = ref('')
const profiles = ref([])
const apiError = ref('')

onMounted(() => {
  isAuthenticated.value = $keycloak.authenticated || false
  if (isAuthenticated.value) {
    userName.value = $keycloak.tokenParsed?.preferred_username || 'User'
  }
})

// HÀM GỌI API QUA APISIX
const fetchData = async () => {
  try {
    // Gọi vào cổng 9080 (APISIX), không phải 3000 (PostgREST)
    const response = await $fetch('http://localhost:9080/api/profiles', {
      headers: {
        // Gắn token (thẻ căn cước) vào Header theo chuẩn Bearer
        Authorization: `Bearer ${$keycloak.token}` 
      }
    })
    profiles.value = response
    apiError.value = ''
  } catch (error) {
    apiError.value = error.data?.message || error.message || 'Lỗi không xác định'
    console.error('Lỗi gọi API:', error)
  }
}
</script>