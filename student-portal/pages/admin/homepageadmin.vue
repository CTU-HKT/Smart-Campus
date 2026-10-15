
<template>
  <div class="user-page">
    <h1>Trang cá nhân Admin</h1>
  </div>
</template>

<script setup>
const { user, isLoggedIn } = useAuth()
</script>

<style scoped>
.user-page {
  padding: 32px;
}
</style>
