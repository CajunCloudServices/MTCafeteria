#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT_DIR/.env}"

cd "$ROOT_DIR"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: env file is missing at $ENV_FILE" >&2
  exit 1
fi

echo "Deploying Docker stack (web image builds Flutter inside the Dockerfile)..."
docker compose --env-file "$ENV_FILE" up -d --build --remove-orphans

echo "Running post-deploy health checks..."
ENV_FILE="$ENV_FILE" node "$ROOT_DIR/scripts/post_deploy_healthcheck.mjs"
