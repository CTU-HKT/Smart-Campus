<!--
  SPDX-License-Identifier: MIT
  Copyright (c) 2026 CTU-HKT. All rights reserved.
-->

<template>
  <div class="page-wrapper">
    <!-- ================= NAVBAR ================= -->
    <header class="navbar">
      <div class="nav-container">
        <!-- Logo -->
        <a href="#" class="logo">
          <span class="logo-bold">Smart</span><span>Campus</span>
        </a>

        <!-- Menu giữa -->
        <nav class="nav-links">
          <a href="#" class="nav-item">Features</a>
          <a href="#" class="nav-item">Pricing</a>
          <a href="#" class="nav-item">About</a>
          <a href="#" class="nav-item">Contact</a>
        </nav>

        <!-- Nút bên phải -->
        <div class="nav-actions">
          <a href="#" @click.prevent="login" class="login-link">
          Log in
          </a>
          <a href="#" class="btn btn-signup">
          Sign up
          </a>
        </div>
      </div> 
    </header>

    <!-- ================= HERO SECTION ================= -->
    <main class="hero-section">
      <div class="hero-container">
        <!-- Cột trái: Tiêu đề, mô tả và nút -->
        <div class="hero-content">
          <h1 class="hero-title">
            Smart online<br />
            system for schools
          </h1>
          <p class="hero-subtitle">
            Submit applications quickly, conveniently, and securely. Automatically check
            eligibility, track real-time status and manage school application documents smarter anytime,
            anywhere.
          </p>

          <div class="hero-buttons">
            <a href="#" class="btn btn-black">Get Started</a>
            <a href="#" class="btn btn-outline">View Repo</a>
          </div>
        </div>


        <div class="hero-image-wrapper">
          <div class="circle-image-container">
           
            <img 
              src="/pictures/123.jpg"
              alt="Hero Illustration" 
              class="hero-img"
            />

          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
const { $keycloak } = useNuxtApp()

const login = async () => {
  // Gọi thẳng sang Keycloak, đăng nhập xong thì trả về /profile
  await $keycloak.login({ redirectUri: window.location.origin + '/profile' })
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

.page-wrapper {
  min-height: 100vh;
  background-color: #ffffff;
  color: #0f172a;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

/* ================= NAVBAR ================= */
.navbar {
  width: 100%;
  padding: 24px 0;
}

.nav-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 32px;
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

.nav-links {
  display: flex;
  align-items: center;
  gap: 32px;
}

.nav-item {
  color: #475569;
  text-decoration: none;
  font-size: 0.95rem;
  font-weight: 500;
  transition: color 0.15s ease;
}

.nav-item:hover {
  color: #000000;
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 20px;
}

.login-link {
  color: #0f172a;
  text-decoration: none;
  font-size: 0.95rem;
  font-weight: 500;
}

.login-link:hover {
  text-decoration: underline;
}

.btn-signup {
  background-color: #000000;
  color: #ffffff;
  padding: 8px 18px;
  font-size: 0.9rem;
  font-weight: 600;
  border-radius: 6px;
}

.btn-signup:hover {
  opacity: 0.85;
}

/* ================= HERO SECTION ================= */
.hero-section {
  padding: 60px 0 100px;
}

.hero-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 32px;
  display: grid;
  grid-template-columns: 1.15fr 0.85fr;
  align-items: center;
  gap: 60px;
}

.hero-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.hero-title {
  font-size: 4rem;
  line-height: 1.1;
  font-weight: 800;
  letter-spacing: -0.035em;
  color: #000000;
}

.hero-subtitle {
  font-size: 1.15rem;
  line-height: 1.6;
  color: #64748b;
  max-width: 520px;
  font-weight: 400;
}

.hero-buttons {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-top: 8px;
}

/* Nút bấm chung */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  border-radius: 6px;
  padding: 12px 26px;
  font-size: 1rem;
  font-weight: 600;
  transition: all 0.15s ease;
  cursor: pointer;
}

.btn-black {
  background-color: #000000;
  color: #ffffff;
  border: 1.5px solid #000000;
}

.btn-black:hover {
  background-color: #1e293b;
  border-color: #1e293b;
}

.btn-outline {
  background-color: #ffffff;
  color: #000000;
  border: 1.5px solid #000000;
}

.btn-outline:hover {
  background-color: #f8fafc;
}

/* ================= KHỐI HÌNH ẢNH TRÒN ================= */
.hero-image-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
}

.circle-image-container {
  width: 440px;
  height: 440px;
  border-radius: 50%;
  overflow: hidden;
  background-color: #f1f5f9;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 20px 40px -15px rgba(0, 0, 0, 0.08);
}

.hero-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

/* ================= RESPONSIVE (MÀN HÌNH NHỎ) ================= */
@media (max-width: 992px) {
  .hero-container {
    grid-template-columns: 1fr;
    text-align: center;
    gap: 48px;
  }

  .hero-content {
    align-items: center;
  }

  .hero-title {
    font-size: 3rem;
  }

  .hero-buttons {
    justify-content: center;
  }

  .nav-links {
    display: none;
  }

  .circle-image-container {
    width: 340px;
    height: 340px;
  }
}

@media (max-width: 600px) {
  .hero-title {
    font-size: 2.3rem;
  }

  .circle-image-container {
    width: 280px;
    height: 280px;
  }

  .hero-buttons {
    flex-direction: column;
    width: 100%;
  }

  .btn {
    width: 100%;
  }
}
</style>