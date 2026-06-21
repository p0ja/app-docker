# Project context

## Stack overview
This repository provides a local Docker-based development environment for a PHP application.

Services:
- `web`: Nginx serving the app on the host port defined by `WEB_PORT`
- `php`: custom PHP-FPM image built from `docker/php/Dockerfile`
- `mysql`: MariaDB database on the host port defined by `MYSQL_PORT`

## Current image versions
- Nginx: `nginx:1.28-alpine`
- PHP base image: `php:8.3-fpm-bookworm`
- MariaDB: `mariadb:11.4`

## Environment variables
The Compose setup reads values from `.env`.

Template file:
- `.env-dist`

Main variables:
- `WEB_PORT`
- `MYSQL_PORT`
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
docker compose logs --tail=100 web php mysql
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

## Known caveats
- MariaDB version upgrades may require a local volume reset during development.
- PECL extension builds, especially `imagick` or `xdebug`, may occasionally fail if upstream dependencies change.
- If Nginx returns `502`, check both `web` and `php` logs and verify Nginx config in `./docker/conf.d`.

## Recommended troubleshooting commands
```bash
docker compose ps
docker compose logs --tail=100 web php mysql
docker compose exec php env | grep DB_
docker compose exec php ls -la /app
docker compose exec web ls -la /app
docker compose config
```

## Suggested next improvements
- Add a short architecture diagram or service flow description.
- Add a `Makefile` with common commands such as `up`, `down`, `reset`, and `logs`.
- Optionally split README quick-start content from deeper troubleshooting docs.
