# Giai đoạn 1: Build ứng dụng
FROM node:22-alpine AS build

# Thư mục làm việc bên trong container
WORKDIR /app

# Copy file khai báo package trước
COPY package*.json ./

# Cài dependency
RUN npm install --legacy-peer-deps

# Copy toàn bộ source code
COPY . .

# Build Nuxt 3
RUN npm run build


# Giai đoạn 2: Chạy ứng dụng
FROM node:22-alpine

WORKDIR /app

# Chỉ lấy sản phẩm đã build
COPY --from=build /app/.output ./.output

# Nuxt server lắng nghe port 3000
ENV PORT=3000
ENV HOST=0.0.0.0

EXPOSE 3000

# Chạy Nuxt production server
CMD ["node", ".output/server/index.mjs"]