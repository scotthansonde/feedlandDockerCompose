#!/bin/sh
set -e

: "$FEEDLAND_DOMAIN"

OUT_DIR="/out"
OUT_FILE="$OUT_DIR/config.json"
TEMPLATE="/in/config.template.json"

if [ -d "$OUT_FILE" ]; then
  echo "ERROR: ./config.json is a directory on the host."
  echo "Delete it and retry: rm -rf ./config.json"
  exit 1
fi

# If file exists already, fix ownership but do not overwrite
if [ -f "$OUT_FILE" ]; then
  U="$(stat -c %u "$OUT_DIR")"
  G="$(stat -c %g "$OUT_DIR")"
  chown "$U:$G" "$OUT_FILE" || true
fi

# Never overwrite non-empty config.json
if [ -f "$OUT_FILE" ] && [ -s "$OUT_FILE" ]; then
  echo "config.json already exists; not overwriting."
  ls -la "$OUT_FILE"
  exit 0
fi

# Ensure dependencies
apk add --no-cache gettext coreutils >/dev/null

# Render
envsubst < "$TEMPLATE" > "$OUT_FILE"
chmod 0644 "$OUT_FILE"

# Match ownership to project directory owner
U="$(stat -c %u "$OUT_DIR")"
G="$(stat -c %g "$OUT_DIR")"
chown "$U:$G" "$OUT_FILE"

echo "Rendered ./config.json (owned by $U:$G)"
ls -la "$OUT_FILE"