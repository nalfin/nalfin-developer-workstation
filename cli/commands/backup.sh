#!/usr/bin/env bash
# =============================================================================
# cli/commands/backup.sh — ndw backup
# Export all PostgreSQL databases to a compressed SQL file
# Optionally upload to Google Drive
# =============================================================================

NDW_BACKUP_DIR="$HOME/backup/ndw"
NDW_GDRIVE_DIR="gdrive:NDW/backups"
NDW_BACKUP_KEEP=5

cmd_backup() {
  local cloud=false

  for arg in "$@"; do
    case "$arg" in
      --cloud) cloud=true ;;
    esac
  done

  output_header "Backup"

  require_command "docker" "Install Docker Desktop and enable WSL integration"

  local user
  user="$(grep "^POSTGRES_USER" "$NDW_ROOT/infra/.env" | cut -d= -f2)"

  local timestamp
  timestamp="$(date +%Y-%m-%d_%H-%M-%S)"

  local filename="ndw_${timestamp}.sql.gz"
  local filepath="$NDW_BACKUP_DIR/$filename"

  output_info "Creating backup directory..."
  mkdir -p "$NDW_BACKUP_DIR"

  output_info "Exporting databases..."
  docker exec ndw_postgres pg_dumpall -U "$user" | gzip > "$filepath"

  local size
  size="$(du -h "$filepath" | cut -f1)"

  output_success "Backup created: $filepath ($size)"

  _backup_cleanup

  if [[ "$cloud" == true ]]; then
    _backup_upload "$filepath" "$filename"
  fi

  output_blank
}

_backup_cleanup() {
  local files=()
  while IFS= read -r f; do
    files+=("$f")
  done < <(find "$NDW_BACKUP_DIR" -maxdepth 1 -name "*.sql.gz" -printf "%T@ %p\n" 2>/dev/null | sort -rn | awk '{print $2}')

  local count="${#files[@]}"

  if [[ "$count" -gt "$NDW_BACKUP_KEEP" ]]; then
    output_info "Cleaning old backups (keeping last $NDW_BACKUP_KEEP)..."
    local i
    for ((i=NDW_BACKUP_KEEP; i<count; i++)); do
      rm -f "${files[$i]}"
    done
    output_success "Old backups removed"
  fi
}

_backup_upload() {
  local filepath="$1"
  local filename="$2"

  if ! command_exists "rclone"; then
    output_warning "rclone not found — skipping cloud upload"
    output_info    "Install rclone: curl https://rclone.org/install.sh | sudo bash"
    return
  fi

  output_info "Uploading to Google Drive..."
  rclone copy "$filepath" "$NDW_GDRIVE_DIR/" --progress

  output_success "Uploaded: $NDW_GDRIVE_DIR/$filename"
}
