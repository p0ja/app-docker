# Project context

## Stack overview
This repository is intended to be reusable as a starter for future PHP web application projects.

Base services:
- `web`: Nginx serving the app on the host port defined by `WEB_PORT`
- `php`: custom PHP-FPM image built from `docker/php/Dockerfile`

Optional services via Docker Compose profiles:
- `mysql` (`db`): MariaDB database
- `redis` (`cache`): Redis for cache, sessions, or queues
- `mailpit` (`mail`, `tools`): local SMTP catcher and email preview UI
- `adminer` (`tools`): lightweight database administration UI

## Reusability strategy
This repo is designed to be adaptable across different PHP applications by:
- keeping the base stack minimal (`web` + `php`)
- making extra dev services optional through Compose profiles
- making the Nginx document root configurable with `APP_DOCUMENT_ROOT`
- making optional PHP extensions configurable through build args and `.env`

## Architecture and request flow

```text
Browser
  |
  v
WEB_PORT -> nginx (web)
              |
              v
           php-fpm (php)
            |      \
            |       +--> Redis (optional, cache profile)
            |
            +----------> MariaDB (optional, db profile)
            |
            +----------> Mailpit SMTP (optional, mail profile)

Adminer UI <- ADMINER_PORT (optional, tools profile)
Mailpit UI <- MAILPIT_UI_PORT (optional, tools/mail profile)
```

## Current image versions
- Nginx: `nginx:1.28-alpine`
- PHP base image: `php:8.3-fpm-bookworm`
- MariaDB: `mariadb:11.4`
- Redis: `redis:7-alpine`
- Adminer: `adminer:4`
- Mailpit: `axllent/mailpit:v1.21`

## Environment variables
The Compose setup reads values from `.env`.

Template file:
- `.env-dist`

Core variables:
- `WEB_PORT`
- `SERVER_NAME`
- `APP_DOCUMENT_ROOT`
- `INSTALL_XDEBUG`
- `INSTALL_IMAGICK`

Optional-service variables:
- `MYSQL_PORT`
- `REDIS_HOST`
- `REDIS_PORT`
- `ADMINER_PORT`
- `SMTP_HOST`
- `SMTP_PORT`
- `MAILPIT_SMTP_PORT`
- `MAILPIT_UI_PORT`
- `DB_HOST`
- `DB_NAME`
- `DB_USER`
- `DB_PASS`
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_DATABASE`

## Local development workflow
Base stack only:

```bash
cp .env-dist .env
docker compose up -d --build
```

Full stack:

```bash
docker compose --profile db --profile cache --profile mail --profile tools up -d --build
```

Clean rebuild:

```bash
docker compose down -v
docker compose build --no-cache
docker compose --profile db --profile cache --profile mail --profile tools up -d
```

Using the Makefile:

```bash
make build
make up
make full-up
make logs
make reset
```

## Persistent storage
MariaDB data is stored in the named Docker volume:
- `mysql_data`

If database initialization scripts should re-run, remove volumes first:

```bash
docker compose down -v
```

## Important implementation notes
- `docker-compose.yml` uses environment-variable substitution with fallback defaults.
- Docker Compose auto-loads `.env`; `.env-dist` is only a template and should be copied to `.env`.
- Nginx config is templated through `docker/conf.d/nginx.conf.template`.
- The default document root is `/app/public`, but it can be changed with `APP_DOCUMENT_ROOT`.
- PHP always includes `pdo`, `pdo_mysql`, `mysqli`, `bcmath`, `exif`, `gd`, `intl`, and `zip`.
- `xdebug` and `imagick` are optional and controlled by build args.
- Redis, Adminer, and Mailpit are development conveniences and not required for every project.

## Known caveats
- Projects with unusual routing or non-front-controller layouts may still need a custom Nginx template.
- MariaDB version upgrades may require a local volume reset during development.
- Optional PECL extension builds may fail if upstream dependencies change.

## Completed improvements
- Converted the stack toward reusable-starter behavior.
- Made extra dev services optional through Compose profiles.
- Replaced fixed Nginx config with a configurable template.
- Simplified the PHP image baseline and made `xdebug`/`imagick` optional.
