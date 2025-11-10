# frozen_string_literal: true

require_relative "lib/plebis_microcredit/version"

Gem::Specification.new do |spec|
  spec.name        = "plebis_microcredit"
  spec.version     = PlebisMicrocredit::VERSION
  spec.authors     = ["PlebisHub Team"]
  spec.email       = ["dev@plebisbrand.info"]
  spec.summary     = "Microcredit campaigns engine for PlebisHub"
  spec.description = "Handles microcredit campaigns, loans, and renewals with IBAN/BIC validation"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = "~> 3.3.10"

  spec.add_dependency "rails", "~> 7.2.3"
  spec.add_dependency "iban-tools"  # IBAN validation
end
