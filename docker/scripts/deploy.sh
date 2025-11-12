#!/bin/bash
# ========================================
# PlebisHub Production Deployment Script
# ========================================
# Handles zero-downtime deployments
# ========================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=================================="
echo "PlebisHub Production Deployment"
echo "=================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}⚠️  Please run as root or with sudo${NC}"
    exit 1
fi

# Check .env exists
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env file not found${NC}"
    exit 1
fi

# Load environment
source .env

# Backup database
echo ""
echo "💾 Creating database backup..."
BACKUP_FILE="backups/db_backup_$(date +%Y%m%d_%H%M%S).sql"
mkdir -p backups
docker compose exec -T db pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "$BACKUP_FILE"
echo -e "${GREEN}✓ Backup saved to $BACKUP_FILE${NC}"

# Pull latest code
echo ""
echo "📥 Pulling latest code..."
git pull origin main
echo -e "${GREEN}✓ Code updated${NC}"

# Build new images
echo ""
echo "🏗️  Building Docker images..."
docker compose build --no-cache app worker
echo -e "${GREEN}✓ Images built${NC}"

# Run migrations
echo ""
echo "💾 Running database migrations..."
docker compose run --rm app bundle exec rake db:migrate
echo -e "${GREEN}✓ Migrations complete${NC}"

# Restart services with zero downtime
echo ""
echo "🔄 Restarting services..."

# Start new worker first
docker compose up -d --no-deps --scale worker=2 worker
sleep 5

# Rolling restart of app servers
docker compose up -d --no-deps --scale app=2 app
sleep 10

# Stop old containers
docker compose up -d --no-deps --scale worker=1 --scale app=1 worker app

echo -e "${GREEN}✓ Services restarted${NC}"

# Clear cache
echo ""
echo "🧹 Clearing cache..."
docker compose exec -T app bundle exec rake cache:clear
echo -e "${GREEN}✓ Cache cleared${NC}"

# Health check
echo ""
echo "🏥 Running health check..."
HEALTH_URL="http://localhost:${APP_PORT:-3000}/health"
if curl -f -s "$HEALTH_URL" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Application is healthy${NC}"
else
    echo -e "${RED}⚠️  Health check failed. Please investigate.${NC}"
    docker compose logs --tail=50 app
    exit 1
fi

# Show status
echo ""
echo "=================================="
echo "Deployment Complete! 🎉"
echo "=================================="
echo ""
docker compose ps
echo ""
echo "Backup saved: $BACKUP_FILE"
echo ""
