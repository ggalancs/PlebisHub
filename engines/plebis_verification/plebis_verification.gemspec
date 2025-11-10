# frozen_string_literal: true

require_relative "lib/plebis_verification/version"

Gem::Specification.new do |spec|
  spec.name        = "plebis_verification"
  spec.version     = PlebisVerification::VERSION
  spec.authors     = ["PlebisHub Team"]
  spec.email       = ["dev@plebisbrand.info"]
  spec.summary     = "User verification engine for PlebisHub"
  spec.description = "Handles SMS verification and document verification (ID/passport) for users"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = "~> 3.3.10"

  spec.add_dependency "rails", "~> 7.2.3"
  spec.add_dependency "paperclip"  # For document uploads
  spec.add_dependency "phonelib"   # Phone number validation
end
