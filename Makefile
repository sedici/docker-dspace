include .env

.PHONY: up update install down stop prune ps bash logs index-discovery oai

default: up

up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker-compose -f docker-compose.yml -f docker-compose-debug.yml -f others/docker-compose-other.yml up -d

update:
	docker-compose -f docker-compose.yml -f docker-compose-debug.yml -f others/docker-compose-other.yml run --rm dspace update
	chown -R $(id -u):$(id -g) data/*

install:
	docker-compose -f docker-compose.yml -f docker-compose-debug.yml -f others/docker-compose-other.yml run dspace install
	chown -R $(id -u):$(id -g) data/*

reset-db:
	docker-compose -f docker-compose.yml -f docker-compose-debug.yml -f others/docker-compose-other.yml run dspace reset-db

index-discovery:
	@echo "[HELP!] Define \"PARAMS\" variable if wants to pass specifics parameters to 'index-discovery' command... In example 'make PARAMS=\"-b\" index-discovery'"...
	@if [ -f "data/install/bin/dspace" ]; then echo "Running \"index-discovery $(PARAMS)\"..."; docker exec -it $(PROJECT_NAME) /dspace/install/bin/dspace index-discovery $(PARAMS); echo "Exiting..."; fi

oai:
	@echo "[HELP!] Define \"PARAMS\" variable if wants to pass specifics parameters to 'oai' command... In example 'make PARAMS=\"import -v\" oai'"...
	@if [ -f "data/install/bin/dspace" ]; then echo "Running \"oai $(PARAMS)\"..."; docker exec -it $(PROJECT_NAME) /dspace/install/bin/dspace oai $(PARAMS); echo "Exiting..."; fi

down: stop


stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose stop

prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose down -v

ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

bash:
	docker exec -i -t '$(PROJECT_NAME)' /bin/bash

logs:
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))

log:
	tail -f data/install/log/$(filter-out $@,$(MAKECMDGOALS)).log

less:
	less -N data/install/log/$(filter-out $@,$(MAKECMDGOALS)).log

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
