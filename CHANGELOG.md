# Changelog

## [1.0.0] - 2026-10-20

### Added

- **Third-Party Compliance (PoF)** - Comprehensive open-source declaration and license compatibility table in README
- **License & Governance** - MIT License and project operational guide in GUIDE.txt
- **Changelog Documentation** - Initialized project changelog tracking development history

### Changed

- **Role-based Redirection** - Automatic routing to admin or student views based on Keycloak realm roles
- **SSO Logout Integration** - Global session termination clearing local auth tokens and Keycloak session
- **Client-Side Auth Flow** - Replaced intermediate callback page with direct Nuxt client plugin (keycloak.client.ts)

### Removed

- Deprecated intermediate authentication callback page (student-portal/pages/callback.vue)

## [UNRELEASED] - 2026-10-18

### Added

- **End-to-End Integration** - Unified end-to-end flow connecting Nuxt 3, APISIX, Keycloak, and PostgREST
- **Keycloak OIDC & PKCE** - Client-side authentication flow using keycloak-js and realm configuration in dxos-realm.json
- **APISIX Gateway JWT Validation** - Gateway route `/api/v1/` with token validation against Keycloak JWKS endpoint

### Changed

- Standardized container port bindings across services (3001 Portal, 8080 Keycloak, 9080 APISIX Gateway)

### Fixed

- JWT claim passing and Authorization header propagation between APISIX Gateway and PostgREST

## [UNRELEASED] - 2026-10-17

### Added

- **PostgreSQL Data Service** - Database schema for digital student administration (users, profiles, applications)
- **Row Level Security (RLS)** - Security policies in 03_security_rls.sql enforcing user_id = sub claim
- **PostgREST Configuration** - Auto-generated RESTful API service from PostgreSQL tables
- **Student & Admin Portals** - Nuxt 3 web views for students (homepageuser.vue) and administrators (homepageadmin.vue)
- **APISIX OIDC Authentication** - Initial OIDC integration for APISIX Gateway

## [UNRELEASED] - 2026-10-07

### Added

- **Environment Setup** - Initial project environment and Docker Compose stack
- **Unified Docker Compose** - Root docker-compose.yml orchestrating APISIX, etcd, and Nuxt 3 Student Portal
- **APISIX & etcd Setup** - Initial Apache APISIX Gateway configuration and etcd distributed storage
- **Student Portal Boilerplate** - Nuxt 3 frontend application setup with TypeScript and Dockerfile
- **Operational Guide** - Deployment instructions and commands in GUIDE.txt

### Fixed

- APISIX container startup failures and network issues with etcd

---

## Component Versions

| Component       | Version   | Technology / Role                    |
| --------------- | --------- | ------------------------------------ |
| Student Portal  | 1.0.0     | Nuxt 3.21.x + Vue 3.5.x              |
| Apache APISIX   | 3.13.0    | API Gateway & OIDC Validation        |
| Keycloak Server | 26.8.0    | Identity and Access Management (IAM) |
| Keycloak JS     | 26.0.x    | OIDC Web Client Library              |
| PostgREST       | 12.0.x    | Automatic REST API Engine            |
| PostgreSQL      | 16-alpine | Relational Database & RLS            |
| etcd            | 3.5.11    | Distributed Key-Value Store          |
