#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/frontend_flutter"
BUILD_DIR="$FRONTEND_DIR/build/web"
SYNC_SCRIPT="$ROOT_DIR/deploy_flutter_web.sh"
FLUTTER_BIN="${FLUTTER_BIN:-flutter}"

if ! command -v "$FLUTTER_BIN" >/dev/null 2>&1; then
  echo "ERROR: Flutter CLI not found. Install Flutter or set FLUTTER_BIN." >&2
  exit 1
fi

if [ ! -d "$FRONTEND_DIR" ]; then
  echo "ERROR: Missing frontend directory at $FRONTEND_DIR" >&2
  exit 1
fi

build_args=("$@")
if [ "${#build_args[@]}" -eq 0 ]; then
  build_args=(--release --pwa-strategy=none --no-tree-shake-icons)
fi

echo "Running Flutter dependency sync..."
(cd "$FRONTEND_DIR" && "$FLUTTER_BIN" pub get)

echo "Building Flutter web bundle..."
(cd "$FRONTEND_DIR" && "$FLUTTER_BIN" build web "${build_args[@]}")

echo "Syncing Flutter web bundle into public/flutter-web..."
"$SYNC_SCRIPT" "$BUILD_DIR"

echo "Flutter web bundle is ready in public/flutter-web"
