<!--
  SPDX-License-Identifier: MIT
  Copyright (c) 2026 CTU-HKT
-->
<template>
  <div class="dashboard-layout">
    <!-- ================= SIDEBAR ================= -->
    <aside class="sidebar">
      <!-- 1. Logo SmartCampus -->
      <div class="sidebar-header">
        <NuxtLink to="/" class="logo">
          <span class="logo-bold">Smart</span><span>Campus</span>
        </NuxtLink>
        <span class="portal-tag">Student</span>
      </div>

      <!-- 2. Menu Điều hướng Sidebar -->
      <nav class="sidebar-nav">
        <!-- Mục Home -->
        <NuxtLink to="/user/homepageuser" class="nav-item">
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
            <polyline points="9 22 9 12 15 12 15 22"/>
          </svg>
          <span class="nav-label">Home</span>
        </NuxtLink>

        <!-- Mục Nộp hồ sơ trực tuyến -->
        <NuxtLink to="/user/usernophoso" class="nav-item">
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="12" y1="18" x2="12" y2="12"/>
            <line x1="9" y1="15" x2="15" y2="15"/>
          </svg>
          <span class="nav-label">Nộp hồ sơ trực tuyến</span>
        </NuxtLink>

        <!-- Mục Kết quả học tập (Đang chọn) -->
        <div class="nav-item active">
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
            <path d="M6 12v5c3 3 9 3 12 0v-5"/>
          </svg>
          <span class="nav-label">Kết quả học tập</span>
        </div>
      </nav>

      <!-- 3. Khu vực tài khoản Sinh viên ở đáy Sidebar -->
      <div class="sidebar-user">
        <NuxtLink to="/info" class="user-profile-click" title="Xem thông tin tài khoản">
          <div class="user-avatar">
            {{ userInitial }}
          </div>
          <div class="user-info">
            <div class="user-name">{{ user?.name || '...' }}</div>
            <div class="user-role">{{ studentId || 'B2100001' }} · Xem hồ sơ</div>
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
      <!-- Header thanh điều hướng -->
      <header class="content-header">
        <div class="breadcrumb">
          <NuxtLink to="/user/homepageuser" class="breadcrumb-link">Portal</NuxtLink>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">Kết quả học tập</span>
        </div>

        <div class="header-right">
          <span class="current-date">{{ currentDateString }}</span>
          <div class="status-indicator">
            <span class="status-dot"></span>
            <span>Hệ thống trực tuyến</span>
          </div>
        </div>
      </header>

      <div class="page-body">
        <!-- Banner tiêu đề trang -->
        <div class="page-title-banner">
          <div>
            <h1 class="page-title">Bảng Kết Quả Học Tập</h1>
            <p class="page-subtitle">
              Tra cứu điểm thi, quá trình rèn luyện và tiến độ học tập chi tiết của sinh viên <strong>{{ user?.name || 'Sinh viên' }}</strong> (MSSV: <strong>{{ studentId }}</strong>).
            </p>
          </div>
          <div class="banner-actions">
            <button class="btn btn-outline" @click="printTranscript">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="6 9 6 2 18 2 18 9"/>
                <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/>
                <rect x="6" y="14" width="12" height="8"/>
              </svg>
              In bảng điểm
            </button>
            <NuxtLink to="/user/homepageuser" class="btn btn-black">
              &larr; Về trang chủ
            </NuxtLink>
          </div>
        </div>

        <!-- Bộ lọc học kỳ (Học kỳ hiện tại & Các học kỳ trước đó) -->
        <div class="semester-filter-bar">
          <div class="semester-label">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
              <line x1="16" y1="2" x2="16" y2="6"/>
              <line x1="8" y1="2" x2="8" y2="6"/>
              <line x1="3" y1="10" x2="21" y2="10"/>
            </svg>
            <span>Học kỳ xem điểm:</span>
          </div>

          <div class="semester-tabs">
            <button 
              v-for="sem in semesters" 
              :key="sem.id"
              class="sem-tab-btn" 
              :class="{ active: selectedSemester === sem.id, current: sem.isCurrent }"
              @click="selectedSemester = sem.id"
            >
              <span v-if="sem.isCurrent" class="current-indicator" title="Học kỳ hiện tại">●</span>
              {{ sem.name }}
              <span v-if="sem.isCurrent" class="sem-tag">Hiện tại</span>
            </button>
          </div>
        </div>

        <!-- KPI TỔNG KẾT ĐIỂM HỌC KỲ & TÍCH LŨY -->
        <div class="kpi-grid">
          <div class="kpi-card">
            <div class="kpi-header">
              <span class="kpi-title">ĐTB Học kỳ (GPA Thang 10)</span>
              <span class="kpi-badge badge-blue">Học kỳ</span>
            </div>
            <div class="kpi-value-row">
              <span class="kpi-number">{{ currentStats.gpa10 }}</span>
              <span class="kpi-sub">/ 10.0</span>
            </div>
            <div class="kpi-footer">Thang điểm chuẩn GDĐH</div>
          </div>

          <div class="kpi-card highlight">
            <div class="kpi-header">
              <span class="kpi-title">ĐTB Học kỳ (GPA Thang 4)</span>
              <span class="kpi-badge badge-purple">Quy đổi</span>
            </div>
            <div class="kpi-value-row">
              <span class="kpi-number text-purple">{{ currentStats.gpa4 }}</span>
              <span class="kpi-sub">/ 4.0</span>
            </div>
            <div class="kpi-footer">Xếp loại: <strong>{{ currentStats.rank }}</strong></div>
          </div>

          <div class="kpi-card">
            <div class="kpi-header">
              <span class="kpi-title">ĐTB Tích lũy (CPA)</span>
              <span class="kpi-badge badge-green">Toàn khóa</span>
            </div>
            <div class="kpi-value-row">
              <span class="kpi-number text-green">{{ currentStats.cpa4 }}</span>
              <span class="kpi-sub">/ 4.0</span>
            </div>
            <div class="kpi-footer">CPA Thang 10: {{ currentStats.cpa10 }}</div>
          </div>

          <div class="kpi-card">
            <div class="kpi-header">
              <span class="kpi-title">Tín chỉ Tích lũy</span>
              <span class="kpi-badge badge-gray">Tiến độ</span>
            </div>
            <div class="kpi-value-row">
              <span class="kpi-number">{{ currentStats.passedCredits }}</span>
              <span class="kpi-sub">/ {{ currentStats.totalCredits }} TC</span>
            </div>
            <div class="kpi-progress">
              <div class="progress-bar" :style="{ width: `${(currentStats.passedCredits / currentStats.totalCredits) * 100}%` }"></div>
            </div>
          </div>
        </div>

        <!-- BẢNG ĐIỂM CHI TIẾT CÁC MÔN HỌC -->
        <section class="transcript-section">
          <div class="section-top">
            <div class="section-title-box">
              <h2 class="section-title">Danh sách môn học - {{ currentSemesterName }}</h2>
              <span class="course-count">({{ filteredCourses.length }} môn học)</span>
            </div>

            <!-- Tìm kiếm môn học -->
            <div class="search-box">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"/>
                <line x1="21" y1="21" x2="16.65" y2="16.65"/>
              </svg>
              <input 
                type="text" 
                v-model="searchQuery" 
                placeholder="Tìm mã hoặc tên môn học..." 
                class="search-input"
              />
            </div>
          </div>

          <div class="table-card">
            <table class="transcript-table">
              <thead>
                <tr>
                  <th class="col-stt">STT</th>
                  <th class="col-code">Mã môn</th>
                  <th class="col-name">Tên môn học</th>
                  <th class="col-credits">Số TC</th>
                  <th class="col-teacher">Giảng viên giảng dạy</th>
                  <th class="col-score">Điểm QT</th>
                  <th class="col-score">Điểm Thi</th>
                  <th class="col-final">Điểm Hệ 10</th>
                  <th class="col-letter">Điểm Chữ</th>
                  <th class="col-gpa4">Thang 4</th>
                  <th class="col-status">Kết quả</th>
                </tr>
              </thead>
              <tbody>
                <tr 
                  v-for="(course, index) in filteredCourses" 
                  :key="course.code + course.semester"
                  :class="{ 'row-highlight': course.isTargetCourse }"
                >
                  <td class="col-stt font-mono">{{ index + 1 }}</td>
                  <td class="col-code font-mono font-bold">{{ course.code }}</td>
                  <td class="col-name">
                    <div class="course-title-wrapper">
                      <span class="course-title">{{ course.name }}</span>
                      <span v-if="course.isTargetCourse" class="target-badge" title="Môn theo yêu cầu đề bài">
                        ⭐ Môn chỉ định
                      </span>
                    </div>
                  </td>
                  <td class="col-credits text-center">{{ course.credits }}</td>
                  <td class="col-teacher">
                    <div class="teacher-info">
                      <span class="teacher-name">{{ course.teacher }}</span>
                      <span v-if="course.teacherCode" class="teacher-tag">{{ course.teacherCode }}</span>
                    </div>
                  </td>
                  <td class="col-score text-center">{{ course.processScore ?? '-' }}</td>
                  <td class="col-score text-center">{{ course.examScore ?? '-' }}</td>
                  <td class="col-final text-center">
                    <span v-if="course.letterGrade === 'I' || course.finalScore === null" class="score-badge score-low">
                      -
                    </span>
                    <span v-else class="score-badge" :class="getScoreClass(course.finalScore)">
                      {{ Number(course.finalScore).toFixed(1) }}
                    </span>
                  </td>
                  <td class="col-letter text-center font-bold">
                    <span class="letter-grade" :class="'grade-' + (course.letterGrade || 'none').toLowerCase()">
                      {{ course.letterGrade || '-' }}
                    </span>
                  </td>
                  <td class="col-gpa4 text-center font-mono">
                    {{ (course.letterGrade === 'I' || course.gpa4 === null) ? '-' : Number(course.gpa4).toFixed(1) }}
                  </td>
                  <td class="col-status text-center">
                    <span class="status-pill" :class="course.passed ? 'passed' : 'failed'">
                      {{ course.passed ? 'Đạt' : 'Chưa đạt' }}
                    </span>
                  </td>
                </tr>

                <tr v-if="filteredCourses.length === 0">
                  <td colspan="11" class="empty-state">
                    Không tìm thấy môn học nào phù hợp với điều kiện tìm kiếm.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>


        </section>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const { $keycloak } = useNuxtApp()

// User info
const user = ref({ name: '...' })
const studentId = ref('...')
const userInitial = computed(() => (user.value?.name || 'A').charAt(0).toUpperCase())
const currentDateString = computed(() => new Date().toLocaleDateString('vi-VN', { 
  weekday: 'long', year: 'numeric', month: 'numeric', day: 'numeric' 
}))

// Danh sách các học kỳ nạp động từ CSDL
const semesters = ref([
  { id: 'HK1-2025-2026', name: 'Học kỳ 1 (2025 - 2026)', isCurrent: true }
])

const selectedSemester = ref('HK1-2025-2026')
const searchQuery = ref('')

// Tên học kỳ đang chọn
const currentSemesterName = computed(() => {
  const found = semesters.value.find(s => s.id === selectedSemester.value)
  return found ? found.name : 'Học kỳ hiện tại'
})

// Dữ liệu môn học: KHÔNG DÙNG DỮ LIỆU GIẢ/MẪU, nạp 100% từ Database
const allCourses = ref([])

// Danh sách môn theo bộ lọc
const filteredCourses = computed(() => {
  return allCourses.value.filter(c => {
    // Lọc theo học kỳ
    if (selectedSemester.value !== 'ALL' && c.semester !== selectedSemester.value) {
      return false
    }
    // Lọc theo tìm kiếm
    if (searchQuery.value) {
      const q = searchQuery.value.toLowerCase()
      const matchCode = c.code.toLowerCase().includes(q)
      const matchName = c.name.toLowerCase().includes(q)
      const matchTeacher = c.teacher.toLowerCase().includes(q)
      if (!matchCode && !matchName && !matchTeacher) return false
    }
    return true
  })
})

// Tính toán thống kê từ dữ liệu thực tế trong CSDL
const currentStats = computed(() => {
  const courses = filteredCourses.value
  if (!courses.length) {
    return { gpa10: '0.00', gpa4: '0.00', cpa10: '0.00', cpa4: '0.00', passedCredits: 0, totalCredits: 0, rank: 'Chưa xét' }
  }

  let totalCredits = 0
  let passedCredits = 0
  let gradedCredits = 0
  let sumScore10Weighted = 0
  let sumScore4Weighted = 0

  courses.forEach(c => {
    totalCredits += c.credits
    if (c.passed) passedCredits += c.credits
    if (c.letterGrade !== 'I' && c.finalScore !== null && c.finalScore !== undefined) {
      gradedCredits += c.credits
      sumScore10Weighted += c.finalScore * c.credits
    }
    if (c.letterGrade !== 'I' && c.gpa4 !== null && c.gpa4 !== undefined) {
      sumScore4Weighted += c.gpa4 * c.credits
    }
  })

  const gpa10 = gradedCredits > 0 ? (sumScore10Weighted / gradedCredits).toFixed(2) : '0.00'
  const gpa4 = gradedCredits > 0 ? (sumScore4Weighted / gradedCredits).toFixed(2) : '0.00'

  let rank = 'Chưa hoàn thành'
  const numGpa4 = parseFloat(gpa4)
  if (gradedCredits > 0) {
    if (numGpa4 >= 3.6) rank = 'Xuất sắc'
    else if (numGpa4 >= 3.2) rank = 'Giỏi'
    else if (numGpa4 >= 2.5) rank = 'Khá'
    else if (numGpa4 >= 2.0) rank = 'Trung bình'
    else rank = 'Yếu'
  }

  return {
    gpa10,
    gpa4,
    cpa10: gpa10,
    cpa4: gpa4,
    passedCredits,
    totalCredits,
    rank
  }
})

const getScoreClass = (score) => {
  if (score >= 8.5) return 'score-excellent'
  if (score >= 7.0) return 'score-good'
  if (score >= 5.5) return 'score-average'
  return 'score-low'
}

const printTranscript = () => {
  window.print()
}

const logout = () => {
  $keycloak.logout({ redirectUri: window.location.origin })
}

onMounted(async () => {
  if ($keycloak.authenticated) {
    const parsed = $keycloak.tokenParsed || {}
    const sub = parsed.sub
    studentId.value = parsed.preferred_username || 'Sinh viên'

    // 1. Lấy thông tin hồ sơ sinh viên từ CSDL (dùng bảng app.sinh_vien đồng bộ với homepageuser)
    try {
      const profileData = await $fetch(`http://localhost:9080/api/postgrest/sinh_vien?keycloak_sub=eq.${sub}`, {
        headers: { Authorization: `Bearer ${$keycloak.token}` }
      })
      if (profileData?.[0]?.ho_ten) {
        user.value = { name: profileData[0].ho_ten }
        studentId.value = profileData[0].ma_sv || studentId.value
      } else {
        user.value = { name: parsed.name || parsed.preferred_username || 'Sinh viên' }
      }
    } catch {
      user.value = { name: parsed.name || parsed.preferred_username || 'Sinh viên' }
    }

    // 2. Tải danh sách môn học thực tế từ CSDL qua PostgREST (RLS tự động lọc chỉ trả về môn của đúng sinh viên này)
    try {
      const data = await $fetch('http://localhost:9080/api/postgrest/dang_ky_mon?select=id,ma_sv,ma_mon,hoc_ky,diem_so,diem_chu,trang_thai_dk,mon_hoc(ten_mon,so_tc,can_bo(ho_ten,ma_cb))', {
        headers: { Authorization: `Bearer ${$keycloak.token}` }
      })

      if (Array.isArray(data) && data.length > 0) {
        allCourses.value = data.map(item => {
          const isDiemI = item.diem_chu === 'I'
          const finalScore = !isDiemI && item.diem_so !== null && item.diem_so !== undefined ? Number(item.diem_so) : null
          let gpa4 = null
          if (finalScore !== null && !isDiemI) {
            if (finalScore >= 8.5) gpa4 = 4.0
            else if (finalScore >= 8.0) gpa4 = 3.5
            else if (finalScore >= 7.0) gpa4 = 3.0
            else if (finalScore >= 6.5) gpa4 = 2.5
            else if (finalScore >= 5.5) gpa4 = 2.0
            else if (finalScore >= 5.0) gpa4 = 1.5
            else if (finalScore >= 4.0) gpa4 = 1.0
            else gpa4 = 0.0
          }
          const passed = !isDiemI && item.trang_thai_dk === 'Đã học' && finalScore !== null && finalScore >= 4.0

          return {
            id: item.id,
            semester: item.hoc_ky,
            code: item.ma_mon,
            name: item.mon_hoc?.ten_mon || item.ma_mon,
            credits: item.mon_hoc?.so_tc || 3,
            teacher: item.mon_hoc?.can_bo?.ho_ten || 'Chưa phân công',
            teacherCode: item.mon_hoc?.can_bo?.ma_cb || '',
            processScore: null,
            examScore: null,
            finalScore: finalScore,
            letterGrade: item.diem_chu || null,
            gpa4: gpa4,
            passed: passed,
            isTargetCourse: item.ma_mon === 'INT3101'
          }
        })

        // Hàm tính khoảng cách thời gian giữa một học kỳ và thời gian thực tế hiện tại
        const getSemesterProximityScore = (semStr) => {
          const now = new Date()
          const match = semStr.match(/HK\s*(\d+)[\s\-_]+(\d{4})[\s\-_]+(\d{4})/i)
          if (match) {
            const term = parseInt(match[1], 10)
            const startYear = parseInt(match[2], 10)
            const endYear = parseInt(match[3], 10)
            
            // Ước lượng ngày giữa học kỳ (midpoint) theo lịch đào tạo ĐH:
            // HK1: khoảng 15/11 năm bắt đầu
            // HK2: khoảng 15/04 năm kết thúc
            // HK3 / Hè: khoảng 15/07 năm kết thúc
            let midDate
            if (term === 1) {
              midDate = new Date(startYear, 10, 15)
            } else if (term === 2) {
              midDate = new Date(endYear, 3, 15)
            } else {
              midDate = new Date(endYear, 6, 15)
            }
            return Math.abs(midDate.getTime() - now.getTime())
          }
          return Infinity
        }

        const uniqueSems = [...new Set(data.map(item => item.hoc_ky).filter(Boolean))]
        if (uniqueSems.length > 0) {
          // Tìm học kỳ có thời gian gần với thời gian thực tế nhất
          let closestSem = uniqueSems[0]
          let minDiff = Infinity

          uniqueSems.forEach(sem => {
            const diff = getSemesterProximityScore(sem)
            if (diff < minDiff) {
              minDiff = diff
              closestSem = sem
            }
          })

          semesters.value = uniqueSems.map(sem => ({
            id: sem,
            name: sem,
            isCurrent: sem === closestSem
          }))
          // Mặc định chọn học kỳ gần với thời gian thực nhất (học kỳ hiện tại)
          selectedSemester.value = closestSem
        }
      } else {
        allCourses.value = []
      }
    } catch (err) {
      console.error('Lỗi khi tải kết quả học tập từ database:', err)
      allCourses.value = []
    }
  } else {
    navigateTo('/')
  }
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');
* { box-sizing: border-box; margin: 0; padding: 0; }
.dashboard-layout { display: flex; min-height: 100vh; background-color: #f8fafc; color: #0f172a; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif; }
.sidebar { width: 260px; background: #fff; border-right: 1px solid #e2e8f0; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; }
.sidebar-header { padding: 24px 20px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #f1f5f9; }
.logo { font-size: 1.25rem; font-weight: 500; color: #000; text-decoration: none; letter-spacing: -0.02em; }
.logo-bold { font-weight: 800; }
.portal-tag { font-size: 0.75rem; font-weight: 700; background: #f1f5f9; color: #475569; padding: 2px 8px; border-radius: 4px; }
.sidebar-nav { padding: 16px 12px; display: flex; flex-direction: column; gap: 4px; flex: 1; }
.nav-item { display: flex; align-items: center; gap: 12px; padding: 10px 14px; border-radius: 8px; color: #64748b; text-decoration: none; font-size: 0.875rem; font-weight: 500; background: transparent; border: none; cursor: pointer; width: 100%; text-align: left; transition: all 0.15s ease; }
.nav-item:hover { background: #f8fafc; color: #0f172a; }
.nav-item.active { background: #000; color: #fff; font-weight: 600; }
.nav-icon { flex-shrink: 0; }
.sidebar-user { padding: 16px 20px; border-top: 1px solid #f1f5f9; display: flex; align-items: center; justify-content: space-between; }
.user-profile-click { display: flex; align-items: center; gap: 12px; text-decoration: none; color: inherit; flex: 1; min-width: 0; }
.user-avatar { width: 36px; height: 36px; border-radius: 50%; background: #e2e8f0; color: #0f172a; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.875rem; }
.user-info { display: flex; flex-direction: column; min-width: 0; }
.user-name { font-size: 0.875rem; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.user-role { font-size: 0.75rem; color: #64748b; }
.btn-logout { background: transparent; border: none; color: #94a3b8; cursor: pointer; padding: 6px; border-radius: 6px; display: flex; align-items: center; justify-content: center; }
.btn-logout:hover { color: #ef4444; background: #fef2f2; }
.main-content { flex: 1; display: flex; flex-direction: column; min-width: 0; }
.content-header { height: 64px; background: #fff; border-bottom: 1px solid #e2e8f0; padding: 0 32px; display: flex; align-items: center; justify-content: space-between; }
.breadcrumb { display: flex; align-items: center; gap: 8px; font-size: 0.875rem; }
.breadcrumb-link { color: #64748b; text-decoration: none; }
.breadcrumb-link:hover { color: #000; }
.breadcrumb-separator { color: #cbd5e1; }
.breadcrumb-current { color: #0f172a; font-weight: 600; }
.header-right { display: flex; align-items: center; gap: 16px; font-size: 0.8125rem; color: #64748b; }
.status-indicator { display: flex; align-items: center; gap: 6px; }
.status-dot { width: 8px; height: 8px; border-radius: 50%; background: #22c55e; }
.page-body { padding: 32px; display: flex; flex-direction: column; gap: 24px; max-width: 1360px; width: 100%; margin: 0 auto; }
.page-title-banner { display: flex; align-items: center; justify-content: space-between; gap: 20px; }
.page-title { font-size: 1.625rem; font-weight: 800; letter-spacing: -0.02em; color: #0f172a; margin-bottom: 6px; }
.page-subtitle { font-size: 0.9375rem; color: #64748b; }
.banner-actions { display: flex; gap: 10px; }
.btn { display: inline-flex; align-items: center; gap: 8px; padding: 8px 16px; font-size: 0.875rem; font-weight: 600; border-radius: 8px; cursor: pointer; text-decoration: none; transition: all 0.15s ease; }
.btn-black { background: #000; color: #fff; border: 1px solid #000; }
.btn-black:hover { background: #27272a; }
.btn-outline { background: #fff; color: #0f172a; border: 1px solid #e2e8f0; }
.btn-outline:hover { background: #f8fafc; border-color: #cbd5e1; }
.semester-filter-bar { background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 12px 18px; display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
.semester-label { display: flex; align-items: center; gap: 8px; font-size: 0.875rem; font-weight: 700; color: #334155; white-space: nowrap; }
.semester-tabs { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.sem-tab-btn { background: #f1f5f9; border: 1px solid transparent; color: #475569; padding: 6px 14px; border-radius: 8px; font-size: 0.8125rem; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 6px; transition: all 0.15s ease; }
.sem-tab-btn:hover { background: #e2e8f0; color: #0f172a; }
.sem-tab-btn.active { background: #000; color: #fff; border-color: #000; }
.current-indicator { color: #22c55e; font-size: 0.65rem; }
.sem-tag { background: #dcfce7; color: #15803d; font-size: 0.6875rem; padding: 2px 6px; border-radius: 4px; font-weight: 700; }
.sem-tab-btn.active .sem-tag { background: #22c55e; color: #fff; }
.kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 16px; }
.kpi-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; display: flex; flex-direction: column; gap: 8px; }
.kpi-card.highlight { border-color: #c084fc; background: linear-gradient(135deg, #fff 0%, #faf5ff 100%); }
.kpi-header { display: flex; align-items: center; justify-content: space-between; }
.kpi-title { font-size: 0.8125rem; font-weight: 600; color: #64748b; }
.kpi-badge { font-size: 0.6875rem; font-weight: 700; padding: 2px 8px; border-radius: 4px; }
.badge-blue { background: #eff6ff; color: #2563eb; }
.badge-purple { background: #f3e8ff; color: #7e22ce; }
.badge-green { background: #dcfce7; color: #15803d; }
.badge-gray { background: #f1f5f9; color: #475569; }
.kpi-value-row { display: flex; align-items: baseline; gap: 4px; }
.kpi-number { font-size: 2rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em; }
.text-purple { color: #7e22ce; }
.text-green { color: #16a34a; }
.kpi-sub { font-size: 0.875rem; color: #94a3b8; font-weight: 600; }
.kpi-footer { font-size: 0.8125rem; color: #64748b; margin-top: auto; }
.kpi-progress { width: 100%; height: 6px; background: #f1f5f9; border-radius: 3px; overflow: hidden; margin-top: 4px; }
.progress-bar { height: 100%; background: #000; border-radius: 3px; }
.transcript-section { background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 24px; display: flex; flex-direction: column; gap: 20px; }
.section-top { display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; }
.section-title-box { display: flex; align-items: baseline; gap: 8px; }
.section-title { font-size: 1.125rem; font-weight: 700; color: #0f172a; }
.course-count { font-size: 0.875rem; color: #64748b; font-weight: 500; }
.search-box { display: flex; align-items: center; gap: 8px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 6px 12px; width: 280px; }
.search-input { border: none; background: transparent; outline: none; font-size: 0.8125rem; width: 100%; color: #0f172a; }
.table-card { border: 1px solid #e2e8f0; border-radius: 8px; overflow-x: auto; }
.transcript-table { width: 100%; border-collapse: collapse; font-size: 0.875rem; text-align: left; }
.transcript-table th { background: #f8fafc; padding: 12px 14px; font-weight: 700; color: #475569; border-bottom: 1px solid #e2e8f0; white-space: nowrap; }
.transcript-table td { padding: 14px; border-bottom: 1px solid #f1f5f9; color: #1e293b; }
.transcript-table tbody tr:hover { background: #f8fafc; }
.row-highlight { background: #f0fdf4 !important; }
.font-mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; }
.font-bold { font-weight: 700; }
.text-center { text-align: center; }
.course-title-wrapper { display: flex; align-items: center; gap: 8px; }
.course-title { font-weight: 600; color: #0f172a; }
.target-badge { font-size: 0.6875rem; font-weight: 700; background: #fef08a; color: #854d0e; padding: 2px 6px; border-radius: 4px; }
.teacher-info { display: flex; flex-direction: column; }
.teacher-name { font-weight: 500; color: #0f172a; }
.teacher-tag { font-size: 0.6875rem; color: #94a3b8; font-family: monospace; }
.score-badge { display: inline-block; padding: 4px 10px; border-radius: 6px; font-weight: 800; font-size: 0.875rem; }
.score-excellent { background: #dcfce7; color: #166534; }
.score-good { background: #eff6ff; color: #1e40af; }
.score-average { background: #fef9c3; color: #854d0e; }
.score-low { background: #fee2e2; color: #991b1b; }
.letter-grade { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 0.8125rem; }
.grade-a { background: #22c55e; color: #fff; }
.grade-b\+ { background: #3b82f6; color: #fff; }
.grade-b { background: #60a5fa; color: #fff; }
.grade-c\+ { background: #eab308; color: #fff; }
.grade-c { background: #f59e0b; color: #fff; }
.grade-d\+ { background: #f97316; color: #fff; }
.grade-d { background: #fb923c; color: #fff; }
.grade-f { background: #ef4444; color: #fff; }
.grade-i { background: #f59e0b; color: #fff; font-weight: 800; }
.status-pill { display: inline-block; padding: 4px 10px; border-radius: 9999px; font-size: 0.75rem; font-weight: 700; }
.status-pill.passed { background: #dcfce7; color: #15803d; }
.status-pill.failed { background: #fee2e2; color: #b91c1c; }
.empty-state { text-align: center; padding: 36px !important; color: #94a3b8; font-style: italic; }
@media (max-width: 900px) { .sidebar { display: none; } .page-body { padding: 16px; } }
</style>
