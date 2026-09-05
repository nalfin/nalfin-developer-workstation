#!/usr/bin/env bash
# =============================================================================
# cli/commands/restore.sh — ndw restore
# Restore SSH keys from Google Drive
# =============================================================================

NDW_BACKUP_DIR="$HOME/backup/ndw"
NDW_GDRIVE_SSH_DIR="gdrive:NDW/ssh"

cmd_restore() {
  local ssh=false

  for arg in "$@"; do
    case "$arg" in
      --ssh) ssh=true ;;
    esac
  done

  if [[ "$ssh" != true ]]; then
    output_error "Usage: ndw restore --ssh"
    output_info  "NDW only restores SSH keys — database/service restores were removed"
    output_info  "since projects here connect to hosted services directly."
    exit 1
  fi

  _restore_ssh
}

_restore_ssh() {
  output_header "Restore SSH Keys"

  require_command "rclone" "https://rclone.org/install"

  output_info "Fetching SSH backups from Google Drive..."
  output_blank

  local files=()
  while IFS= read -r line; do
    files+=("$line")
  done < <(rclone lsf "$NDW_GDRIVE_SSH_DIR" --include "*.zip" --include "*.tar.enc" | sort -r)

  if [[ ${#files[@]} -eq 0 ]]; then
    output_error "No SSH backups found in Google Drive"
    output_info  "Run 'ndw backup --ssh' first"
    exit 1
  fi

  local i=1
  for f in "${files[@]}"; do
    echo -e "    ${COLOR_CYAN}[$i]${COLOR_RESET} $f"
    ((i++))
  done

  output_blank
  echo -n "  Select backup [1-${#files[@]}]: "
  read -r choice

  if [[ "$choice" -lt 1 || "$choice" -gt "${#files[@]}" ]]; then
    output_error "Invalid selection"
    exit 1
  fi

  local selected="${files[$((choice-1))]}"
  local localpath="$NDW_BACKUP_DIR/$selected"

  mkdir -p "$NDW_BACKUP_DIR"

  output_info "Downloading $selected from Google Drive..."
  rclone copy "$NDW_GDRIVE_SSH_DIR/$selected" "$NDW_BACKUP_DIR/" --progress

  output_blank
  echo -n "  Enter decryption password: "
  read -rs password
  echo ""

  output_info "Extracting SSH keys..."
  mkdir -p "$HOME/.ssh"

  if [[ "$selected" == *.tar.enc ]]; then
    require_command "openssl" "should be preinstalled — Git Bash / macOS both ship it"
    export NDW_BACKUP_PW="$password"
    openssl enc -d -aes-256-cbc -pbkdf2 -salt -pass env:NDW_BACKUP_PW -in "$localpath" | tar -C "$HOME" -xzf -
    unset NDW_BACKUP_PW
  else
    # Legacy .zip backups (made before NDW switched to tar+openssl)
    require_command "unzip" "https://gnuwin32.sourceforge.net/packages/unzip.htm"
    unzip -P "$password" -o "$localpath" -d "$HOME" &>/dev/null
  fi
  unset password

  chmod 700 "$HOME/.ssh"
  chmod 600 "$HOME/.ssh"/* 2>/dev/null || true
  chmod 644 "$HOME/.ssh"/*.pub 2>/dev/null || true

  rm -f "$localpath"

  output_blank
  output_success "SSH keys restored to ~/.ssh/"
  output_dim     "Test GitHub: ssh -T git@github.com"
  output_blank
}
