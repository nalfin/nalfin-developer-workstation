#!/usr/bin/env bash
# =============================================================================
# cli/router.sh — Map CLI arguments to command handlers
# Only routing logic lives here — no business logic
# =============================================================================
set -euo pipefail

router() {
  local command="${1:-help}"
  shift || true

  case "$command" in
    help | --help | -h)
      source "$NDW_ROOT/cli/commands/help.sh"
      cmd_help "$@"
      ;;
    version | --version | -v)
      source "$NDW_ROOT/cli/commands/version.sh"
      cmd_version "$@"
      ;;
    bootstrap)
      source "$NDW_ROOT/cli/commands/bootstrap.sh"
      cmd_bootstrap "$@"
      ;;
    doctor)
      source "$NDW_ROOT/cli/commands/doctor.sh"
      cmd_doctor "$@"
      ;;
    db)
      source "$NDW_ROOT/cli/commands/db.sh"
      cmd_db "$@"
      ;;
    work)
      source "$NDW_ROOT/cli/commands/work.sh"
      cmd_work "$@"
      ;;
    backup)
      source "$NDW_ROOT/cli/commands/backup.sh"
      cmd_backup "$@"
      ;;
    restore)
      source "$NDW_ROOT/cli/commands/restore.sh"
      cmd_restore "$@"
      ;;
    *)
      output_error "Unknown command: '$command'"
      output_info  "Run 'ndw --help' to see available commands."
      exit 1
      ;;
  esac
}
