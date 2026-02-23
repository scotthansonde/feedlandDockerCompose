#!/bin/sh
set -e

# Queries the MySQL database for pending email confirmations
# Requires .env to be present with MYSQL_USER_PASSWORD set

ENV_FILE="./.env"

if [ ! -f "$ENV_FILE" ]; then
  printf "Error: %s not found. Please run generate-env.sh first.\n" "$ENV_FILE" >&2
  exit 1
fi

# Source the .env file to get MYSQL_USER_PASSWORD
# shellcheck disable=SC1090
. "$ENV_FILE"

if [ -z "${MYSQL_USER_PASSWORD:-}" ]; then
  printf "Error: MYSQL_USER_PASSWORD is not set in .env\n" >&2
  exit 1
fi

# Query the pendingConfirmations table
RESULT=$(docker exec mysql_db mysql -u feedland -p"$MYSQL_USER_PASSWORD" feedland -e "SELECT * FROM pendingConfirmations\G" 2>/dev/null || true)

if [ -z "$RESULT" ]; then
  printf "No pending confirmations found\n"
else
  printf "%s\n" "$RESULT"
  
  # Check if there are any rows
  ROW_COUNT=$(printf "%s\n" "$RESULT" | grep -c "^\*\*\*" || true)
  
  if [ "$ROW_COUNT" -gt 0 ]; then
    printf "\nConfirmation URLs:\n"
    # Extract urlRedirect from the result and use it to build URLs with magicStrings
    URL_SERVER=$(printf "%s\n" "$RESULT" | grep "urlRedirect:" | head -1 | sed 's/.*urlRedirect: *//;s/ *$//')
    
    if [ -n "$URL_SERVER" ]; then
      # Extract all magicString values and print URLs
      printf "%s\n" "$RESULT" | grep "magicString:" | sed 's/.*magicString: *//;s/ *$//' | while read -r MAGIC_STRING; do
        if [ -n "$MAGIC_STRING" ]; then
          printf "%suserconfirms?emailConfirmCode=%s\n" "$URL_SERVER" "$MAGIC_STRING"
        fi
      done
    fi
  fi
fi
