# app-docker

## Overview
This repository is a reusable local Docker starter for PHP web applications.

Default services:
- **web**: Nginx
- **php**: custom PHP-FPM image

Optional services via Docker Compose profiles:
- **mysql** (`db`): MariaDB database
- **redis** (`cache`): Redis cache/session store
- **mailpit** (`mail`, `tools`): local SMTP catcher and mail UI
- **adminer** (`tools`): lightweight database administration UI

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
            |       +--> Redis (redis, optional)
            |
            +----------> MariaDB (mysql, optional)
            |
            +----------> Mailpit SMTP (mailpit, optional)

Adminer UI  <- ADMINER_PORT (optional)
Mailpit UI  <- MAILPIT_UI_PORT (optional)
```

## Compose profiles
Start only the base web/PHP stack:

```bash
docker compose up -d --build
```

Add MariaDB:

```bash
docker compose --profile db up -d --build
```

Add MariaDB + Redis + tools:

```bash
docker compose --profile db --profile cache --profile tools up -d --build
```

Add everything including SMTP testing:

```bash
docker compose --profile db --profile cache --profile mail --profile tools up -d --build
```

## Quick reset and rebuild

Use this sequence to test the full stack from a clean local state:

```bash
cp .env-dist .env
docker compose down -v
docker compose build --no-cache
docker compose --profile db --profile cache --profile mail --profile tools up -d
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

Important variables:
- `WEB_PORT`
- `SERVER_NAME`
- `APP_DOCUMENT_ROOT`
- `MYSQL_PORT`
- `REDIS_PORT`
- `ADMINER_PORT`
- `MAILPIT_SMTP_PORT`
- `MAILPIT_UI_PORT`
- `INSTALL_XDEBUG`
- `INSTALL_IMAGICK`

### 2. Verify ports are free
Common defaults:
- web: `8888`
- mysql: `3325`
- redis: `6379`
- adminer: `8080`
- mailpit smtp: `1025`
- mailpit ui: `8025`

### 3. App layout assumption
The default Nginx document root is:

```text
/app/public
```

For projects with a different public directory, change:
- `APP_DOCUMENT_ROOT` in `.env`

### 4. Open dev tools when enabled
- App: `http://localhost:8888`
- Adminer: `http://localhost:8080`
- Mailpit: `http://localhost:8025`

## Reusing this starter for a new project
1. Copy your application into `./app`.
2. Copy `.env-dist` to `.env`.
3. Adjust `APP_DOCUMENT_ROOT` if your app does not use `/public`.
4. Enable only the profiles you need.
5. Enable optional PHP features with:
   - `INSTALL_XDEBUG=true`
   - `INSTALL_IMAGICK=true`

## Documentation
- `docs/project-context.md` — persistent project knowledge and technical notes
- `docs/troubleshooting.md` — deeper troubleshooting steps and common fixes
