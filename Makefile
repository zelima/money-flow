# Money Flow Application Makefile
# Common commands for development, testing, and deployment

.PHONY: help install setup start stop restart logs clean test lint format deploy

# Default target
help: ## Show this help message
	@echo "Money Flow Application - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Development Setup
install: ## Install all dependencies
	@echo "Installing API dependencies..."
	cd api && pip install -r requirements.txt
	@echo "Installing web-app dependencies..."
	cd web-app && pip install -r requirements.txt
	@echo "Installing data-pipeline dependencies..."
	cd data-pipeline && pip install -r requirements.txt
	@echo "Installing moneyflow-functions dependencies..."
	cd moneyflow-functions && pip install -r requirements.txt

setup: ## Setup development environment (database, dependencies)
	@echo "Setting up development environment..."
	make install
	make db-start
	@echo "Waiting for database to be ready..."
	sleep 10
	make db-migrate
	@echo "Development environment setup complete!"

# Database Management
db-start: ## Start PostgreSQL database
	@echo "Starting PostgreSQL database..."
	docker-compose up -d postgres

db-stop: ## Stop PostgreSQL database
	@echo "Stopping PostgreSQL database..."
	docker-compose stop postgres

db-restart: ## Restart PostgreSQL database
	@echo "Restarting PostgreSQL database..."
	make db-stop
	make db-start

db-migrate: ## Run database migrations
	@echo "Running database migrations..."
	docker-compose exec postgres psql -U budget_user -d georgian_budget -f /docker-entrypoint-initdb.d/01_schema.sql
	docker-compose exec postgres psql -U budget_user -d georgian_budget -f /docker-entrypoint-initdb.d/02_seed_data.sql
	docker-compose exec postgres psql -U budget_user -d georgian_budget -f /docker-entrypoint-initdb.d/03_generate_historical_budgets.sql

db-reset: ## Reset database (drop and recreate)
	@echo "Resetting database..."
	docker-compose down -v
	docker-compose up -d postgres
	@echo "Waiting for database to be ready..."
	sleep 10
	make db-migrate

db-logs: ## Show database logs
	docker-compose logs postgres

# Application Management
start: ## Start all services (database, API, frontend)
	@echo "Starting all services..."
	docker-compose up -d

start-dev: ## Start services in development mode with hot reload
	@echo "Starting services in development mode..."
	docker-compose up

stop: ## Stop all services
	@echo "Stopping all services..."
	docker-compose down

restart: ## Restart all services
	@echo "Restarting all services..."
	make stop
	make start

logs: ## Show logs for all services
	docker-compose logs -f

logs-api: ## Show API logs
	docker-compose logs -f api

logs-frontend: ## Show frontend logs
	docker-compose logs -f frontend

# Individual Service Management
start-api: ## Start only the API service
	@echo "Starting API service..."
	docker-compose up -d api

start-frontend: ## Start only the frontend service
	@echo "Starting frontend service..."
	docker-compose up -d frontend



# Testing



# Code Quality
lint: ## Run linting checks
	@echo "Running linting checks..."
	@echo "API linting..."
	cd api && flake8 . --max-line-length=88 --extend-ignore=E203,W503
	@echo "Web-app linting..."
	cd web-app && flake8 . --max-line-length=88 --extend-ignore=E203,W503

format: ## Format code with black
	@echo "Formatting code..."
	@echo "API formatting..."
	cd api && black .
	@echo "Web-app formatting..."
	cd web-app && black .

# Data Pipeline
pipeline-run: ## Run data pipeline locally
	@echo "Running data pipeline..."
	cd data-pipeline && dpp run all --verbose

pipeline-test: ## Test data pipeline
	@echo "Testing data pipeline..."
	cd data-pipeline && dpp test


# Pre-commit and Code Quality
pre-commit-install: ## Install pre-commit hooks
	@echo "Installing pre-commit hooks..."
	pip install -r requirements-dev.txt
	pre-commit install

pre-commit-run: ## Run pre-commit on all files
	@echo "Running pre-commit on all files..."
	pre-commit run --all-files

pre-commit-update: ## Update pre-commit hooks
	@echo "Updating pre-commit hooks..."
	pre-commit autoupdate



# Testing
test: ## Run all tests
	@echo "Running all tests..."
	make test-api
	make test-web-app
	make test-integration

test-api: ## Run API tests
	@echo "Running API tests..."
	PYTHONPATH=. python -m pytest api/tests/ -v --cov=api --cov-report=term-missing

test-web-app: ## Run web-app tests
	@echo "Running web-app tests..."
	PYTHONPATH=. python -m pytest web-app/web_app_tests/ -v --cov=web-app --cov-report=term-missing

test-integration: ## Run integration tests
	@echo "Running integration tests..."
	python -m pytest tests/ -v --cov=. --cov-report=term-missing

test-coverage: ## Run tests with coverage reports
	@echo "Running tests with coverage reports..."
	make test-api
	make test-web-app
	@echo "Coverage reports generated in each service directory"

test-install: ## Install test dependencies
	@echo "Installing test dependencies..."
	cd api && pip install -r requirements-test.txt
	cd web-app && pip install -r requirements-test.txt

# Utility Commands
status: ## Show status of all services
	@echo "Service Status:"
	docker-compose ps

clean: ## Clean up containers, images, and volumes
	@echo "Cleaning up..."
	docker-compose down -v --rmi all
	docker system prune -f

clean-deps: ## Clean up Python dependencies
	@echo "Cleaning up Python dependencies..."
	find . -name "__pycache__" -type d -exec rm -rf {} +
	find . -name "*.pyc" -delete
	find . -name "*.pyo" -delete
	find . -name "*.pyd" -delete
	find . -name ".pytest_cache" -type d -exec rm -rf {} +
	find . -name ".coverage" -delete
	find . -name "htmlcov" -type d -exec rm -rf {} +
	find . -name "coverage.xml" -delete

# Development shortcuts
dev: ## Start development environment with hot reload
	@echo "Starting development environment..."
	make start-dev

api-only: ## Start only API for development
	@echo "Starting API only..."
	@echo "Make sure you have set GOOGLE_CLOUD_PROJECT environment variable"
	@echo "Run: export GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID"
	make db-start
	sleep 5
	make start-api

frontend-only: ## Start only frontend for development
	@echo "Starting frontend only..."
	make start-frontend

# GCP Setup
gcp-auth: ## Setup GCP authentication for local development
	@echo "Setting up GCP authentication..."
	@echo "1. Run: gcloud auth application-default login"
	@echo "2. Set your project: gcloud config set project YOUR_PROJECT_ID"
	@echo "3. Export your project ID: export GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID"
	@echo "4. Make sure you have access to the Cloud Storage bucket: georgian-budget-data"

gcp-status: ## Check current GCP configuration
	@echo "Current GCP configuration:"
	@echo "Project ID: $(shell gcloud config get-value project 2>/dev/null || echo 'Not set')"
	@echo "Account: $(shell gcloud config get-value account 2>/dev/null || echo 'Not set')"
	@echo "GOOGLE_CLOUD_PROJECT env var: $(shell echo $$GOOGLE_CLOUD_PROJECT)"

# Health checks
health: ## Check health of all services
	@echo "Checking service health..."
	@echo "Database:"
	@curl -s http://localhost:5432 || echo "Database not accessible"
	@echo "API:"
	@curl -s http://localhost:8000/health || echo "API not accessible"
	@echo "Frontend:"
	@curl -s http://localhost:5000 || echo "Frontend not accessible"

# Port forwarding for local development
forward-api: ## Forward API port for local development
	@echo "Forwarding API port..."
	kubectl port-forward service/money-flow-api 8000:8000

forward-frontend: ## Forward frontend port for local development
	@echo "Forwarding frontend port..."
	kubectl port-forward service/money-flow-frontend 5000:5000
