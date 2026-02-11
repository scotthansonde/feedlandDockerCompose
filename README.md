# FeedLand Docker Compose

This repo provides a simple Docker Compose setup to run:

- **FeedLand**
- **MySQL** (for FeedLand data)
- optional **Caddy** (HTTPS reverse proxy)

---

## Quick start

You have two options:

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

This is enforced by the `check` service in `docker-compose.yml`.

---

## Common commands

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
