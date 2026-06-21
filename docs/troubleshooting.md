# Troubleshooting

## Quick troubleshooting commands

```bash
docker compose ps
docker compose logs --tail=100 web php mysql
docker compose exec php env | grep DB_
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
Change `WEB_PORT` or `MYSQL_PORT` in `.env`.

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
