#!/usr/bin/env bash
# =============================================================================
# cli/commands/db.sh — ndw db
# Manage development infrastructure via Docker Compose
# =============================================================================

NDW_COMPOSE_FILE="$NDW_ROOT/infra/docker-compose.yml"
NDW_COMPOSE_ENV="$NDW_ROOT/infra/.env"

cmd_db() {
  local subcommand="${1:-help}"
  shift || true

  case "$subcommand" in
    up)      _db_up "$@" ;;
    down)    _db_down "$@" ;;
    status)  _db_status "$@" ;;
    logs)    _db_logs "$@" ;;
    shell)   _db_shell "$@" ;;
    create)  _db_create "$@" ;;
    list)    _db_list "$@" ;;
    help | --help | -h) _db_help ;;
    *)
      output_error "Unknown subcommand: '$subcommand'"
      output_info  "Run 'ndw db --help' to see available subcommands."
      exit 1
      ;;
  esac
}

_db_compose() {
  docker compose \
    --file "$NDW_COMPOSE_FILE" \
    --env-file "$NDW_COMPOSE_ENV" \
    "$@"
}

_db_pg_user() {
  grep "^POSTGRES_USER" "$NDW_COMPOSE_ENV" | cut -d= -f2
}

_db_up() {
  output_header "DB — Up"
  require_command "docker" "Install Docker Desktop and enable WSL integration"
  output_info "Starting services..."
  _db_compose up -d
  output_blank
  output_success "Services started"
  output_blank
  _db_status
}

_db_down() {
  output_header "DB — Down"
  require_command "docker" "Install Docker Desktop and enable WSL integration"
  output_info "Stopping services..."
  _db_compose down
  output_blank
  output_success "Services stopped"
  output_blank
}

_db_status() {
  output_header "DB — Status"
  require_command "docker" "Install Docker Desktop and enable WSL integration"
  _db_compose ps
  output_blank
}

_db_logs() {
  local service="${1:-}"
  output_header "DB — Logs"
  require_command "docker" "Install Docker Desktop and enable WSL integration"
  if [[ -n "$service" ]]; then
    _db_compose logs -f "$service"
  else
    _db_compose logs -f
  fi
}

_db_shell() {
  output_header "DB — Shell"
  require_command "docker" "Install Docker Desktop and enable WSL integration"

  local user
  user="$(_db_pg_user)"

  output_info "Connecting to PostgreSQL as '${user}'..."
  output_dim  "Type \\q to exit"
  output_blank

  docker exec -it ndw_postgres psql -U "$user" -d postgres
}

_db_create() {
  local dbname="${1:-}"

  if [[ -z "$dbname" ]]; then
    output_error "Database name is required"
    output_info  "Usage: ndw db create <name>"
    exit 1
  fi

  output_header "DB — Create"
  require_command "docker" "Install Docker Desktop and enable WSL integration"

  local user
  user="$(_db_pg_user)"

  output_info "Creating database '$dbname'..."
  docker exec -i ndw_postgres psql -U "$user" -d postgres -c "CREATE DATABASE $dbname;"
  output_success "Database '$dbname' created"
  output_blank
}

_db_list() {
  output_header "DB — Databases"
  require_command "docker" "Install Docker Desktop and enable WSL integration"

  local user
  user="$(_db_pg_user)"

  docker exec -i ndw_postgres psql -U "$user" -d postgres -c "\l"
  output_blank
}

_db_help() {
  output_header "ndw db — Database Management"

  echo -e "  ${COLOR_BOLD}Usage:${COLOR_RESET}"
  echo -e "    ndw db <subcommand> [options]"
  output_blank

  echo -e "  ${COLOR_BOLD}Subcommands:${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}up${COLOR_RESET}              Start all services"
  echo -e "    ${COLOR_CYAN}down${COLOR_RESET}            Stop all services"
  echo -e "    ${COLOR_CYAN}status${COLOR_RESET}          Show service status"
  echo -e "    ${COLOR_CYAN}logs [service]${COLOR_RESET}  Follow logs (all or specific service)"
  echo -e "    ${COLOR_CYAN}shell${COLOR_RESET}           Open PostgreSQL shell"
  echo -e "    ${COLOR_CYAN}create <name>${COLOR_RESET}   Create a new database"
  echo -e "    ${COLOR_CYAN}list${COLOR_RESET}            List all databases"
  output_blank

  echo -e "  ${COLOR_BOLD}Services:${COLOR_RESET}"
  echo -e "    ${COLOR_DIM}postgres   :5432${COLOR_RESET}"
  echo -e "    ${COLOR_DIM}redis      :6379${COLOR_RESET}"
  echo -e "    ${COLOR_DIM}adminer    :8080${COLOR_RESET}"
  echo -e "    ${COLOR_DIM}mailpit    :8025${COLOR_RESET}"
  output_blank
}
