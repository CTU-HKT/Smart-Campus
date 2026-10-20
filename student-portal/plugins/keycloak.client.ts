// SPDX-License-Identifier: MIT
// Copyright (c) 2026 CTU-HKT. All rights reserved.

import Keycloak from 'keycloak-js'

export default defineNuxtPlugin(async (nuxtApp) => {
  const keycloak = new Keycloak({
    url: 'http://localhost:8080',
    realm: 'dxos',
    clientId: 'portal'
  })

  try {
    // Khởi tạo, bật PKCE để bảo mật, kiểm tra xem user đã login chưa
    const authenticated = await keycloak.init({
      onLoad: 'check-sso',
      pkceMethod: 'S256',
      checkLoginIframe: false
    })

    // Tự động refresh token trước khi hết hạn 60 giây
    if (authenticated) {
      setInterval(() => {
        keycloak.updateToken(60).catch(() => {
          console.error('Không thể refresh token')
        })
      }, 10000)
    }
  } catch (error) {
    console.error('Lỗi khởi tạo Keycloak:', error)
  }

  // Cung cấp keycloak cho toàn bộ app qua hàm useNuxtApp().$keycloak
  return {
    provide: {
      keycloak
    }
  }
})