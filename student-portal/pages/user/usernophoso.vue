<!--
  SPDX-License-Identifier: MIT
  Copyright (c) 2026 CTU-HKT. All rights reserved.
-->
<template>
  <div class="dashboard-layout">
    <!-- ================= SIDEBAR ================= -->
    <aside class="sidebar">
      <!-- 1. Góc trên cùng bên trái: Logo SmartCampus -->
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

        <!-- Mục Nộp hồ sơ trực tuyến (ĐANG CHỌN - FILE VUE MỚI) -->
        <div class="nav-item active">
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="12" y1="18" x2="12" y2="12"/>
            <line x1="9" y1="15" x2="15" y2="15"/>
          </svg>
          <span class="nav-label">Nộp hồ sơ trực tuyến</span>
          <span class="nav-badge pulse-badge">Mới</span>
        </div>

        <!-- Mục Hồ sơ đã nộp -->
        <NuxtLink to="/user/homepageuser?tab=records" class="nav-item">
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
            <polyline points="10 9 9 9 8 9"/>
          </svg>
          <span class="nav-label">Hồ sơ đã nộp</span>
        </NuxtLink>

        <!-- Mục Kết quả học tập -->
        <NuxtLink to="/user/userketquahoctap" class="nav-item">
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
            <path d="M6 12v5c3 3 9 3 12 0v-5"/>
          </svg>
          <span class="nav-label">Kết quả học tập</span>
        </NuxtLink>

        <!-- Mục Notifications -->
        <NuxtLink to="/user/homepageuser?tab=notifications" class="nav-item">
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
            <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
          </svg>
          <span class="nav-label">Thông báo</span>
        </NuxtLink>

        <!-- Mục Settings -->
        <NuxtLink to="/user/homepageuser?tab=settings" class="nav-item">
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="3"/>
            <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/>
          </svg>
          <span class="nav-label">Cài đặt</span>
        </NuxtLink>
      </nav>

      <!-- 3. Khu vực tài khoản Sinh viên ở đáy Sidebar -->
      <div class="sidebar-user">
        <NuxtLink to="/info" class="user-profile-click" title="Xem thông tin tài khoản">
          <div class="user-avatar">
            {{ userInitial }}
          </div>
          <div class="user-info">
            <div class="user-name">{{ user?.name || '...' }}</div>
            <div class="user-role">{{ studentId || 'Sinh viên' }} · Xem hồ sơ</div>
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
          <NuxtLink to="/user/homepageuser" class="breadcrumb-link">Portal</NuxtLink>
          <span class="breadcrumb-separator">/</span>
          <span class="breadcrumb-current">Nộp hồ sơ trực tuyến</span>
        </div>

        <div class="header-right">
          <span class="current-date">{{ currentDateString }}</span>
          <div class="status-indicator">
            <span class="status-dot"></span>
            <span>Hệ thống trực tuyến (BPMN Active)</span>
          </div>
        </div>
      </header>

      <!-- Toast thông báo thành công -->
      <div v-if="toastMessage" class="toast-alert animate-fade-in">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
          <polyline points="22 4 12 14.01 9 11.01"/>
        </svg>
        <span>{{ toastMessage }}</span>
        <button class="toast-close" @click="toastMessage = ''">&times;</button>
      </div>

      <!-- Tiêu đề trang Nộp hồ sơ -->
      <div class="catalog-header-banner">
        <div>
          <h1 class="catalog-title">Hệ Thống Nộp Hồ Sơ & Đơn Trực Tuyến</h1>
          <p class="catalog-subtitle">
            Lựa chọn loại hồ sơ cần nộp. Hệ thống sẽ tự động liên kết môn học, chuyển hồ sơ đến đúng Giảng viên và Trưởng khoa phụ trách qua luồng số hóa Flowable BPMN.
          </p>
        </div>
        <NuxtLink to="/user/homepageuser" class="btn btn-outline">
          &larr; Về trang chủ
        </NuxtLink>
      </div>

      <!-- Lưới danh sách các loại đơn trong hệ thống -->
      <div class="doc-types-grid">
        <!-- CARD ĐƠN XIN ĐIỂM I (NỔI BẬT THEO YÊU CẦU ĐỀ BÀI) -->
        <div class="doc-type-card featured-card" @click="openDiemIModal">
          <div class="card-top-row">
            <span class="badge-flowable">
              <span class="pulse-dot"></span> Flowable BPMN 2.0
            </span>
            <span class="badge-code font-mono">XIN_DIEM_I</span>
          </div>

          <div class="card-icon-title">
            <div class="type-icon-box gold-icon">
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
              </svg>
            </div>
            <div>
              <h3 class="type-title">Đơn xin điểm I</h3>
              <span class="type-category">Học vụ & Điểm số sinh viên</span>
            </div>
          </div>

          <p class="type-description">
            Đề nghị xét điểm I (chưa hoàn thành) cho môn học có điểm &lt; 8.0. Hồ sơ sẽ được tự động chuyển đến đúng Giảng viên giảng dạy và Trưởng khoa để thẩm định và cập nhật điểm I tự động.
          </p>

          <div class="card-workflow-preview">
            <span class="wf-step">1. Sinh viên nộp</span>
            <span class="wf-arrow">&rarr;</span>
            <span class="wf-step">2. Giảng viên duyệt</span>
            <span class="wf-arrow">&rarr;</span>
            <span class="wf-step">3. Trưởng khoa duyệt</span>
            <span class="wf-arrow">&rarr;</span>
            <span class="wf-step highlight-step">4. Đổi điểm 'I'</span>
          </div>

          <div class="card-action-bar">
            <button class="btn btn-black btn-block">
              Nộp đơn xin điểm I ngay &rarr;
            </button>
          </div>
        </div>

      </div>
    </main>

    <!-- ================= POPUP MODAL NỘP ĐƠN XIN ĐIỂM I ================= -->
    <div v-if="isDiemIModalOpen" class="modal-overlay" @click.self="isDiemIModalOpen = false">
      <div class="modal-box-large animate-slide-up">
        <!-- Header modal -->
        <div class="modal-large-header">
          <div class="modal-header-icon-title">
            <div class="modal-icon-badge">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
              </svg>
            </div>
            <div>
              <h2 class="modal-main-title">Nộp Đơn Xin Điểm I (Incomplete Grade)</h2>
              <p class="modal-sub-title">Quy trình số hoá Flowable: Giảng viên &rarr; Trưởng khoa phê duyệt</p>
            </div>
          </div>
          <button @click="isDiemIModalOpen = false" class="btn-close-modal" title="Đóng">&times;</button>
        </div>

        <!-- Body modal -->
        <div class="modal-large-body">
          <!-- Banner hướng dẫn & Quy tắc điểm < 8.0 -->
          <div class="rule-alert-banner">
            <svg class="rule-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <line x1="12" y1="8" x2="12" y2="12"/>
              <line x1="12" y1="16" x2="12.01" y2="16"/>
            </svg>
            <div class="rule-text">
              <strong>Điều kiện nộp đơn:</strong> Sinh viên trong một học kỳ, học môn của một giảng viên, có điểm <strong>&lt; 8.0</strong> (hoặc đang học chưa có điểm) mới đủ điều kiện nộp đơn xin điểm I cho đúng giảng viên giảng dạy.
            </div>
          </div>

          <!-- BƯỚC 1: CHỌN MÔN HỌC -->
          <section class="form-section">
            <div class="section-label-row">
              <span class="step-num">1</span>
              <label class="form-label font-bold">Chọn môn học cần xin điểm I (Trong các môn bạn đã/đang học):</label>
            </div>

            <!-- Loading -->
            <div v-if="isLoadingCourses" class="loading-box">
              <div class="spinner"></div>
              <span>Đang tải danh sách môn học từ CSDL...</span>
            </div>

            <!-- Danh sách môn học để chọn -->
            <div v-else class="courses-selector-grid">
              <div 
                v-for="course in studentCourses" 
                :key="course.id"
                class="course-select-card"
                :class="{ 
                  'selected': selectedCourse?.id === course.id,
                  'disabled-card': !course.isEligible,
                  'already-submitted-card': course.hasSubmitted
                }"
                @click="course.isEligible ? (selectedCourse = course) : (course.hasSubmitted ? alert(`Môn '${course.name}' đã có hồ sơ xin điểm I (${course.submittedAppCode || ''} - ${course.submittedAppStatus || ''}). Mỗi môn chỉ được nộp 1 hồ sơ!`) : null)"
              >
                <div class="course-card-head">
                  <span class="course-code font-mono">{{ course.code }}</span>
                  <span class="course-sem">{{ course.semester }}</span>
                </div>

                <div class="course-card-name">{{ course.name }} ({{ course.credits }} TC)</div>

                <div class="course-card-teacher">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                    <circle cx="12" cy="7" r="4"/>
                  </svg>
                  <span>GV: <strong>{{ course.teacherName }}</strong></span>
                </div>

                <div class="course-card-foot">
                  <!-- Tag điểm -->
                  <div v-if="course.finalScore !== null" class="score-indicator">
                    Điểm: <strong>{{ course.finalScore.toFixed(1) }}</strong>
                    <span v-if="course.letterGrade">({{ course.letterGrade }})</span>
                  </div>
                  <div v-else class="score-indicator text-muted">
                    Chưa có điểm (Đang học)
                  </div>

                  <!-- Tag trạng thái hồ sơ / đủ điều kiện -->
                  <span v-if="course.hasSubmitted" class="eligibility-tag tag-has-submitted" :title="'Mã hồ sơ: ' + course.submittedAppCode">
                    🔒 Đã nộp đơn ({{ course.submittedAppStatus }})
                  </span>
                  <span v-else-if="course.isEligible" class="eligibility-tag tag-ok">
                    ✓ Đủ điều kiện (&lt; 8.0)
                  </span>
                  <span v-else class="eligibility-tag tag-not-ok">
                    ✗ Điểm &ge; 8.0 (Không đủ ĐK)
                  </span>
                </div>
              </div>

              <div v-if="studentCourses.length === 0" class="empty-courses">
                Không tìm thấy dữ liệu đăng ký môn học của bạn trong hệ thống.
              </div>
            </div>

            <!-- Tóm tắt môn được chọn & Luồng xét duyệt -->
            <div v-if="selectedCourse" class="selected-summary-box animate-fade-in">
              <div class="summary-head">
                <span class="check-icon">✓</span>
                <span>Môn đã chọn: <strong>{{ selectedCourse.name }}</strong> ({{ selectedCourse.code }} - {{ selectedCourse.semester }})</span>
              </div>
              <div class="approval-route-grid">
                <div class="route-item">
                  <span class="route-role">Giảng viên học phần (Task 1):</span>
                  <span class="route-name">{{ selectedCourse.teacherName }} (Mã: {{ selectedCourse.teacherCode }})</span>
                </div>
                <div class="route-arrow">&rarr;</div>
                <div class="route-item">
                  <span class="route-role">Trưởng khoa phê duyệt (Task 2):</span>
                  <span class="route-name">Nguyễn Trưởng Khoa (TK_KTPM - {{ selectedCourse.faculty }})</span>
                </div>
              </div>
            </div>
          </section>

          <!-- BƯỚC 2: NHẬP LÝ DO XIN ĐIỂM I -->
          <section class="form-section">
            <div class="section-label-row">
              <span class="step-num">2</span>
              <label class="form-label font-bold">Lý do xin nhận điểm I <span class="required-star">*</span>:</label>
            </div>

            <!-- Gợi ý nhanh -->
            <div class="reason-templates">
              <span class="tpl-label">Gợi ý nhanh:</span>
              <button 
                type="button" 
                class="tpl-btn"
                @click="applyReasonTemplate('Lý do sức khỏe / Điều trị y tế không thể tham gia thi đúng hạn')"
              >
                + Lý do sức khỏe / Y tế
              </button>
              <button 
                type="button" 
                class="tpl-btn"
                @click="applyReasonTemplate('Trùng lịch thực tập tốt nghiệp / Công tác đột xuất của trường')"
              >
                + Trùng lịch thực tập / Công tác
              </button>
              <button 
                type="button" 
                class="tpl-btn"
                @click="applyReasonTemplate('Gia đình có việc đột xuất bất khả kháng theo quy chế')"
              >
                + Việc gia đình đột xuất
              </button>
            </div>

            <textarea 
              v-model="diemIReason" 
              class="form-textarea" 
              rows="3" 
              placeholder="Nhập chi tiết lý do của bạn để Giảng viên và Trưởng khoa xem xét..."
            ></textarea>
          </section>

          <!-- BƯỚC 3: TỆP MINH CHỨNG & GHI CHÚ -->
          <section class="form-section">
            <div class="section-label-row">
              <span class="step-num">3</span>
              <label class="form-label font-bold">Minh chứng đính kèm (Giấy tờ y tế, đơn xác nhận...):</label>
            </div>
            <input 
              type="text" 
              v-model="diemIAttachment" 
              class="form-input" 
              placeholder="Nhập tên tệp minh chứng hoặc đường dẫn minh chứng (ví dụ: giay_xac_nhan_y_te.pdf)"
            />
          </section>

          <!-- BƯỚC 4: CAM KẾT -->
          <section class="form-section">
            <label class="commitment-checkbox-label">
              <input type="checkbox" v-model="diemICommitment" class="checkbox-input" />
              <span>Tôi cam kết các thông tin khai báo trên là chính xác và sẽ chủ động liên hệ Giảng viên để hoàn thành đánh giá học phần theo đúng thời hạn quy định.</span>
            </label>
          </section>
        </div>

        <!-- Footer modal -->
        <div class="modal-large-footer">
          <button 
            type="button" 
            class="btn btn-outline" 
            @click="isDiemIModalOpen = false"
            :disabled="isSubmitting"
          >
            Hủy bỏ
          </button>

          <button 
            type="button" 
            class="btn btn-black btn-submit-app"
            @click="submitDiemIApplication"
            :disabled="isSubmitting || !selectedCourse"
          >
            <span v-if="isSubmitting" class="spinner-small"></span>
            <span>{{ isSubmitting ? 'Đang kích hoạt quy trình Flowable...' : 'Xác nhận Nộp Đơn Xin Điểm I' }}</span>
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const { $keycloak } = useNuxtApp()

// State người dùng
const user = ref({ name: '...' })
const studentId = ref('')
const toastMessage = ref('')

// State Modal Nộp đơn điểm I
const isDiemIModalOpen = ref(false)
const isLoadingCourses = ref(false)
const studentCourses = ref([])
const selectedCourse = ref(null)
const diemIReason = ref('')
const diemIAttachment = ref('')
const diemICommitment = ref(false)
const isSubmitting = ref(false)

// 2. Tải danh sách môn học của sinh viên từ app.dang_ky_mon
const fetchStudentCourses = async () => {
  if (!$keycloak.authenticated) return
  isLoadingCourses.value = true
  try {
    // Tải đồng thời danh sách môn học và danh sách hồ sơ sinh viên đã nộp
    const [coursesData, existingApps] = await Promise.all([
      $fetch('http://localhost:9080/api/postgrest/dang_ky_mon?select=id,ma_sv,ma_mon,hoc_ky,diem_so,diem_chu,trang_thai_dk,mon_hoc(ten_mon,so_tc,ma_cb_phu_trach,can_bo(ho_ten,ma_cb,don_vi))', {
        headers: { Authorization: `Bearer ${$keycloak.token}` }
      }),
      $fetch('http://localhost:9080/api/postgrest/ho_so?select=id,ma_hs,ma_dk,trang_thai,ma_loai', {
        headers: { Authorization: `Bearer ${$keycloak.token}` }
      })
    ])

    const appMap = new Map()
    if (Array.isArray(existingApps)) {
      existingApps.forEach(a => {
        if (a.ma_dk && a.ma_loai === 'XIN_DIEM_I') {
          appMap.set(Number(a.ma_dk), a)
        }
      })
    }

    if (Array.isArray(coursesData)) {
      studentCourses.value = coursesData.map(item => {
        const finalScore = item.diem_so !== null && item.diem_so !== undefined ? Number(item.diem_so) : null
        const existingApp = appMap.get(Number(item.id))
        const hasSubmitted = !!existingApp
        
        // Điều kiện đúng theo yêu cầu:
        // 1. Điểm < 8.0 (hoặc đang học chưa có điểm)
        // 2. Chưa có điểm I
        // 3. Mỗi môn học chỉ có 1 hồ sơ độc lập duy nhất (nếu đã nộp thì không được nộp lại)
        const isScoreEligible = (finalScore === null || finalScore < 8.0) && item.diem_chu !== 'I'
        const isEligible = isScoreEligible && !hasSubmitted

        return {
          id: item.id,
          code: item.ma_mon,
          name: item.mon_hoc?.ten_mon || item.ma_mon,
          credits: item.mon_hoc?.so_tc || 3,
          semester: item.hoc_ky,
          finalScore: finalScore,
          letterGrade: item.diem_chu,
          statusDk: item.trang_thai_dk,
          teacherName: item.mon_hoc?.can_bo?.ho_ten || 'Giảng viên bộ môn',
          teacherCode: item.mon_hoc?.can_bo?.ma_cb || item.mon_hoc?.ma_cb_phu_trach || 'CB001',
          faculty: item.mon_hoc?.can_bo?.don_vi || 'Khoa Công nghệ Thông tin & Truyền thông',
          hasSubmitted: hasSubmitted,
          submittedAppCode: existingApp?.ma_hs,
          submittedAppStatus: existingApp?.trang_thai,
          isEligible: isEligible
        }
      })
    }
  } catch (error) {
    console.error('Lỗi tải danh sách môn học:', error)
  } finally {
    isLoadingCourses.value = false
  }
}

// Mở modal nộp đơn xin điểm I
const openDiemIModal = async () => {
  selectedCourse.value = null
  diemIReason.value = ''
  diemIAttachment.value = ''
  diemICommitment.value = false
  isDiemIModalOpen.value = true
  await fetchStudentCourses()
}

// Gợi ý nhanh lý do
const applyReasonTemplate = (tpl) => {
  diemIReason.value = tpl
}

// Nộp đơn xin điểm I: Gọi PostgREST app.ho_so + Kích hoạt Flowable BPMN
const submitDiemIApplication = async () => {
  if (!selectedCourse.value) {
    alert('Vui lòng chọn môn học cần xin điểm I!')
    return
  }
  if (selectedCourse.value.hasSubmitted) {
    alert(`Môn "${selectedCourse.value.name}" (${selectedCourse.value.code}) đã có hồ sơ xin điểm I (Mã: ${selectedCourse.value.submittedAppCode || ''}, Trạng thái: ${selectedCourse.value.submittedAppStatus || ''}). Mỗi môn học chỉ được nộp 1 hồ sơ duy nhất!`)
    return
  }
  if (!diemIReason.value.trim()) {
    alert('Vui lòng nhập lý do xin điểm I!')
    return
  }
  if (!diemICommitment.value) {
    alert('Vui lòng tích chọn cam kết hoàn thành học phần!')
    return
  }

  isSubmitting.value = true
  try {
    // Kiểm tra an toàn trước khi nộp: Đảm bảo môn này chưa tồn tại hồ sơ trong CSDL
    const checkDuplicate = await $fetch(`http://localhost:9080/api/postgrest/ho_so?ma_dk=eq.${selectedCourse.value.id}&ma_loai=eq.XIN_DIEM_I`, {
      headers: { Authorization: `Bearer ${$keycloak.token}` }
    })
    if (checkDuplicate && checkDuplicate.length > 0) {
      alert(`Môn "${selectedCourse.value.name}" đã có hồ sơ xin điểm I trong hệ thống. Mỗi môn học chỉ có 1 hồ sơ độc lập!`)
      isSubmitting.value = false
      return
    }

    const randomSuffix = Math.floor(100000 + Math.random() * 900000)
    const newCode = `DIEMI-${randomSuffix}`

    // 1. Tạo bản ghi trong bảng app.ho_so
    const postgrestRes = await $fetch('http://localhost:9080/api/postgrest/ho_so', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${$keycloak.token}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: {
        ma_hs: newCode,
        ma_sv: studentId.value,
        ma_loai: 'XIN_DIEM_I',
        ma_dk: selectedCourse.value.id,
        hoc_ky: selectedCourse.value.semester,
        ly_do: diemIReason.value.trim(),
        trang_thai: 'Mới',
        ghi_chu: diemIAttachment.value.trim() ? `Minh chứng: ${diemIAttachment.value.trim()}` : null
      }
    })

    const createdRecord = Array.isArray(postgrestRes) ? postgrestRes[0] : postgrestRes
    const newHoSoId = createdRecord?.id || Date.now()

    // 2. Kích hoạt Flowable process instance qua APISIX Gateway
    const teacherId = selectedCourse.value.teacherCode || 'CB001'
    const deanId = 'TK_KTPM' // Trưởng khoa CNTT&TT
    const currentScore = selectedCourse.value.finalScore !== null ? Number(selectedCourse.value.finalScore) : 0.0

    try {
      await $fetch('http://localhost:9080/api/flowable/process-api/runtime/process-instances', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${$keycloak.token}`,
          'Content-Type': 'application/json'
        },
        body: {
          processDefinitionKey: 'quyTrinhDuyetDiemI_CNTT',
          variables: [
            { name: 'hoSoId', value: Number(newHoSoId) },
            { name: 'maDk', value: Number(selectedCourse.value.id) },
            { name: 'maSv', value: String(studentId.value) },
            { name: 'giangVienId', value: String(teacherId) },
            { name: 'truongKhoaId', value: String(deanId) },
            { name: 'diemHienTai', value: Number(currentScore) }
          ]
        }
      })
    } catch (flowErr) {
      console.warn('Thông báo kích hoạt Flowable:', flowErr)
    }

    // 3. Đóng modal & hiển thị Toast
    isDiemIModalOpen.value = false
    toastMessage.value = `Nộp đơn xin điểm I thành công! Mã hồ sơ: ${newCode}. Hồ sơ đã chuyển đến Giảng viên (${selectedCourse.value.teacherName}) để xét duyệt.`

    // 4. Chuyển hướng sang trang hồ sơ
    setTimeout(() => {
      navigateTo('/user/homepageuser?tab=records')
    }, 1500)
  } catch (err) {
    console.error('Lỗi gửi hồ sơ xin điểm I:', err)
    alert('Không thể nộp đơn: ' + (err.data?.message || err.message || 'Vui lòng thử lại.'))
  } finally {
    isSubmitting.value = false
  }
}


onMounted(async () => {
  if ($keycloak.authenticated) {
    const parsed = $keycloak.tokenParsed || {}
    const sub = parsed.sub
    studentId.value = parsed.preferred_username || 'B2100001'

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
  } else {
    navigateTo('/')
  }
})

const logout = () => $keycloak.logout({ redirectUri: window.location.origin })
const userInitial = computed(() => (user.value?.name || 'A').charAt(0).toUpperCase())
const currentDateString = computed(() => new Date().toLocaleDateString('vi-VN', { weekday: 'long', year: 'numeric', month: 'numeric', day: 'numeric' }))
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');
* { box-sizing: border-box; margin: 0; padding: 0; }
.dashboard-layout { display: flex; min-height: 100vh; background-color: #f8fafc; color: #0f172a; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
.sidebar { width: 260px; background-color: #ffffff; border-right: 1px solid #e2e8f0; display: flex; flex-direction: column; position: sticky; top: 0; height: 100vh; z-index: 20; }
.sidebar-header { padding: 24px 20px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #f1f5f9; }
.logo { font-size: 1.25rem; font-weight: 500; color: #000000; text-decoration: none; letter-spacing: -0.02em; }
.logo-bold { font-weight: 800; }
.portal-tag { font-size: 0.75rem; font-weight: 700; background-color: #f1f5f9; color: #475569; padding: 2px 8px; border-radius: 4px; letter-spacing: 0.04em; text-transform: uppercase; }
.sidebar-nav { flex: 1; padding: 16px 12px; display: flex; flex-direction: column; gap: 4px; overflow-y: auto; }
.nav-item { display: flex; align-items: center; gap: 12px; padding: 11px 14px; border-radius: 8px; background: transparent; border: none; color: #475569; font-size: 0.95rem; font-weight: 500; font-family: inherit; cursor: pointer; width: 100%; text-align: left; transition: all 0.15s ease; text-decoration: none; }
.nav-item:hover { background-color: #f1f5f9; color: #000000; }
.nav-item.active { background-color: #000000; color: #ffffff; }
.nav-icon { flex-shrink: 0; }
.nav-label { flex: 1; }
.nav-badge { font-size: 0.72rem; font-weight: 700; background-color: #f1f5f9; color: #334155; padding: 2px 7px; border-radius: 10px; }
.nav-item.active .nav-badge { background-color: #334155; color: #ffffff; }
.pulse-badge { background-color: #ecfdf5; color: #059669; border: 1px solid #a7f3d0; font-weight: 700; }
.sidebar-user { padding: 16px; border-top: 1px solid #f1f5f9; display: flex; align-items: center; gap: 12px; background-color: #ffffff; }
.user-profile-click { display: flex; align-items: center; gap: 12px; flex: 1; min-width: 0; text-decoration: none; cursor: pointer; transition: opacity 0.15s ease; }
.user-profile-click:hover { opacity: 0.8; }
.user-avatar { width: 38px; height: 38px; border-radius: 50%; background-color: #000000; color: #ffffff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.95rem; }
.user-info { flex: 1; min-width: 0; }
.user-name { font-size: 0.9rem; font-weight: 600; color: #0f172a; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.user-role { font-size: 0.75rem; color: #64748b; }
.btn-logout { background: transparent; border: none; color: #94a3b8; cursor: pointer; padding: 6px; border-radius: 6px; transition: color 0.15s, background-color 0.15s; }
.btn-logout:hover { background-color: #fef2f2; color: #ef4444; }
.main-content { flex: 1; padding: 32px 40px; max-width: 1280px; }
.content-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid #e2e8f0; }
.breadcrumb { display: flex; align-items: center; gap: 8px; font-size: 0.9rem; }
.breadcrumb-link { color: #64748b; text-decoration: none; font-weight: 500; }
.breadcrumb-link:hover { color: #000000; }
.breadcrumb-separator { color: #cbd5e1; }
.breadcrumb-current { color: #0f172a; font-weight: 600; }
.header-right { display: flex; align-items: center; gap: 20px; font-size: 0.85rem; color: #64748b; }
.status-indicator { display: flex; align-items: center; gap: 6px; }
.status-dot { width: 8px; height: 8px; border-radius: 50%; background-color: #22c55e; box-shadow: 0 0 8px #22c55e; }
.toast-alert { display: flex; align-items: center; gap: 12px; background-color: #064e3b; color: #ecfdf5; padding: 14px 20px; border-radius: 8px; margin-bottom: 24px; font-size: 0.92rem; font-weight: 500; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); }
.toast-close { background: none; border: none; color: #a7f3d0; font-size: 1.4rem; cursor: pointer; margin-left: auto; line-height: 1; }

.catalog-header-banner { display: flex; align-items: flex-start; justify-content: space-between; gap: 20px; margin-bottom: 28px; }
.catalog-title { font-size: 1.85rem; font-weight: 800; color: #000000; letter-spacing: -0.025em; margin-bottom: 6px; }
.catalog-subtitle { font-size: 0.95rem; color: #64748b; max-width: 760px; line-height: 1.5; }
.doc-types-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(360px, 520px)); gap: 24px; }
.doc-type-card { background-color: #ffffff; border: 1.5px solid #e2e8f0; border-radius: 12px; padding: 24px; display: flex; flex-direction: column; justify-content: space-between; cursor: pointer; transition: all 0.2s ease; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02); }
.doc-type-card:hover { border-color: #000000; transform: translateY(-3px); box-shadow: 0 12px 24px -6px rgba(0, 0, 0, 0.08); }
.featured-card { border: 2px solid #000000; background: linear-gradient(180deg, #ffffff 0%, #fafafa 100%); }
.card-top-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
.badge-flowable { display: inline-flex; align-items: center; gap: 6px; font-size: 0.72rem; font-weight: 700; background-color: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; padding: 3px 10px; border-radius: 20px; text-transform: uppercase; }
.pulse-dot { width: 6px; height: 6px; border-radius: 50%; background-color: #10b981; }
.badge-regular { font-size: 0.72rem; font-weight: 600; background-color: #f1f5f9; color: #475569; padding: 3px 8px; border-radius: 20px; }
.badge-code { font-size: 0.75rem; color: #94a3b8; }
.card-icon-title { display: flex; align-items: center; gap: 14px; margin-bottom: 14px; }
.type-icon-box { width: 44px; height: 44px; border-radius: 10px; background-color: #f1f5f9; color: #0f172a; display: flex; align-items: center; justify-content: center; }
.gold-icon { background-color: #000000; color: #fbbf24; }
.type-title { font-size: 1.2rem; font-weight: 700; color: #000000; }
.type-category { font-size: 0.8rem; color: #64748b; }
.type-description { font-size: 0.9rem; color: #475569; line-height: 1.55; margin-bottom: 18px; flex: 1; }
.card-workflow-preview { background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 12px; display: flex; align-items: center; justify-content: space-between; font-size: 0.76rem; font-weight: 600; color: #475569; margin-bottom: 20px; flex-wrap: wrap; gap: 4px; }
.wf-arrow { color: #94a3b8; }
.highlight-step { color: #d97706; font-weight: 700; }
.card-action-bar { margin-top: auto; }
.btn-block { width: 100%; display: flex; align-items: center; justify-content: center; gap: 8px; }
.btn-black { background-color: #000000; color: #ffffff; border: none; padding: 10px 18px; border-radius: 6px; font-weight: 600; cursor: pointer; font-size: 0.9rem; transition: opacity 0.15s ease; text-decoration: none; }
.btn-black:hover:not(:disabled) { opacity: 0.9; }
.btn-black:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-outline { background: transparent; border: 1.5px solid #cbd5e1; padding: 8px 16px; border-radius: 6px; cursor: pointer; font-weight: 600; font-size: 0.9rem; color: #0f172a; text-decoration: none; transition: all 0.15s ease; }
.btn-outline:hover { border-color: #000000; }
.font-mono { font-family: monospace; }
.font-bold { font-weight: 700; }

/* MODAL NỘP ĐƠN */
.modal-overlay { position: fixed; inset: 0; background-color: rgba(0, 0, 0, 0.55); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 60; padding: 20px; }
.modal-box-large { background-color: #ffffff; border-radius: 14px; max-width: 820px; width: 100%; max-height: 92vh; display: flex; flex-direction: column; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); overflow: hidden; border: 1px solid #e2e8f0; }
.modal-large-header { padding: 20px 28px; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: space-between; background-color: #f8fafc; }
.modal-header-icon-title { display: flex; align-items: center; gap: 14px; }
.modal-icon-badge { width: 44px; height: 44px; border-radius: 10px; background-color: #000000; color: #fbbf24; display: flex; align-items: center; justify-content: center; }
.modal-main-title { font-size: 1.25rem; font-weight: 800; color: #000000; letter-spacing: -0.02em; }
.modal-sub-title { font-size: 0.82rem; color: #64748b; margin-top: 2px; }
.btn-close-modal { background: none; border: none; font-size: 1.8rem; line-height: 1; color: #94a3b8; cursor: pointer; transition: color 0.15s ease; }
.btn-close-modal:hover { color: #000000; }
.modal-large-body { padding: 24px 28px; overflow-y: auto; flex: 1; display: flex; flex-direction: column; gap: 24px; }
.rule-alert-banner { display: flex; align-items: flex-start; gap: 12px; background-color: #fffbeb; border: 1px solid #fef3c7; border-left: 4px solid #f59e0b; padding: 12px 16px; border-radius: 6px; }
.rule-icon { color: #d97706; flex-shrink: 0; margin-top: 2px; }
.rule-text { font-size: 0.88rem; color: #78350f; line-height: 1.5; }
.form-section { display: flex; flex-direction: column; gap: 10px; }
.section-label-row { display: flex; align-items: center; gap: 8px; }
.step-num { width: 22px; height: 22px; border-radius: 50%; background-color: #000000; color: #ffffff; font-size: 0.75rem; font-weight: 700; display: flex; align-items: center; justify-content: center; }
.form-label { font-size: 0.92rem; color: #0f172a; }
.required-star { color: #ef4444; }
.loading-box { display: flex; align-items: center; gap: 12px; padding: 24px; justify-content: center; color: #64748b; font-size: 0.9rem; }
.spinner { width: 20px; height: 20px; border: 2px solid #e2e8f0; border-top-color: #000000; border-radius: 50%; animation: spin 0.8s linear infinite; }
.spinner-small { width: 14px; height: 14px; border: 2px solid rgba(255, 255, 255, 0.4); border-top-color: #ffffff; border-radius: 50%; animation: spin 0.8s linear infinite; display: inline-block; }
@keyframes spin { to { transform: rotate(360deg); } }

/* CHỌN MÔN HỌC */
.courses-selector-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(230px, 1fr)); gap: 12px; max-height: 260px; overflow-y: auto; padding: 4px; }
.course-select-card { border: 1.5px solid #e2e8f0; border-radius: 8px; padding: 12px 14px; cursor: pointer; transition: all 0.15s ease; background-color: #ffffff; display: flex; flex-direction: column; gap: 6px; }
.course-select-card:hover:not(.disabled-card) { border-color: #000000; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05); }
.course-select-card.selected { border-color: #000000; background-color: #f8fafc; box-shadow: 0 0 0 2px #000000; }
.course-select-card.disabled-card { opacity: 0.55; cursor: not-allowed; background-color: #f8fafc; border-style: dashed; }
.course-card-head { display: flex; align-items: center; justify-content: space-between; }
.course-code { font-size: 0.82rem; font-weight: 700; color: #000000; }
.course-sem { font-size: 0.72rem; color: #64748b; }
.course-card-name { font-size: 0.9rem; font-weight: 600; color: #0f172a; line-height: 1.3; }
.course-card-teacher { font-size: 0.78rem; color: #475569; display: flex; align-items: center; gap: 4px; }
.course-card-foot { display: flex; align-items: center; justify-content: space-between; padding-top: 6px; border-top: 1px solid #f1f5f9; margin-top: 4px; }
.score-indicator { font-size: 0.78rem; font-weight: 600; }
.eligibility-tag { font-size: 0.7rem; font-weight: 700; padding: 2px 6px; border-radius: 4px; }
.tag-ok { background-color: #dcfce7; color: #15803d; }
.tag-not-ok { background-color: #fee2e2; color: #b91c1c; }
.tag-has-submitted { background-color: #fef3c7; color: #b45309; border: 1px solid #fde68a; }
.course-select-card.already-submitted-card { border-color: #fcd34d; background-color: #fffdf5; opacity: 0.75; }
.empty-courses { grid-column: 1 / -1; text-align: center; padding: 20px; color: #94a3b8; font-style: italic; }

/* TÓM TẮT MÔN ĐƯỢC CHỌN */
.selected-summary-box { background-color: #f0fdf4; border: 1.5px solid #86efac; border-radius: 8px; padding: 14px 18px; margin-top: 6px; }
.summary-head { display: flex; align-items: center; gap: 8px; font-size: 0.92rem; color: #166534; margin-bottom: 10px; }
.check-icon { width: 18px; height: 18px; border-radius: 50%; background-color: #16a34a; color: #ffffff; display: flex; align-items: center; justify-content: center; font-size: 0.75rem; font-weight: 800; }
.approval-route-grid { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; font-size: 0.84rem; background-color: #ffffff; padding: 10px 14px; border-radius: 6px; border: 1px solid #bbf7d0; }
.route-item { display: flex; flex-direction: column; gap: 2px; }
.route-role { font-size: 0.74rem; font-weight: 700; color: #059669; text-transform: uppercase; }
.route-name { font-weight: 600; color: #0f172a; }
.route-arrow { color: #16a34a; font-weight: bold; font-size: 1.1rem; }

/* REASON TEMPLATES & FORM */
.reason-templates { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; margin-bottom: 4px; }
.tpl-label { font-size: 0.8rem; color: #64748b; }
.tpl-btn { background-color: #f1f5f9; border: 1px solid #e2e8f0; color: #334155; font-size: 0.78rem; font-weight: 500; padding: 4px 10px; border-radius: 14px; cursor: pointer; transition: all 0.15s ease; font-family: inherit; }
.tpl-btn:hover { background-color: #000000; color: #ffffff; border-color: #000000; }
.form-textarea { width: 100%; border: 1.5px solid #cbd5e1; border-radius: 8px; padding: 10px 14px; font-family: inherit; font-size: 0.92rem; color: #0f172a; resize: vertical; outline: none; transition: border-color 0.15s ease; }
.form-textarea:focus { border-color: #000000; }
.form-input { width: 100%; border: 1.5px solid #cbd5e1; border-radius: 8px; padding: 10px 14px; font-family: inherit; font-size: 0.92rem; color: #0f172a; outline: none; transition: border-color 0.15s ease; }
.form-input:focus { border-color: #000000; }
.commitment-checkbox-label { display: flex; align-items: flex-start; gap: 10px; font-size: 0.86rem; color: #475569; line-height: 1.45; cursor: pointer; background-color: #f8fafc; padding: 12px 14px; border-radius: 8px; border: 1px solid #e2e8f0; }
.checkbox-input { margin-top: 3px; cursor: pointer; }
.modal-large-footer { padding: 18px 28px; border-top: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: flex-end; gap: 12px; background-color: #f8fafc; }
.btn-submit-app { display: inline-flex; align-items: center; gap: 8px; }

/* MODAL DIALOG */
.modal-box { background-color: #ffffff; padding: 28px; border-radius: 12px; max-width: 480px; width: 90%; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); }
.modal-box h3 { font-size: 1.25rem; font-weight: 700; margin-bottom: 12px; color: #000000; }
.modal-box p { color: #64748b; line-height: 1.5; margin-bottom: 24px; }
.modal-actions { display: flex; justify-content: flex-end; gap: 12px; }

/* ANIMATIONS */
.animate-fade-in { animation: fadeIn 0.25s ease-out; }
.animate-slide-up { animation: slideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1); }
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
@keyframes slideUp { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }

@media (max-width: 992px) {
  .doc-types-grid { grid-template-columns: 1fr; }
  .sidebar { width: 220px; }
}
@media (max-width: 768px) {
  .dashboard-layout { flex-direction: column; }
  .sidebar { width: 100%; height: auto; position: relative; }
  .main-content { padding: 20px; }
  .modal-box-large { width: 95%; max-height: 95vh; }
  .modal-large-header, .modal-large-body, .modal-large-footer { padding: 16px; }
}
</style>
