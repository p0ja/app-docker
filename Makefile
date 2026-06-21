.PHONY: help up full-up build rebuild down reset logs full-logs ps config shell-php shell-web mysql-logs redis-logs mail-logs

help:
	@echo "Available targets:"
	@echo "  up         - Start base web/php stack"
	@echo "  full-up    - Start full stack with db, cache, mail, and tools profiles"
	@echo "  build      - Build images"
	@echo "  rebuild    - Rebuild images without cache and restart base stack"
	@echo "  down       - Stop containers"
	@echo "  reset      - Stop containers, remove volumes, rebuild, and start full stack"
	@echo "  logs       - Show recent logs for base stack"
	@echo "  full-logs  - Show recent logs for full stack"
	@echo "  ps         - Show container status"
	@echo "  config     - Show rendered docker compose config"
	@echo "  shell-php  - Open a shell in the php container"
	@echo "  shell-web  - Open a shell in the web container"
	@echo "  mysql-logs - Show mysql logs"
	@echo "  redis-logs - Show redis logs"
	@echo "  mail-logs  - Show mailpit logs"

up:
	docker compose up -d

full-up:
	docker compose --profile db --profile cache --profile mail --profile tools up -d

build:
	docker compose build

rebuild:
	docker compose build --no-cache
	docker compose up -d

down:
	docker compose down

reset:
	docker compose down -v
	docker compose build --no-cache
	docker compose --profile db --profile cache --profile mail --profile tools up -d

logs:
	docker compose logs --tail=100 web php

full-logs:
	docker compose --profile db --profile cache --profile mail --profile tools logs --tail=100 web php mysql redis adminer mailpit

ps:
	docker compose ps

config:
	docker compose config

shell-php:
	docker compose exec php sh

shell-web:
	docker compose exec web sh

mysql-logs:
	docker compose --profile db logs mysql

redis-logs:
	docker compose --profile cache logs redis

mail-logs:
	docker compose --profile mail logs mailpit
