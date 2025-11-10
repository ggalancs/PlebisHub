#!/bin/bash
# Setup script for PlebisHub test environment
# This script configures Ruby 3.3.10, PostgreSQL, and test database
# to avoid repeating manual setup steps in future sessions

set -e  # Exit on any error

echo "==================================================================="
echo "PlebisHub Test Environment Setup Script"
echo "==================================================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# ===================================================================
# 1. Ruby 3.3.10 Installation via rbenv
# ===================================================================
echo ""
echo "1. Checking Ruby 3.3.10..."
if [ -d "/opt/rbenv/versions/3.3.10" ]; then
    print_status "Ruby 3.3.10 is already installed"
else
    print_warning "Ruby 3.3.10 not found, installing..."
    RBENV_ROOT=/opt/rbenv /opt/rbenv/bin/rbenv install 3.3.10
    print_status "Ruby 3.3.10 installed successfully"
fi

# Verify Ruby version
RUBY_VERSION=$(RBENV_VERSION=3.3.10 /opt/rbenv/shims/ruby --version)
print_status "Ruby version: $RUBY_VERSION"

# ===================================================================
# 2. PostgreSQL Configuration
# ===================================================================
echo ""
echo "2. Configuring PostgreSQL..."

# Check if PostgreSQL is installed
if ! command -v pg_ctlcluster &> /dev/null; then
    print_error "PostgreSQL is not installed. Please install PostgreSQL 16 first."
    exit 1
fi

# Check if PostgreSQL is running
if sudo pg_ctlcluster 16 main status | grep -q "online"; then
    print_status "PostgreSQL is already running"
else
    print_warning "Starting PostgreSQL..."

    # Fix SSL certificate permissions if needed
    if [ -f "/etc/ssl/private/ssl-cert-snakeoil.key" ]; then
        sudo chmod 600 /etc/ssl/private/ssl-cert-snakeoil.key
        sudo chgrp postgres /etc/ssl/private/ssl-cert-snakeoil.key
        print_status "Fixed SSL certificate permissions"
    fi

    # Start PostgreSQL
    sudo pg_ctlcluster 16 main start
    sleep 2
    print_status "PostgreSQL started successfully"
fi

# Configure pg_hba.conf for trust authentication (test environment only!)
PG_HBA="/etc/postgresql/16/main/pg_hba.conf"
if ! grep -q "^local.*all.*postgres.*trust" "$PG_HBA"; then
    print_warning "Configuring pg_hba.conf for local trust authentication..."
    sudo sed -i 's/^local.*all.*postgres.*peer/local   all             postgres                                trust/' "$PG_HBA"
    sudo sed -i 's/^local.*all.*all.*peer/local   all             all                                     trust/' "$PG_HBA"
    sudo pg_ctlcluster 16 main reload
    print_status "pg_hba.conf configured for trust authentication"
else
    print_status "pg_hba.conf already configured"
fi

# ===================================================================
# 3. Database User and Database Creation
# ===================================================================
echo ""
echo "3. Setting up database user and databases..."

# Create database user if it doesn't exist
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='changeme'" | grep -q 1; then
    print_status "Database user 'changeme' already exists"
else
    print_warning "Creating database user 'changeme'..."
    sudo -u postgres psql -c "CREATE USER changeme WITH SUPERUSER PASSWORD 'changeme';"
    print_status "Database user created"
fi

# Create test database if it doesn't exist
if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw participa_test; then
    print_status "Test database 'participa_test' already exists"
else
    print_warning "Creating test database..."
    sudo -u postgres psql -c "CREATE DATABASE participa_test OWNER changeme;"
    print_status "Test database created"
fi

# Create development database if it doesn't exist
if sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw participa_development; then
    print_status "Development database 'participa_development' already exists"
else
    print_warning "Creating development database..."
    sudo -u postgres psql -c "CREATE DATABASE participa_development OWNER changeme;"
    print_status "Development database created"
fi

# ===================================================================
# 4. Rails Configuration Files
# ===================================================================
echo ""
echo "4. Configuring Rails files..."

# Create config/database.yml from example if it doesn't exist
if [ ! -f "config/database.yml" ]; then
    if [ -f "config/database.yml.example" ]; then
        print_warning "Creating config/database.yml from example..."
        cp config/database.yml.example config/database.yml
        # Update test credentials
        sed -i '/^test:/,/^[a-z]/ s/username:.*/username: changeme/' config/database.yml
        sed -i '/^test:/,/^[a-z]/ s/password:.*/password: changeme/' config/database.yml
        print_status "config/database.yml created and configured"
    else
        print_error "config/database.yml.example not found!"
        exit 1
    fi
else
    print_status "config/database.yml already exists"
fi

# Create config/secrets.yml if it doesn't exist
if [ ! -f "config/secrets.yml" ]; then
    print_warning "Creating config/secrets.yml..."
    cat > config/secrets.yml <<'SECRETS_EOF'
test:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] || "a" * 128 %>
  users:
    min_militant_amount: 3

development:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] || "b" * 128 %>
  users:
    min_militant_amount: 3

production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  users:
    min_militant_amount: 3
SECRETS_EOF
    print_status "config/secrets.yml created"
else
    print_status "config/secrets.yml already exists"
fi

# ===================================================================
# 5. Bundle Install
# ===================================================================
echo ""
echo "5. Installing Ruby dependencies..."
RBENV_VERSION=3.3.10 /opt/rbenv/shims/bundle install
print_status "Bundle install completed"

# ===================================================================
# 6. Database Setup
# ===================================================================
echo ""
echo "6. Setting up test database..."

# Run migrations
print_warning "Running database migrations..."
RBENV_VERSION=3.3.10 RAILS_ENV=test /opt/rbenv/shims/rails db:migrate
print_status "Migrations completed"

# Seed engine activations
print_warning "Seeding engine activations..."
RBENV_VERSION=3.3.10 RAILS_ENV=test /opt/rbenv/shims/rails runner <<'SEED_SCRIPT'
# Seed all engines
EngineActivation.seed_all

# Enable all engines for testing
EngineActivation.all.each do |ea|
  ea.update!(enabled: true)
  puts "Enabled: #{ea.engine_name}"
end

puts "\nTotal enabled engines: #{EngineActivation.where(enabled: true).count}"
SEED_SCRIPT
print_status "Engine activations seeded and enabled"

# ===================================================================
# 7. Verification
# ===================================================================
echo ""
echo "7. Verifying setup..."

# Test database connection
if RBENV_VERSION=3.3.10 RAILS_ENV=test /opt/rbenv/shims/rails runner "puts 'DB Connection: OK'" 2>&1 | grep -q "DB Connection: OK"; then
    print_status "Database connection successful"
else
    print_error "Database connection failed"
    exit 1
fi

# Verify engines are loaded
ENABLED_COUNT=$(RBENV_VERSION=3.3.10 RAILS_ENV=test /opt/rbenv/shims/rails runner "puts EngineActivation.where(enabled: true).count" 2>&1 | tail -1)
if [ "$ENABLED_COUNT" = "9" ]; then
    print_status "All 9 engines are enabled"
else
    print_warning "Found $ENABLED_COUNT enabled engines (expected 9)"
fi

# ===================================================================
# Complete
# ===================================================================
echo ""
echo "==================================================================="
echo -e "${GREEN}Setup completed successfully!${NC}"
echo "==================================================================="
echo ""
echo "You can now run tests with:"
echo "  RBENV_VERSION=3.3.10 RAILS_ENV=test rails test"
echo ""
echo "Or run the Rails console with:"
echo "  RBENV_VERSION=3.3.10 RAILS_ENV=test rails console"
echo ""
