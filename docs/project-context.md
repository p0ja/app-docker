# Project context

## Stack overview
This repository provides a local Docker-based development environment for a PHP application.

Services:
- `web`: Nginx serving the app on the host port defined by `WEB_PORT`
- `php`: custom PHP-FPM image built from `docker/php/Dockerfile`
- `mysql`: MariaDB database on the host port defined by `MYSQL_PORT`
- `redis`: Redis for cache, sessions, or queue-related local development needs
- `adminer`: lightweight database administration UI for local inspection
- `mailpit`: local SMTP catcher and email preview UI

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
            |       +--> Redis (redis)
            |
            +----------> MariaDB (mysql)
            |
            +----------> Mailpit SMTP (mailpit)

Adminer UI <- ADMINER_PORT
Mailpit UI <- MAILPIT_UI_PORT
```

Request/data flow:
1. Requests enter through `WEB_PORT` on the host.
2. Nginx handles HTTP traffic and forwards PHP execution to the `php` container.
3. The PHP container runs the app mounted from `./app`.
4. Database connections should target `DB_HOST=mysql` on the internal Docker network.
5. Redis connections should target `REDIS_HOST=redis`.
6. Outgoing local SMTP should target `SMTP_HOST=mailpit` and `SMTP_PORT=1025`.
7. MariaDB data persists in the `mysql_data` named volume.
8. Adminer is available for DB inspection and Mailpit is available for local email inspection.

## Current image versions
- Nginx: `nginx:1.28-alpine`
- PHP base image: `php:8.3-fpm-bookworm`
- MariaDB: `mariadb:11.4`
- Redis: `redis:7-alpine`
- Adminer: `adminer:4`
- Mailpit: `axllent/mailpit:latest`

## Environment variables
The Compose setup reads values from `.env`.

Template file:
- `.env-dist`

Main variables:
- `WEB_PORT`
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
Initial setup:

```bash
cp .env-dist .env
docker compose up -d --build
```

Clean rebuild:

```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
docker compose ps
docker compose logs --tail=100 web php mysql redis adminer mailpit
```

Using the Makefile:

```bash
make build
make up
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
- MariaDB init scripts mounted from `./docker/db` run only on first DB initialization.
- PHP image includes `pdo_mysql`, `mysqli`, `bcmath`, `exif`, `gd`, `intl`, `zip`, `xdebug`, and `imagick`.
- Redis, Adminer, and Mailpit are provided for local development convenience and may not correspond to production services.

## Known caveats
- MariaDB version upgrades may require a local volume reset during development.
- PECL extension builds, especially `imagick` or `xdebug`, may occasionally fail if upstream dependencies change.
- If Nginx returns `502`, check both `web` and `php` logs and verify Nginx config in `./docker/conf.d`.
- Mailpit uses `latest`, so if you want stricter reproducibility later, pin it to a specific version.

## Recommended troubleshooting commands
See `docs/troubleshooting.md` for deeper troubleshooting steps.

## Completed improvements
- Added a short architecture and service flow description.
- Added a `Makefile` with common Docker commands.
- Split quick-start content in `README.md` from deeper troubleshooting notes in `docs/troubleshooting.md`.
- Added Redis, Adminer, and Mailpit for richer local PHP development workflows.
