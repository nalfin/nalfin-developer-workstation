# Changelog

All notable changes to NDW will be documented here.

Format: [Semantic Versioning](https://semver.org)

---

## [Unreleased]

### Changed — Windows-native rewrite (no more WSL/Docker)
- Dropped `db`/`work` commands, `infra/docker-compose.yml`, `config/services.yaml` — local Postgres/Redis/Adminer removed since projects now use Supabase (Postgres) and Upstash (Redis) directly.
- `backup`/`restore` now only handle SSH keys (`--ssh`); database backup/restore removed along with local Postgres.
- `bootstrap` now only creates workspace folders and installs dotfiles — no more `.env` generation or database creation.
- Dropped zsh/Oh My Zsh/Powerlevel10k entirely. Replaced with `dotfiles/aliases.sh` (plain POSIX aliases, sourced from both `.bashrc` and `.zshrc`) and `dotfiles/starship.toml` (cross-shell prompt, works in Git Bash on Windows and zsh/bash on macOS).
- `bootstrap/setup` rewritten from an apt-only installer into an optional, interactive menu using `winget` (Windows) or `brew` (macOS).
- Added `is_windows()` detection in `cli/lib/common.sh`.
- Symlink steps (`ln -s`) now fall back to a copy/wrapper script if symlinks aren't permitted (e.g. Windows without Developer Mode).
- Added `ndw setup`, `ndw upgrade`, `ndw uninstall` — forward to the matching `bootstrap/*` script so they work from any directory, not just inside the repo.
- `backup --ssh` / `restore --ssh` switched from `zip -P` (weak ZipCrypto, and `zip` isn't preinstalled on Git Bash) to `tar` + `openssl enc -aes-256-cbc -pbkdf2` — no extra tools needed on Windows/macOS, and stronger encryption. New backups are `.tar.enc`; `restore --ssh` still reads old `.zip` backups for compatibility.
- Added change-triggered auto-backup for Windows (`bootstrap/windows/ndw-ssh-autobackup-*.ps1`): a Scheduled Task checks a hash of `~/.ssh` at login + hourly and only runs `ndw backup --ssh --auto` when it actually changed. Password stored DPAPI-encrypted. `backup.sh` gained a `--auto` flag (reads password from `NDW_SSH_BACKUP_PASSWORD` env var, non-interactive) to support this.
- `backup --ssh` now auto-deletes old backups on Google Drive, keeping only the newest `NDW_BACKUP_KEEP` (default 10) so storage doesn't grow unbounded and `restore --ssh` doesn't get a huge pick-list.

## [0.1.0] — Phase 1: Foundation

### Added
- Repository structure
- `bin/ndw` entry point
- `cli/app.sh` bootstrap
- `cli/router.sh` command dispatcher
- `cli/lib/output.sh` colored output helpers
- `cli/lib/config.sh` version + config management
- `cli/lib/common.sh` utility functions
- Command stubs: `doctor`, `db`, `work`, `backup`, `restore`
- `bootstrap/install`, `uninstall`, `upgrade`
