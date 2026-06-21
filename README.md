# app-docker

## Overview
This repository provides a local Docker-based development environment for a PHP application using:
- **web**: Nginx
- **php**: custom PHP-FPM image
- **mysql**: MariaDB

## Architecture

```text
Browser
  |
  v
WEB_PORT -> nginx (web)
              |
              v
           php-fpm (php)
              |
              v
          MariaDB (mysql) <- MYSQL_PORT (optional host access)
```

Service flow:
1. The browser connects to the `web` service through `WEB_PORT`.
2. Nginx serves static files and forwards PHP requests to the `php` service.
3. The `php` service runs the application code from `./app`.
4. The application connects to the `mysql` service using `DB_HOST=mysql`.
5. MariaDB stores persistent data in the `mysql_data` named volume.

## Quick reset and rebuild

Use this sequence to test the full stack from a clean local state:

```bash
cp .env-dist .env
docker compose down -v
docker compose build --no-cache
docker compose up -d
docker compose ps
docker compose logs --tail=100 web php mysql
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
- `DB_NAME`
- `DB_USER`
- `DB_PASS`
- `MYSQL_ROOT_PASSWORD`

### 2. Verify ports are free
Make sure these host ports are available:
- web: `8888`
- mysql: `3325`

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

### 6. Check MySQL startup
```bash
docker compose logs mysql
```

Look for startup completion and no authentication or init-script errors.

### 7. Open the app
Open in your browser:

```text
http://localhost:8888
```

If you changed `WEB_PORT`, use that port instead.

### 8. Check app files are mounted
```bash
docker compose exec php ls -la /app
docker compose exec web ls -la /app
```

### 9. Check DB variables inside PHP container
```bash
docker compose exec php env | grep DB_
```

Expected values should include:
- `DB_HOST=mysql`
- your configured DB name/user/password

### 10. Check rendered Compose config
```bash
docker compose config
```

This shows the final configuration after `.env` substitution.

## Documentation
- `docs/project-context.md` — persistent project knowledge and technical notes
- `docs/troubleshooting.md` — deeper troubleshooting steps and common fixes
