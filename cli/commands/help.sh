#!/usr/bin/env bash
# =============================================================================
# cli/commands/help.sh — ndw help / ndw --help
# =============================================================================

cmd_help() {
  output_header "NDW — Nalfin Developer Workstation v${NDW_VERSION}"

  echo -e "  ${COLOR_BOLD}Usage:${COLOR_RESET}"
  echo -e "    ndw <command> [subcommand] [options]"
  output_blank

  echo -e "  ${COLOR_BOLD}Commands:${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}doctor${COLOR_RESET}     Check environment health"
  echo -e "    ${COLOR_CYAN}db${COLOR_RESET}         Manage development databases"
  echo -e "    ${COLOR_CYAN}work${COLOR_RESET}       Start / stop workspace"
  echo -e "    ${COLOR_CYAN}backup${COLOR_RESET}     Backup databases"
  echo -e "    ${COLOR_CYAN}restore${COLOR_RESET}    Restore databases"
  output_blank

  echo -e "  ${COLOR_BOLD}Global options:${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}--help, -h${COLOR_RESET}       Show this help"
  echo -e "    ${COLOR_CYAN}--version, -v${COLOR_RESET}    Show version"
  output_blank

  output_dim "Run 'ndw <command> --help' for command-specific help."
  output_blank
}
