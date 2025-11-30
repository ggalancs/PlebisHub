#!/bin/bash
# ============================================================
# PlebisHub Quick Start - One Command Installation
# ============================================================
# Usage: ./quick-start.sh [development|production]
# ============================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          PlebisHub Quick Start Installation            ║${NC}"
echo -e "${BLUE}║       Rails 7.2 Democratic Participation Platform      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first:${NC}"
    echo "   https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed. Please install Docker Compose:${NC}"
    echo "   https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✓ Docker and Docker Compose found${NC}"

# Determine mode
MODE=${1:-development}
echo -e "${BLUE}→ Installation mode: ${MODE}${NC}"

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    echo ""
    echo -e "${YELLOW}→ Creating .env file from template...${NC}"
    cp .env.example .env

    # Generate secure secrets automatically
    echo -e "${YELLOW}→ Generating secure secrets...${NC}"

    # Generate SECRET_KEY_BASE
    SECRET_KEY=$(openssl rand -hex 64)
    sed -i.bak "s/your_secret_key_here_generate_with_rake_secret/${SECRET_KEY}/" .env

    # Generate DB password
    DB_PASS=$(openssl rand -hex 16)
    sed -i.bak "s/your_secure_database_password_here/${DB_PASS}/" .env

    # Generate Redis password
    REDIS_PASS=$(openssl rand -hex 16)
    sed -i.bak "s/your_secure_redis_password_here/${REDIS_PASS}/" .env

    # Set mode
    if [ "$MODE" = "development" ]; then
        sed -i.bak "s/RAILS_ENV=production/RAILS_ENV=development/" .env
        sed -i.bak "s/RACK_ENV=production/RACK_ENV=development/" .env
        sed -i.bak "s/BUILD_TARGET=production/BUILD_TARGET=base/" .env
    fi

    rm -f .env.bak
    echo -e "${GREEN}✓ Secure configuration generated${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Create required directories
echo ""
echo -e "${YELLOW}→ Creating required directories...${NC}"
mkdir -p log tmp storage backups docker/nginx/ssl
echo -e "${GREEN}✓ Directories created${NC}"

# Make scripts executable
chmod +x docker/scripts/*.sh 2>/dev/null || true

# Build and start
echo ""
echo -e "${YELLOW}→ Building Docker images (this may take 5-10 minutes)...${NC}"

if [ "$MODE" = "development" ]; then
    docker compose -f docker-compose.yml -f docker-compose.dev.yml build
else
    docker compose build
fi

echo -e "${GREEN}✓ Images built successfully${NC}"

# Start services
echo ""
echo -e "${YELLOW}→ Starting database and redis...${NC}"
docker compose up -d db redis
echo -e "${YELLOW}→ Waiting for services to be healthy (15 seconds)...${NC}"
sleep 15

# Setup database
echo ""
echo -e "${YELLOW}→ Setting up database...${NC}"
if [ "$MODE" = "development" ]; then
    docker compose -f docker-compose.yml -f docker-compose.dev.yml run --rm app bundle exec rake db:create db:migrate db:seed
else
    docker compose run --rm app bundle exec rake db:create db:migrate
fi
echo -e "${GREEN}✓ Database ready${NC}"

# Start all services
echo ""
echo -e "${YELLOW}→ Starting all services...${NC}"
if [ "$MODE" = "development" ]; then
    docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
else
    docker compose up -d
fi

# Wait for health check
echo ""
echo -e "${YELLOW}→ Waiting for application to start...${NC}"
sleep 10

# Check health
if curl -sf http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Application is healthy!${NC}"
else
    echo -e "${YELLOW}⚠ Application is starting up, please wait...${NC}"
fi

# Done!
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Installation Complete! 🎉                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Access PlebisHub:${NC}"
echo "  🌐 Web Application: http://localhost:3000"
echo "  👤 Admin Panel:     http://localhost:3000/admin"
if [ "$MODE" = "development" ]; then
echo "  ⚡ Vite Dev Server:  http://localhost:3036"
fi
echo "  💚 Health Check:    http://localhost:3000/health"
echo ""
echo -e "${BLUE}Useful Commands:${NC}"
echo "  make start          # Start all services"
echo "  make stop           # Stop all services"
echo "  make logs           # View logs"
echo "  make console        # Rails console"
echo "  make shell          # Container shell"
echo "  make help           # All commands"
echo ""
echo -e "${BLUE}Container Status:${NC}"
docker compose ps
echo ""
