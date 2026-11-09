<!--
  SPDX-License-Identifier: MIT
  Copyright (c) 2026 CTU-HKT
-->
<template>
  <div class="complete-wrapper">
    <div class="complete-card">
      <!-- Header -->
      <div class="card-header">
        <div class="brand-row">
          <span class="logo-bold">Smart</span><span>Campus</span>
          <span class="role-badge" :class="{ 'teacher-badge': isTeacher }">
            {{ isTeacher ? 'Cán bộ / Giảng viên' : 'Sinh viên' }}
          </span>
        </div>
        <h1 class="card-title">
          {{ isTeacher ? 'Hoàn thiện hồ sơ Cán bộ' : 'Hoàn thiện hồ sơ Sinh viên' }}
        </h1>
        <p class="card-subtitle">
          Vui lòng cập nhật các thông tin cơ sở dưới đây để hoàn tất kích hoạt tài khoản của bạn trên hệ thống SmartCampus.
        </p>
      </div>

      <!-- Error / Success Alert -->
      <div v-if="alertMessage" :class="['alert-box', alertType]">
        {{ alertMessage }}
      </div>

      <!-- Form -->
      <form @submit.prevent="handleSubmit" class="profile-form">
        <!-- Họ và tên -->
        <div class="form-group">
          <label class="form-label" for="fullName">Họ và tên <span class="required">*</span></label>
          <input
            id="fullName"
            v-model="fullName"
            type="text"
            class="form-input"
            maxlength="100"
            placeholder="Nguyễn Văn A"
            required
          />
        </div>

        <!-- Email (Read-only từ Keycloak) -->
        <div class="form-group">
          <label class="form-label" for="email">Email tài khoản</label>
          <input
            id="email"
            v-model="email"
            type="email"
            class="form-input readonly-input"
            disabled
          />
          <span class="input-hint">Email được xác thực và đồng bộ từ Keycloak SSO.</span>
        </div>

        <!-- Mã định danh (MSSV hoặc Mã CB/GV) -->
        <div class="form-group">
          <label class="form-label" for="userCode">
            {{ isTeacher ? 'Mã cán bộ / Giảng viên' : 'Mã số sinh viên (MSSV)' }}
            <span class="required">*</span>
          </label>
          <input
            id="userCode"
            v-model="userCode"
            type="text"
            class="form-input"
            maxlength="20"
            :disabled="!!existingRecord"
            :placeholder="isTeacher ? 'Ví dụ: CB1024, GV08...' : 'Ví dụ: B2101234, B2205678...'"
            required
          />
          <span v-if="existingRecord" class="input-hint">Mã đã được gán cho tài khoản này và không thể đổi.</span>
        </div>

        <!-- Khoa / Đơn vị -->
        <div class="form-group">
          <label class="form-label" for="faculty">
            {{ isTeacher ? 'Khoa / Đơn vị công tác' : 'Khoa quản lý' }}
            <span class="required">*</span>
          </label>
          <input
            id="faculty"
            v-model="faculty"
            type="text"
            class="form-input"
            maxlength="100"
            placeholder="Ví dụ: Công nghệ Thông tin & Truyền thông"
            required
          />
        </div>

        <!-- Chức vụ (cán bộ) -->
        <div v-if="isTeacher" class="form-group">
          <label class="form-label" for="chucVu">Chức vụ <span class="required">*</span></label>
          <select id="chucVu" v-model="chucVu" class="form-input" required>
            <option value="" disabled>-- Chọn chức vụ --</option>
            <option v-for="cv in CHUC_VU_OPTIONS" :key="cv" :value="cv">{{ cv }}</option>
          </select>
        </div>

        <!-- Ngành học (sinh viên) -->
        <div v-else class="form-group">
          <label class="form-label" for="major">Ngành / Lớp <span class="required">*</span></label>
          <input
            id="major"
            v-model="major"
            type="text"
            class="form-input"
            maxlength="100"
            placeholder="Ví dụ: Kỹ thuật Phần mềm - K21"
            required
          />
        </div>

        <!-- Số điện thoại -->
        <div class="form-group">
          <label class="form-label" for="phone">Số điện thoại liên hệ</label>
          <input
            id="phone"
            v-model="phone"
            type="tel"
            class="form-input"
            maxlength="20"
            placeholder="09xx xxx xxx"
          />
        </div>

        <!-- Ngày sinh (sinh viên, bắt buộc theo CSDL) -->
        <div v-if="!isTeacher" class="form-group">
          <label class="form-label" for="dateOfBirth">Ngày sinh <span class="required">*</span></label>
          <input
            id="dateOfBirth"
            v-model="dateOfBirth"
            type="date"
            class="form-input"
            required
          />
        </div>

        <!-- Nút Submit -->
        <button type="submit" class="btn btn-submit" :disabled="isSubmitting">
          <span v-if="!isSubmitting">Lưu và Tiếp tục</span>
          <span v-else class="loading-state">
            <span class="mini-spinner"></span>
            Đang lưu hồ sơ...
          </span>
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

// Khớp với ràng buộc CHECK của cột app.can_bo.chuc_vu
const CHUC_VU_OPTIONS = ['Giảng viên', 'Trưởng khoa', 'Chuyên viên PĐT']

const { $keycloak } = useNuxtApp()

const fullName = ref('')
const email = ref('')
const userCode = ref('')
const faculty = ref('')
const major = ref('')
const chucVu = ref('')
const phone = ref('')
const dateOfBirth = ref('')

const isTeacher = ref(false)
const isSubmitting = ref(false)
const alertMessage = ref('')
const alertType = ref('error')
// Bản ghi hồ sơ đã có trong DB (nếu có). Khi có, lưu bằng PATCH thay vì POST.
const existingRecord = ref(null)

const apiBase = 'http://localhost:9080/api/postgrest'

onMounted(async () => {
  if (!$keycloak.authenticated) {
    return navigateTo('/')
  }

  const parsed = $keycloak.tokenParsed || {}
  const roles = parsed.realm_access?.roles || []
  isTeacher.value = roles.includes('teacher')

  // Tự động điền trước tên và email từ Keycloak
  fullName.value = parsed.name || `${parsed.given_name || ''} ${parsed.family_name || ''}`.trim() || parsed.preferred_username || ''
  email.value = parsed.email || ''

  // Nếu user đã có bản ghi trong DB thì fetch lên để điền sẵn
  try {
    const sub = parsed.sub
    const table = isTeacher.value ? 'can_bo' : 'sinh_vien'

    const res = await $fetch(`${apiBase}/${table}?keycloak_sub=eq.${sub}`, {
      headers: {
        Authorization: `Bearer ${$keycloak.token}`
      }
    })
    const existing = res?.[0]
    if (existing) {
      existingRecord.value = existing
      if (isTeacher.value) {
        if (existing.ma_cb) userCode.value = existing.ma_cb
        if (existing.ho_ten) fullName.value = existing.ho_ten
        if (existing.don_vi) faculty.value = existing.don_vi
        if (existing.chuc_vu) chucVu.value = existing.chuc_vu
      } else {
        if (existing.ma_sv) userCode.value = existing.ma_sv
        if (existing.ho_ten) fullName.value = existing.ho_ten
        if (existing.khoa) faculty.value = existing.khoa
        if (existing.lop) major.value = existing.lop
        if (existing.sdt) phone.value = existing.sdt
        if (existing.ngay_sinh) dateOfBirth.value = existing.ngay_sinh
      }
    }
  } catch (err) {
    console.warn('Chưa có dữ liệu hồ sơ cũ:', err)
  }
})

const handleSubmit = async () => {
  const missing = !userCode.value.trim()
    || !faculty.value.trim()
    || !fullName.value.trim()
    || (isTeacher.value ? !chucVu.value : !major.value.trim() || !dateOfBirth.value)

  if (missing) {
    alertType.value = 'error'
    alertMessage.value = 'Vui lòng điền đầy đủ các thông tin bắt buộc (*)'
    return
  }

  isSubmitting.value = true
  alertMessage.value = ''

  try {
    const parsed = $keycloak.tokenParsed || {}
    const sub = parsed.sub
    const token = $keycloak.token
    const table = isTeacher.value ? 'can_bo' : 'sinh_vien'

    // Dữ liệu gửi đi (không gồm keycloak_sub khi cập nhật, vì khóa này không đổi)
    const fields = isTeacher.value
      ? {
          ho_ten: fullName.value.trim(),
          chuc_vu: chucVu.value,
          don_vi: faculty.value.trim(),
          email: email.value.trim()
        }
      : {
          ho_ten: fullName.value.trim(),
          ngay_sinh: dateOfBirth.value,
          lop: major.value.trim(),
          khoa: faculty.value.trim(),
          email: email.value.trim(),
          sdt: phone.value.trim() || null
        }

    const codeField = isTeacher.value ? 'ma_cb' : 'ma_sv'
    const headers = {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }

    let response
    if (existingRecord.value) {
      // Đã có hồ sơ: cập nhật đúng bản ghi của chính user (RLS cho phép)
      response = await fetch(`${apiBase}/${table}?keycloak_sub=eq.${sub}`, {
        method: 'PATCH',
        headers,
        body: JSON.stringify(fields)
      })
    } else {
      // Chưa có hồ sơ: tạo mới. Không dùng upsert để tránh đụng vào bản ghi của người khác.
      response = await fetch(`${apiBase}/${table}`, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          [codeField]: userCode.value.trim(),
          keycloak_sub: sub,
          ...fields
        })
      })
    }

    if (!response.ok) {
      const err = await response.json().catch(() => ({}))
      throw new Error(err.message || `Không thể lưu hồ sơ (mã lỗi ${response.status}).`)
    }

    alertType.value = 'success'
    alertMessage.value = 'Hồ sơ đã được lưu thành công! Đang chuyển hướng...'

    // Chuyển hướng đúng theo role
    setTimeout(() => {
      if (isTeacher.value) {
        navigateTo('/admin/homepageadmin')
      } else {
        navigateTo('/user/homepageuser')
      }
    }, 700)
  } catch (error) {
    console.error('Lỗi lưu hồ sơ:', error)
    alertType.value = 'error'
    alertMessage.value = error.message || 'Đã xảy ra lỗi khi lưu thông tin.'
  } finally {
    isSubmitting.value = false
  }
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');
* { box-sizing: border-box; margin: 0; padding: 0; }
.complete-wrapper { min-height: 100vh; display: flex; align-items: center; justify-content: center; background-color: #f8fafc; font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; padding: 40px 20px; }
.complete-card { width: 100%; max-width: 540px; background: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 36px 32px; box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.05); }
.card-header { margin-bottom: 24px; }
.brand-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.logo-bold { font-size: 1.25rem; font-weight: 800; color: #000000; }
.brand-row span:nth-child(2) { font-size: 1.25rem; color: #000000; }
.role-badge { font-size: 0.75rem; font-weight: 600; padding: 4px 10px; border-radius: 999px; background-color: #f1f5f9; color: #475569; }
.role-badge.teacher-badge { background-color: #000000; color: #ffffff; }
.card-title { font-size: 1.5rem; font-weight: 700; color: #0f172a; letter-spacing: -0.02em; margin-bottom: 6px; }
.card-subtitle { font-size: 0.9rem; color: #64748b; line-height: 1.5; }
.alert-box { padding: 12px 16px; border-radius: 6px; font-size: 0.9rem; margin-bottom: 20px; line-height: 1.4; }
.alert-box.error { background-color: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
.alert-box.success { background-color: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; }
.profile-form { display: flex; flex-direction: column; gap: 18px; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-label { font-size: 0.88rem; font-weight: 600; color: #334155; }
.required { color: #ef4444; }
.form-input { width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.95rem; color: #0f172a; background: #ffffff; outline: none; transition: border-color 0.15s ease, box-shadow 0.15s ease; font-family: inherit; }
.form-input:focus { border-color: #000000; box-shadow: 0 0 0 1px #000000; }
.readonly-input { background-color: #f8fafc; color: #64748b; cursor: not-allowed; border-color: #e2e8f0; }
.input-hint { font-size: 0.78rem; color: #94a3b8; }
.btn-submit { margin-top: 10px; background-color: #000000; color: #ffffff; border: none; padding: 12px; border-radius: 6px; font-size: 0.95rem; font-weight: 600; cursor: pointer; transition: opacity 0.15s ease; display: flex; align-items: center; justify-content: center; }
.btn-submit:hover:not(:disabled) { opacity: 0.85; }
.btn-submit:disabled { opacity: 0.6; cursor: not-allowed; }
.loading-state { display: flex; align-items: center; gap: 8px; }
.mini-spinner { width: 16px; height: 16px; border: 2px solid #ffffff; border-top-color: transparent; border-radius: 50%; animation: spin 0.8s linear infinite; display: inline-block; }
@keyframes spin { to { transform: rotate(360deg); } }
</style>