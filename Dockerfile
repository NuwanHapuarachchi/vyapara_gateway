# Multi-stage Dockerfile to build Flutter Web and serve with Nginx

# --- Build stage: compile Flutter web app ---
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Cache dependencies first
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source and build
COPY . .
RUN flutter pub get --offline \
 && flutter build web --release --web-renderer canvaskit --tree-shake-icons


# --- Runtime stage: serve via Nginx ---
FROM nginx:1.25-alpine AS runtime

# Replace default server with SPA-aware config
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf

# Copy built web assets
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]


