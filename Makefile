# Makefile for SkillRx Beacon deployment tasks
#
# Usage:
#   make build        - Build Docker image
#   make up           - Start containers
#   make down         - Stop containers
#   make logs         - View container logs
#   make shell        - Open shell in container
#   make db-prepare   - Prepare database
#   make import       - Import content from XML

.PHONY: build up down logs shell db-prepare import test clean help

# Docker image name
IMAGE_NAME ?= skillrx-beacon
DOCKER_COMPOSE ?= docker compose

# Default target
help:
	@echo "SkillRx Beacon - Deployment Tasks"
	@echo ""
	@echo "Docker Commands:"
	@echo "  make build       - Build Docker image"
	@echo "  make build-simple - Build simplified Docker image (for Pi)"
	@echo "  make up          - Start containers (production)"
	@echo "  make up-dev      - Start containers (development)"
	@echo "  make down        - Stop containers"
	@echo "  make logs        - View container logs"
	@echo "  make shell       - Open shell in container"
	@echo ""
	@echo "Database Commands:"
	@echo "  make db-prepare  - Prepare database"
	@echo "  make db-migrate  - Run migrations"
	@echo "  make db-seed     - Seed database"
	@echo "  make import      - Import content from XML"
	@echo ""
	@echo "Development Commands:"
	@echo "  make test        - Run test suite"
	@echo "  make lint        - Run linter"
	@echo "  make clean       - Clean generated files"
	@echo ""

# Docker commands
build:
	docker build -t $(IMAGE_NAME) .

build-simple:
	docker build -f Dockerfile.simple -t $(IMAGE_NAME):simple .

up:
	$(DOCKER_COMPOSE) -f docker-compose.yml -f docker-compose.production.yml up -d

up-dev:
	$(DOCKER_COMPOSE) -f docker-compose.yml -f docker-compose.development.yml up

down:
	$(DOCKER_COMPOSE) down

logs:
	$(DOCKER_COMPOSE) logs -f

shell:
	$(DOCKER_COMPOSE) exec web /bin/bash

# Database commands
db-prepare:
	$(DOCKER_COMPOSE) run --rm web bin/rails db:prepare

db-migrate:
	$(DOCKER_COMPOSE) run --rm web bin/rails db:migrate

db-seed:
	$(DOCKER_COMPOSE) run --rm web bin/rails db:seed

import:
	$(DOCKER_COMPOSE) run --rm web bin/rails data:import_content

# Development commands
test:
	bin/rspec

lint:
	bin/rubocop

clean:
	rm -rf log/*.log tmp/cache tmp/pids tmp/sockets
	rm -rf public/assets app/assets/builds/*

# Production deployment (non-Docker)
deploy-setup:
	sudo ./bin/setup-production

deploy-restart:
	sudo systemctl restart skillrx

deploy-status:
	sudo systemctl status skillrx

deploy-logs:
	sudo journalctl -u skillrx -f
