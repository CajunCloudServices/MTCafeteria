# syntax=docker/dockerfile:1
#
# Flutter is compiled in-image so production always matches frontend_flutter/ —
# you do not need to commit public/flutter-web for Docker-based deploys.

FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build
WORKDIR /frontend

COPY frontend_flutter/pubspec.yaml frontend_flutter/pubspec.lock ./
RUN flutter pub get

COPY frontend_flutter/ ./
RUN flutter build web --release --pwa-strategy=none

FROM node:22-alpine

WORKDIR /app

COPY web/package*.json ./
RUN npm ci --omit=dev

COPY web ./

COPY public ./public

COPY --from=flutter-build /frontend/build/web ./public/flutter-web

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["npm", "start"]
