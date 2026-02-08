# FeedLand Docker Compose

This project provides a simple Docker Compose setup to run:
- a **FeedLand server**
- a **MySQL server** for FeedLand data
- optionally a **Caddy server** for HTTPS (if you enable the `caddy` compose profile)

---

## One-step install (Linux/macOS)

From the repo folder:

```bash
chmod +x install.sh scripts/init-env.sh
./install.sh
```

The installer will:
- Prompt for `FEEDLAND_DOMAIN` (example: `feed.example.com`)
- Create `.env` from `.env.example` if needed
- Generate strong random MySQL passwords (if missing/placeholders)
- Start the stack with `docker compose up -d`

### Non-interactive install (Linux/macOS)

If you want to run without prompts (e.g. automation), set the domain as an environment variable:

```bash
FEEDLAND_DOMAIN=feed.example.com ./install.sh
```

---

## Windows notes

The `.sh` installer works best from:
- **WSL (recommended)**, or
- **Git Bash** (often works)

### Windows PowerShell fallback (no prompt)

In PowerShell, you can do the equivalent without `install.sh` prompts:

```powershell
# From the repo root
$env:FEEDLAND_DOMAIN = "feed.example.com"

# Run the env initializer (requires Git Bash or WSL for the .sh script)
bash ./scripts/init-env.sh

# Ensure FEEDLAND_DOMAIN is in .env (append if missing)
if (-not (Select-String -Path ".env" -Pattern "^FEEDLAND_DOMAIN=" -Quiet)) {
  Add-Content -Path ".env" -Value "`nFEEDLAND_DOMAIN=$env:FEEDLAND_DOMAIN"
}

docker compose up -d
```

> Tip: If you don’t have `bash` available on Windows, install WSL or Git for Windows (Git Bash), then rerun the Linux/macOS steps.

---

## What this does

- `./install.sh` prepares `.env` and starts the stack
- `docker compose up -d` starts the containers in the background (detached mode), so the terminal is returned immediately and the containers keep running
- A `config.json` file can be generated using the values from `.env` (depending on how your FeedLand image/startup is configured)
- A MySQL server will be started and a `feedland` database can be initialized (depending on your compose configuration)
- A FeedLand server will be started
- If activated, a Caddy server can be started forwarding HTTPS to the FeedLand instance

---

## Viewing the generated MySQL passwords later

The generated credentials are stored in `.env`.

To display them:

```bash
grep '^MYSQL_\(ROOT_PASSWORD\|USER_PASSWORD\)=' .env
```

⚠️ Keep `.env` private and out of version control.

---

## Managing the services

- View logs:
  ```bash
  docker compose logs -f
  ```

- Restart services:
  ```bash
  docker compose restart
  ```

- Stop services:
  ```bash
  docker compose down
  ```

---

## Important notes about MySQL passwords

MySQL environment variables are applied **only on first startup**, when the database volume is empty.

If you change MySQL passwords in `.env` after MySQL has already been initialized, you must either:
- Rotate the passwords inside MySQL manually, or
- Remove the MySQL data volume and start fresh

---

## Security notes

- Do **not** expose MySQL to the public internet unless you really need to
- Keep `.env` private and backed up securely
- Use HTTPS in production (via Caddy or another reverse proxy)

---

Enjoy your FeedLand instance!
