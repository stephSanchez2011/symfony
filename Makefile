#!make
ifeq (,$(wildcard .env.prod))
	include .env
else
	include .env.prod
endif

.PHONY: help
.DEFAULT_GOAL := help
RUN_IN_CONTAINER := docker exec -t ${PHPFPM_HOST}
RUN_IN_CONTAINER_YARN := docker exec -t ${REACTJS_HOST}
SUBCOMMAND = $(subst +,-, $(filter-out $@,$(MAKECMDGOALS)))

help:
	@clear
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

# --------------------------------------------------------------------
# DEV
# --------------------------------------------------------------------

project-start: project-stop
	docker-compose -f docker/dev-docker-compose.yml up --build -d
	@${RUN_IN_CONTAINER} composer install ${SUBCOMMAND};

project-stop:
	docker-compose -f docker/dev-docker-compose.yml stop
	docker-compose -f docker/dev-docker-compose.yml rm  --force

# --------------------------------------------------------------------
# DATABASE
# --------------------------------------------------------------------

database-reset:
	@${RUN_IN_CONTAINER} php bin/console doctrine:database:drop --if-exists --force ${SUBCOMMAND}
	@${RUN_IN_CONTAINER} php bin/console doctrine:database:create ${SUBCOMMAND}
	@${RUN_IN_CONTAINER} php bin/console doctrine:schema:update --force ${SUBCOMMAND}

# --------------------------------------------------------------------
# DOCKER
# --------------------------------------------------------------------

docker-hard-reset: ## Supprime tout container, volume, image...
	docker stop $$(docker ps -a -q); docker rm $$(docker ps -a -q); docker volume rm $$(docker volume ls -qf dangling=true); docker rmi $$(docker images -q) --force
	rm -rf back/vendor/*
	rm -rf back/var/cache/*
	rm -rf back/var/log/*
	rm -rf back/var/sessions/*

# --------------------------------------------------------------------
# COMPOSER
# --------------------------------------------------------------------

composer: ## Composer
	@${RUN_IN_CONTAINER} composer ${SUBCOMMAND};

# --------------------------------------------------------------------
# APPLICATION
# --------------------------------------------------------------------

php: ## PHP
	@${RUN_IN_CONTAINER} php ${SUBCOMMAND}

