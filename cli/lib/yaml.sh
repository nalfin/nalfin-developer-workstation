#!/usr/bin/env bash
# =============================================================================
# cli/lib/yaml.sh — Simple YAML parser helper
# Supports: key: value, section.key: value, and list items (- value)
# =============================================================================

# Get a single value from yaml file
# Usage: yaml_get config/services.yaml "postgres.port"
yaml_get() {
  local file="$1"
  local key="$2"

  local section=""
  local subkey=""

  if [[ "$key" == *.* ]]; then
    section="${key%%.*}"
    subkey="${key#*.}"
  else
    subkey="$key"
  fi

  local in_section=false
  local result=""

  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    if [[ -n "$section" ]]; then
      if [[ "$line" =~ ^${section}: ]]; then
        in_section=true
        continue
      fi
      if [[ "$in_section" == true ]]; then
        if [[ "$line" =~ ^[a-zA-Z] ]]; then
          in_section=false
          continue
        fi
        if [[ "$line" =~ ^[[:space:]]+${subkey}:[[:space:]]*(.+)$ ]]; then
          result="${BASH_REMATCH[1]}"
          break
        fi
      fi
    else
      if [[ "$line" =~ ^${subkey}:[[:space:]]*(.+)$ ]]; then
        result="${BASH_REMATCH[1]}"
        break
      fi
    fi
  done < "$file"

  echo "$result"
}

# Get list items from yaml file
# Usage: yaml_list config/services.yaml "postgres.databases"
#        yaml_list config/workspace.yaml "folders"  (root-level list)
yaml_list() {
  local file="$1"
  local key="$2"

  local items=()

  # Root-level list (no section) e.g. "folders"
  if [[ "$key" != *.* ]]; then
    local in_list=false
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ -z "${line// }" ]] && continue

      if [[ "$line" =~ ^${key}: ]]; then
        in_list=true
        continue
      fi

      if [[ "$in_list" == true ]]; then
        if [[ "$line" =~ ^[a-zA-Z] ]]; then
          break
        fi
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+(.+)$ ]]; then
          items+=("${BASH_REMATCH[1]}")
        fi
      fi
    done < "$file"

    printf '%s\n' "${items[@]}"
    return
  fi

  # Nested list e.g. "postgres.databases"
  local section="${key%%.*}"
  local subkey="${key#*.}"
  local in_section=false
  local in_list=false

  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    if [[ "$line" =~ ^${section}: ]]; then
      in_section=true
      continue
    fi

    if [[ "$in_section" == true ]]; then
      if [[ "$line" =~ ^[a-zA-Z] ]]; then
        in_section=false
        in_list=false
        continue
      fi

      if [[ "$line" =~ ^[[:space:]]+${subkey}: ]]; then
        in_list=true
        continue
      fi

      if [[ "$in_list" == true ]]; then
        if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.+)$ ]]; then
          items+=("${BASH_REMATCH[1]}")
        else
          in_list=false
        fi
      fi
    fi
  done < "$file"

  printf '%s\n' "${items[@]}"
}
