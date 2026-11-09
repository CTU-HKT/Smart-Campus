// SPDX-License-Identifier: MIT
// Copyright (c) 2026 CTU-HKT

export type UserRole = 'student' | 'teacher' | 'admin' | null

export interface User {
  id: string
  name: string
  username: string
  email: string
  role: UserRole
}

export const useAuth = () => {
  // Dùng cookie để lưu thông tin người dùng và token khi F5
  const authUser = useCookie<User | null>('auth_user', { default: () => null })
  const token = useCookie<string | null>('access_token', { default: () => null })

  // Kiểm tra trạng thái đăng nhập
  const isLoggedIn = computed(() => !!authUser.value)

  // Kiểm tra quyền
  const isAdminOrTeacher = computed(() => {
    return authUser.value?.role === 'admin' || authUser.value?.role === 'teacher'
  })

  const isStudent = computed(() => authUser.value?.role === 'student')

  // Hàm Đăng xuất triệt để cả Cookie lẫn Keycloak SSO
  const logout = async () => {
    authUser.value = null
    token.value = null

    // Gọi Keycloak logout để hủy session trên Keycloak Server
    if (typeof window !== 'undefined') {
      const nuxtApp = useNuxtApp() as any
      if (nuxtApp.$keycloak && nuxtApp.$keycloak.authenticated) {
        await nuxtApp.$keycloak.logout({ redirectUri: window.location.origin })
        return
      }
    }

    navigateTo('/')
  }

  return {
    user: authUser,
    token,
    isLoggedIn,
    isAdminOrTeacher,
    isStudent,
    logout
  }
}
