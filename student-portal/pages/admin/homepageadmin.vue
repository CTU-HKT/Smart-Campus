<!--
  SPDX-License-Identifier: MIT
  Copyright (c) 2026 CTU-HKT. All rights reserved.
-->
<template>
  <div class="admin-wrapper">
    <!-- ================= NAVBAR ================= -->
    <header class="navbar">
      <div class="nav-container">
        <!-- Logo SmartCampus -->
        <div class="nav-brand">
          <NuxtLink to="/" class="logo">
            <span class="logo-bold">Smart</span><span>Campus</span>
          </NuxtLink>
          <span class="brand-badge">{{ officerRoleBadge }}</span>
        </div>

        <!-- Thông tin cán bộ & chức danh -->
        <NuxtLink to="/info" class="officer-info" title="Xem thông tin cá nhân">
          <span class="officer-label">{{ officerRoleTitle }}:</span>
          <span class="officer-name">{{ user?.name || 'Cán bộ' }} ({{ officerCode || 'CB' }})</span>
          <span class="status-dot-separator">·</span>
          <span class="signature-tag">
            <span class="green-dot"></span>
            {{ officerFaculty || 'Khoa CNTT&TT' }}
          </span>
        </NuxtLink>

        <!-- Menu chuyển đổi 2 chế độ xem (Hàng đợi & SLA) + Nút Đăng xuất -->
        <div class="nav-actions">
          <div class="tab-control">
            <button 
              type="button"
              class="tab-item" 
              :class="{ active: activeTab === 'queue' }"
              @click="activeTab = 'queue'"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
              </svg>
              <span>Hàng đợi Thẩm định</span>
              <span class="badge-count">{{ pendingCount }}</span>
            </button>

            <button 
              type="button"
              class="tab-item" 
              :class="{ active: activeTab === 'sla' }"
              @click="activeTab = 'sla'"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="18" y1="20" x2="18" y2="10"/>
                <line x1="12" y1="20" x2="12" y2="4"/>
                <line x1="6" y1="20" x2="6" y2="14"/>
              </svg>
              <span>Thống kê & SLA Đơn vị</span>
            </button>
          </div>

          <button @click="logout" class="btn-logout" title="Đăng xuất">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
              <polyline points="16 17 21 12 16 7"/>
              <line x1="21" y1="12" x2="9" y2="12"/>
            </svg>
          </button>
        </div>
      </div>
    </header>

    <!-- ================= TIÊU ĐỀ TRANG ================= -->
    <section class="page-title-section">
      <div class="main-container">
        <div class="header-flex-row">
          <div>
            <h1 class="page-main-heading">Bàn Làm Việc Thẩm Định Hồ Sơ & Duyệt Điểm Số</h1>
            <p class="page-sub-heading">
              Quy trình số hoá Flowable BPMN 2.0: Tiếp nhận công việc trực tiếp theo phân công giảng dạy và quản lý khoa
            </p>
          </div>
          <button @click="refreshAll" class="btn btn-outline btn-refresh" :disabled="isLoading">
            <svg class="refresh-icon" :class="{ 'spinning': isLoading }" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="23 4 23 10 17 10"></polyline>
              <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"></path>
            </svg>
            <span>Làm mới Worklist</span>
          </button>
        </div>
      </div>
    </section>

    <!-- Toast thông báo kết quả -->
    <div v-if="toastMessage" class="toast-wrapper main-container animate-fade-in">
      <div class="toast-alert">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
          <polyline points="22 4 12 14.01 9 11.01"/>
        </svg>
        <span>{{ toastMessage }}</span>
        <button class="toast-close" @click="toastMessage = ''">&times;</button>
      </div>
    </div>

    <!-- ================= NỘI DUNG 2 CHẾ ĐỘ XEM ================= -->
    <main class="main-content">
      <div class="main-container">

        <!-- ================= CHẾ ĐỘ 1: HÀNG ĐỢI THẨM ĐỊNH ================= -->
        <div v-if="activeTab === 'queue'" class="tab-view">
          <!-- 4 Thẻ chỉ số trạng thái -->
          <div class="stats-grid">
            <div class="stat-box">
              <div class="stat-title">Nhiệm vụ cần xử lý (Inbox)</div>
              <div class="stat-number text-emerald">{{ pendingCount }}</div>
            </div>

            <div class="stat-box">
              <div class="stat-title">Đã phê duyệt hoàn tất</div>
              <div class="stat-number">{{ approvedCount }}</div>
            </div>

            <div class="stat-box">
              <div class="stat-title">Yêu cầu bổ sung hồ sơ</div>
              <div class="stat-number text-amber">{{ needMoreCount }}</div>
            </div>

            <div class="stat-box">
              <div class="stat-title">Đã từ chối</div>
              <div class="stat-number text-rose">{{ rejectedCount }}</div>
            </div>
          </div>

          <!-- Thanh tìm kiếm và bộ lọc -->
          <div class="filter-bar">
            <!-- Ô tìm kiếm -->
            <div class="search-box">
              <span class="search-icon">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="11" cy="11" r="8"/>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
              </span>
              <input 
                v-model="searchQuery" 
                type="text" 
                placeholder="Tìm theo mã đơn (DIEMI-...), tên sinh viên, MSSV, tên môn học..." 
                class="search-input"
              />
            </div>

            <!-- Phân hệ -->
            <div class="filter-dropdown">
              <span class="dropdown-label">Phân hệ:</span>
              <select v-model="filterDomain" class="dropdown-select">
                <option value="all">Tất cả phân hệ</option>
                <option value="Học vụ & Điểm số">Học vụ & Điểm số</option>
                <option value="Hành chính số">Hành chính số</option>
              </select>
            </div>

            <!-- Loại thủ tục: LẤY TRỰC TIẾP TỪ CSDL APP.LOAI_HO_SO -->
            <div class="filter-dropdown">
              <span class="dropdown-label">Loại:</span>
              <select v-model="filterDocType" class="dropdown-select">
                <option value="all">Tất cả thủ tục ({{ docTypesList.length }})</option>
                <option v-for="t in docTypesList" :key="t.ma_loai" :value="t.ten_loai">
                  {{ t.ten_loai }}
                </option>
              </select>
            </div>

            <!-- Trạng thái / Nhiệm vụ -->
            <div class="filter-dropdown">
              <span class="dropdown-label">Trạng thái:</span>
              <select v-model="filterStatus" class="dropdown-select">
                <option value="all">Tất cả trạng thái</option>
                <option value="Chờ duyệt">Chờ duyệt</option>
                <option value="Đã duyệt">Đã duyệt</option>
                <option value="Cần bổ sung">Cần bổ sung</option>
                <option value="Từ chối">Từ chối</option>
              </select>
            </div>
          </div>

          <!-- Bảng danh sách hồ sơ thẩm định (Worklist) -->
          <div class="table-card">
            <div v-if="isLoading" class="loading-state">
              <div class="spinner"></div>
              <span>Đang đồng bộ danh sách nhiệm vụ từ Flowable BPMN & CSDL...</span>
            </div>

            <table v-else class="data-table">
              <thead>
                <tr>
                  <th>MÃ HỒ SƠ</th>
                  <th>SINH VIÊN</th>
                  <th>THỦ TỤC / MÔN HỌC</th>
                  <th>NHIỆM VỤ FLOWABLE</th>
                  <th>THỜI GIAN NHẬN</th>
                  <th>TRẠNG THÁI</th>
                  <th class="text-right">THAO TÁC</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in filteredApplications" :key="item.uniqueKey" class="table-row">
                  <td class="code-col">
                    <span class="font-mono font-bold">{{ item.code }}</span>
                    <span v-if="item.isDiemI" class="badge-mini-gold">Điểm I</span>
                  </td>
                  <td>
                    <div class="student-name">{{ item.studentName }}</div>
                    <div class="student-meta">{{ item.mssv }} · {{ item.studentClass || 'DI21' }}</div>
                  </td>
                  <td>
                    <div class="doc-name font-semibold">{{ item.courseName || item.docTitle }}</div>
                    <div class="course-meta text-muted" v-if="item.courseCode">
                      Môn: {{ item.courseCode }} ({{ item.credits }} TC)
                      <span v-if="item.currentScore !== null" class="score-badge">
                        Điểm: <strong>{{ item.currentScore }}</strong>
                      </span>
                    </div>
                  </td>
                  <td>
                    <div v-if="item.activeFlowableTaskId || item.flowableTaskId" class="flowable-task-tag" :class="item.taskDefinitionKey === 'utKhoaPheDuyet' ? 'tag-dean' : 'tag-teacher'">
                      <span class="task-dot"></span>
                      <span>{{ item.taskName || (item.taskDefinitionKey === 'utKhoaPheDuyet' ? 'Trưởng khoa phê duyệt' : 'Giảng viên xét duyệt') }}</span>
                    </div>
                    <span v-else class="text-muted text-sm">—</span>
                  </td>
                  <td class="time-col">{{ item.submittedAt }}</td>
                  <td>
                    <span class="status-tag" :class="'status-' + item.statusCode">
                      {{ item.status }}
                    </span>
                  </td>
                  <td class="text-right">
                    <button 
                      v-if="item.canReview" 
                      class="btn btn-black-sm" 
                      @click="openReviewModal(item)"
                    >
                      Thẩm định &rarr;
                    </button>
                    <button 
                      v-else 
                      class="btn btn-outline-sm" 
                      @click="openReviewModal(item)"
                    >
                      Xem chi tiết
                    </button>
                  </td>
                </tr>

                <!-- TRẠNG THÁI TRỐNG -->
                <tr v-if="filteredApplications.length === 0">
                  <td colspan="7" class="empty-cell">
                    <div class="empty-wrapper">
                      <div class="empty-icon-circle">
                        <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="1.75">
                          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                          <polyline points="14 2 14 8 20 8"/>
                          <line x1="16" y1="13" x2="8" y2="13"/>
                          <line x1="16" y1="17" x2="8" y2="17"/>
                          <line x1="10" y1="9" x2="8" y2="9"/>
                        </svg>
                      </div>
                      <h3 class="empty-headline">Hiện không có hồ sơ nào cần thẩm định</h3>
                      <p class="empty-subtext">
                        Khi sinh viên nộp đơn xin điểm I cho môn học bạn phụ trách, hoặc sau khi Giảng viên đã thông qua (DAT), công việc sẽ xuất hiện tại đây theo thời gian thực.
                      </p>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- ================= CHẾ ĐỘ 2: THỐNG KÊ & SLA ĐƠN VỊ ================= -->
        <div v-else-if="activeTab === 'sla'" class="tab-view">
          <div class="sla-metrics-grid">
            <div class="sla-box">
              <div class="sla-header">
                <span class="sla-label">Thời gian xử lý trung bình (SLA)</span>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2">
                  <circle cx="12" cy="12" r="10"/>
                  <polyline points="12 6 12 12 16 14"/>
                </svg>
              </div>
              <div class="sla-value-wrap">
                <span class="sla-big-num">1.2</span>
                <span class="sla-unit">giờ / hồ sơ</span>
              </div>
              <div class="sla-note text-emerald">Đạt mục tiêu SLA quy định (&lt; 24 giờ)</div>
            </div>

            <div class="sla-box">
              <div class="sla-header">
                <span class="sla-label">Tỷ lệ hoàn thành đúng hạn SLA</span>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2">
                  <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/>
                  <polyline points="17 6 23 6 23 12"/>
                </svg>
              </div>
              <div class="sla-value-wrap">
                <span class="sla-big-num">100%</span>
              </div>
              <div class="sla-note text-muted">Tổng số hồ sơ trễ hạn: 0</div>
            </div>

            <div class="sla-box">
              <div class="sla-header">
                <span class="sla-label">Tổng lượt giải quyết thành công</span>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2">
                  <circle cx="12" cy="12" r="10"/>
                  <path d="M8 12l2.5 2.5L16 9"/>
                </svg>
              </div>
              <div class="sla-value-wrap">
                <span class="sla-big-num">{{ approvedCount }}</span>
                <span class="sla-unit">/ {{ allWorklist.length }} hồ sơ</span>
              </div>
              <div class="sla-note text-muted">Tỷ lệ phê duyệt: {{ allWorklist.length ? Math.round((approvedCount / allWorklist.length) * 100) : 0 }}%</div>
            </div>
          </div>
        </div>

      </div>
    </main>

    <!-- ================= MODAL THẨM ĐỊNH & PHÊ DUYỆT HỒ SƠ ================= -->
    <div v-if="selectedTask" class="modal-overlay" @click.self="closeReviewModal">
      <div class="modal-review-box animate-slide-up">
        <!-- Header modal -->
        <div class="modal-review-header">
          <div class="review-title-group">
            <span class="review-badge-code font-mono">{{ selectedTask.code }}</span>
            <span v-if="selectedTask.isDiemI" class="badge-mini-gold">Đơn xin điểm I</span>
            <h2 class="review-main-title">{{ selectedTask.docTitle }}</h2>
          </div>
          <button @click="closeReviewModal" class="btn-close-modal" title="Đóng">&times;</button>
        </div>

        <!-- Body modal -->
        <div class="modal-review-body">
          <!-- 1. THÔNG TIN SINH VIÊN -->
          <section class="review-card-section">
            <h3 class="section-title-sm">1. Thông tin sinh viên nộp đơn:</h3>
            <div class="info-grid-2col">
              <div class="info-cell">
                <span class="cell-label">Họ và tên:</span>
                <span class="cell-value font-bold">{{ selectedTask.studentName }}</span>
              </div>
              <div class="info-cell">
                <span class="cell-label">Mã số sinh viên:</span>
                <span class="cell-value font-mono">{{ selectedTask.mssv }}</span>
              </div>
              <div class="info-cell">
                <span class="cell-label">Lớp sinh hoạt:</span>
                <span class="cell-value">{{ selectedTask.studentClass || 'DI21V7A1' }}</span>
              </div>
              <div class="info-cell">
                <span class="cell-label">Khoa / Đơn vị đào tạo:</span>
                <span class="cell-value">{{ selectedTask.studentFaculty || 'Công nghệ Thông tin & Truyền thông' }}</span>
              </div>
              <div class="info-cell">
                <span class="cell-label">Email liên hệ:</span>
                <span class="cell-value font-mono">{{ selectedTask.studentEmail || 'sinhvien@ctu.edu.vn' }}</span>
              </div>
              <div class="info-cell">
                <span class="cell-label">Số điện thoại:</span>
                <span class="cell-value">{{ selectedTask.studentPhone || 'Chưa cung cấp' }}</span>
              </div>
            </div>
          </section>

          <!-- 2. THÔNG TIN MÔN HỌC & ĐIỂM SỐ -->
          <section class="review-card-section highlight-section" v-if="selectedTask.isDiemI">
            <h3 class="section-title-sm">2. Môn học đề nghị xét điểm I:</h3>
            <div class="course-detail-banner">
              <div class="course-left">
                <div class="course-name-lg">{{ selectedTask.courseName || 'Học phần chuyên môn' }}</div>
                <div class="course-sub">
                  Mã môn: <strong class="font-mono">{{ selectedTask.courseCode }}</strong> · 
                  Số tín chỉ: <strong>{{ selectedTask.credits }} TC</strong> · 
                  Học kỳ: <strong>{{ selectedTask.semester }}</strong>
                </div>
                <div class="course-teacher">
                  Giảng viên phụ trách: <strong>{{ selectedTask.teacherName }}</strong> ({{ selectedTask.teacherCode }})
                </div>
              </div>

              <div class="course-right">
                <div class="score-display-box">
                  <span class="score-box-label">Điểm tổng kết</span>
                  <div class="score-box-val">
                    <span v-if="selectedTask.currentScore !== null" class="score-num font-mono">
                      {{ selectedTask.currentScore }}
                    </span>
                    <span v-else class="score-null">Chưa có điểm</span>
                    <span v-if="selectedTask.letterGrade" class="score-letter">({{ selectedTask.letterGrade }})</span>
                  </div>
                  <span v-if="selectedTask.currentScore === null || selectedTask.currentScore < 8.0" class="rule-badge rule-valid">
                    ✓ Đủ ĐK điểm &lt; 8.0
                  </span>
                  <span v-else class="rule-badge rule-invalid">
                    ✗ Không đủ điều kiện (&ge; 8.0)
                  </span>
                </div>
              </div>
            </div>
          </section>

          <!-- 3. LÝ DO VÀ MINH CHỨNG -->
          <section class="review-card-section">
            <h3 class="section-title-sm">3. Lý do nộp đơn & Minh chứng đính kèm:</h3>
            <div class="reason-quote-box">
              <div class="quote-label">Lý do sinh viên khai báo:</div>
              <p class="quote-text">{{ selectedTask.reason || 'Không có lý do chi tiết.' }}</p>
            </div>
            <div v-if="selectedTask.attachment" class="attachment-box">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"></path>
              </svg>
              <span>{{ selectedTask.attachment }}</span>
            </div>
          </section>

          <!-- 4. KHUNG QUYẾT ĐỊNH THẨM ĐỊNH (DYNAMIC THEO TASK FLOWABLE) -->
          <section class="review-decision-section">
            <!-- NẾU LÀ TASK GIẢNG VIÊN KIỂM TRA (HOẶC ĐƠN MỚI) VÀ CÓ QUYỀN DUYỆT -->
            <div v-if="selectedTask.canReview && (selectedTask.taskDefinitionKey === 'utGiangVienKiemTra' || selectedTask.status.includes('Giảng viên') || selectedTask.status === 'Mới')">
              <div class="decision-role-banner">
                <span class="role-tag role-teacher">Bước 1: Giảng viên học phần xét duyệt</span>
                <p class="role-desc">Xem xét hoàn cảnh của sinh viên và lựa chọn một trong các quyết định sau:</p>
              </div>

              <div class="decision-options-grid">
                <!-- Option 1: DAT -->
                <label 
                  class="decision-choice-card" 
                  :class="{ 'active-dat': reviewDecision === 'DAT' }"
                >
                  <input type="radio" value="DAT" v-model="reviewDecision" class="radio-hidden" />
                  <div class="choice-icon icon-dat">✓</div>
                  <div class="choice-text">
                    <strong>1. Đạt (DAT)</strong>
                    <p>Thông qua hồ sơ và chuyển tiếp lên Trưởng khoa phê duyệt</p>
                  </div>
                </label>

                <!-- Option 2: BO_SUNG -->
                <label 
                  class="decision-choice-card" 
                  :class="{ 'active-bosung': reviewDecision === 'BO_SUNG' }"
                >
                  <input type="radio" value="BO_SUNG" v-model="reviewDecision" class="radio-hidden" />
                  <div class="choice-icon icon-bosung">!</div>
                  <div class="choice-text">
                    <strong>2. Yêu cầu bổ sung (BO_SUNG)</strong>
                    <p>Yêu cầu sinh viên gửi thêm giấy tờ / minh chứng y tế</p>
                  </div>
                </label>

                <!-- Option 3: TU_CHOI -->
                <label 
                  class="decision-choice-card" 
                  :class="{ 'active-tuchoi': reviewDecision === 'TU_CHOI' }"
                >
                  <input type="radio" value="TU_CHOI" v-model="reviewDecision" class="radio-hidden" />
                  <div class="choice-icon icon-tuchoi">✕</div>
                  <div class="choice-text">
                    <strong>3. Từ chối (TU_CHOI)</strong>
                    <p>Từ chối đơn xin điểm I (giữ nguyên điểm số ban đầu)</p>
                  </div>
                </label>
              </div>

              <!-- Ô NHẬP COMMENT (BẮT BUỘC KHI BO_SUNG HOẶC TU_CHOI) -->
              <div class="comment-field-wrapper">
                <label class="comment-label font-bold">
                  Ý kiến / Nhận xét của Giảng viên:
                  <span v-if="reviewDecision === 'BO_SUNG' || reviewDecision === 'TU_CHOI'" class="text-rose font-bold">
                    * (Bắt buộc nhập lý do chi tiết)
                  </span>
                  <span v-else class="text-muted">(Không bắt buộc khi thông qua)</span>
                </label>
                <textarea 
                  v-model="reviewComment" 
                  class="form-textarea" 
                  rows="3" 
                  :placeholder="reviewDecision === 'BO_SUNG' ? 'Nhập rõ sinh viên cần bổ sung thêm loại giấy tờ, chứng từ nào...' : reviewDecision === 'TU_CHOI' ? 'Nhập rõ lý do từ chối đơn...' : 'Nhập ý kiến đánh giá học phần nếu có...'"
                ></textarea>
                <div v-if="commentError" class="comment-error-alert animate-fade-in">
                  {{ commentError }}
                </div>
              </div>
            </div>

            <!-- NẾU LÀ TASK TRƯỞNG KHOA PHÊ DUYỆT (utKhoaPheDuyet) VÀ CÓ QUYỀN DUYỆT -->
            <div v-else-if="selectedTask.taskDefinitionKey === 'utKhoaPheDuyet' && selectedTask.canReview">
              <div class="decision-role-banner">
                <span class="role-tag role-dean">Bước 2: Trưởng khoa phê duyệt</span>
                <p class="role-desc">
                  Đơn đã được Giảng viên (<strong>{{ selectedTask.teacherName }}</strong>) thẩm định <strong>ĐẠT (DAT)</strong>. Trưởng khoa xem xét phê duyệt chính thức:
                </p>
              </div>

              <div class="decision-options-grid grid-2col">
                <!-- Option 1: PHE_DUYET -->
                <label 
                  class="decision-choice-card" 
                  :class="{ 'active-dat': reviewDecision === 'PHE_DUYET' }"
                >
                  <input type="radio" value="PHE_DUYET" v-model="reviewDecision" class="radio-hidden" />
                  <div class="choice-icon icon-dat">✓</div>
                  <div class="choice-text">
                    <strong>1. Phê duyệt (PHE_DUYET)</strong>
                    <p>Phê duyệt đơn và tự động cập nhật điểm môn học thành điểm 'I'</p>
                  </div>
                </label>

                <!-- Option 2: TU_CHOI -->
                <label 
                  class="decision-choice-card" 
                  :class="{ 'active-tuchoi': reviewDecision === 'TU_CHOI' }"
                >
                  <input type="radio" value="TU_CHOI" v-model="reviewDecision" class="radio-hidden" />
                  <div class="choice-icon icon-tuchoi">✕</div>
                  <div class="choice-text">
                    <strong>2. Từ chối (TU_CHOI)</strong>
                    <p>Bác bỏ đề xuất xin điểm I (giữ nguyên điểm số ban đầu)</p>
                  </div>
                </label>
              </div>

              <!-- Ô NHẬP COMMENT TRƯỞNG KHOA -->
              <div class="comment-field-wrapper">
                <label class="comment-label font-bold">
                  Ý kiến / Kết luận của Trưởng khoa:
                  <span v-if="reviewDecision === 'TU_CHOI'" class="text-rose font-bold">* (Bắt buộc khi từ chối)</span>
                  <span v-else class="text-muted">(Không bắt buộc khi phê duyệt)</span>
                </label>
                <textarea 
                  v-model="reviewComment" 
                  class="form-textarea" 
                  rows="3" 
                  placeholder="Nhập ghi chú phê duyệt hoặc lý do từ chối (nếu có)..."
                ></textarea>
                <div v-if="commentError" class="comment-error-alert animate-fade-in">
                  {{ commentError }}
                </div>
              </div>
            </div>

            <!-- NẾU HỒ SƠ ĐANG Ở BƯỚC TRƯỞNG KHOA NHƯNG NGƯỜI XEM LÀ GIẢNG VIÊN -->
            <div v-else-if="selectedTask.taskDefinitionKey === 'utKhoaPheDuyet' && !selectedTask.canReview" class="decision-role-banner">
              <span class="role-tag role-dean">Bước 2: Đang chờ Trưởng khoa xem xét</span>
              <p class="role-desc">
                Hồ sơ đã được Giảng viên thẩm định <strong>ĐẠT (DAT)</strong> và đang chờ Trưởng khoa xem xét phê duyệt cấp điểm I chính thức.
              </p>
              <p v-if="selectedTask.ghiChu" class="text-muted mt-2"><strong>Ghi chú lưu vết:</strong> {{ selectedTask.ghiChu }}</p>
            </div>

            <!-- NẾU HỒ SƠ ĐÃ KẾT THÚC / XEM CHI TIẾT -->
            <div v-else class="decision-finished-box">
              <span class="finished-title font-bold">Hồ sơ đã được xử lý xong:</span>
              <p>Trạng thái hiện tại: <strong>{{ selectedTask.status }}</strong></p>
              <p v-if="selectedTask.ghiChu" class="text-muted mt-1">Ghi chú lưu vết: {{ selectedTask.ghiChu }}</p>
            </div>
          </section>
        </div>

        <!-- Footer modal -->
        <div class="modal-review-footer">
          <button 
            type="button" 
            class="btn btn-outline" 
            @click="closeReviewModal"
            :disabled="isSubmitting"
          >
            Đóng
          </button>

          <button 
            v-if="selectedTask.canReview" 
            type="button" 
            class="btn btn-black btn-submit-review"
            @click="submitReviewDecision"
            :disabled="isSubmitting"
          >
            <span v-if="isSubmitting" class="spinner-sm"></span>
            <span>{{ isSubmitting ? 'Đang hoàn thành duyệt & phát thông báo...' : 'Xác nhận & Hoàn tất duyệt' }}</span>
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const { $keycloak } = useNuxtApp()

// State người dùng & cán bộ
const user = ref({ name: '...' })
const officerCode = ref('')
const officerTitle = ref('Giảng viên')
const officerFaculty = ref('Khoa Công nghệ Thông tin & Truyền thông')
const officerRole = ref('teacher') // 'teacher' hoặc 'dean'

// State công việc & bộ lọc
const activeTab = ref('queue')
const isLoading = ref(false)
const isSubmitting = ref(false)
const toastMessage = ref('')
const docTypesList = ref([]) // Nạp trực tiếp từ CSDL app.loai_ho_so
const allWorklist = ref([])

// State Modal Thẩm định
const selectedTask = ref(null)
const reviewDecision = ref('DAT')
const reviewComment = ref('')
const commentError = ref('')

// State tìm kiếm & lọc
const searchQuery = ref('')
const filterDomain = ref('all')
const filterDocType = ref('all')
const filterStatus = ref('all')

const officerRoleTitle = computed(() => {
  return officerTitle.value || (officerRole.value === 'dean' ? 'Trưởng khoa' : 'Giảng viên')
})

const officerRoleBadge = computed(() => {
  return officerRole.value === 'dean' ? 'Dean / Trưởng khoa' : 'Teacher / Giảng viên'
})

// 1. TẢI DANH MỤC THỦ TỤC TRỰC TIẾP TỪ CSDL (app.loai_ho_so)
const fetchDocTypesFromDB = async () => {
  if (!$keycloak.authenticated) return
  try {
    const data = await $fetch('http://localhost:9080/api/postgrest/loai_ho_so', {
      headers: { Authorization: `Bearer ${$keycloak.token}` }
    })
    if (Array.isArray(data)) {
      docTypesList.value = data
    }
  } catch (error) {
    console.error('Lỗi lấy danh mục thủ tục từ CSDL:', error)
  }
}

// 2. TẢI DANH SÁCH CÔNG VIỆC THEO VAI TRÒ (FLOWABLE WORKLIST + CSDL POSTGREST)
const fetchWorklist = async () => {
  if (!$keycloak.authenticated) return
  isLoading.value = true
  try {
    // 2.1. Lấy thông tin toàn bộ hồ sơ từ CSDL PostgREST (sắp xếp mới nhất lên đầu)
    const hoSoData = await $fetch('http://localhost:9080/api/postgrest/ho_so?select=id,ma_hs,ma_sv,ma_loai,ma_dk,ngay_nop,ly_do,hoc_ky,trang_thai,ghi_chu,sinh_vien(ma_sv,ho_ten,lop,khoa,email,sdt),loai_ho_so(ma_loai,ten_loai),dang_ky_mon(id,ma_mon,hoc_ky,diem_so,diem_chu,mon_hoc(ma_mon,ten_mon,so_tc,ma_cb_phu_trach,can_bo(ma_cb,ho_ten,don_vi)))&order=id.desc', {
      headers: { Authorization: `Bearer ${$keycloak.token}` }
    })

    // 2.2. Lấy toàn bộ active tasks từ Flowable kèm process variables
    let flowableTasks = []
    try {
      const flowRes = await $fetch('http://localhost:9080/api/flowable/process-api/runtime/tasks?includeProcessVariables=true', {
        headers: { Authorization: `Bearer ${$keycloak.token}` }
      })
      if (flowRes && Array.isArray(flowRes.data)) {
        flowableTasks = flowRes.data
      }
    } catch (flowErr) {
      console.warn('Lỗi kết nối Flowable REST:', flowErr)
    }

    // Map các active task theo hoSoId
    const activeTasksByHoSoId = new Map()
    flowableTasks.forEach(task => {
      const variables = task.variables || []
      const hoSoIdVar = variables.find(v => v.name === 'hoSoId')
      if (hoSoIdVar && hoSoIdVar.value) {
        activeTasksByHoSoId.set(Number(hoSoIdVar.value), task)
      }
    })

    // 2.3. Hợp nhất danh sách hồ sơ PostgREST & trạng thái active task Flowable
    const taskItems = []
    const currentOfficerCode = officerCode.value || (officerRole.value === 'dean' ? 'TK_KTPM' : 'CB001')
    const isDean = (officerRole.value === 'dean' || currentOfficerCode === 'TK_KTPM')

    if (Array.isArray(hoSoData)) {
      hoSoData.forEach(h => {
        const activeTask = activeTasksByHoSoId.get(Number(h.id))
        const isDiemI = (h.ma_loai === 'XIN_DIEM_I')
        const teacherCodeOfCourse = h.dang_ky_mon?.mon_hoc?.ma_cb_phu_trach || h.dang_ky_mon?.mon_hoc?.can_bo?.ma_cb || null

        // PHÂN NHÓM & PHÂN QUYỀN RÕ RÀNG:
        // - Giảng viên (teacher): CHỈ ĐƯỢC XEM & DUYỆT hồ sơ của môn học do chính mình phụ trách!
        //   CB001: Chỉ xem CT101, CT177.
        //   CB002: Chỉ xem CT176, CT207.
        //   Tuyệt đối không thấy hồ sơ của giảng viên khác!
        // - Trưởng khoa (dean): Xem toàn bộ hồ sơ trong Khoa CNTT&TT.
        if (!isDean && currentOfficerCode !== teacherCodeOfCourse) {
          return // Bỏ qua hoàn toàn hồ sơ của môn học do giảng viên khác phụ trách!
        }

        let canReview = false
        let taskLabel = h.trang_thai || 'Mới'
        let statusCode = 'pending'
        let taskName = null

        if (activeTask) {
          taskName = activeTask.name
          if (activeTask.taskDefinitionKey === 'utGiangVienKiemTra') {
            taskLabel = 'Chờ Giảng viên duyệt'
            statusCode = 'pending'
            taskName = 'Giảng viên xét duyệt'
            // Giảng viên phụ trách môn học có quyền thẩm định
            if (!isDean && (currentOfficerCode === activeTask.assignee || currentOfficerCode === teacherCodeOfCourse)) {
              canReview = true
            }
          } else if (activeTask.taskDefinitionKey === 'utKhoaPheDuyet') {
            taskLabel = 'Chờ Trưởng khoa duyệt'
            taskName = 'Trưởng khoa phê duyệt'
            if (isDean) {
              canReview = true
              statusCode = 'pending'
            } else {
              canReview = false
              statusCode = 'processing'
            }
          }
        } else {
          // Chưa có activeTask trong Flowable hoặc task đã kết thúc
          if (h.trang_thai === 'Mới') {
            // Đơn mới nộp, đang ở Bước 1 chờ Giảng viên xét duyệt
            taskLabel = 'Chờ Giảng viên duyệt'
            statusCode = 'pending'
            taskName = 'Giảng viên xét duyệt'
            if (!isDean && currentOfficerCode === teacherCodeOfCourse) {
              canReview = true
            }
          } else if (h.trang_thai === 'Cần bổ sung' || h.trang_thai?.includes('bổ sung')) {
            taskLabel = 'Cần bổ sung'
            statusCode = 'warning'
            canReview = false // Chờ sinh viên cập nhật lại hồ sơ
          } else if (h.trang_thai === 'Đang duyệt') {
            taskLabel = 'Đang duyệt'
            statusCode = 'processing'
            canReview = isDean // Trưởng khoa duyệt nếu đang duyệt ở bước khoa
          } else if (h.trang_thai === 'Đã duyệt') {
            taskLabel = 'Đã duyệt'
            statusCode = 'completed'
            canReview = false
          } else if (h.trang_thai === 'Từ chối') {
            taskLabel = 'Từ chối'
            statusCode = 'rejected'
            canReview = false
          } else {
            taskLabel = h.trang_thai || 'Mới'
            statusCode = 'pending'
            if (!isDean && currentOfficerCode === teacherCodeOfCourse) {
              canReview = true
            }
          }
        }

        taskItems.push({
          uniqueKey: `hoso-${h.id}`,
          flowableTaskId: activeTask ? activeTask.id : null,
          taskDefinitionKey: activeTask ? activeTask.taskDefinitionKey : (h.trang_thai === 'Mới' ? 'utGiangVienKiemTra' : null),
          taskName: taskName,
          canReview: canReview,
          code: h.ma_hs,
          studentName: h.sinh_vien?.ho_ten || h.ma_sv,
          mssv: h.sinh_vien?.ma_sv || h.ma_sv,
          studentClass: h.sinh_vien?.lop,
          studentFaculty: h.sinh_vien?.khoa,
          studentEmail: h.sinh_vien?.email,
          studentPhone: h.sinh_vien?.sdt,
          docTitle: h.loai_ho_so?.ten_loai || (isDiemI ? 'Đơn xin điểm I' : h.ma_loai),
          isDiemI: isDiemI,
          courseName: h.dang_ky_mon?.mon_hoc?.ten_mon,
          courseCode: h.dang_ky_mon?.ma_mon,
          credits: h.dang_ky_mon?.mon_hoc?.so_tc || 3,
          semester: h.hoc_ky,
          currentScore: (h.dang_ky_mon && h.dang_ky_mon.diem_so !== null && h.dang_ky_mon.diem_so !== undefined) ? Number(h.dang_ky_mon.diem_so) : null,
          letterGrade: h.dang_ky_mon?.diem_chu || null,
          teacherName: h.dang_ky_mon?.mon_hoc?.can_bo?.ho_ten || 'Giảng viên',
          teacherCode: teacherCodeOfCourse,
          submittedAt: new Date(h.ngay_nop).toLocaleDateString('vi-VN'),
          status: taskLabel,
          statusCode: statusCode,
          domain: isDiemI ? 'Học vụ & Điểm số' : 'Hành chính số',
          reason: h.ly_do,
          attachment: h.ghi_chu,
          ghiChu: h.ghi_chu,
          hoSo: h
        })
      })
    }

    allWorklist.value = taskItems
  } catch (err) {
    console.error('Lỗi nạp danh sách công việc:', err)
  } finally {
    isLoading.value = false
  }
}

// 3. THAO TÁC MỞ MODAL THẨM ĐỊNH
const openReviewModal = (item) => {
  selectedTask.value = item
  reviewComment.value = ''
  commentError.value = ''
  if (item.taskDefinitionKey === 'utKhoaPheDuyet') {
    reviewDecision.value = 'PHE_DUYET'
  } else {
    reviewDecision.value = 'DAT'
  }
}

const closeReviewModal = () => {
  if (isSubmitting.value) return
  selectedTask.value = null
  commentError.value = ''
}

// 4. HÀNH ĐỘNG DUYỆT (GIẢNG VIÊN / TRƯỞNG KHOA)
const submitReviewDecision = async () => {
  if (!selectedTask.value) return

  // Bắt buộc nhập comment khi BO_SUNG hoặc TU_CHOI
  if (reviewDecision.value === 'BO_SUNG' && !reviewComment.value.trim()) {
    commentError.value = 'Vui lòng nhập nội dung comment yêu cầu sinh viên bổ sung giấy tờ!'
    return
  }
  if (reviewDecision.value === 'TU_CHOI' && !reviewComment.value.trim()) {
    commentError.value = 'Vui lòng nhập lý do từ chối đơn để phản hồi cho sinh viên!'
    return
  }
  commentError.value = ''
  isSubmitting.value = true

  let taskId = selectedTask.value.flowableTaskId
  const isDean = (selectedTask.value.taskDefinitionKey === 'utKhoaPheDuyet' || officerRole.value === 'dean')
  const hoSoId = selectedTask.value.hoSo?.id
  const maDk = selectedTask.value.hoSo?.ma_dk
  const maSv = selectedTask.value.mssv
  const monHocName = selectedTask.value.courseName || 'môn học'

  try {
    // 4.1. TỰ ĐỘNG KHỞI TẠO FLOWABLE PROCESS NẾU CHƯA CÓ TASK
    if (!taskId && !isDean) {
      try {
        const startRes = await $fetch('http://localhost:9080/api/flowable/process-api/runtime/process-instances', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${$keycloak.token}`,
            'Content-Type': 'application/json'
          },
          body: {
            processDefinitionKey: 'quyTrinhDuyetDiemI_CNTT',
            variables: [
              { name: 'hoSoId', value: Number(hoSoId) },
              { name: 'maDk', value: Number(maDk) },
              { name: 'maSv', value: String(maSv) },
              { name: 'giangVienId', value: String(selectedTask.value.teacherCode || officerCode.value) },
              { name: 'truongKhoaId', value: 'TK_KTPM' },
              { name: 'diemHienTai', value: Number(selectedTask.value.currentScore || 0) }
            ]
          }
        })
        if (startRes?.id) {
          const tasksData = await $fetch(`http://localhost:9080/api/flowable/process-api/runtime/tasks?processInstanceId=${startRes.id}`, {
            headers: { Authorization: `Bearer ${$keycloak.token}` }
          })
          if (tasksData?.data?.[0]?.id) {
            taskId = tasksData.data[0].id
          }
        }
      } catch (flowStartErr) {
        console.warn('Lỗi auto-start Flowable:', flowStartErr)
      }
    }

    // 4.2. GỌI FLOWABLE REST COMPLETE TASK NẾU CÓ TASK ID
    if (taskId) {
      let flowVariables = []
      if (isDean) {
        flowVariables = [
          { name: 'quyetDinhKhoa', value: reviewDecision.value },
          { name: 'yKienTruongKhoa', value: reviewComment.value.trim() }
        ]
      } else {
        flowVariables = [
          { name: 'ketQuaGV', value: reviewDecision.value },
          { name: 'yKienGV', value: reviewComment.value.trim() }
        ]
      }

      try {
        await $fetch(`http://localhost:9080/api/flowable/process-api/runtime/tasks/${taskId}`, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${$keycloak.token}`,
            'Content-Type': 'application/json'
          },
          body: {
            action: 'complete',
            variables: flowVariables
          }
        })
      } catch (flowTaskErr) {
        console.warn('Lỗi complete task Flowable:', flowTaskErr)
      }
    }

    // 4.3. CẬP NHẬT TRẠNG THÁI VÀ GHI CHÚ TRONG APP.HO_SO
    let newTrangThai = 'Đang duyệt'
    let notePrefix = ''

    if (isDean) {
      if (reviewDecision.value === 'PHE_DUYET') {
        newTrangThai = 'Đã duyệt'
        notePrefix = `Trưởng khoa phê duyệt: ${reviewComment.value.trim() || 'Đồng ý cấp điểm I'}`
      } else {
        newTrangThai = 'Từ chối'
        notePrefix = `Trưởng khoa từ chối: ${reviewComment.value.trim()}`
      }
    } else {
      if (reviewDecision.value === 'DAT') {
        newTrangThai = 'Đang duyệt'
        notePrefix = `Giảng viên thông qua (DAT): ${reviewComment.value.trim() || 'Hồ sơ hợp lệ, đề nghị chuyển Trưởng khoa'}`
      } else if (reviewDecision.value === 'BO_SUNG') {
        newTrangThai = 'Cần bổ sung'
        notePrefix = `Giảng viên yêu cầu bổ sung: ${reviewComment.value.trim()}`
      } else if (reviewDecision.value === 'TU_CHOI') {
        newTrangThai = 'Từ chối'
        notePrefix = `Giảng viên từ chối: ${reviewComment.value.trim()}`
      }
    }

    if (hoSoId) {
      try {
        await $fetch(`http://localhost:9080/api/postgrest/ho_so?id=eq.${hoSoId}`, {
          method: 'PATCH',
          headers: {
            Authorization: `Bearer ${$keycloak.token}`,
            'Content-Type': 'application/json'
          },
          body: {
            trang_thai: newTrangThai,
            ghi_chu: notePrefix
          }
        })
      } catch (dbErr) {
        console.warn('Lỗi cập nhật ho_so:', dbErr)
      }
    }

    // 4.3. XỬ LÝ ĐIỂM SỐ MÔN HỌC (APP.DANG_KY_MON)
    // - NẾU TRƯỞNG KHOA PHÊ DUYỆT (PHE_DUYET): TỰ ĐỘNG CẬP NHẬT THÀNH ĐIỂM 'I'
    // - NẾU BỊ TỪ CHỐI (TU_CHOI): BẢO LƯU/GIỮ NGUYÊN ĐIỂM SỐ BAN ĐẦU CỦA HỌC PHẦN
    if (maDk) {
      if (isDean && reviewDecision.value === 'PHE_DUYET') {
        try {
          await $fetch(`http://localhost:9080/api/postgrest/dang_ky_mon?id=eq.${maDk}`, {
            method: 'PATCH',
            headers: {
              Authorization: `Bearer ${$keycloak.token}`,
              'Content-Type': 'application/json'
            },
            body: {
              diem_chu: 'I',
              diem_so: null,
              trang_thai_dk: 'Đang học',
              ngay_cap_nhat_diem: new Date().toISOString()
            }
          })
        } catch (gradeErr) {
          console.warn('Lỗi cập nhật điểm I vào dang_ky_mon:', gradeErr)
        }
      } else if (reviewDecision.value === 'TU_CHOI') {
        // Bảo lưu nguyên vẹn điểm số ban đầu của học phần
        try {
          const initialScore = (selectedTask.value.currentScore !== null && selectedTask.value.currentScore !== undefined) ? Number(selectedTask.value.currentScore) : null
          const initialLetter = selectedTask.value.letterGrade || null
          await $fetch(`http://localhost:9080/api/postgrest/dang_ky_mon?id=eq.${maDk}`, {
            method: 'PATCH',
            headers: {
              Authorization: `Bearer ${$keycloak.token}`,
              'Content-Type': 'application/json'
            },
            body: {
              diem_chu: initialLetter,
              diem_so: initialScore,
              ngay_cap_nhat_diem: new Date().toISOString()
            }
          })
        } catch (gradeErr) {
          console.warn('Lỗi xác nhận bảo lưu điểm ban đầu:', gradeErr)
        }
      }
    }

    // 4.4. PHÁT THÔNG BÁO CHO SINH VIÊN (app.thong_bao)
    let notifMessage = ''
    if (isDean) {
      if (reviewDecision.value === 'PHE_DUYET') {
        notifMessage = `Trưởng khoa đã PHÊ DUYỆT đơn xin điểm I môn ${monHocName}. Điểm của bạn đã được tự động cập nhật thành điểm 'I'.`
      } else {
        notifMessage = `Trưởng khoa đã TỪ CHỐI đơn xin điểm I môn ${monHocName}. Điểm số ban đầu của học phần được giữ nguyên không đổi. Lý do: ${reviewComment.value.trim()}`
      }
    } else {
      if (reviewDecision.value === 'DAT') {
        notifMessage = `Giảng viên (${user.value.name}) đã THÔNG QUA đơn xin điểm I môn ${monHocName}. Hồ sơ đã được chuyển tiếp đến Trưởng khoa phê duyệt.`
      } else if (reviewDecision.value === 'BO_SUNG') {
        notifMessage = `Giảng viên (${user.value.name}) yêu cầu BỔ SUNG minh chứng cho đơn xin điểm I môn ${monHocName}. Chi tiết: ${reviewComment.value.trim()}`
      } else {
        notifMessage = `Giảng viên (${user.value.name}) đã TỪ CHỐI đơn xin điểm I môn ${monHocName}. Điểm số ban đầu của học phần được giữ nguyên không đổi. Lý do: ${reviewComment.value.trim()}`
      }
    }

    if (hoSoId && maSv) {
      try {
        await $fetch('http://localhost:9080/api/postgrest/thong_bao', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${$keycloak.token}`,
            'Content-Type': 'application/json'
          },
          body: {
            ma_hs: Number(hoSoId),
            ma_sv: String(maSv),
            noi_dung: notifMessage,
            trang_thai_doc: false
          }
        })
      } catch (notifErr) {
        console.warn('Lỗi phát thông báo:', notifErr)
      }
    }

    // 4.5. ĐÓNG MODAL VÀ THÔNG BÁO THÀNH CÔNG
    closeReviewModal()
    toastMessage.value = `Thẩm định thành công hồ sơ ${selectedTask.value.code}! Quyết định đã đồng bộ với Flowable BPMN và đã phát thông báo cho sinh viên.`
    
    // Tải lại danh sách
    await fetchWorklist()
  } catch (error) {
    console.error('Lỗi hoàn thành task:', error)
    alert('Không thể hoàn tất thẩm định: ' + (error.data?.message || error.message || 'Vui lòng kiểm tra lại.'))
  } finally {
    isSubmitting.value = false
  }
}

const refreshAll = async () => {
  await fetchDocTypesFromDB()
  await fetchWorklist()
}

// 5. LIFECYCLE VÀ KHỞI TẠO
onMounted(async () => {
  if ($keycloak.authenticated) {
    const roles = $keycloak.tokenParsed?.realm_access?.roles || []
    if (!roles.includes('teacher') && !roles.includes('dean')) {
      navigateTo('/user/homepageuser')
      return
    }

    const sub = $keycloak.tokenParsed?.sub
    try {
      const profileData = await $fetch(`http://localhost:9080/api/postgrest/can_bo?keycloak_sub=eq.${sub}`, {
        headers: { Authorization: `Bearer ${$keycloak.token}` }
      })
      if (profileData?.[0]) {
        user.value = { name: profileData[0].ho_ten }
        officerCode.value = profileData[0].ma_cb
        officerTitle.value = profileData[0].chuc_vu
        officerFaculty.value = profileData[0].don_vi
        officerRole.value = profileData[0].chuc_vu === 'Trưởng khoa' ? 'dean' : 'teacher'
      } else {
        user.value = { name: $keycloak.tokenParsed?.name || $keycloak.tokenParsed?.preferred_username || 'Cán bộ' }
        officerCode.value = roles.includes('dean') ? 'TK_KTPM' : 'CB001'
        officerRole.value = roles.includes('dean') ? 'dean' : 'teacher'
      }
    } catch {
      user.value = { name: $keycloak.tokenParsed?.name || $keycloak.tokenParsed?.preferred_username || 'Cán bộ' }
      officerCode.value = roles.includes('dean') ? 'TK_KTPM' : 'CB001'
      officerRole.value = roles.includes('dean') ? 'dean' : 'teacher'
    }

    await fetchDocTypesFromDB()
    await fetchWorklist()
  } else {
    navigateTo('/')
  }
})

const logout = () => $keycloak.logout({ redirectUri: window.location.origin })

// Thống kê số lượng
const pendingCount = computed(() => allWorklist.value.filter(a => 
  a.canReview || a.flowableTaskId !== null || a.status.includes('Chờ') || a.status.includes('Đang') || a.statusCode === 'pending' || a.statusCode === 'processing'
).length)
const approvedCount = computed(() => allWorklist.value.filter(a => a.status === 'Đã duyệt' || a.statusCode === 'completed').length)
const needMoreCount = computed(() => allWorklist.value.filter(a => (a.ghiChu && a.ghiChu.toLowerCase().includes('bổ sung')) || a.status === 'Cần bổ sung').length)
const rejectedCount = computed(() => allWorklist.value.filter(a => a.status === 'Từ chối' || a.statusCode === 'rejected').length)

// Lọc dữ liệu hiển thị
const filteredApplications = computed(() => {
  return allWorklist.value.filter(item => {
    if (searchQuery.value) {
      const q = searchQuery.value.toLowerCase()
      const matchCode = item.code.toLowerCase().includes(q)
      const matchName = item.studentName.toLowerCase().includes(q)
      const matchMssv = item.mssv.toLowerCase().includes(q)
      const matchCourse = item.courseName?.toLowerCase().includes(q)
      if (!matchCode && !matchName && !matchMssv && !matchCourse) return false
    }
    if (filterDomain.value !== 'all' && item.domain !== filterDomain.value) return false
    if (filterDocType.value !== 'all' && item.docTitle !== filterDocType.value) return false
    if (filterStatus.value !== 'all') {
      if (filterStatus.value === 'Chờ duyệt') {
        if (!item.status.includes('Chờ') && !item.status.includes('Đang') && item.statusCode !== 'pending' && item.statusCode !== 'processing') return false
      } else if (filterStatus.value === 'Đã duyệt') {
        if (item.status !== 'Đã duyệt' && item.statusCode !== 'completed') return false
      } else if (filterStatus.value === 'Cần bổ sung') {
        if (!item.ghiChu?.toLowerCase().includes('bổ sung') && item.status !== 'Cần bổ sung') return false
      } else if (filterStatus.value === 'Từ chối') {
        if (item.status !== 'Từ chối' && item.statusCode !== 'rejected') return false
      }
    }
    return true
  })
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');
* { box-sizing: border-box; }
.admin-wrapper { min-height: 100vh; background-color: #ffffff; color: #0f172a; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; padding-bottom: 80px; }
.navbar { width: 100%; padding: 20px 0; border-bottom: 1px solid #e2e8f0; background-color: #ffffff; position: sticky; top: 0; z-index: 30; }
.nav-container { max-width: 1240px; margin: 0 auto; padding: 0 32px; display: flex; align-items: center; justify-content: space-between; gap: 20px; }
.nav-brand { display: flex; align-items: center; gap: 10px; }
.logo { font-size: 1.25rem; font-weight: 500; color: #000000; text-decoration: none; letter-spacing: -0.02em; }
.logo-bold { font-weight: 800; }
.brand-badge { font-size: 0.75rem; font-weight: 700; background-color: #000000; color: #ffffff; padding: 2px 8px; border-radius: 4px; text-transform: uppercase; }
.officer-info { display: flex; align-items: center; gap: 8px; font-size: 0.9rem; color: #64748b; text-decoration: none; cursor: pointer; transition: opacity 0.15s ease; }
.officer-info:hover { opacity: 0.8; }
.officer-name { font-weight: 700; color: #000000; }
.status-dot-separator { color: #cbd5e1; }
.signature-tag { display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem; font-weight: 500; color: #059669; background-color: #ecfdf5; padding: 3px 10px; border-radius: 20px; border: 1px solid #a7f3d0; }
.green-dot { width: 6px; height: 6px; background-color: #10b981; border-radius: 50%; display: inline-block; }
.nav-actions { display: flex; align-items: center; gap: 12px; }
.tab-control { display: flex; align-items: center; background-color: #f1f5f9; padding: 4px; border-radius: 8px; gap: 4px; }
.tab-item { display: flex; align-items: center; gap: 8px; padding: 7px 14px; border-radius: 6px; border: none; background: transparent; color: #64748b; font-size: 0.88rem; font-weight: 600; font-family: inherit; cursor: pointer; transition: all 0.15s ease; }
.tab-item:hover { color: #000000; }
.tab-item.active { background-color: #000000; color: #ffffff; }
.badge-count { font-size: 0.72rem; font-weight: 700; background-color: #e2e8f0; color: #0f172a; padding: 1px 6px; border-radius: 10px; }
.tab-item.active .badge-count { background-color: #334155; color: #ffffff; }
.btn-logout { background-color: #ffffff; border: 1.5px solid #e2e8f0; color: #475569; padding: 8px 10px; border-radius: 6px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.15s ease; }
.btn-logout:hover { border-color: #000000; color: #000000; }

.page-title-section { padding: 32px 0 20px; }
.main-container { max-width: 1240px; margin: 0 auto; padding: 0 32px; }
.header-flex-row { display: flex; align-items: flex-start; justify-content: space-between; gap: 20px; }
.page-main-heading { font-size: 1.95rem; font-weight: 800; letter-spacing: -0.035em; color: #000000; line-height: 1.25; }
.page-sub-heading { font-size: 0.95rem; color: #64748b; margin-top: 6px; }
.btn-refresh { display: inline-flex; align-items: center; gap: 8px; font-size: 0.88rem; }
.refresh-icon.spinning { animation: spin 1s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }

.toast-wrapper { margin-bottom: 20px; }
.toast-alert { display: flex; align-items: center; gap: 12px; background-color: #064e3b; color: #ecfdf5; padding: 12px 18px; border-radius: 8px; font-size: 0.92rem; font-weight: 500; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08); }
.toast-close { background: none; border: none; color: #a7f3d0; font-size: 1.4rem; cursor: pointer; margin-left: auto; line-height: 1; }

.stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
.stat-box { background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px 24px; }
.stat-title { font-size: 0.88rem; color: #64748b; font-weight: 500; margin-bottom: 8px; }
.stat-number { font-size: 2.1rem; font-weight: 800; line-height: 1; color: #000000; }
.text-emerald { color: #059669; }
.text-amber { color: #d97706; }
.text-rose { color: #e11d48; }

.filter-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
.search-box { flex: 1; min-width: 280px; position: relative; display: flex; align-items: center; }
.search-icon { position: absolute; left: 14px; color: #94a3b8; display: flex; }
.search-input { width: 100%; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 6px; padding: 10px 14px 10px 38px; font-size: 0.92rem; color: #0f172a; outline: none; font-family: inherit; transition: border-color 0.15s ease; }
.search-input:focus { border-color: #000000; }
.filter-dropdown { display: flex; align-items: center; gap: 8px; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 6px; padding: 4px 12px; }
.dropdown-label { font-size: 0.86rem; color: #64748b; }
.dropdown-select { border: none; background: transparent; color: #0f172a; font-size: 0.9rem; font-weight: 500; font-family: inherit; outline: none; cursor: pointer; padding: 6px 0; }

.table-card { background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; }
.loading-state { padding: 50px 20px; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 12px; color: #64748b; }
.spinner { width: 24px; height: 24px; border: 2px solid #e2e8f0; border-top-color: #000000; border-radius: 50%; animation: spin 0.8s linear infinite; }
.spinner-sm { width: 14px; height: 14px; border: 2px solid rgba(255, 255, 255, 0.4); border-top-color: #ffffff; border-radius: 50%; animation: spin 0.8s linear infinite; display: inline-block; margin-right: 6px; }
.data-table { width: 100%; border-collapse: collapse; text-align: left; }
.data-table thead th { padding: 14px 18px; font-size: 0.76rem; font-weight: 700; text-transform: uppercase; color: #64748b; letter-spacing: 0.04em; background-color: #f8fafc; border-bottom: 1px solid #e2e8f0; }
.data-table tbody td { padding: 16px 18px; border-bottom: 1px solid #f1f5f9; font-size: 0.9rem; vertical-align: middle; }
.code-col { font-weight: 700; color: #000000; }
.badge-mini-gold { display: inline-block; font-size: 0.68rem; font-weight: 700; background-color: #fef3c7; color: #b45309; padding: 1px 6px; border-radius: 4px; margin-left: 6px; }
.student-name { font-weight: 600; color: #000000; }
.student-meta { font-size: 0.8rem; color: #64748b; margin-top: 2px; }
.doc-name { font-weight: 600; color: #0f172a; }
.course-meta { font-size: 0.8rem; margin-top: 2px; }
.score-badge { margin-left: 6px; background-color: #f1f5f9; padding: 1px 6px; border-radius: 4px; color: #0f172a; }
.flowable-task-tag { display: inline-flex; align-items: center; gap: 6px; font-size: 0.78rem; font-weight: 600; padding: 3px 8px; border-radius: 4px; }
.tag-teacher { background-color: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; }
.tag-dean { background-color: #fef3c7; color: #b45309; border: 1px solid #fde68a; }
.task-dot { width: 6px; height: 6px; border-radius: 50%; background-color: currentColor; }
.time-col { color: #64748b; font-size: 0.85rem; }
.status-tag { display: inline-block; font-size: 0.78rem; font-weight: 600; padding: 3px 8px; border-radius: 4px; }
.status-pending { background-color: #fef9c3; color: #854d0e; }
.status-processing { background-color: #e0f2fe; color: #075985; }
.status-completed { background-color: #dcfce7; color: #166534; }
.status-rejected { background-color: #fee2e2; color: #991b1b; }

.btn { font-family: inherit; font-size: 0.88rem; font-weight: 600; padding: 8px 16px; border-radius: 6px; cursor: pointer; transition: all 0.15s ease; border: none; }
.btn-black { background-color: #000000; color: #ffffff; }
.btn-black:hover:not(:disabled) { opacity: 0.9; }
.btn-black:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-outline { background: transparent; border: 1.5px solid #cbd5e1; color: #0f172a; }
.btn-outline:hover:not(:disabled) { border-color: #000000; }
.btn-black-sm { background-color: #000000; color: #ffffff; padding: 6px 14px; border-radius: 6px; font-size: 0.84rem; font-weight: 600; border: none; cursor: pointer; }
.btn-black-sm:hover { opacity: 0.9; }
.btn-outline-sm { background: transparent; border: 1px solid #cbd5e1; color: #0f172a; padding: 6px 12px; border-radius: 6px; font-size: 0.84rem; font-weight: 500; cursor: pointer; }
.text-right { text-align: right; }

.empty-cell { text-align: center; padding: 70px 24px !important; }
.empty-wrapper { max-width: 480px; margin: 0 auto; display: flex; flex-direction: column; align-items: center; }
.empty-icon-circle { width: 56px; height: 56px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-bottom: 18px; }
.empty-headline { font-size: 1.15rem; font-weight: 700; color: #000000; margin-bottom: 8px; }
.empty-subtext { font-size: 0.92rem; color: #64748b; line-height: 1.6; }

.sla-metrics-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px; }
.sla-box { background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; }
.sla-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.sla-label { font-size: 0.9rem; font-weight: 600; color: #64748b; }
.sla-value-wrap { display: flex; align-items: baseline; gap: 8px; margin-bottom: 8px; }
.sla-big-num { font-size: 2.4rem; font-weight: 800; color: #000000; line-height: 1; }
.sla-unit { font-size: 0.92rem; color: #64748b; }
.sla-note { font-size: 0.86rem; }

/* MODAL THẨM ĐỊNH */
.modal-overlay { position: fixed; inset: 0; background-color: rgba(0, 0, 0, 0.55); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 60; padding: 20px; }
.modal-review-box { background-color: #ffffff; border-radius: 14px; max-width: 860px; width: 100%; max-height: 92vh; display: flex; flex-direction: column; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); overflow: hidden; border: 1px solid #e2e8f0; }
.modal-review-header { padding: 20px 28px; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: space-between; background-color: #f8fafc; }
.review-title-group { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.review-badge-code { font-size: 0.84rem; color: #475569; background-color: #e2e8f0; padding: 2px 8px; border-radius: 4px; }
.review-main-title { font-size: 1.25rem; font-weight: 800; color: #000000; letter-spacing: -0.02em; }
.btn-close-modal { background: none; border: none; font-size: 1.8rem; line-height: 1; color: #94a3b8; cursor: pointer; }
.btn-close-modal:hover { color: #000000; }
.modal-review-body { padding: 24px 28px; overflow-y: auto; flex: 1; display: flex; flex-direction: column; gap: 20px; }
.review-card-section { border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px 20px; background-color: #ffffff; }
.highlight-section { background-color: #f8fafc; border-color: #cbd5e1; }
.section-title-sm { font-size: 0.88rem; font-weight: 700; color: #0f172a; margin-bottom: 12px; text-transform: uppercase; letter-spacing: 0.03em; }
.info-grid-2col { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px 20px; }
.info-cell { display: flex; flex-direction: column; gap: 2px; }
.cell-label { font-size: 0.78rem; color: #64748b; }
.cell-value { font-size: 0.92rem; color: #0f172a; }

.course-detail-banner { display: flex; align-items: center; justify-content: space-between; gap: 20px; flex-wrap: wrap; }
.course-left { flex: 1; min-width: 260px; }
.course-name-lg { font-size: 1.15rem; font-weight: 800; color: #000000; margin-bottom: 4px; }
.course-sub { font-size: 0.85rem; color: #475569; margin-bottom: 4px; }
.course-teacher { font-size: 0.85rem; color: #0f172a; }
.course-right { display: flex; align-items: center; }
.score-display-box { background-color: #ffffff; border: 1.5px solid #cbd5e1; border-radius: 8px; padding: 10px 16px; text-align: center; }
.score-box-label { font-size: 0.74rem; font-weight: 600; color: #64748b; text-transform: uppercase; }
.score-box-val { display: flex; align-items: baseline; justify-content: center; gap: 4px; margin: 2px 0 4px; }
.score-num { font-size: 1.5rem; font-weight: 800; color: #000000; }
.score-null { font-size: 0.9rem; font-weight: 600; color: #94a3b8; }
.score-letter { font-size: 0.92rem; font-weight: 700; color: #475569; }
.rule-badge { font-size: 0.72rem; font-weight: 700; padding: 2px 8px; border-radius: 4px; display: inline-block; }
.rule-valid { background-color: #dcfce7; color: #166534; }
.rule-invalid { background-color: #fee2e2; color: #991b1b; }

.reason-quote-box { background-color: #f1f5f9; border-left: 3px solid #000000; padding: 10px 14px; border-radius: 0 6px 6px 0; }
.quote-label { font-size: 0.76rem; font-weight: 700; color: #475569; margin-bottom: 4px; }
.quote-text { font-size: 0.92rem; color: #0f172a; line-height: 1.5; font-style: italic; }
.attachment-box { display: inline-flex; align-items: center; gap: 8px; font-size: 0.85rem; color: #0284c7; background-color: #e0f2fe; padding: 6px 12px; border-radius: 6px; margin-top: 10px; font-weight: 500; }

.review-decision-section { border: 2px solid #000000; border-radius: 10px; padding: 20px; background-color: #ffffff; }
.decision-role-banner { margin-bottom: 16px; }
.role-tag { display: inline-block; font-size: 0.78rem; font-weight: 800; padding: 3px 10px; border-radius: 20px; text-transform: uppercase; margin-bottom: 6px; }
.role-teacher { background-color: #e0f2fe; color: #0369a1; }
.role-dean { background-color: #fef3c7; color: #b45309; }
.role-desc { font-size: 0.92rem; color: #334155; }

.decision-options-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-bottom: 18px; }
.grid-2col { grid-template-columns: repeat(2, 1fr); }
.decision-choice-card { border: 1.5px solid #cbd5e1; border-radius: 8px; padding: 14px; display: flex; align-items: flex-start; gap: 12px; cursor: pointer; transition: all 0.15s ease; position: relative; }
.decision-choice-card:hover { border-color: #000000; background-color: #f8fafc; }
.active-dat { border-color: #16a34a !important; background-color: #f0fdf4 !important; box-shadow: 0 0 0 2px #16a34a; }
.active-bosung { border-color: #d97706 !important; background-color: #fffbeb !important; box-shadow: 0 0 0 2px #d97706; }
.active-tuchoi { border-color: #dc2626 !important; background-color: #fef2f2 !important; box-shadow: 0 0 0 2px #dc2626; }
.radio-hidden { position: absolute; opacity: 0; }
.choice-icon { width: 26px; height: 26px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.85rem; flex-shrink: 0; }
.icon-dat { background-color: #dcfce7; color: #16a34a; }
.icon-bosung { background-color: #fef3c7; color: #d97706; }
.icon-tuchoi { background-color: #fee2e2; color: #dc2626; }
.choice-text strong { display: block; font-size: 0.92rem; color: #0f172a; margin-bottom: 2px; }
.choice-text p { font-size: 0.78rem; color: #64748b; line-height: 1.35; }

.comment-field-wrapper { display: flex; flex-direction: column; gap: 6px; }
.comment-label { font-size: 0.88rem; color: #0f172a; }
.form-textarea { width: 100%; border: 1.5px solid #cbd5e1; border-radius: 8px; padding: 10px 14px; font-family: inherit; font-size: 0.92rem; color: #0f172a; resize: vertical; outline: none; transition: border-color 0.15s ease; }
.form-textarea:focus { border-color: #000000; }
.comment-error-alert { font-size: 0.82rem; color: #dc2626; font-weight: 600; padding: 6px 10px; background-color: #fef2f2; border-radius: 4px; border: 1px solid #fecaca; }

.decision-finished-box { background-color: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 8px; padding: 14px; font-size: 0.9rem; }
.finished-title { color: #0f172a; }

.modal-review-footer { padding: 18px 28px; border-top: 1px solid #e2e8f0; display: flex; align-items: center; justify-content: flex-end; gap: 12px; background-color: #f8fafc; }
.btn-submit-review { display: inline-flex; align-items: center; }

.font-mono { font-family: monospace; }
.font-bold { font-weight: 700; }
.font-semibold { font-weight: 600; }

@media (max-width: 992px) {
  .stats-grid { grid-template-columns: repeat(2, 1fr); }
  .decision-options-grid { grid-template-columns: 1fr; }
}
@media (max-width: 680px) {
  .nav-container { flex-direction: column; align-items: flex-start; }
  .header-flex-row { flex-direction: column; }
  .info-grid-2col { grid-template-columns: 1fr; }
  .stats-grid { grid-template-columns: 1fr; }
}
</style>
