#!/usr/bin/env bash
# =============================================================================
# cli/commands/help.sh — ndw help / ndw --help
# =============================================================================

cmd_help() {
  output_header "NDW — Nalfin Developer Workstation v${NDW_VERSION}"

  echo -e "  ${COLOR_BOLD}Usage:${COLOR_RESET}"
  echo -e "    ndw <command> [options]"
  output_blank

  echo -e "  ${COLOR_BOLD}Commands:${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}bootstrap${COLOR_RESET}       Restore workspace folders + dotfiles"
  echo -e "    ${COLOR_CYAN}doctor${COLOR_RESET}          Check environment health"
  echo -e "    ${COLOR_CYAN}backup --ssh${COLOR_RESET}    Backup SSH keys to Google Drive (encrypted)"
  echo -e "    ${COLOR_CYAN}restore --ssh${COLOR_RESET}   Restore SSH keys from Google Drive"
  echo -e "    ${COLOR_CYAN}setup${COLOR_RESET}           Install optional tools (Node/PHP/Python/Warp/VS Code/etc)"
  echo -e "    ${COLOR_CYAN}upgrade${COLOR_RESET}         Update NDW to the latest version"
  echo -e "    ${COLOR_CYAN}uninstall${COLOR_RESET}       Remove NDW"
  output_blank

  echo -e "  ${COLOR_BOLD}Global options:${COLOR_RESET}"
  echo -e "    ${COLOR_CYAN}--help, -h${COLOR_RESET}       Show this help"
  echo -e "    ${COLOR_CYAN}--version, -v${COLOR_RESET}    Show version"
  output_blank

  output_dim "New device? bash bootstrap/install  →  ndw restore --ssh  →  ndw bootstrap"
  output_dim "Want Node/PHP/Python/Warp/VS Code too? ndw setup (optional)"
  output_blank
}
