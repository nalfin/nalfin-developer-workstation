#!/usr/bin/env bash
# =============================================================================
# cli/commands/bootstrap.sh — ndw bootstrap
# Restore identity on this workstation: workspace folders + dotfiles
# =============================================================================

cmd_bootstrap() {
  local subcommand="${1:-run}"
  shift || true

  case "$subcommand" in
    run)     _bootstrap_run "$@" ;;
    help | --help | -h) _bootstrap_help ;;
    *)
      output_error "Unknown subcommand: '$subcommand'"
      output_info  "Run 'ndw bootstrap --help' to see available subcommands."
      exit 1
      ;;
  esac
}

_bootstrap_run() {
  output_header "NDW — Bootstrap"
  output_dim "Restoring workstation identity..."
  output_blank

  _bootstrap_workspace
  _bootstrap_dotfiles

  output_blank
  output_success "Bootstrap complete!"
  output_dim     "Run 'ndw doctor' to check which tools are still missing."
  output_blank
}

_bootstrap_workspace() {
  output_header "Workspace Folders"

  source "$NDW_ROOT/cli/lib/yaml.sh"

  while IFS= read -r folder; do
    [[ -z "$folder" ]] && continue
    local expanded
    expanded="${folder/#\~/$HOME}"
    mkdir -p "$expanded"
    output_success "$folder"
  done < <(yaml_list "$NDW_ROOT/config/workspace.yaml" "folders")

  output_blank
}

_bootstrap_dotfiles() {
  output_header "Dotfiles"

  local dotfiles_dir="$NDW_ROOT/dotfiles"

  _link "$dotfiles_dir/gitconfig"     "$HOME/.gitconfig"
  _link "$dotfiles_dir/aliases.sh"    "$HOME/.ndw_aliases"
  _link "$dotfiles_dir/starship.toml" "$HOME/.config/starship.toml"

  _wire_shell_rc "$HOME/.bashrc"
  is_macos && _wire_shell_rc "$HOME/.zshrc"

  output_blank
  output_success "Dotfiles installed!"
  output_dim     "Reload shell: source ~/.bashrc  (or open a new Warp tab)"
  output_blank
}

# Add a source line for ~/.ndw_aliases to a shell rc file, once.
_wire_shell_rc() {
  local rc="$1"
  local shell_name
  shell_name="$(basename "$rc" | sed 's/^\.//')"  # bashrc / zshrc

  mkdir -p "$(dirname "$rc")"
  touch "$rc"

  if grep -qF ".ndw_aliases" "$rc" 2>/dev/null; then
    output_success "Already wired: $rc"
    return
  fi

  {
    echo ""
    echo "# Added by NDW"
    echo '[[ -f "$HOME/.ndw_aliases" ]] && source "$HOME/.ndw_aliases"'
    echo "command -v starship >/dev/null 2>&1 && eval \"\$(starship init ${shell_name%rc})\""
  } >> "$rc"
  output_success "Wired: $rc → sources ~/.ndw_aliases + starship (if installed)"
}

_link() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [[ -f "$target" && ! -L "$target" ]]; then
    mv "$target" "${target}.backup"
    output_warning "Backed up: $target → ${target}.backup"
  fi

  [[ -L "$target" ]] && rm "$target"

  if ln -s "$source" "$target" 2>/dev/null; then
    output_success "Linked: $target → $source"
  else
    # Symlinks need Developer Mode on Windows — fall back to a copy.
    cp "$source" "$target"
    output_warning "Copied (symlink failed): $target"
    output_dim     "Enable Developer Mode on Windows for real symlinks (Settings → For developers)."
  fi
}

_bootstrap_help() {
  output_header "ndw bootstrap — Workstation Identity"

  echo -e "  ${COLOR_BOLD}Usage:${COLOR_RESET}"
  echo -e "    ndw bootstrap [subcommand]"
  output_blank

  echo -e "  ${COLOR_BOLD}Subcommands:${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}run${COLOR_RESET}    Restore workstation identity (default)"
  output_blank

  echo -e "  ${COLOR_BOLD}What it does:${COLOR_RESET}"
  echo -e "    ${COLOR_DIM}1. Create workspace folders from config/workspace.yaml${COLOR_RESET}"
  echo -e "    ${COLOR_DIM}2. Install dotfiles (gitconfig, aliases, starship prompt)${COLOR_RESET}"
  output_blank
  output_dim "Run 'ndw restore --ssh' first if this is a new device."
  output_blank
}
