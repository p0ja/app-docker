# app-docker

## Overview
This repository is a reusable local Docker starter for PHP web applications.

## Who this starter is for
This starter is a good fit for:
- PHP web applications running on **PHP-FPM**
- projects served by **Nginx**
- apps that use a **front controller** such as `public/index.php`
- projects that may optionally need local **MariaDB**, **PostgreSQL**, **Redis**, **Mailpit**, or **Adminer**

This starter may need adjustment for:
- plain PHP sites without front-controller routing
- projects using **Apache** instead of Nginx
- projects with unusual directory layouts or deployment assumptions

## Database modes
This starter supports two common database modes:

### MySQL / MariaDB mode
Use:
- `DB_DRIVER=mysql`
- `DB_HOST=mysql`
- Compose profile: `db`

### PostgreSQL mode
Use:
- `DB_DRIVER=pgsql`
- `DB_HOST=postgres`
- `INSTALL_PGSQL=true`
- Compose profile: `postgres`

If your PHP application needs native PostgreSQL support, enable PostgreSQL extensions during build with:

```env
INSTALL_PGSQL=true
```

## Default services
- **web**: Nginx
- **php**: custom PHP-FPM image

## Optional services via Docker Compose profiles
- **mysql** (`db`): MariaDB database
- **postgres** (`postgres`): PostgreSQL database
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
            +----------> PostgreSQL (postgres, optional)
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

Add PostgreSQL:

```bash
docker compose --profile postgres up -d --build
```

Add MariaDB + Redis + tools:

```bash
docker compose --profile db --profile cache --profile tools up -d --build
```

Add PostgreSQL + Redis + tools:

```bash
docker compose --profile postgres --profile cache --profile tools up -d --build
```

Add everything including SMTP testing:

```bash
docker compose --profile db --profile postgres --profile cache --profile mail --profile tools up -d --build
```

## Quick reset and rebuild

Use this sequence to test the full stack from a clean local state:

```bash
cp .env-dist .env
docker compose down -v
docker compose build --no-cache
docker compose --profile db --profile postgres --profile cache --profile mail --profile tools up -d
docker compose ps
docker compose logs --tail=100 web php mysql postgres redis adminer mailpit
docker compose config
```

## Reusing this starter for a new project
1. Copy your application into `./app`.
2. Copy `.env-dist` to `.env`.
3. Set `APP_DOCUMENT_ROOT` to match your app.
4. Choose the Compose profiles you need.
5. Choose the database mode that matches your app:
   - MariaDB/MySQL mode: `DB_DRIVER=mysql`, `DB_HOST=mysql`
   - PostgreSQL mode: `DB_DRIVER=pgsql`, `DB_HOST=postgres`, `INSTALL_PGSQL=true`
6. Enable optional PHP features if needed:
   - `INSTALL_XDEBUG=true`
   - `INSTALL_IMAGICK=true`
7. If the default Nginx template does not fit your app style, switch to one of the example templates in `docker/conf.d/examples/`.

## Nginx template options
- `docker/conf.d/nginx.conf.template` — default front-controller template
- `docker/conf.d/examples/nginx.front-controller.conf.template` — explicit example for frameworks using `/index.php`
- `docker/conf.d/examples/nginx.plain-php.conf.template` — example for simpler PHP sites without front-controller fallback

## Validation checklist
### Base stack
```bash
cp .env-dist .env
docker compose down -v
docker compose build --no-cache
docker compose up -d
docker compose ps
docker compose logs --tail=100 web php
```

### MariaDB profile
```bash
docker compose down -v
docker compose --profile db up -d --build
docker compose --profile db ps
docker compose --profile db logs --tail=100 web php mysql
```

### PostgreSQL profile
```bash
cp .env-dist .env
# then set DB_DRIVER=pgsql, DB_HOST=postgres, INSTALL_PGSQL=true
docker compose down -v
docker compose build --no-cache
docker compose --profile postgres up -d
docker compose --profile postgres ps
docker compose --profile postgres logs --tail=100 web php postgres
```

### Full stack
```bash
docker compose down -v
docker compose --profile db --profile postgres --profile cache --profile mail --profile tools up -d --build
docker compose --profile db --profile postgres --profile cache --profile mail --profile tools ps
docker compose --profile db --profile postgres --profile cache --profile mail --profile tools logs --tail=100 web php mysql postgres redis adminer mailpit
```

## Documentation
- `docs/project-context.md` — persistent project knowledge and technical notes
- `docs/troubleshooting.md` — deeper troubleshooting steps and common fixes
