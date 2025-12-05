# frozen_string_literal: true

require_relative 'lib/plebis_gamification/version'

Gem::Specification.new do |spec|
  spec.name        = 'plebis_gamification'
  spec.version     = PlebisGamification::VERSION
  spec.authors     = ['PlebisHub Team']
  spec.email       = ['dev@plebishub.org']
  spec.summary     = 'Gamification System for PlebisHub'
  spec.description = 'Badges, points, and achievements engine'
  spec.homepage    = 'https://github.com/plebis/plebishub'
  spec.license     = 'MIT'

  # VERSIONES OBLIGATORIAS (ver GUIA_MAESTRA_MODULARIZACION.md sección 1.5)
  spec.required_ruby_version = '>= 3.3.6'

  spec.files = Dir['{app,config,db,lib,spec}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  # Rails dependency
  spec.add_dependency 'rails', '~> 7.2.3'

  # Development dependencies
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'rspec-rails'
end
