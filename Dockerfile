FROM node:22-alpine AS builder
WORKDIR /app

# Install pnpm
RUN apk add --no-cache libc6-compat
RUN npm install -g pnpm@8

# Copy package manifests first to leverage layer cache
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install 

# Copy source and build
COPY . .
RUN pnpm run build

FROM nginx:stable-alpine

# Copy built static site
COPY --from=builder /app/dist /usr/share/nginx/html

# Replace default nginx conf with our SPA-friendly config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
