#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: ./deploy_flutter_web.sh /absolute/path/to/flutter/build/web"
  exit 1
fi

SOURCE_DIR="$1"
TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/public/flutter-web"

if [[ "$SOURCE_DIR" != /* ]]; then
  echo "ERROR: Provide an absolute path to the Flutter build/web directory."
  exit 1
fi

if [ ! -d "$SOURCE_DIR" ] || [ ! -f "$SOURCE_DIR/index.html" ]; then
  echo "ERROR: '$SOURCE_DIR' does not look like a Flutter web build directory."
  exit 1
fi

required_files=(
  "index.html"
  "main.dart.js"
  "flutter_bootstrap.js"
  "flutter_service_worker.js"
)

for rel in "${required_files[@]}"; do
  if [ ! -f "$SOURCE_DIR/$rel" ]; then
    echo "ERROR: Missing required Flutter artifact '$rel' in '$SOURCE_DIR'."
    echo "Run a fresh Flutter web build and retry."
    exit 1
  fi
done

if [ ! -s "$SOURCE_DIR/main.dart.js" ]; then
  echo "ERROR: '$SOURCE_DIR/main.dart.js' is empty."
  echo "Run a fresh Flutter web build and retry."
  exit 1
fi

mkdir -p "$TARGET_DIR"
rsync -av --delete "$SOURCE_DIR"/ "$TARGET_DIR"/

echo "Deployed Flutter web build to $TARGET_DIR"
