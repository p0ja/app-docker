# app-docker

## Overview
This repository provides a local Docker-based development environment for a PHP application using:
- **web**: Nginx
- **php**: custom PHP-FPM image
- **mysql**: MariaDB
- **redis**: Redis cache/session store
- **adminer**: lightweight database administration UI
- **mailpit**: local SMTP catcher and mail UI

## Architecture

```text
Browser
  |
  v
WEB_PORT -> nginx (web)
              |
              v
           php-fpm (php)
            |      \
            |       +--> Redis (redis)
            |
            +----------> MariaDB (mysql) <- MYSQL_PORT
            |
            +----------> Mailpit SMTP (mailpit) <- MAILPIT_SMTP_PORT

Adminer UI  <- ADMINER_PORT
Mailpit UI  <- MAILPIT_UI_PORT
```

Service flow:
1. The browser connects to the `web` service through `WEB_PORT`.
2. Nginx serves static files and forwards PHP requests to the `php` service.
3. The `php` service runs the application code from `./app`.
4. The application connects to `mysql` using `DB_HOST=mysql`.
5. The application can use `redis` using `REDIS_HOST=redis`.
6. The application can send SMTP mail to `mailpit` using `SMTP_HOST=mailpit`.
7. MariaDB stores persistent data in the `mysql_data` named volume.
8. Adminer provides a local DB UI and Mailpit provides a local mail UI.

## Quick reset and rebuild

Use this sequence to test the full stack from a clean local state:

```bash
cp .env-dist .env
docker compose down -v
docker compose build --no-cache
docker compose up -d
docker compose ps
docker compose logs --tail=100 web php mysql redis adminer mailpit
docker compose config
```

## First startup sanity checklist

### 1. Prepare env file
Copy the template and adjust values if needed:

```bash
cp .env-dist .env
```

Check these values in `.env`:
- `WEB_PORT`
- `MYSQL_PORT`
- `REDIS_PORT`
- `ADMINER_PORT`
- `MAILPIT_SMTP_PORT`
- `MAILPIT_UI_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASS`
- `MYSQL_ROOT_PASSWORD`

### 2. Verify ports are free
Make sure these host ports are available:
- web: `8888`
- mysql: `3325`
- redis: `6379`
- adminer: `8080`
- mailpit smtp: `1025`
- mailpit ui: `8025`

If needed, change them in `.env`.

### 3. Start clean if you used an older setup
Because the database volume setup changed, a clean start is often safest:

```bash
docker compose down -v
```

### 4. Start the stack
```bash
docker compose up -d --build
```

### 5. Confirm containers are running
```bash
docker compose ps
```

Expected services:
- `web`
- `php`
- `mysql`
- `redis`
- `adminer`
- `mailpit`

### 6. Check service startup
```bash
docker compose logs mysql redis mailpit
```

Look for startup completion and no authentication or init-script errors.

### 7. Open the app and dev tools
App:

```text
http://localhost:8888
```

Adminer:

```text
http://localhost:8080
```

Mailpit:

```text
http://localhost:8025
```

If you changed ports in `.env`, use those values instead.

### 8. Check app files are mounted
```bash
docker compose exec php ls -la /app
docker compose exec web ls -la /app
```

### 9. Check DB and service variables inside PHP container
```bash
docker compose exec php env | grep -E 'DB_|REDIS_|SMTP_'
```

Expected values should include:
- `DB_HOST=mysql`
- `REDIS_HOST=redis`
- `SMTP_HOST=mailpit`
- your configured DB name/user/password

### 10. Check rendered Compose config
```bash
docker compose config
```

This shows the final configuration after `.env` substitution.

## Documentation
- `docs/project-context.md` — persistent project knowledge and technical notes
- `docs/troubleshooting.md` — deeper troubleshooting steps and common fixes
