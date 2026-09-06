#!/usr/bin/env bash
# =============================================================================
# cli/commands/backup.sh — ndw backup
# Backup SSH keys to Google Drive (encrypted)
# =============================================================================

NDW_BACKUP_DIR="$HOME/backup/ndw"
NDW_GDRIVE_SSH_DIR="gdrive:NDW/ssh"

cmd_backup() {
  local ssh=false
  local auto=false

  for arg in "$@"; do
    case "$arg" in
      --ssh) ssh=true ;;
      --auto) auto=true ;;
    esac
  done

  if [[ "$ssh" != true ]]; then
    output_error "Usage: ndw backup --ssh"
    output_info  "NDW only backs up SSH keys — database/service backups were removed"
    output_info  "since projects here connect to hosted services directly."
    exit 1
  fi

  _backup_ssh "$auto"
}

_backup_ssh() {
  local auto="$1"

  output_header "Backup SSH Keys"

  require_command "rclone" "https://rclone.org/install"

  if [[ ! -d "$HOME/.ssh" ]]; then
    output_error "No .ssh directory found"
    exit 1
  fi

  local timestamp
  timestamp="$(date +%Y-%m-%d_%H-%M-%S)"

  local filename="ssh_${timestamp}.tar.enc"
  local filepath="$NDW_BACKUP_DIR/$filename"

  mkdir -p "$NDW_BACKUP_DIR"

  require_command "tar" "should be preinstalled — Git Bash / macOS both ship it"
  require_command "openssl" "should be preinstalled — Git Bash / macOS both ship it"

  local password

  if [[ "$auto" == true ]]; then
    # Non-interactive: password comes from the caller (e.g. the scheduled
    # auto-backup check script), never typed here.
    if [[ -z "${NDW_SSH_BACKUP_PASSWORD:-}" ]]; then
      output_error "NDW_SSH_BACKUP_PASSWORD not set — auto mode requires it"
      exit 1
    fi
    password="$NDW_SSH_BACKUP_PASSWORD"
  else
    output_info "Enter encryption password for SSH backup:"
    echo -n "  Password: "
    read -rs password
    echo ""
    echo -n "  Confirm:  "
    read -rs password2
    echo ""

    if [[ "$password" != "$password2" ]]; then
      output_error "Passwords do not match"
      exit 1
    fi
    unset password2
  fi

  output_info "Encrypting SSH keys..."
  export NDW_BACKUP_PW="$password"
  (cd "$HOME" && tar -czf - .ssh/) | openssl enc -aes-256-cbc -pbkdf2 -salt -pass env:NDW_BACKUP_PW -out "$filepath"
  unset NDW_BACKUP_PW password NDW_SSH_BACKUP_PASSWORD

  local size
  size="$(du -h "$filepath" | cut -f1)"

  output_success "Encrypted: $filepath ($size)"

  output_info "Uploading to Google Drive..."
  if [[ "$auto" == true ]]; then
    rclone copy "$filepath" "$NDW_GDRIVE_SSH_DIR/"
  else
    rclone copy "$filepath" "$NDW_GDRIVE_SSH_DIR/" --progress
  fi

  rm -f "$filepath"

  output_blank
  output_success "SSH keys backed up to Google Drive: $NDW_GDRIVE_SSH_DIR/$filename"
  if [[ "$auto" != true ]]; then
    output_warning "Remember your encryption password — it cannot be recovered!"
  fi
  output_blank
}
