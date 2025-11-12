# 🚀 PlebisHub Docker Quick Start

Get PlebisHub running in 3 commands!

## Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- 4GB RAM minimum
- 10GB disk space

## Installation

```bash
# 1. Setup (creates config, builds images, initializes database)
make setup

# 2. Start services
make start

# 3. Open browser
# → http://localhost:3000
```

## That's it! 🎉

### What just happened?

1. ✅ Created `.env` configuration file
2. ✅ Built 4 Docker images (Rails app, Frontend, PostgreSQL, Redis)
3. ✅ Started 5 containers (app, worker, database, cache, frontend)
4. ✅ Created and migrated database
5. ✅ Seeded with example data

## Useful Commands

```bash
make start        # Start all services
make stop         # Stop all services
make logs         # View logs
make console      # Rails console
make test         # Run tests
make help         # See all commands
```

## Common Tasks

### Access Admin Panel
```
http://localhost:3000/admin
```

### View Logs
```bash
make logs              # All services
make logs SERVICE=app  # Specific service
```

### Database Operations
```bash
make db-migrate    # Run migrations
make db-seed       # Seed data
make db-backup     # Backup database
```

### Development Mode (with Vite HMR)
```bash
make start-dev
# Rails: http://localhost:3000
# Vite:  http://localhost:3036
```

## Troubleshooting

**Port already in use?**
```bash
# Edit .env and change APP_PORT
nano .env
```

**Need to reset everything?**
```bash
make clean
make setup
```

**Still having issues?**
Check the full documentation: [DOCKER_README.md](DOCKER_README.md)

## Next Steps

1. Configure email in `.env` (SMTP_* variables)
2. Set up SSL for production (see DOCKER_README.md)
3. Configure AWS S3 for file uploads (optional)
4. Customize ActiveAdmin at `/admin`

## Need Help?

- 📖 Full docs: [DOCKER_README.md](DOCKER_README.md)
- 🐛 Issues: Check `make logs`
- 💬 Shell: `make shell`
- 🔍 Status: `make ps`

---

Happy coding! 🚀
