#!/usr/bin/env bash
# =============================================================================
# cli/lib/config.sh — NDW configuration
# Single source of truth for version, paths, and runtime config
# =============================================================================
set -euo pipefail

# Version — bump this on every release
NDW_VERSION="0.1.0"

# Config directory
NDW_CONFIG_DIR="${NDW_CONFIG_DIR:-$HOME/.config/ndw}"
NDW_CONFIG_FILE="$NDW_CONFIG_DIR/config.env"

export NDW_VERSION NDW_CONFIG_DIR NDW_CONFIG_FILE

# Load user config if it exists
if [[ -f "$NDW_CONFIG_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$NDW_CONFIG_FILE"
fi
