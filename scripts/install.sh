#!/usr/bin/env bash
set -euo pipefail

if ! command -v pwsh >/dev/null 2>&1; then
  echo "PowerShell 7+ (pwsh) is required for the cross-platform installer." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pwsh -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/install.ps1" "$@"
