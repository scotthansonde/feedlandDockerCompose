#!/usr/bin/env sh
set -eu

# FeedLand Docker Compose - environment initialization
#
# - Creates .env from .env.example if missing
# - Generates strong MySQL passwords if missing or placeholder
# - Never overwrites existing values
# - Sets .env permissions to 600 where supported
#
# Usage:
#   ./scripts/init-env.sh
#
# Notes:
# - Treats empty, CHANGEME, or REPLACE_ME as placeholders.
# - Generates env-safe (alphanumeric) passwords to avoid quoting issues.

ENV_FILE=".env"
ENV_EXAMPLE=".env.example"

error() {
  echo "Error: $*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

generate_password() {
  # Generate a strong, env-safe password (A-Za-z0-9 only)
  if command_exists openssl; then
    openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | cut -c1-40
    return
  fi

  if command_exists python3; then
    python3 - <<'EOF'
import secrets, string
alphabet = string.ascii_letters + string.digits
print(''.join(secrets.choice(alphabet) for _ in range(40)))
EOF
    return
  fi

  error "Neither openssl nor python3 is available to generate passwords"
}

ensure_env_file() {
  if [ -f "$ENV_FILE" ]; then
    return
  fi

  [ -f "$ENV_EXAMPLE" ] || error "Missing $ENV_EXAMPLE"

  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "Created $ENV_FILE from $ENV_EXAMPLE"
}

get_value() {
  key="$1"
  sed -n "s/^$key=//p" "$ENV_FILE" | head -n 1 || true
}

set_value() {
  key="$1"
  value="$2"

  if grep -q "^$key=" "$ENV_FILE"; then
    tmp="$(mktemp)"
    sed "s/^$key=.*/$key=$value/" "$ENV_FILE" > "$tmp"
    mv "$tmp" "$ENV_FILE"
  else
    printf "\n%s=%s\n" "$key" "$value" >> "$ENV_FILE"
  fi
}

is_placeholder() {
  val="${1:-}"
  [ -z "$val" ] && return 0
  [ "$val" = "CHANGEME" ] && return 0
  [ "$val" = "REPLACE_ME" ] && return 0
  return 1
}

main() {
  ensure_env_file

  root_pw="$(get_value MYSQL_ROOT_PASSWORD)"
  user_pw="$(get_value MYSQL_USER_PASSWORD)"

  if is_placeholder "$root_pw"; then
    new_pw="$(generate_password)"
    set_value MYSQL_ROOT_PASSWORD "$new_pw"
    echo "Generated MYSQL_ROOT_PASSWORD"
  fi

  if is_placeholder "$user_pw"; then
    new_pw="$(generate_password)"
    set_value MYSQL_USER_PASSWORD "$new_pw"
    echo "Generated MYSQL_USER_PASSWORD"
  fi

  chmod 600 "$ENV_FILE" 2>/dev/null || true

  echo ""
  echo "✅ Environment setup complete."
  echo "   Passwords are stored in $ENV_FILE"
  echo ""
  echo "To view them later:"
  echo "  grep '^MYSQL_\\(ROOT_PASSWORD\\|USER_PASSWORD\\)=' .env"
}

main "$@"
