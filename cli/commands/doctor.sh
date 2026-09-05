#!/usr/bin/env bash
# =============================================================================
# cli/commands/doctor.sh — ndw doctor
# Check environment health
# =============================================================================

cmd_doctor() {
  output_header "Doctor — $(os_label)"

  local has_error=0

  _check_tool "Git"       "git"       "--version"  "$(_hint_git)"       || has_error=1
  _check_tool "Node.js"   "node"      "--version"  "$(_hint_node)"      || has_error=1
  _check_tool "pnpm"      "pnpm"      "--version"  "corepack prepare pnpm@latest --activate" || has_error=1
  _check_tool "Python"    "python3"   "--version"  "$(_hint_python)"    || has_error=1
  _check_tool "uv"        "uv"        "--version"  "https://github.com/astral-sh/uv" || has_error=1
  _check_tool "PHP"       "php"       "--version"  "$(_hint_php)"       || has_error=1
  _check_tool "Composer"  "composer"  "--version"  "https://getcomposer.org" || has_error=1
  _check_tool "rclone"    "rclone"    "version"    "https://rclone.org/install" || has_error=1
  _check_ssh                                                            || has_error=1
  _check_evocave_identity

  output_blank

  if [[ $has_error -eq 1 ]]; then
    output_warning "Some checks failed. See above for details."
    output_dim     "Run 'bash bootstrap/setup' to install missing tools."
  else
    output_success "All checks passed."
  fi

  output_blank
}

_hint_git() {
  if is_windows; then echo "winget install Git.Git"
  elif is_macos; then echo "brew install git"
  else echo "sudo apt install git"
  fi
}

_hint_node() {
  if is_windows; then echo "winget install OpenJS.NodeJS.LTS"
  elif is_macos; then echo "brew install node"
  else echo "https://nodejs.org"
  fi
}

_hint_python() {
  if is_windows; then echo "winget install Python.Python.3"
  elif is_macos; then echo "brew install python3"
  else echo "sudo apt install python3"
  fi
}

_hint_php() {
  if is_windows; then echo "winget install PHP.PHP"
  elif is_macos; then echo "brew install php"
  else echo "sudo apt install php"
  fi
}

_check_tool() {
  local label="$1"
  local cmd="$2"
  local flag="$3"
  local hint="$4"

  if command_exists "$cmd"; then
    local version
    version="$("$cmd" "$flag" 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || echo "unknown")"
    output_success "$(printf '%-12s' "$label") ${COLOR_DIM}${version}${COLOR_RESET}"
    return 0
  else
    output_error "$(printf '%-12s' "$label") Not found — $hint"
    return 1
  fi
}

_check_evocave_identity() {
  if [[ -f "$HOME/.gitconfig-evocave" ]]; then
    output_success "$(printf '%-12s' "Evocave git")  ${COLOR_DIM}~/.gitconfig-evocave found${COLOR_RESET}"
  else
    output_warning "$(printf '%-12s' "Evocave git")  ~/.gitconfig-evocave not found"
    output_dim     "             Commits in ~/dev/projects/evocave/ will silently use your default identity."
    output_dim     "             Create it: cat > ~/.gitconfig-evocave << 'EOF'"
    output_dim     "                        [user]"
    output_dim     "                            email = your-evocave-email@example.com"
    output_dim     "                        EOF"
  fi
}

_check_ssh() {
  local ssh_dir="$HOME/.ssh"

  if [[ ! -d "$ssh_dir" ]]; then
    output_error "$(printf '%-12s' "SSH key")  Not found — run: ndw restore --ssh"
    return 1
  fi

  local key
  for f in "$ssh_dir"/*; do
    [[ -f "$f" ]] || continue
    [[ "$f" == *.pub ]] && continue
    [[ "$(basename "$f")" == "known_hosts" ]] && continue
    [[ "$(basename "$f")" == "known_hosts.old" ]] && continue
    [[ "$(basename "$f")" == "config" ]] && continue
    key="$f"
    break
  done

  if [[ -n "${key:-}" ]]; then
    output_success "$(printf '%-12s' "SSH key")  ${COLOR_DIM}${key}${COLOR_RESET}"
    return 0
  fi

  output_error "$(printf '%-12s' "SSH key")  Not found — run: ndw restore --ssh"
  return 1
}
