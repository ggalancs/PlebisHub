# frozen_string_literal: true

require_relative "lib/plebis_impulsa/version"

Gem::Specification.new do |spec|
  spec.name        = "plebis_impulsa"
  spec.version     = PlebisImpulsa::VERSION
  spec.authors     = ["PlebisHub Team"]
  spec.email       = ["dev@plebis.org"]
  spec.summary     = "Citizen project submission and evaluation platform for PlebisHub"
  spec.description = "Impulsa platform for submitting, evaluating, and voting on citizen projects with multi-step wizard and state machine"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  # REQUIRED VERSIONS (from modularization guide)
  spec.required_ruby_version = ">= 3.3.6"

  spec.add_dependency "rails", "~> 7.2.3"

  # File attachments - using ActiveStorage (built into Rails)
  # No additional dependency needed

  # Flag management
  spec.add_dependency "flag_shih_tzu"
end
