# Project context

## Stack overview
This repository is intended to be reusable as a starter for future PHP web application projects.

Base services:
- `web`: Nginx serving the app on the host port defined by `WEB_PORT`
- `php`: custom PHP-FPM image built from `docker/php/Dockerfile`

Optional services via Docker Compose profiles:
- `mysql` (`db`): MariaDB database
- `postgres` (`postgres`): PostgreSQL database
- `redis` (`cache`): Redis for cache, sessions, or queues
- `mailpit` (`mail`, `tools`): local SMTP catcher and email preview UI
- `adminer` (`tools`): lightweight database administration UI

## Intended use and scope
Best suited for:
- PHP-FPM web applications
- Nginx-based local development
- front-controller apps with a configurable public document root
- projects that may optionally use MariaDB, PostgreSQL, Redis, Adminer, and Mailpit in development

Less suitable without modification for:
- Apache-based apps
- apps with highly custom web server rules
- non-standard PHP project layouts

## Reusability strategy
This repo is designed to be adaptable across different PHP applications by:
- keeping the base stack minimal (`web` + `php`)
- making extra dev services optional through Compose profiles
- supporting either MariaDB/MySQL or PostgreSQL in local development
- making the Nginx document root configurable with `APP_DOCUMENT_ROOT`
- providing multiple Nginx template examples
- making optional PHP extensions configurable through build args and `.env`

## Database modes
### MariaDB/MySQL mode
Recommended settings:
- `DB_DRIVER=mysql`
- `DB_HOST=mysql`
- use Compose profile: `db`

### PostgreSQL mode
Recommended settings:
- `DB_DRIVER=pgsql`
- `DB_HOST=postgres`
- `INSTALL_PGSQL=true`
- use Compose profile: `postgres`

If the application requires PHP PostgreSQL drivers, the PHP image can now install:
- `pdo_pgsql`
- `pgsql`

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
            +----------> PostgreSQL (optional, postgres profile)
            |
            +----------> Mailpit SMTP (optional, mail profile)

Adminer UI <- ADMINER_PORT (optional, tools profile)
Mailpit UI <- MAILPIT_UI_PORT (optional, tools/mail profile)
```

## Current image versions
- Nginx: `nginx:1.28-alpine`
- PHP base image: `php:8.3-fpm-bookworm`
- MariaDB: `mariadb:11.4`
- PostgreSQL: `postgres:17-alpine`
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
- `DB_DRIVER`
- `INSTALL_XDEBUG`
- `INSTALL_IMAGICK`
- `INSTALL_PGSQL`

Optional-service variables:
- `MYSQL_PORT`
- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_PORT`
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

Full stack with MariaDB:

```bash
docker compose --profile db --profile cache --profile mail --profile tools up -d --build
```

Full stack with PostgreSQL:

```bash
INSTALL_PGSQL=true DB_DRIVER=pgsql DB_HOST=postgres docker compose --profile postgres --profile cache --profile mail --profile tools up -d --build
```

Clean rebuild:

```bash
docker compose down -v
docker compose build --no-cache
docker compose --profile db --profile postgres --profile cache --profile mail --profile tools up -d
```

Using the Makefile:

```bash
make build
make up
make full-up
make postgres-up
make logs
make reset
```

## Validation checklist
- Base stack boots successfully.
- Optional `db` profile boots successfully when using MariaDB/MySQL.
- Optional `postgres` profile boots successfully when using PostgreSQL.
- Optional full stack boots successfully.
- `APP_DOCUMENT_ROOT` is adjusted correctly for the current application.
- Appropriate Nginx template is selected for the project type.

## Persistent storage
Database data is stored in named Docker volumes:
- `mysql_data`
- `postgres_data`

If database initialization scripts should re-run, remove volumes first:

```bash
docker compose down -v
```

## Important implementation notes
- `docker-compose.yml` uses environment-variable substitution with fallback defaults.
- Docker Compose auto-loads `.env`; `.env-dist` is only a template and should be copied to `.env`.
- Nginx config is templated through `docker/conf.d/nginx.conf.template`.
- Additional Nginx examples are stored under `docker/conf.d/examples/`.
- The default document root is `/app/public`, but it can be changed with `APP_DOCUMENT_ROOT`.
- PHP always includes `pdo`, `pdo_mysql`, `mysqli`, `bcmath`, `exif`, `gd`, `intl`, and `zip`.
- If `INSTALL_PGSQL=true`, the PHP image also installs `pdo_pgsql` and `pgsql`.
- `xdebug` and `imagick` are optional and controlled by build args.
- Redis, Adminer, and Mailpit are development conveniences and not required for every project.

## Known caveats
- Projects with unusual routing or non-front-controller layouts may still need a custom Nginx template.
- MariaDB or PostgreSQL version upgrades may require a local volume reset during development.
- Optional PECL or DB-related extension builds may fail if upstream dependencies change.

## Completed improvements
- Converted the stack toward reusable-starter behavior.
- Made extra dev services optional through Compose profiles.
- Added PostgreSQL as an optional profile.
- Added optional PHP PostgreSQL extensions.
- Replaced fixed Nginx config with a configurable template.
- Added Nginx examples for multiple app styles.
- Simplified the PHP image baseline and made `xdebug`/`imagick` optional.
- Added a validation checklist and clearer starter scope documentation.
