# frozen_string_literal: true

source 'https://rubygems.org'

ruby '>= 3.3.6'

# Rails 7.2 - Following official upgrade guide
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails' # Legacy - will be removed after full Vue migration
gem 'json', '>= 2.0' # Ruby 3.3 compatible (old 1.8.6 breaks)
gem 'rails', '~> 7.2.3'
gem 'sass-rails' # Legacy - for Sprockets SASS compilation
gem 'sdoc', '>= 2.0', group: :doc # Ruby 3.3 / json 2.x compatible
gem 'spring', group: :development
gem 'sprockets-rails' # Legacy assets (will be phased out)
gem 'sqlite3', '~> 1.4'
gem 'vite_rails', '~> 3.0' # Modern frontend with Vite + Vue 3
gem 'coffee-rails' # Required by Sprockets processor (even without .coffee files)
# REMOVED: turbolinks (replaced by Vue Router / native navigation)
# REMOVED: uglifier (Vite handles JS minification)
# therubyracer removed - deprecated and crashes on Ruby 3.x
# Node.js is used as the JavaScript runtime instead

gem 'airbrake'
gem 'pg'
gem 'rb-readline'
gem 'unicorn'

gem 'activeadmin', '~> 3.2' # Rails 7.1+ compatible
gem 'active_skin'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'cancancan', '~> 3.5' # Updated from 1.9 - Rails 7.2 compatible
gem 'carmen-rails'
gem 'devise', '~> 4.9' # Rails 7.0+ compatible
gem 'esendex'
gem 'formtastic'
gem 'formtastic-bootstrap'
gem 'ransack', '~> 4.2' # Rails 7.2+ compatible (required by ActiveAdmin)
gem 'simple_captcha2', require: 'simple_captcha'
gem 'spanish_vat_validators', '0.0.6' # , github: 'leio10/spanish_vat_validators'
# mailcatcher removed from Gemfile - install separately: gem install mailcatcher
# See README.md for development email setup instructions
gem 'auto_html'
gem 'aws-sdk-rails', '~> 3.0' # Updated for Rails 7.2+ compatibility
gem 'cocoon'
gem 'date_validator'
gem 'ffi' # Ruby 3.3 compatible
gem 'ffi-icu'
gem 'flag_shih_tzu'
gem 'font-awesome-rails', '~> 4.7'
gem 'friendly_id', '~> 5.2' # Updated for Rails 5
gem 'iban-tools'
gem 'kaminari'
gem 'paper_trail', '~> 15.2' # Rails 7.2+ compatible
gem 'paranoia', '~> 3.0' # Rails 7.2 compatible
gem 'phonelib'
gem 'pushmeup'
gem 'rack-attack', '~> 6.7' # Rate limiting and throttling
gem 'rack-openid'
gem 'rails_autolink'
gem 'rake-progressbar'
gem 'redis', '~> 5.0' # Redis client for Rack::Attack cache
gem 'ruby-openid'
gem 'secure_headers'
gem 'sidekiq', '~> 7.0' # Background job processing (replaces Resque)
gem 'sidekiq-unique-jobs', '~> 8.0' # Ensure jobs run only once
gem 'unicode'
gem 'wicked_pdf'
# ActiveStorage for file uploads (Rails 5.2+)
# Replaces deprecated Paperclip gem
gem 'd3-rails'
gem 'digest-crc'
gem 'espeak-ruby', require: false
gem 'grape'
gem 'image_processing', '~> 1.12' # For image variants (required by ActiveStorage)
gem 'jquery-fileupload-rails'
gem 'mini_magick', '~> 4.12'      # Image processing backend
gem 'norma43', git: 'https://github.com/podemos-info/norma43.git'
gem 'rexml', '>= 3.4.2' # CVE-2025-58767 security fix
gem 'rqrcode'
gem 'rubypress'
gem 'state_machines' # Ruby 3.3 compatible
gem 'state_machines-activerecord'
gem 'state_machines-audit_trail', '~> 1.0'
gem 'validate_url'
gem 'xmlrpc'

# Web server - must be in all environments for Docker/production
gem 'puma', '~> 6.0'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'byebug', '~> 11.1' # Ruby 2.7 compatible
  gem 'capistrano', '~> 3.10.2'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 6.2' # Ruby 2.7+ compatible
  gem 'launchy'
  gem 'listen' # Required by Rails 6.0 for file watching
  gem 'minitest-rails', '~> 7.1' # Rails 7.2 compatible
  gem 'minitest-reporters'
  gem 'mocha', require: false
  gem 'nokogiri', '~> 1.16' # Required by Rails 7.2, Ruby 3.3 compatible
  gem 'rails-controller-testing' # Required for assigns() and assert_template in controller specs
  gem 'rails-perftest'
  gem 'rspec_junit_formatter', require: false # For CI test results
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'ruby-prof'
  gem 'selenium-webdriver' # Modern driver for Capybara
  gem 'simplecov'
  gem 'webmock'
  # gem 'capybara-webkit' # Commented: deprecated and requires Qt (qmake)
  # gem 'minitest-rails-capybara' # Temporarily disabled for upgrade
end

# PlebisHub Engines
gem 'plebis_cms', path: 'engines/plebis_cms'
gem 'plebis_collaborations', path: 'engines/plebis_collaborations'
gem 'plebis_gamification', path: 'engines/plebis_gamification'
gem 'plebis_impulsa', path: 'engines/plebis_impulsa'
gem 'plebis_microcredit', path: 'engines/plebis_microcredit'
gem 'plebis_participation', path: 'engines/plebis_participation'
gem 'plebis_proposals', path: 'engines/plebis_proposals'
gem 'plebis_verification', path: 'engines/plebis_verification'
gem 'plebis_votes', path: 'engines/plebis_votes'
