#!/usr/bin/env bash
# =============================================================================
# cli/lib/output.sh — Colored terminal output helpers
# Auto-disables colors when stdout is not a TTY (e.g. pipes, CI)
# =============================================================================

if [[ -t 1 ]]; then
  COLOR_RESET="\033[0m"
  COLOR_BOLD="\033[1m"
  COLOR_DIM="\033[2m"
  COLOR_RED="\033[0;31m"
  COLOR_GREEN="\033[0;32m"
  COLOR_YELLOW="\033[0;33m"
  COLOR_BLUE="\033[0;34m"
  COLOR_CYAN="\033[0;36m"
else
  COLOR_RESET=""
  COLOR_BOLD=""
  COLOR_DIM=""
  COLOR_RED=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_BLUE=""
  COLOR_CYAN=""
fi

output_header() {
  echo -e "\n${COLOR_BOLD}${COLOR_CYAN}$*${COLOR_RESET}"
  echo -e "${COLOR_DIM}$(printf '%.0s─' {1..50})${COLOR_RESET}"
}

output_info() {
  echo -e "  ${COLOR_BLUE}→${COLOR_RESET}  $*"
}

output_success() {
  echo -e "  ${COLOR_GREEN}✓${COLOR_RESET}  $*"
}

output_warning() {
  echo -e "  ${COLOR_YELLOW}⚠${COLOR_RESET}  $*"
}

output_error() {
  echo -e "  ${COLOR_RED}✗${COLOR_RESET}  $*" >&2
}

output_dim() {
  echo -e "  ${COLOR_DIM}$*${COLOR_RESET}"
}

output_blank() {
  echo ""
}
