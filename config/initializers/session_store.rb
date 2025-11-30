# Be sure to restart your server when you modify this file.

# SEC-004: Secure session cookie configuration
# - secure: true in production ensures cookies only sent over HTTPS
# - httponly: true prevents JavaScript access to session cookie (XSS protection)
# - same_site: :lax prevents CSRF attacks while allowing normal navigation
Rails.application.config.session_store :cookie_store,
  key: '_plebis_hub_session',
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax
