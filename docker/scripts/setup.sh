#!/bin/bash
# ========================================
# PlebisHub Docker Setup Script
# ========================================
# Initializes the application for first run
# ========================================

set -e

echo "=================================="
echo "PlebisHub Docker Setup"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ .env file created. Please edit it with your configuration.${NC}"
    echo ""
    echo "IMPORTANT: You must set the following variables:"
    echo "  - SECRET_KEY_BASE (generate with: docker compose run --rm app bundle exec rake secret)"
    echo "  - POSTGRES_PASSWORD"
    echo "  - REDIS_PASSWORD"
    echo ""
    read -p "Press Enter after you've configured .env file..."
fi

# Generate SECRET_KEY_BASE if not set
if grep -q "your_secret_key_here" .env; then
    echo -e "${YELLOW}⚠️  Generating SECRET_KEY_BASE...${NC}"
    SECRET=$(docker compose run --rm app bundle exec rake secret 2>/dev/null || openssl rand -hex 64)
    sed -i.bak "s/your_secret_key_here_generate_with_rake_secret/$SECRET/" .env
    rm .env.bak 2>/dev/null || true
    echo -e "${GREEN}✓ SECRET_KEY_BASE generated${NC}"
fi

# Create required directories
echo ""
echo "📁 Creating required directories..."
mkdir -p log tmp storage docker/postgres/init docker/nginx/sites docker/nginx/ssl
echo -e "${GREEN}✓ Directories created${NC}"

# Build Docker images
echo ""
echo "🐳 Building Docker images..."
docker compose build
echo -e "${GREEN}✓ Images built successfully${NC}"

# Start database and redis
echo ""
echo "🚀 Starting database and redis..."
docker compose up -d db redis
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Setup database
echo ""
echo "💾 Setting up database..."
docker compose run --rm app bundle exec rake db:create db:migrate
echo -e "${GREEN}✓ Database setup complete${NC}"

# Seed database (optional)
read -p "Do you want to seed the database with example data? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker compose run --rm app bundle exec rake db:seed
    echo -e "${GREEN}✓ Database seeded${NC}"
fi

# Start all services
echo ""
echo "🚀 Starting all services..."
docker compose up -d
echo -e "${GREEN}✓ All services started${NC}"

# Show status
echo ""
echo "=================================="
echo "Setup Complete! 🎉"
echo "=================================="
echo ""
echo "Services running:"
docker compose ps
echo ""
echo "Access the application:"
echo "  - Web: http://localhost:3000"
echo "  - Admin: http://localhost:3000/admin"
echo "  - Frontend Dev: http://localhost:3036 (if in development mode)"
echo ""
echo "Useful commands:"
echo "  - View logs: docker compose logs -f"
echo "  - Stop: docker compose down"
echo "  - Restart: docker compose restart"
echo "  - Shell: docker compose exec app sh"
echo ""
