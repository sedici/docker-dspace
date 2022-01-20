include .env

.PHONY: up down restart install update prune status bash logs dspace

default: up

restart: down up

up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml up -d

update:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml stop
	docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml run dspace update
	sudo chown -R $(id -u):$(id -g) data/*
	@echo "Starting up containers for $(PROJECT_NAME)..."ls
	docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml up -d

install:
	docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml run dspace install
	sudo chown -R $(id -u):$(id -g) data/*

reset-db:
	docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml run dspace reset-db

index-discovery:
	@echo "[HELP] pass specifics parameters to 'index-discovery' command... For example: 'make index-discovery -b'"...
	docker-compose exec dspace  /dspace/install/bin/dspace index-discovery $(filter-out $@,$(MAKECMDGOALS))

dspace:
	@echo "[HELP] pass specifics parameters to 'dspace' command... For example: 'make dspace \"dsprop -p dspace.dir\""
	docker-compose exec dspace  /dspace/install/bin/dspace $(filter-out $@,$(MAKECMDGOALS))

run:
	#run any command in dspace container like "/dspace/install/bin/make-handle-config"
	docker-compose exec dspace  $(filter-out $@,$(MAKECMDGOALS))


down: 
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml stop

prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose down -v

status: ps
ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

bash:
	docker exec -i -t 'dspace_$(PROJECT_NAME)' /bin/bash

logs:
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))

log:
	tail -f data/install/log/$(filter-out $@,$(MAKECMDGOALS)).log

less:
	less -N data/install/log/$(filter-out $@,$(MAKECMDGOALS)).log

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
