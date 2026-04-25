#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT_DIR/.env}"

cd "$ROOT_DIR"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: env file is missing at $ENV_FILE" >&2
  exit 1
fi

echo "Building and syncing Flutter web bundle into public/flutter-web..."
bash "$ROOT_DIR/scripts/build_and_sync_flutter_web.sh" --release --pwa-strategy=none

echo "Deploying Docker stack..."
docker compose --env-file "$ENV_FILE" up -d --build --remove-orphans

echo "Running post-deploy health checks..."
ENV_FILE="$ENV_FILE" node "$ROOT_DIR/scripts/post_deploy_healthcheck.mjs"
