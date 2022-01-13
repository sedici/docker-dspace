include .env

.PHONY: up update install down stop prune ps bash logs dsbin

default: up

up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml up -d

update:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml stop
	docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml run dspace update
	sudo chown -R $(id -u):$(id -g) data/*
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml up -d

install:
	docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml run dspace install
	sudo chown -R $(id -u):$(id -g) data/*

reset-db:
	docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml run dspace reset-db

index-discovery:
	@echo "[HELP] pass specifics parameters to 'index-discovery' command... In example 'make index-discovery -b'"...
	docker-compose exec dspace  /dspace/install/bin/dspace index-discovery $(filter-out $@,$(MAKECMDGOALS))

dsbin:
	@echo "[HELP!] Define \"COMMAND\" variable if wants to pass specifics command to 'bin/dspace' DSpace's CLI... In example 'make COMMAND=\"dsprop -p dspace.dir\" dsbin'"...
	@if [ -f "data/install/bin/dspace" ]; then echo "Running \"bin/dspace $(COMMAND)\"..."; docker exec -it $(PROJECT_NAME) /dspace/install/bin/dspace $(COMMAND); echo "Exiting..."; fi


down: stop


stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose -f docker-compose.yml -f others/docker-compose-debug.yml stop

prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose down -v

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
