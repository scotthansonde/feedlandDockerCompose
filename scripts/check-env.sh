#!/bin/sh
set -eu

if [ -z "${FEEDLAND_DOMAIN:-}" ]; then
  echo "FEEDLAND_DOMAIN is not set. Set it in .env."
  exit 1
fi

if [ "$FEEDLAND_DOMAIN" = "feedland.example.com" ]; then
  echo "FEEDLAND_DOMAIN is still the example value. Edit .env and set a real hostname."
  exit 1
fi

echo "FEEDLAND_DOMAIN looks good: $FEEDLAND_DOMAIN"