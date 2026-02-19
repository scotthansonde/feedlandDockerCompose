# FeedLand Docker Compose 
## A Docker Compose file to quickly start an instance of [FeedLand](https://docs.feedland.com/)

This repo provides a simple Docker Compose setup to run:

- **FeedLand**
- **MySQL** (for FeedLand data)
- optional **Caddy** (HTTPS reverse proxy)
- optional run FeedLand on localhost using HTTP on the default FeedLand port 1452

---

## Quick start

You have three options:

### Option 1: Manual `.env` (edit it yourself)

```bash
cp .env.example .env
nano .env   # or your editor
```

- Set `FEEDLAND_DOMAIN` to your real hostname (not `feedland.example.com`)
- (Optional) enable Caddy later by uncommenting `COMPOSE_PROFILES=caddy`

Then start:

```bash
docker compose up -d
```

---

### Option 2: Generate `.env` automatically (recommended)

This prompts for `FEEDLAND_DOMAIN` and generates strong MySQL passwords:

```bash
chmod +x scripts/generate-env.sh
./scripts/generate-env.sh
```

Then start:

```bash
docker compose up -d
```

---

### Option 3: Generate config.json for localhost development 

This sets `FEEDLAND_DOMAIN` to localhost:1452,
deactivates Caddy, and generates strong MySQL passwords:

```bash
chmod +x scripts/generate-env.sh
./scripts/generate-env.sh --http-localhost
```

Then start:

```bash
docker compose up -d
```

---

## What this does

- `docker compose up -d` starts the containers in the background (detached mode), so the terminal is returned once the containers have started
- If it doesn't exist, a `config.json` file will be generated using the values from `.env` 
- A MySQL server will be started 
  - If databases do not yet exist
    - Passwords will be set based on the values in `.env`
    - The `feedland` database will be initialized 
  - The generated database passwords are stored in `.env`
- A FeedLand server will be started
- If activated, a Caddy server can be started to forward HTTPS to the FeedLand instance

`config.json` can be extended or edited to meet your needs. 
---

## Enabling Caddy later

Edit `.env` and change:

```env
#COMPOSE_PROFILES=caddy
```

to:

```env
COMPOSE_PROFILES=caddy
```

Then apply:

```bash
docker compose up -d
```

---

## Validation (domain required)

`docker compose up -d` will refuse to start if:

- `FEEDLAND_DOMAIN` is missing, or
- `FEEDLAND_DOMAIN=feedland.example.com`

This is enforced by the `prep_config` service in `docker-compose.yml`.

---

## Common commands

Restart the feedland server (for example, after chaning config.json):

´´´bash
docker compose restart feedland
```

View logs:

```bash
docker compose logs -f
```

Stop:

```bash
docker compose down
```

Reset everything (⚠️ deletes MySQL + FeedLand data volumes):

```bash
docker compose down -v
```
---
## FeedLand E-Mail Validation
Some users running a local Feedland instance may not have the ability or desire to connect Feedland with an email service. As a shortcut to getting a new user added to the system, you can
do the following:

  * Sign up for a new user, and enter a username and email address
  * FeedLand will report an error sending email, but still create a new record in its `pendingConfirmations` table
  * From the folder containing docker-compose.yml run 
    ```bash
    ./scripts/query-pending-confirmations.sh
    ``` 
    This will show the pending confirmations and automatically generate the confirmation URL(s) using the `magicString` value(s) from `config.json`. The generated URLs will look like:
    ```
    http://"$FEEDLAND_DOMAIN"/userconfirms?emailConfirmCode=MAGIC_STRING_HERE
    ```
  * Copy the confirmation URL and submit it in your browser and enjoy!

(adapted from [DOCKER.md](https://github.com/cshotton/feedlandInstall/blob/main/DOCKER.md) by Chuck Schotton)
