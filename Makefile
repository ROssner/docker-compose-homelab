# -------------------------------------------------------
# Makefile — unified commands for docker-compose-homelab
# Usage: make <target> STACK=<monitoring|webstack|traefik|logging>
# -------------------------------------------------------

STACK ?= all
COMPOSE_FILES := monitoring webstack traefik logging

.PHONY: up down restart logs ps pull clean health backup

up:
ifeq ($(STACK),all)
	@for stack in $(COMPOSE_FILES); do \
		echo "Starting $$stack..."; \
		docker compose -f $$stack/docker-compose.yml --env-file .env up -d; \
	done
else
	docker compose -f $(STACK)/docker-compose.yml --env-file .env up -d
endif

down:
ifeq ($(STACK),all)
	@for stack in $(COMPOSE_FILES); do \
		echo "Stopping $$stack..."; \
		docker compose -f $$stack/docker-compose.yml --env-file .env down; \
	done
else
	docker compose -f $(STACK)/docker-compose.yml --env-file .env down
endif

restart:
	$(MAKE) down STACK=$(STACK)
	$(MAKE) up STACK=$(STACK)

logs:
	docker compose -f $(STACK)/docker-compose.yml --env-file .env logs -f --tail=100

ps:
	@for stack in $(COMPOSE_FILES); do \
		echo "=== $$stack ==="; \
		docker compose -f $$stack/docker-compose.yml --env-file .env ps; \
	done

pull:
	@for stack in $(COMPOSE_FILES); do \
		echo "Pulling $$stack images..."; \
		docker compose -f $$stack/docker-compose.yml --env-file .env pull; \
	done

clean:
	docker system prune -f
	docker volume prune -f

health:
	@bash scripts/healthcheck.sh

backup:
	@bash scripts/backup-volumes.sh
