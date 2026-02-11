#!/bin/sh
set -eu

: "${FEEDLAND_DB:?missing}"
: "${FEEDLAND_USER:?missing}"
: "${FEEDLAND_PASSWORD:?missing}"
: "${SETUP_SQL_URL:?missing}"

apk add --no-cache curl >/dev/null

echo "Writing /work/00-user.sql ..."
tmpfile="$(mktemp)"
cat > "$tmpfile" <<EOF
CREATE USER IF NOT EXISTS '${FEEDLAND_USER}'@'%' IDENTIFIED BY '${FEEDLAND_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${FEEDLAND_DB}\`.* TO '${FEEDLAND_USER}'@'%';
FLUSH PRIVILEGES;
EOF
mv "$tmpfile" /work/00-user.sql

echo "Downloading setup.sql -> /work/01-setup.sql ..."
curl -fsSL "$SETUP_SQL_URL" -o /work/01-setup.sql
chmod 0644 /work/00-user.sql /work/01-setup.sql
echo "Init dir contents:"
ls -la /work