#!/usr/bin/env bash
# =============================================================================
# cli/commands/work.sh — ndw work
# Workspace lifecycle management
# =============================================================================

cmd_work() {
  local subcommand="${1:-help}"
  shift || true

  case "$subcommand" in
    start)   _work_start "$@" ;;
    stop)    _work_stop "$@" ;;
    status)  _work_status "$@" ;;
    help | --help | -h) _work_help ;;
    *)
      output_error "Unknown subcommand: '$subcommand'"
      output_info  "Run 'ndw work --help' to see available subcommands."
      exit 1
      ;;
  esac
}

_work_start() {
  output_header "Work — Start"

  require_command "docker" "Install Docker Desktop and enable WSL integration"

  output_info "Starting infrastructure..."
  source "$NDW_ROOT/cli/commands/db.sh"
  _db_compose up -d
  output_success "Infrastructure ready"

  output_blank
  _work_print_services
  output_blank
  output_success "Workspace ready! Happy coding 🚀"
  output_blank
}

_work_stop() {
  output_header "Work — Stop"

  require_command "docker" "Install Docker Desktop and enable WSL integration"

  output_info "Stopping infrastructure..."
  source "$NDW_ROOT/cli/commands/db.sh"
  _db_compose down
  output_success "Infrastructure stopped"
  output_blank
}

_work_status() {
  output_header "Work — Status"

  require_command "docker" "Install Docker Desktop and enable WSL integration"

  source "$NDW_ROOT/cli/commands/db.sh"
  _db_compose ps
  output_blank
}

_work_print_services() {
  echo -e "  ${COLOR_BOLD}Services:${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}PostgreSQL${COLOR_RESET}   ${COLOR_DIM}localhost:5432${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}Redis${COLOR_RESET}        ${COLOR_DIM}localhost:6379${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}Adminer${COLOR_RESET}      ${COLOR_DIM}http://localhost:8080${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}Mailpit${COLOR_RESET}      ${COLOR_DIM}http://localhost:8025${COLOR_RESET}"
}

_work_help() {
  output_header "ndw work — Workspace Lifecycle"

  echo -e "  ${COLOR_BOLD}Usage:${COLOR_RESET}"
  echo -e "    ndw work <subcommand>"
  output_blank

  echo -e "  ${COLOR_BOLD}Subcommands:${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}start${COLOR_RESET}    Start workspace (infrastructure + services)"
  echo -e "    ${COLOR_CYAN}stop${COLOR_RESET}     Stop workspace"
  echo -e "    ${COLOR_CYAN}status${COLOR_RESET}   Show workspace status"
  output_blank
}
