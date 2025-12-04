# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'plebis_collaborations/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'plebis_collaborations'
  spec.version     = PlebisCollaborations::VERSION
  spec.authors     = ['PlebisHub Team']
  spec.email       = ['dev@plebis.io']
  spec.homepage    = 'https://github.com/podemos-info/plebis_hub'
  spec.summary     = 'PlebisHub Collaborations Engine - Financial Contributions Module'
  spec.description = 'Manages economic collaborations, recurring payments, SEPA direct debits, and donation processing for PlebisHub platform'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  # Rails dependency
  spec.add_dependency 'rails', '~> 7.2.3'

  # External dependencies used by this engine
  # Note: These are already in main Gemfile, but documented here for clarity
  # - iban-tools: IBAN validation for bank accounts
  # - state_machines-activerecord: State machine for order status
  # - paranoia: Soft deletes for collaborations
  # - Integration with Redsys payment gateway
  # - Integration with SEPA direct debit system
end
