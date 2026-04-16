#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_DIR="$ROOT_DIR/.githooks"

if [ ! -d "$ROOT_DIR/.git" ]; then
  echo "ERROR: $ROOT_DIR is not a git repository root." >&2
  exit 1
fi

if [ ! -d "$HOOKS_DIR" ]; then
  echo "ERROR: Missing hooks directory at $HOOKS_DIR" >&2
  exit 1
fi

chmod +x "$HOOKS_DIR"/pre-push
git -C "$ROOT_DIR" config core.hooksPath .githooks

echo "Configured git hooks: core.hooksPath=.githooks"
echo "Active hook: .githooks/pre-push"
