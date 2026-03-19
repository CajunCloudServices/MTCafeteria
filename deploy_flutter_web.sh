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

mkdir -p "$TARGET_DIR"
rsync -av --delete "$SOURCE_DIR"/ "$TARGET_DIR"/

echo "Deployed Flutter web build to $TARGET_DIR"
