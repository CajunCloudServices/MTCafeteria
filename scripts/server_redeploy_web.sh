#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
  echo "ERROR: .env is missing. Copy .env.example to .env and set production values first."
  exit 1
fi

bash "$ROOT_DIR/scripts/build_and_sync_flutter_web.sh" --release --pwa-strategy=none
docker compose --env-file .env up -d --build web
