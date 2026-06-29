#!/usr/bin/env bash
# =============================================================================
# cli/commands/bootstrap.sh — ndw bootstrap
# Setup workstation from scratch using config files
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
  output_dim "Setting up workstation from config..."
  output_blank

  _bootstrap_workspace
  _bootstrap_env
  _bootstrap_databases
  _bootstrap_dotfiles

  output_blank
  output_success "Bootstrap complete!"
  output_dim     "Run 'ndw doctor' to verify your environment."
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

_bootstrap_env() {
  output_header "Generate ENV"

  source "$NDW_ROOT/cli/lib/yaml.sh"

  local pg_user pg_port redis_port adminer_port mailpit_smtp mailpit_ui
  local services_yaml="$NDW_ROOT/config/services.yaml"
  local env_file="$NDW_ROOT/infra/.env"

  pg_user="$(yaml_get "$services_yaml" "postgres.user")"
  pg_port="$(yaml_get "$services_yaml" "postgres.port")"
  redis_port="$(yaml_get "$services_yaml" "redis.port")"
  adminer_port="$(yaml_get "$services_yaml" "adminer.port")"
  mailpit_smtp="$(yaml_get "$services_yaml" "mailpit.smtp_port")"
  mailpit_ui="$(yaml_get "$services_yaml" "mailpit.ui_port")"

  cat > "$env_file" << ENVEOF
# =============================================================================
# infra/.env — Generated from config/services.yaml
# Do not edit manually — run: bash bootstrap/generate-env
# =============================================================================

# PostgreSQL
POSTGRES_USER=${pg_user}
POSTGRES_PASSWORD=secret
POSTGRES_PORT=${pg_port}

# Redis
REDIS_PORT=${redis_port}

# Adminer
ADMINER_PORT=${adminer_port}

# Mailpit
MAILPIT_SMTP_PORT=${mailpit_smtp}
MAILPIT_UI_PORT=${mailpit_ui}
ENVEOF

  output_success "infra/.env generated from config/services.yaml"
  output_blank
}

_bootstrap_databases() {
  output_header "Databases"

  if ! command_exists "docker"; then
    output_warning "Docker not found — skipping database setup"
    output_info    "Start Docker Desktop and run 'ndw bootstrap' again"
    output_blank
    return
  fi

  if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -q "ndw_postgres"; then
    output_warning "PostgreSQL not running — starting services first..."
    source "$NDW_ROOT/cli/commands/db.sh"
    _db_compose up -d
    output_blank
    output_info "Waiting for PostgreSQL to be ready..."
    sleep 3
  fi

  local user
  user="$(grep "^POSTGRES_USER" "$NDW_ROOT/infra/.env" | cut -d= -f2)"

  source "$NDW_ROOT/cli/lib/yaml.sh"

  while IFS= read -r dbname; do
    [[ -z "$dbname" ]] && continue
    local exists
    exists="$(docker exec ndw_postgres psql -U "$user" -d postgres -tAc \
      "SELECT 1 FROM pg_database WHERE datname='$dbname';" 2>/dev/null || true)"
    if [[ "$exists" == "1" ]]; then
      output_success "$(printf '%-20s' "$dbname") already exists"
    else
      docker exec -i ndw_postgres psql -U "$user" -d postgres -c \
        "CREATE DATABASE $dbname;" &>/dev/null
      output_success "$(printf '%-20s' "$dbname") created"
    fi
  done < <(yaml_list "$NDW_ROOT/config/services.yaml" "postgres.databases")

  output_blank
}

_bootstrap_dotfiles() {
  output_header "Dotfiles"

  local dotfiles_dir="$NDW_ROOT/dotfiles"

  _link "$dotfiles_dir/zshrc"     "$HOME/.zshrc"
  _link "$dotfiles_dir/gitconfig" "$HOME/.gitconfig"
  _link "$dotfiles_dir/p10k.zsh"  "$HOME/.p10k.zsh"

  output_blank
  output_success "Dotfiles installed!"
  output_dim     "Reload shell: source ~/.zshrc"
  output_blank
}

_link() {
  local source="$1"
  local target="$2"

  if [[ -f "$target" && ! -L "$target" ]]; then
    mv "$target" "${target}.backup"
    output_warning "Backed up: $target → ${target}.backup"
  fi

  [[ -L "$target" ]] && rm "$target"

  ln -s "$source" "$target"
  output_success "Linked: $target → $source"
}

_bootstrap_help() {
  output_header "ndw bootstrap — Workstation Setup"

  echo -e "  ${COLOR_BOLD}Usage:${COLOR_RESET}"
  echo -e "    ndw bootstrap [subcommand]"
  output_blank

  echo -e "  ${COLOR_BOLD}Subcommands:${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}run${COLOR_RESET}    Setup workstation from config (default)"
  output_blank

  echo -e "  ${COLOR_BOLD}What it does:${COLOR_RESET}"
  echo -e "    ${COLOR_DIM}1. Create workspace folders from config/workspace.yaml${COLOR_RESET}"
  echo -e "    ${COLOR_DIM}2. Generate infra/.env from config/services.yaml${COLOR_RESET}"
  echo -e "    ${COLOR_DIM}3. Create databases from config/services.yaml${COLOR_RESET}"
  echo -e "    ${COLOR_DIM}4. Install dotfiles symlinks${COLOR_RESET}"
  output_blank
}
