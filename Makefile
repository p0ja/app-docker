.PHONY: help up build rebuild down reset logs ps config shell-php shell-web mysql-logs

help:
	@echo "Available targets:"
	@echo "  up         - Start containers in detached mode"
	@echo "  build      - Build images"
	@echo "  rebuild    - Rebuild images without cache and restart"
	@echo "  down       - Stop containers"
	@echo "  reset      - Stop containers, remove volumes, rebuild, and start"
	@echo "  logs       - Show recent logs for web, php, and mysql"
	@echo "  ps         - Show container status"
	@echo "  config     - Show rendered docker compose config"
	@echo "  shell-php  - Open a shell in the php container"
	@echo "  shell-web  - Open a shell in the web container"
	@echo "  mysql-logs - Show mysql logs"

up:
	docker compose up -d

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
	docker compose up -d

logs:
	docker compose logs --tail=100 web php mysql

ps:
	docker compose ps

config:
	docker compose config

shell-php:
	docker compose exec php sh

shell-web:
	docker compose exec web sh

mysql-logs:
	docker compose logs mysql
