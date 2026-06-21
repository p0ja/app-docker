# Troubleshooting

## Quick troubleshooting commands

Base stack only:

```bash
docker compose ps
docker compose logs --tail=100 web php
docker compose exec php ls -la /app
docker compose config
```

Full stack with optional services enabled:

```bash
docker compose --profile db --profile postgres --profile cache --profile mail --profile tools ps
docker compose --profile db --profile postgres --profile cache --profile mail --profile tools logs --tail=100 web php mysql postgres redis adminer mailpit
docker compose exec php env | grep -E 'DB_|REDIS_|SMTP_'
```

## Common issues

### Nginx returns an error page or 502
Check:
- `docker compose logs web php`
- nginx template in `docker/conf.d/nginx.conf.template`
- example templates in `docker/conf.d/examples/`
- whether `APP_DOCUMENT_ROOT` matches the actual app public directory
- whether PHP is running correctly

### App routes do not work
If the app is not a front-controller app, the default Nginx template may be wrong.
Try replacing it with:
- `docker/conf.d/examples/nginx.plain-php.conf.template`

If the app does use a front controller, keep or restore:
- `docker/conf.d/examples/nginx.front-controller.conf.template`

### App cannot connect to MariaDB/MySQL
If using the `db` profile, check:
- `DB_DRIVER=mysql`
- `DB_HOST=mysql`
- `docker compose --profile db logs mysql`
- `.env`
- `docker compose config`

### App cannot connect to PostgreSQL
If using the `postgres` profile, check:
- `DB_DRIVER=pgsql`
- `DB_HOST=postgres`
- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
- `INSTALL_PGSQL=true` if the PHP app requires native PostgreSQL extensions
- `docker compose --profile postgres logs postgres`
- rebuild after enabling PostgreSQL extensions:
  ```bash
  docker compose build --no-cache
  ```

### App cannot connect to Redis
If using the `cache` profile, check:
- `REDIS_HOST=redis`
- `REDIS_PORT=6379`
- `docker compose --profile cache logs redis`

### Email is not visible in Mailpit
If using the `mail` profile, check:
- `SMTP_HOST=mailpit`
- `SMTP_PORT=1025`
- `docker compose --profile mail logs mailpit`
- Mailpit UI at `http://localhost:8025`

### Adminer cannot log in
If using the `tools` profile, try:
- server: `mysql` for MariaDB/MySQL
- server: `postgres` for PostgreSQL
- username/password/database values from your selected database settings

### PHP build fails
Check:
- whether `INSTALL_XDEBUG`, `INSTALL_IMAGICK`, or `INSTALL_PGSQL` is enabled
- `docker compose build --no-cache`
- PECL output for failing optional extensions
- package installation output for PostgreSQL development libraries if `INSTALL_PGSQL=true`
