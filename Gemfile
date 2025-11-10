source 'https://rubygems.org'

ruby '3.3.10'

# Rails 7.2 - Following official upgrade guide
gem 'rails', '~> 7.2.3'
gem 'json', '>= 2.0' # Ruby 3.3 compatible (old 1.8.6 breaks)
gem 'sprockets-rails' # Required in Rails 7.0 (no longer bundled)
gem 'sqlite3', '~> 1.4'
gem 'sass-rails'
gem 'uglifier', '>= 2.7.2'
gem 'coffee-rails', '~> 4.2'
gem 'therubyracer', git: 'https://github.com/cowboyd/therubyracer.git',  platforms: :ruby
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '>= 2.0',          group: :doc # Ruby 3.3 / json 2.x compatible
gem 'spring',        group: :development

gem 'unicorn'
gem 'pg'
gem 'rb-readline'
gem 'airbrake'

gem 'devise', '~> 4.9' # Rails 7.0+ compatible
gem 'cancancan', '~> 1.9'
gem 'bootstrap-sass', '~> 3.4.1'
gem 'formtastic'
gem 'formtastic-bootstrap'
gem 'spanish_vat_validators', '0.0.6'#, github: 'leio10/spanish_vat_validators'
gem 'simple_captcha2', require: 'simple_captcha'
gem 'carmen-rails'
gem 'esendex'
gem 'ransack', '~> 4.2' # Rails 7.2+ compatible (required by ActiveAdmin)
gem 'activeadmin', '~> 3.2' # Rails 7.1+ compatible
gem 'active_skin'
gem 'mailcatcher' # for staging too
gem 'resque'
gem 'resque_mailer' # for automated email sending in background
gem 'aws-sdk-rails', '~> 2.1' # aws-sdk-rails >= 3 requires Ruby >= 2.6
gem 'kaminari'
gem 'pushmeup'
gem 'date_validator'
gem 'phonelib'
gem 'iban-tools'
gem 'paper_trail', '~> 15.2' # Rails 7.2+ compatible
gem 'ffi' # Ruby 3.3 compatible
gem 'ffi-icu'
gem 'unicode'
gem 'rack-openid'
gem 'ruby-openid'
gem "secure_headers"
gem 'rake-progressbar'
gem 'rails_autolink'
gem 'flag_shih_tzu'
gem 'wicked_pdf'
gem "font-awesome-rails", '~> 4.7'
gem 'friendly_id', '~> 5.2' # Updated for Rails 5
gem 'auto_html'
gem "paranoia", "~> 3.0" # Rails 7.2 compatible
gem 'cocoon'
gem 'paperclip', '~> 5.2.1'
gem 'validate_url'
gem 'norma43', git: 'https://github.com/podemos-info/norma43.git'
gem "d3-rails"
gem "jquery-fileupload-rails"
gem 'state_machines' # Ruby 3.3 compatible
gem 'state_machines-activerecord'
gem 'state_machines-audit_trail', '~> 1.0'
gem 'rubypress'
gem 'digest-crc'
gem 'xmlrpc'
gem "espeak-ruby", require: false
gem 'grape'
gem 'rqrcode'

group :development, :test do
  gem 'listen' # Required by Rails 6.0 for file watching
  gem 'puma'
  gem 'capistrano', '~> 3.10.2'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'factory_bot_rails', '~> 6.2' # Ruby 2.7+ compatible
  gem 'byebug', '~> 11.1' # Ruby 2.7 compatible
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rails-perftest'
  gem 'ruby-prof'
  gem 'simplecov'
  gem 'rspec-rails'
  gem 'webmock'
  gem 'minitest-reporters'
  gem 'nokogiri', '~> 1.16' # Required by Rails 7.2, Ruby 3.3 compatible
  gem 'capybara'
  # gem 'capybara-webkit' # Commented: deprecated and requires Qt (qmake)
  gem 'selenium-webdriver' # Modern driver for Capybara
  gem 'launchy'
  gem 'database_cleaner'
  gem 'mocha', require: false
  gem 'minitest-rails', '~> 7.1' # Rails 7.2 compatible
  # gem 'minitest-rails-capybara' # Temporarily disabled for upgrade
  gem 'rails-controller-testing' # Required for assigns() and assert_template in controller specs
end


# PlebisHub Engines
gem 'plebis_cms', path: 'engines/plebis_cms'
gem 'plebis_participation', path: 'engines/plebis_participation'
gem 'plebis_proposals', path: 'engines/plebis_proposals'
gem 'plebis_impulsa', path: 'engines/plebis_impulsa'
gem 'plebis_verification', path: 'engines/plebis_verification'
gem 'plebis_microcredit', path: 'engines/plebis_microcredit'
