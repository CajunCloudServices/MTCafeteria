#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
  echo "ERROR: .env is missing. Copy .env.example to .env and set production values first."
  exit 1
fi

git fetch origin
git pull --ff-only origin main
docker compose --env-file .env up -d --build --remove-orphans
