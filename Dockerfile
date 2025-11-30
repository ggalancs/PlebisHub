# ========================================
# PlebisHub Rails Application Dockerfile
# ========================================
# Multi-stage build for optimal image size and security
# Base: Ruby 3.3.6 on Alpine Linux
# Includes: Rails 7.2, PostgreSQL client, Redis client
# ========================================

# ==================== Stage 1: Base ====================
FROM ruby:3.3.6-alpine AS base

# Install runtime dependencies
RUN apk add --no-cache \
    postgresql-client \
    nodejs \
    tzdata \
    libstdc++ \
    gcompat \
    git \
    build-base \
    postgresql-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Set environment to production by default
ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true

# ==================== Stage 2: Builder ====================
FROM base AS builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    git \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    && rm -rf /var/cache/apk/*

# Copy Gemfile, lock, and engines (path gems required by Gemfile)
COPY Gemfile Gemfile.lock ./
COPY engines/ ./engines/
RUN bundle config set --local deployment 'true' \
    && bundle config set --local without 'development test' \
    && bundle install --jobs 4 --retry 3 \
    && rm -rf ~/.bundle/ \
    && find ./vendor/bundle -name "*.c" -delete 2>/dev/null || true \
    && find ./vendor/bundle -name "*.o" -delete 2>/dev/null || true

# Copy application code
COPY . .

# Build arg for asset precompilation (dummy value for build time only)
ARG SECRET_KEY_BASE=dummy_key_for_build_only

# Precompile assets (includes Vite build artifacts if pre-built)
# Skip database connection and certain initializers during asset compilation
RUN SECRET_KEY_BASE=$SECRET_KEY_BASE \
    RAILS_ENV=production \
    DATABASE_URL="postgresql://dummy:dummy@localhost/dummy" \
    SKIP_DB_CONNECTION=true \
    bundle exec rake assets:precompile \
    && rm -rf node_modules tmp/cache

# ==================== Stage 3: Production ====================
FROM base AS production

# Copy application code (includes vendor/bundle from deployment mode)
COPY --from=builder /app /app

# Create non-root user for security
RUN addgroup -g 1000 -S appgroup \
    && adduser -u 1000 -S appuser -G appgroup \
    && chown -R appuser:appgroup /app

USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start server with Unicorn
CMD ["bundle", "exec", "unicorn", "-c", "config/unicorn.rb"]
