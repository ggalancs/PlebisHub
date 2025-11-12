#!/bin/bash
# ========================================
# PlebisHub Development Helper Script
# ========================================
# Quick commands for development workflow
# ========================================

set -e

COMMAND=$1
shift || true

case "$COMMAND" in
  start)
    echo "🚀 Starting development environment..."
    docker compose --profile development up -d
    echo "✓ Services started"
    echo "  - Rails: http://localhost:3000"
    echo "  - Vite HMR: http://localhost:3036"
    ;;

  stop)
    echo "🛑 Stopping development environment..."
    docker compose down
    echo "✓ Services stopped"
    ;;

  restart)
    echo "🔄 Restarting services..."
    docker compose restart
    echo "✓ Services restarted"
    ;;

  logs)
    SERVICE=${1:-}
    if [ -z "$SERVICE" ]; then
      docker compose logs -f
    else
      docker compose logs -f "$SERVICE"
    fi
    ;;

  shell)
    SERVICE=${1:-app}
    echo "🐚 Opening shell in $SERVICE..."
    docker compose exec "$SERVICE" sh
    ;;

  rails)
    echo "🚂 Running Rails command: $@"
    docker compose exec app bundle exec rails "$@"
    ;;

  rake)
    echo "🔨 Running Rake task: $@"
    docker compose exec app bundle exec rake "$@"
    ;;

  console)
    echo "💎 Opening Rails console..."
    docker compose exec app bundle exec rails console
    ;;

  db:reset)
    echo "💾 Resetting database..."
    docker compose exec app bundle exec rake db:drop db:create db:migrate db:seed
    echo "✓ Database reset complete"
    ;;

  db:migrate)
    echo "💾 Running migrations..."
    docker compose exec app bundle exec rake db:migrate
    echo "✓ Migrations complete"
    ;;

  db:seed)
    echo "🌱 Seeding database..."
    docker compose exec app bundle exec rake db:seed
    echo "✓ Database seeded"
    ;;

  test)
    echo "🧪 Running tests..."
    docker compose exec app bundle exec rspec "$@"
    ;;

  npm)
    echo "📦 Running npm command: $@"
    docker compose exec frontend pnpm "$@"
    ;;

  build)
    echo "🏗️  Building Docker images..."
    docker compose build "$@"
    echo "✓ Build complete"
    ;;

  clean)
    echo "🧹 Cleaning up..."
    docker compose down -v
    docker system prune -f
    echo "✓ Cleanup complete"
    ;;

  ps)
    docker compose ps
    ;;

  *)
    echo "PlebisHub Development Helper"
    echo ""
    echo "Usage: ./docker/scripts/dev.sh COMMAND [args]"
    echo ""
    echo "Commands:"
    echo "  start              Start development environment"
    echo "  stop               Stop all services"
    echo "  restart            Restart all services"
    echo "  logs [service]     Show logs (optionally for specific service)"
    echo "  shell [service]    Open shell in service (default: app)"
    echo "  rails <cmd>        Run Rails command"
    echo "  rake <task>        Run Rake task"
    echo "  console            Open Rails console"
    echo "  db:reset           Reset database"
    echo "  db:migrate         Run migrations"
    echo "  db:seed            Seed database"
    echo "  test [args]        Run RSpec tests"
    echo "  npm <cmd>          Run pnpm command in frontend"
    echo "  build [service]    Build Docker images"
    echo "  clean              Remove containers and volumes"
    echo "  ps                 Show running services"
    echo ""
    echo "Examples:"
    echo "  ./docker/scripts/dev.sh start"
    echo "  ./docker/scripts/dev.sh logs app"
    echo "  ./docker/scripts/dev.sh rails db:migrate"
    echo "  ./docker/scripts/dev.sh console"
    ;;
esac
