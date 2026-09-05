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
