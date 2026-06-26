#!/usr/bin/env bash
# =============================================================================
# cli/lib/common.sh — Shared utility functions
# =============================================================================
set -euo pipefail

# Check if a command exists in PATH
command_exists() {
  command -v "$1" &>/dev/null
}

# Require a command or exit with a helpful message
require_command() {
  local cmd="$1"
  local hint="${2:-}"
  if ! command_exists "$cmd"; then
    output_error "Required command not found: '$cmd'"
    [[ -n "$hint" ]] && output_info "$hint"
    exit 1
  fi
}

# OS detection
is_wsl()   { [[ -f /proc/version ]] && grep -qi "microsoft" /proc/version; }
is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
is_linux() { [[ "$(uname -s)" == "Linux" ]]; }

# Human-readable OS label
os_label() {
  if is_wsl;     then echo "WSL2 (Windows)"
  elif is_macos; then echo "macOS"
  elif is_linux; then echo "Linux"
  else echo "Unknown"
  fi
}
