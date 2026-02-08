#!/usr/bin/env sh
set -eu

# One-step installer for FeedLand Docker Compose
# - Prompts for FEEDLAND_DOMAIN (unless already set)
# - Creates/updates .env safely (via ./scripts/init-env.sh)
# - Writes FEEDLAND_DOMAIN into .env if missing
# - Starts the stack with docker compose

ENV_FILE=".env"
INIT_SCRIPT="./scripts/init-env.sh"

say() { printf "%s\n" "$*"; }
err() { printf "Error: %s\n" "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

is_windows() {
  case "$(uname -s 2>/dev/null || echo unknown)" in
    CYGWIN*|MINGW*|MSYS*) return 0 ;;
    *) return 1 ;;
  esac
}

ensure_prereqs() {
  if ! have docker; then
    err "docker not found. Please install Docker first."
    exit 1
  fi

  # Prefer Compose v2 ("docker compose"), fall back to legacy ("docker-compose")
  if docker compose version >/dev/null 2>&1; then
    COMPOSE="docker compose"
  elif have docker-compose; then
    COMPOSE="docker-compose"
  else
    err "Docker Compose not found. Install Docker Desktop or the docker compose plugin."
    exit 1
  fi

  if [ ! -f "$INIT_SCRIPT" ]; then
    err "Missing $INIT_SCRIPT. Are you in the repo root?"
    exit 1
  fi
}

read_domain() {
  # If already set, don't prompt.
  if [ -n "${FEEDLAND_DOMAIN:-}" ]; then
    return 0
  fi

  # If we can't prompt (not a TTY), require env var.
  if [ ! -t 0 ]; then
    err "FEEDLAND_DOMAIN is required in non-interactive mode."
    err "Example: FEEDLAND_DOMAIN=feed.example.com ./install.sh"
    exit 1
  fi

  say ""
  say "FeedLand needs a hostname to start."
  say "Example: feed.example.com"
  printf "Enter FEEDLAND_DOMAIN: "
  read -r FEEDLAND_DOMAIN || true

  # Trim spaces (basic)
  FEEDLAND_DOMAIN=$(printf "%s" "$FEEDLAND_DOMAIN" | tr -d '[:space:]')

  if [ -z "$FEEDLAND_DOMAIN" ]; then
    err "FEEDLAND_DOMAIN cannot be empty."
    exit 1
  fi

  export FEEDLAND_DOMAIN
}

ensure_env_domain() {
  # Ensure FEEDLAND_DOMAIN exists in .env without overwriting existing value.
  if [ -f "$ENV_FILE" ] && grep -q '^FEEDLAND_DOMAIN=' "$ENV_FILE"; then
    return 0
  fi
  printf "\nFEEDLAND_DOMAIN=%s\n" "$FEEDLAND_DOMAIN" >> "$ENV_FILE"
}

main() {
  if is_windows; then
    say "Detected a Windows-like shell environment."
    say ""
    say "This installer works best in:"
    say "  - WSL (recommended), or"
    say "  - Git Bash (usually works), or"
    say "  - macOS/Linux"
    say ""
    say "If you're in PowerShell, use the PowerShell instructions in the README."
    say ""
    # Continue anyway; it often works in Git Bash.
  fi

  ensure_prereqs
  read_domain

  # Generate passwords & create .env if needed
  "$INIT_SCRIPT"

  # Ensure domain stored in .env
  ensure_env_domain

  say ""
  say "Starting containers (detached)…"
  # shellcheck disable=SC2086
  $COMPOSE up -d

  say ""
  say "✅ Done."
  say "To view logs:   $COMPOSE logs -f"
  say "To stop:        $COMPOSE down"
  say ""
  say "Your FEEDLAND_DOMAIN is set to: $FEEDLAND_DOMAIN"
}

main "$@"
