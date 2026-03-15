#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLCHAIN_DIR="$ROOT_DIR/tool/linux_toolchain_wrapped"

if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="${FLUTTER_BIN:-$(command -v flutter)}"
else
  FLUTTER_BIN="${FLUTTER_BIN:-$HOME/Software/sdk/flutter_sdk/bin/flutter}"
fi

if [[ ! -d "$TOOLCHAIN_DIR" ]]; then
  echo "Missing shared Linux toolchain wrapper directory: $TOOLCHAIN_DIR" >&2
  exit 1
fi

export PATH="$TOOLCHAIN_DIR:$PATH"
exec "$FLUTTER_BIN" "$@"