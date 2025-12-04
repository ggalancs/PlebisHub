# frozen_string_literal: true

require_relative 'lib/plebis_proposals/version'

Gem::Specification.new do |spec|
  spec.name        = 'plebis_proposals'
  spec.version     = PlebisProposals::VERSION
  spec.authors     = ['PlebisHub Team']
  spec.email       = ['dev@plebis.org']
  spec.summary     = 'Community proposals and support system for PlebisHub'
  spec.description = 'Allows users to create and support community proposals with Reddit-style filtering and voting thresholds'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  # REQUIRED VERSIONS (from modularization guide)
  spec.required_ruby_version = '>= 3.3.6'

  spec.add_dependency 'rails', '~> 7.2.3'
end
