#!/usr/bin/env bash
# =============================================================================
# cli/commands/restore.sh — ndw restore
# Restore PostgreSQL databases from a backup file
# =============================================================================

NDW_BACKUP_DIR="$HOME/backup/ndw"
NDW_GDRIVE_DIR="gdrive:NDW/backups"

cmd_restore() {
  local cloud=false
  local file=""

  # Parse flags
  for arg in "$@"; do
    case "$arg" in
      --cloud) cloud=true ;;
      -*) ;;
      *) file="$arg" ;;
    esac
  done

  output_header "Restore"

  require_command "docker" "Install Docker Desktop and enable WSL integration"

  if [[ "$cloud" == true ]]; then
    _restore_from_cloud
  elif [[ -n "$file" ]]; then
    _restore_file "$file"
  else
    _restore_pick_local
  fi
}

_restore_pick_local() {
  if [[ ! -d "$NDW_BACKUP_DIR" ]] || [[ -z "$(ls -A "$NDW_BACKUP_DIR" 2>/dev/null)" ]]; then
    output_error "No backups found in $NDW_BACKUP_DIR"
    output_info  "Run 'ndw backup' first"
    exit 1
  fi

  output_info "Available backups:"
  output_blank

  local i=1
  local files=()
  while IFS= read -r f; do
    local size
    size="$(du -h "$f" | cut -f1)"
    echo -e "    ${COLOR_CYAN}[$i]${COLOR_RESET} $(basename "$f") ${COLOR_DIM}($size)${COLOR_RESET}"
    files+=("$f")
    ((i++))
  done < <(ls -t "$NDW_BACKUP_DIR"/*.sql.gz 2>/dev/null)

  output_blank
  echo -n "  Select backup [1-${#files[@]}]: "
  read -r choice

  if [[ "$choice" -lt 1 || "$choice" -gt "${#files[@]}" ]]; then
    output_error "Invalid selection"
    exit 1
  fi

  _restore_file "${files[$((choice-1))]}"
}

_restore_from_cloud() {
  if ! command_exists "rclone"; then
    output_error "rclone not found"
    output_info  "Install rclone: curl https://rclone.org/install.sh | sudo bash"
    exit 1
  fi

  output_info "Fetching backup list from Google Drive..."
  output_blank

  local files=()
  while IFS= read -r line; do
    files+=("$line")
  done < <(rclone lsf "$NDW_GDRIVE_DIR" --include "*.sql.gz" | sort -r)

  if [[ ${#files[@]} -eq 0 ]]; then
    output_error "No backups found in Google Drive"
    output_info  "Run 'ndw backup --cloud' first"
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
  rclone copy "$NDW_GDRIVE_DIR/$selected" "$NDW_BACKUP_DIR/" --progress

  _restore_file "$localpath"
}

_restore_file() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    output_error "File not found: $file"
    exit 1
  fi

  local user
  user="$(grep "^POSTGRES_USER" "$NDW_ROOT/infra/.env" | cut -d= -f2)"

  output_blank
  output_warning "This will restore from: $(basename "$file")"
  echo -n "  Are you sure? [y/N]: "
  read -r confirm

  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    output_info "Restore cancelled"
    exit 0
  fi

  output_blank
  output_info "Restoring from $(basename "$file")..."
  gunzip -c "$file" | docker exec -i ndw_postgres psql -U "$user" -d postgres -q

  output_blank
  output_success "Restore complete!"
  output_blank
}
