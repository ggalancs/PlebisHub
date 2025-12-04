# frozen_string_literal: true

require_relative 'lib/plebis_microcredit/version'

Gem::Specification.new do |spec|
  spec.name        = 'plebis_microcredit'
  spec.version     = PlebisMicrocredit::VERSION
  spec.authors     = ['PlebisHub Team']
  spec.email       = ['dev@plebisbrand.info']
  spec.summary     = 'Microcredit campaigns engine for PlebisHub'
  spec.description = 'Handles microcredit campaigns, loans, and renewals with IBAN/BIC validation'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.required_ruby_version = '>= 3.3.6'

  spec.add_dependency 'iban-tools' # IBAN validation
  spec.add_dependency 'rails', '~> 7.2.3'

  # NOTE: This engine also requires the following gems to be in the main Gemfile:
  # - norma43 (git: 'https://github.com/podemos-info/norma43.git') - Spanish bank file format parser
  # - paperclip - File attachment management
  # - acts_as_paranoid - Soft deletes
  # - friendly_id - URL slugs
  # - flag_shih_tzu - Bit flags
end
