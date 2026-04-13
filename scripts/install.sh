#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for PowerShell 7+
if command -v pwsh >/dev/null 2>&1; then
  PWSH=pwsh
elif command -v powershell >/dev/null 2>&1; then
  echo "Warning: Using 'powershell' (Windows PowerShell). 'pwsh' (PowerShell 7+) is recommended." >&2
  PWSH=powershell
else
  echo "Error: PowerShell 7+ (pwsh) is required." >&2
  echo "" >&2
  echo "Install it from: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell" >&2
  echo "" >&2
  echo "Quick install:" >&2
  echo "  macOS:  brew install powershell/tap/powershell" >&2
  echo "  Ubuntu: sudo snap install powershell --classic" >&2
  echo "  Fedora: sudo dnf install powershell" >&2
  exit 1
fi

exec "$PWSH" -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/install.ps1" "$@"
