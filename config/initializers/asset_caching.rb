# frozen_string_literal: true

# Asset Caching Configuration
#
# Configures cache headers for static assets to improve performance.
# Works with both Sprockets and Vite assets.

Rails.application.config.after_initialize do
  # Enable asset caching in production
  if Rails.env.production?
    # Configure static file serving with cache headers
    Rails.application.config.public_file_server.headers = {
      # Cache static assets for 1 year (they have fingerprinted filenames)
      'Cache-Control' => 'public, max-age=31536000, immutable',
      # Add Vary header for proper CDN caching
      'Vary' => 'Accept-Encoding'
    }

    # Enable gzip compression for served assets
    Rails.application.config.middleware.use Rack::Deflater
  end
end

# Middleware to add specific cache headers for different asset types
class AssetCacheHeaders
  CACHE_DURATIONS = {
    # Fingerprinted assets (immutable) - 1 year
    fingerprinted: 'public, max-age=31536000, immutable',
    # Fonts - 1 year
    fonts: 'public, max-age=31536000',
    # Images - 1 month
    images: 'public, max-age=2592000',
    # HTML pages - no cache
    html: 'no-cache, no-store, must-revalidate',
    # API responses - no cache
    api: 'no-store, max-age=0'
  }.freeze

  FINGERPRINT_PATTERN = /-[a-f0-9]{8,64}\./i

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    path = env['PATH_INFO']

    # Add appropriate cache headers based on asset type
    if asset_path?(path)
      cache_control = determine_cache_control(path)
      headers['Cache-Control'] = cache_control if cache_control
    end

    [status, headers, response]
  end

  private

  def asset_path?(path)
    path.start_with?('/assets/', '/vite/', '/vite-dev/', '/packs/')
  end

  def determine_cache_control(path)
    if fingerprinted?(path)
      CACHE_DURATIONS[:fingerprinted]
    elsif font_file?(path)
      CACHE_DURATIONS[:fonts]
    elsif image_file?(path)
      CACHE_DURATIONS[:images]
    end
  end

  def fingerprinted?(path)
    FINGERPRINT_PATTERN.match?(path)
  end

  def font_file?(path)
    path.match?(/\.(woff2?|ttf|otf|eot)$/i)
  end

  def image_file?(path)
    path.match?(/\.(png|jpe?g|gif|svg|webp|avif|ico)$/i)
  end
end

# Insert middleware in production
Rails.application.config.middleware.insert_before(
  Rack::Runtime,
  AssetCacheHeaders
) if Rails.env.production?
