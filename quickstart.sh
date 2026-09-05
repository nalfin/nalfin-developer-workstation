#!/usr/bin/env bash
# =============================================================================
# quickstart.sh — One-line installer for a brand new device
#
# Usage (Windows Git Bash / macOS Terminal — after Git is installed):
#
#   curl -fsSL https://raw.githubusercontent.com/nalfin/nalfin-developer-workstation/main/quickstart.sh | bash
#
# This only works because the repo is public — no SSH key/token needed to
# clone. SSH keys themselves are restored separately from Google Drive
# (see `ndw restore --ssh`) since they must never live in this repo.
# =============================================================================
set -euo pipefail

REPO_URL="https://github.com/nalfin/nalfin-developer-workstation.git"
TARGET_DIR="$HOME/dev/platform/nalfin-developer-workstation"

echo ""
echo "NDW Quickstart"
echo "──────────────────────────────────────────────────"

if ! command -v git >/dev/null 2>&1; then
  echo "✗ Git is not installed — this is the one thing you need to install manually first."
  echo ""
  echo "  Windows: https://git-scm.com/download/win  (gives you Git Bash)"
  echo "  macOS:   xcode-select --install"
  echo ""
  echo "Then re-run this command."
  exit 1
fi

mkdir -p "$(dirname "$TARGET_DIR")"

if [[ -d "$TARGET_DIR/.git" ]]; then
  echo "→ Repo already exists at $TARGET_DIR, pulling latest..."
  git -C "$TARGET_DIR" pull
else
  echo "→ Cloning to $TARGET_DIR..."
  git clone "$REPO_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"

echo "→ Running bootstrap/install..."
bash bootstrap/install

echo ""
echo "──────────────────────────────────────────────────"
echo "Done! Next steps:"
echo ""
echo "  ndw restore --ssh     # restore your SSH keys (new device)"
echo "  ndw bootstrap          # create workspace folders + dotfiles"
echo "  bash bootstrap/setup   # optional: install Node/PHP/Python/Warp/VS Code/etc"
echo ""
