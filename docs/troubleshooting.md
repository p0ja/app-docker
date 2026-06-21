# Troubleshooting

## Quick troubleshooting commands

```bash
docker compose ps
docker compose logs --tail=100 web php mysql redis adminer mailpit
docker compose exec php env | grep -E 'DB_|REDIS_|SMTP_'
docker compose exec php ls -la /app
docker compose exec web ls -la /app
docker compose config
```

## Database initialization scripts
Files in `./docker/db` mounted to `/docker-entrypoint-initdb.d` run only on first database initialization.

If they did not run:

```bash
docker compose down -v
docker compose up -d --build
```

## Common issues

### Port already allocated
Change one of these in `.env` if needed:
- `WEB_PORT`
- `MYSQL_PORT`
- `REDIS_PORT`
- `ADMINER_PORT`
- `MAILPIT_SMTP_PORT`
- `MAILPIT_UI_PORT`

### MySQL auth fails
Old DB volume data may still exist. Reset with:

```bash
docker compose down -v
docker compose up -d --build
```

### App cannot connect to DB
Check:
- `.env`
- `docker compose config`
- `docker compose logs php mysql`
- whether the app is using `DB_HOST=mysql`

### App cannot connect to Redis
Check:
- `REDIS_HOST=redis`
- `REDIS_PORT=6379`
- `docker compose logs redis`
- whether the PHP app actually has Redis client support configured

### Email is not visible in Mailpit
Check:
- `SMTP_HOST=mailpit`
- `SMTP_PORT=1025`
- `docker compose logs mailpit`
- Mailpit UI at `http://localhost:8025`

### Adminer cannot log in
Try:
- server: `mysql`
- username: value of `MYSQL_USER`
- password: value of `MYSQL_PASSWORD`
- database: value of `MYSQL_DATABASE`

### Nginx returns an error page or 502
Check:
- `docker compose logs web php`
- nginx config in `./docker/conf.d`
- whether PHP is running correctly

### PHP build fails
If the PHP image build fails:
- rebuild with `docker compose build --no-cache`
- inspect PECL extension output for `imagick` or `xdebug`
- verify package names still match the Debian base image used by `docker/php/Dockerfile`
