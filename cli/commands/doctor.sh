#!/usr/bin/env bash
# =============================================================================
# cli/commands/doctor.sh — ndw doctor
# Check environment health
# =============================================================================

cmd_doctor() {
  output_header "Doctor — $(os_label)"

  local has_error=0

  _check_docker                                                                          || has_error=1
  _check_tool "Git"       "git"       "--version"  "sudo apt install git"               || has_error=1
  _check_tool "Node.js"   "node"      "--version"  "https://nodejs.org"                 || has_error=1
  _check_tool "pnpm"      "pnpm"      "--version"  "npm install -g pnpm"                || has_error=1
  _check_tool "Python"    "python3"   "--version"  "sudo apt install python3"           || has_error=1
  _check_tool "uv"        "uv"        "--version"  "https://github.com/astral-sh/uv"   || has_error=1
  _check_tool "PHP"       "php"       "--version"  "sudo apt install php"               || has_error=1
  _check_tool "Composer"  "composer"  "--version"  "https://getcomposer.org"            || has_error=1
  _check_ssh                                                                             || has_error=1

  output_blank

  if [[ $has_error -eq 1 ]]; then
    output_warning "Some checks failed. See above for details."
  else
    output_success "All checks passed."
  fi

  output_blank
}

_check_docker() {
  local version
  version="$(docker version --format '{{.Client.Version}}' 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1 || true)"

  if [[ -n "$version" ]]; then
    output_success "$(printf '%-12s' "Docker") ${COLOR_DIM}${version}${COLOR_RESET}"
    return 0
  fi

  if command_exists "docker"; then
    output_warning "$(printf '%-12s' "Docker") Found but not connected — enable WSL integration in Docker Desktop"
    return 1
  fi

  output_error "$(printf '%-12s' "Docker") Not found — https://docs.docker.com/get-docker"
  return 1
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

_check_ssh() {
  local ssh_dir="$HOME/.ssh"

  if [[ ! -d "$ssh_dir" ]]; then
    output_error "$(printf '%-12s' "SSH key")  Not found — run: ssh-keygen -t ed25519"
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

  output_error "$(printf '%-12s' "SSH key")  Not found — run: ssh-keygen -t ed25519"
  return 1
}
