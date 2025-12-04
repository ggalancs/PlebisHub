# frozen_string_literal: true

require_relative 'lib/plebis_cms/version'

Gem::Specification.new do |spec|
  spec.name        = 'plebis_cms'
  spec.version     = PlebisCms::VERSION
  spec.authors     = ['PlebisHub Team']
  spec.email       = ['dev@plebishub.org']
  spec.summary     = 'Content Management System for PlebisHub'
  spec.description = 'Blog posts, pages, and notifications management engine'
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
