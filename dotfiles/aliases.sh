# =============================================================================
# dotfiles/aliases.sh — Cross-shell aliases (bash + zsh)
# Sourced from ~/.bashrc (Windows/Linux) and ~/.zshrc (macOS)
# Tool-dependent aliases are guarded so this file never breaks on a
# freshly restored device where those tools aren't installed yet.
# =============================================================================

_ndw_has() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------
alias cl='clear'

# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------
alias dev='cd ~/dev'
alias ev='cd ~/dev/projects/evocave'
alias per='cd ~/dev/personal'
alias clients='cd ~/dev/clients'
alias playground='cd ~/dev/playground'

# ---------------------------------------------------------------------------
# Evocave
# ---------------------------------------------------------------------------
alias cd_api='cd ~/dev/projects/evocave/evocave-api'
alias cd_dash='cd ~/dev/projects/evocave/evocave-dash'
alias cd_help='cd ~/dev/projects/evocave/evocave-help'
alias cd_docs='cd ~/dev/projects/evocave/evocave-docs'

alias nd-api='cd ~/dev/projects/evocave/evocave-api && pnpm dev'
alias nd-dash='cd ~/dev/projects/evocave/evocave-dash && pnpm dev -- -p 3001'
alias nd-help='cd ~/dev/projects/evocave/evocave-help && pnpm dev -- -p 3002'
alias nd-docs='cd ~/dev/projects/evocave/evocave-docs && pnpm dev -- -p 3003'

alias nb-api='cd ~/dev/projects/evocave/evocave-api && pnpm build'
alias nb-dash='cd ~/dev/projects/evocave/evocave-dash && pnpm build'
alias nb-help='cd ~/dev/projects/evocave/evocave-help && pnpm build'
alias nb-docs='cd ~/dev/projects/evocave/evocave-docs && pnpm build'

# ---------------------------------------------------------------------------
# Node / pnpm
# ---------------------------------------------------------------------------
alias n='node'
alias nrd='pnpm dev'
alias nrb='pnpm build'
alias nps='pnpm prisma studio'
alias dbstudio='pnpm db:studio'

# ---------------------------------------------------------------------------
# Git
# ---------------------------------------------------------------------------
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'

_ndw_has lazygit && alias lg='lazygit'

# ---------------------------------------------------------------------------
# Modern CLI replacements (only if installed)
# ---------------------------------------------------------------------------
if _ndw_has eza; then
  alias ls='eza --icons=auto'
  alias ll='eza -lah --icons=auto --group-directories-first'
  alias la='eza -a --icons=auto'
  alias tree='eza --tree --icons=auto'
fi

_ndw_has bat  && alias cat='bat'
_ndw_has rg   && alias grep='rg'
_ndw_has fd   && alias find='fd'

unset -f _ndw_has 2>/dev/null || true
