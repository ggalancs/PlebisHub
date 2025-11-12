# ========================================
# PlebisHub Makefile
# ========================================
# Quick commands for Docker operations
# ========================================

.PHONY: help setup start stop restart logs build clean test deploy

.DEFAULT_GOAL := help

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m

help: ## Show this help message
	@echo "$(BLUE)PlebisHub Docker Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

setup: ## Initial setup (creates .env, builds images, sets up database)
	@echo "$(BLUE)Setting up PlebisHub...$(NC)"
	@chmod +x docker/scripts/*.sh
	@./docker/scripts/setup.sh

start: ## Start all services
	@echo "$(BLUE)Starting services...$(NC)"
	@docker compose up -d
	@echo "$(GREEN)✓ Services started$(NC)"
	@echo "  - Web: http://localhost:3000"
	@echo "  - Admin: http://localhost:3000/admin"

start-dev: ## Start development environment (with Vite HMR)
	@echo "$(BLUE)Starting development environment...$(NC)"
	@docker compose --profile development up -d
	@echo "$(GREEN)✓ Development environment started$(NC)"
	@echo "  - Rails: http://localhost:3000"
	@echo "  - Vite HMR: http://localhost:3036"

stop: ## Stop all services
	@echo "$(BLUE)Stopping services...$(NC)"
	@docker compose down
	@echo "$(GREEN)✓ Services stopped$(NC)"

restart: ## Restart all services
	@echo "$(BLUE)Restarting services...$(NC)"
	@docker compose restart
	@echo "$(GREEN)✓ Services restarted$(NC)"

logs: ## Show logs (use SERVICE=app to show specific service)
	@docker compose logs -f $(SERVICE)

ps: ## Show running services
	@docker compose ps

build: ## Build Docker images
	@echo "$(BLUE)Building images...$(NC)"
	@docker compose build $(SERVICE)
	@echo "$(GREEN)✓ Build complete$(NC)"

rebuild: ## Rebuild images without cache
	@echo "$(BLUE)Rebuilding images...$(NC)"
	@docker compose build --no-cache $(SERVICE)
	@echo "$(GREEN)✓ Rebuild complete$(NC)"

shell: ## Open shell in app container
	@docker compose exec app sh

console: ## Open Rails console
	@docker compose exec app bundle exec rails console

db-migrate: ## Run database migrations
	@echo "$(BLUE)Running migrations...$(NC)"
	@docker compose exec app bundle exec rake db:migrate
	@echo "$(GREEN)✓ Migrations complete$(NC)"

db-seed: ## Seed database
	@echo "$(BLUE)Seeding database...$(NC)"
	@docker compose exec app bundle exec rake db:seed
	@echo "$(GREEN)✓ Database seeded$(NC)"

db-reset: ## Reset database (drop, create, migrate, seed)
	@echo "$(YELLOW)⚠️  This will delete all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose exec app bundle exec rake db:drop db:create db:migrate db:seed; \
		echo "$(GREEN)✓ Database reset complete$(NC)"; \
	fi

db-backup: ## Create database backup
	@echo "$(BLUE)Creating database backup...$(NC)"
	@mkdir -p backups
	@docker compose exec -T db pg_dump -U postgres plebishub_production > backups/db_backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✓ Backup created in backups/$(NC)"

test: ## Run tests
	@docker compose exec app bundle exec rspec

test-frontend: ## Run frontend tests
	@docker compose exec frontend pnpm test

clean: ## Remove containers and volumes
	@echo "$(YELLOW)⚠️  This will remove all containers and volumes!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		docker system prune -f; \
		echo "$(GREEN)✓ Cleanup complete$(NC)"; \
	fi

deploy: ## Deploy to production (requires sudo)
	@echo "$(BLUE)Deploying to production...$(NC)"
	@sudo ./docker/scripts/deploy.sh

stats: ## Show container resource usage
	@docker stats --no-stream

health: ## Check application health
	@curl -f http://localhost:3000/health && echo "" && echo "$(GREEN)✓ Application is healthy$(NC)" || echo "$(YELLOW)⚠️  Health check failed$(NC)"

# Aliases
up: start ## Alias for start
down: stop ## Alias for stop
log: logs ## Alias for logs
