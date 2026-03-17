#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

BUILD_IMAGES=true
BUILD_FRONTEND=false

for arg in "$@"; do
  case "$arg" in
    --no-build)
      BUILD_IMAGES=false
      ;;
    --build-frontend)
      BUILD_FRONTEND=true
      ;;
    --help|-h)
      cat <<'USAGE'
Usage: ./deploy_web_stack.sh [--no-build] [--build-frontend]
  --no-build        Skip docker image rebuild and just restart containers.
  --build-frontend  Force local flutter web build before docker compose.
USAGE
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      exit 1
      ;;
  esac
done

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example. Review values before exposing publicly."
fi

set -a
source ./.env
set +a

if [ "${JWT_SECRET:-replace-with-strong-secret}" = "replace-with-strong-secret" ]; then
  echo "ERROR: Set a real JWT_SECRET in .env before deploying."
  exit 1
fi

FRONTEND_DOCKERFILE="frontend_flutter/Dockerfile"

if [ "$BUILD_FRONTEND" = true ] || [ ! -f frontend_flutter/build/web/index.html ]; then
  FLUTTER_BIN="${FLUTTER_BIN:-}"
  if [ -z "$FLUTTER_BIN" ] && command -v flutter >/dev/null 2>&1; then
    FLUTTER_BIN="$(command -v flutter)"
  fi
  if [ -z "$FLUTTER_BIN" ] && [ -x "/Users/lajicpajam/Development/flutter/bin/flutter" ]; then
    FLUTTER_BIN="/Users/lajicpajam/Development/flutter/bin/flutter"
  fi

  if [ -n "$FLUTTER_BIN" ]; then
    echo "Building Flutter web locally with: $FLUTTER_BIN"
    (
      cd frontend_flutter
      "$FLUTTER_BIN" pub get
      "$FLUTTER_BIN" build web --release --dart-define=API_BASE_URL=
    )
  else
    echo "Flutter binary not found. Falling back to dockerized frontend build (slower)."
    FRONTEND_DOCKERFILE="frontend_flutter/Dockerfile.builder"
  fi
fi

export FRONTEND_DOCKERFILE

echo "Starting backend/frontend/database (frontend dockerfile: $FRONTEND_DOCKERFILE)..."
if [ "$BUILD_IMAGES" = true ]; then
  sudo docker compose --env-file .env up -d --build backend frontend postgres
else
  sudo docker compose --env-file .env up -d backend frontend postgres
fi

echo "Applying database schema and seed (idempotent)..."
sudo docker compose --env-file .env exec -T postgres \
  psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-mtc_cafeteria}" \
  < backend/sql/schema.sql
sudo docker compose --env-file .env exec -T postgres \
  psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-mtc_cafeteria}" \
  < backend/sql/seed.sql

echo
echo "Stack status:"
sudo docker compose --env-file .env ps
echo
if command -v hostname >/dev/null 2>&1; then
  HOST_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
fi
if [ -z "${HOST_IP:-}" ]; then
  HOST_IP="localhost"
fi
echo "Frontend URL: http://${HOST_IP}:${FRONTEND_PORT:-8086}"
echo "Backend health: http://${HOST_IP}:${BACKEND_PORT:-3201}/health"
