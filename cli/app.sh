#!/usr/bin/env bash
# =============================================================================
# cli/app.sh — Bootstrap: load shared libraries, then delegate to router
# =============================================================================
set -euo pipefail

source "$NDW_ROOT/cli/lib/output.sh"
source "$NDW_ROOT/cli/lib/config.sh"
source "$NDW_ROOT/cli/lib/common.sh"

source "$NDW_ROOT/cli/router.sh"

main() {
  router "$@"
}
