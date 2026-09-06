#!/usr/bin/env bash
# =============================================================================
# cli/commands/backup.sh — ndw backup
# Backup SSH keys to Google Drive (encrypted)
# =============================================================================

NDW_BACKUP_DIR="$HOME/backup/ndw"
NDW_GDRIVE_SSH_DIR="gdrive:NDW/ssh"
NDW_BACKUP_KEEP=10   # how many backups to keep on Google Drive; older ones auto-deleted

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

  _cleanup_old_backups "$auto"

  output_blank
  output_success "SSH keys backed up to Google Drive: $NDW_GDRIVE_SSH_DIR/$filename"
  if [[ "$auto" != true ]]; then
    output_warning "Remember your encryption password — it cannot be recovered!"
  fi
  output_blank
}

# Keeps only the newest $NDW_BACKUP_KEEP backups on Google Drive, deletes the rest.
# Sorting by filename works because timestamps are zero-padded ISO-ish
# (ssh_YYYY-MM-DD_HH-MM-SS.*), so lexical sort == chronological sort,
# for both the current .tar.enc format and legacy .zip backups.
_cleanup_old_backups() {
  local auto="$1"
  local files
  files="$(rclone lsf "$NDW_GDRIVE_SSH_DIR" --include "*.zip" --include "*.tar.enc" 2>/dev/null | sort -r)"

  [[ -z "$files" ]] && return

  local count=0
  local removed=0
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    count=$((count + 1))
    if (( count > NDW_BACKUP_KEEP )); then
      rclone delete "$NDW_GDRIVE_SSH_DIR/$f" 2>/dev/null
      removed=$((removed + 1))
      [[ "$auto" != true ]] && output_dim "Removed old backup: $f"
    fi
  done <<< "$files"

  if (( removed > 0 )) && [[ "$auto" != true ]]; then
    output_info "Cleaned up $removed old backup(s), keeping the newest $NDW_BACKUP_KEEP"
  fi
}
