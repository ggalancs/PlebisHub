# 🐳 PlebisHub Docker Setup

Complete Docker containerization for PlebisHub with production-ready configuration.

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Development](#-development)
- [Production Deployment](#-production-deployment)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone https://github.com/yourusername/PlebisHub.git
cd PlebisHub

# 2. Run setup script (creates .env, builds images, sets up database)
chmod +x docker/scripts/*.sh
./docker/scripts/setup.sh

# 3. Access application
# Web: http://localhost:3000
# Admin: http://localhost:3000/admin
```

## 🏗️ Architecture

PlebisHub uses a **multi-container architecture** with the following services:

```
┌─────────────────────────────────────────────────────┐
│                    Nginx (Port 80)                  │
│              Reverse Proxy & Load Balancer          │
└──────────────────┬──────────────────────────────────┘
                   │
        ┌──────────┴──────────┬──────────────┐
        ▼                     ▼              ▼
┌──────────────┐      ┌──────────────┐  ┌────────────┐
│  Rails App   │      │   Frontend   │  │   Worker   │
│  (Port 3000) │      │  (Port 3036) │  │  (Resque)  │
│              │      │   Vue + Vite │  │            │
└──────┬───────┘      └──────────────┘  └─────┬──────┘
       │                                       │
       └───────────┬───────────────────────────┘
                   │
        ┌──────────┴──────────┬─────────────┐
        ▼                     ▼             ▼
┌──────────────┐      ┌──────────────┐
│  PostgreSQL  │      │    Redis     │
│  (Port 5432) │      │  (Port 6379) │
└──────────────┘      └──────────────┘
```

### Services

| Service    | Technology      | Port | Purpose                          |
|------------|----------------|------|----------------------------------|
| **app**    | Rails 7.2 + Ruby 3.3 | 3000 | Main application server |
| **frontend** | Vue 3 + Vite | 3036 | Frontend development server (dev only) |
| **db**     | PostgreSQL 16  | 5432 | Database                         |
| **redis**  | Redis 7        | 6379 | Cache & background jobs          |
| **worker** | Resque         | -    | Background job processor         |
| **nginx**  | Nginx          | 80/443 | Reverse proxy (production)    |

## 📦 Prerequisites

- **Docker**: >= 20.10
- **Docker Compose**: >= 2.0
- **RAM**: Minimum 4GB recommended
- **Disk**: 10GB free space

### Install Docker

**Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**macOS:**
```bash
brew install --cask docker
```

**Windows:**
Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)

## 💻 Installation

### 1. Setup Environment

```bash
# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
```

**Required variables:**
```bash
SECRET_KEY_BASE=your_secret_key_here  # Generate with: rake secret
POSTGRES_PASSWORD=strong_password
REDIS_PASSWORD=strong_password
```

### 2. Build Images

```bash
# Build all services
docker compose build

# Or build specific service
docker compose build app
```

### 3. Initialize Database

```bash
# Create and migrate database
docker compose run --rm app bundle exec rake db:create db:migrate

# Seed with example data
docker compose run --rm app bundle exec rake db:seed
```

### 4. Start Services

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Check status
docker compose ps
```

## 🛠️ Development

### Using Helper Script

```bash
# Start development environment (includes Vite HMR)
./docker/scripts/dev.sh start

# Common commands
./docker/scripts/dev.sh console        # Rails console
./docker/scripts/dev.sh logs app       # View app logs
./docker/scripts/dev.sh shell app      # Open shell in app
./docker/scripts/dev.sh rails routes   # Run Rails command
./docker/scripts/dev.sh db:migrate     # Run migrations
./docker/scripts/dev.sh test           # Run tests
```

### Manual Commands

```bash
# Rails console
docker compose exec app bundle exec rails console

# Run migrations
docker compose exec app bundle exec rake db:migrate

# Run tests
docker compose exec app bundle exec rspec

# Frontend commands
docker compose exec frontend pnpm test
docker compose exec frontend pnpm build

# Database access
docker compose exec db psql -U postgres -d plebishub_production
```

### Hot Module Replacement (HMR)

Frontend development with Vite HMR:

```bash
# Start with development profile
docker compose --profile development up -d

# Access Vite dev server
# http://localhost:3036
```

### Code Changes

- **Rails**: Code reloads automatically in development mode
- **Frontend**: Vite provides instant HMR at http://localhost:3036
- **Gems/Dependencies**: Rebuild image after adding gems:
  ```bash
  docker compose build app
  docker compose restart app
  ```

## 🚀 Production Deployment

### Initial Setup

```bash
# 1. Set production environment
export RAILS_ENV=production

# 2. Configure .env for production
# Update all passwords, secrets, SMTP, AWS credentials

# 3. Build production images
docker compose build --no-cache

# 4. Setup database
docker compose run --rm app bundle exec rake db:create db:migrate

# 5. Precompile assets
docker compose run --rm app bundle exec rake assets:precompile

# 6. Start with nginx proxy
docker compose --profile production up -d
```

### Zero-Downtime Deployments

```bash
# Run deployment script
sudo ./docker/scripts/deploy.sh
```

The deployment script:
- ✅ Creates database backup
- ✅ Pulls latest code
- ✅ Builds new images
- ✅ Runs migrations
- ✅ Performs rolling restart
- ✅ Verifies health check

### SSL Configuration

1. Place SSL certificates in `docker/nginx/ssl/`:
   ```
   docker/nginx/ssl/
   ├── cert.pem
   └── key.pem
   ```

2. Uncomment SSL lines in `docker/nginx/sites/plebishub.conf`

3. Restart nginx:
   ```bash
   docker compose restart nginx
   ```

### Auto-scaling

Horizontal scaling for high traffic:

```bash
# Scale app servers
docker compose up -d --scale app=4

# Scale workers
docker compose up -d --scale worker=3
```

Nginx automatically load balances across all app instances.

## ⚙️ Configuration

### Environment Variables

See `.env.example` for all available variables.

**Critical variables:**

| Variable | Description | Required |
|----------|-------------|----------|
| `SECRET_KEY_BASE` | Rails secret key | ✅ Yes |
| `POSTGRES_PASSWORD` | Database password | ✅ Yes |
| `REDIS_PASSWORD` | Redis password | ✅ Yes |
| `SMTP_*` | Email configuration | Production |
| `AWS_*` | S3 storage config | If using S3 |

### Database Configuration

Database URL is automatically constructed:
```
postgresql://user:password@db:5432/database
```

Override with `DATABASE_URL` if needed.

### Redis Configuration

Redis URL for Resque:
```
redis://:password@redis:6379/0
```

### Resource Limits

Add resource limits in `docker-compose.yml`:

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

## 🔍 Monitoring

### Health Checks

Each service has built-in health checks:

```bash
# Check all services health
docker compose ps

# Manual health check
curl http://localhost:3000/health
```

### Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f app

# Last 100 lines
docker compose logs --tail=100 app

# With timestamps
docker compose logs -f -t app
```

### Resource Usage

```bash
# Container stats
docker stats

# Disk usage
docker system df

# Clean up unused resources
docker system prune -a
```

## 🐛 Troubleshooting

### Common Issues

**1. Port already in use**
```bash
# Find process using port
sudo lsof -i :3000

# Change port in .env
APP_PORT=3001
```

**2. Permission errors**
```bash
# Fix permissions
sudo chown -R $USER:$USER .
```

**3. Database connection failed**
```bash
# Check database is running
docker compose ps db

# Check database logs
docker compose logs db

# Restart database
docker compose restart db
```

**4. Out of disk space**
```bash
# Clean up Docker resources
docker system prune -a --volumes

# Remove old images
docker image prune -a
```

**5. Assets not loading**
```bash
# Precompile assets
docker compose exec app bundle exec rake assets:precompile

# Clear cache
docker compose exec app bundle exec rake tmp:clear
```

### Reset Everything

```bash
# Stop and remove everything
docker compose down -v

# Remove all images
docker rmi $(docker images -q plebishub*)

# Start fresh
./docker/scripts/setup.sh
```

### Get Help

- Check logs: `docker compose logs -f`
- Shell access: `docker compose exec app sh`
- Database console: `docker compose exec db psql -U postgres`
- Rails console: `docker compose exec app bundle exec rails console`

## 📚 Additional Resources

- **Docker Docs**: https://docs.docker.com
- **Docker Compose**: https://docs.docker.com/compose
- **Rails Docker**: https://guides.rubyonrails.org/development_dependencies_install.html#docker
- **Best Practices**: https://docs.docker.com/develop/dev-best-practices

## 🤝 Contributing

When modifying Docker configuration:

1. Test locally with `docker compose build`
2. Update this README if adding new services
3. Update `.env.example` with new variables
4. Test production build with `BUILD_TARGET=production`

## 📄 License

Same as PlebisHub project license.

---

**Made with ❤️ by PlebisHub DevOps Team**
