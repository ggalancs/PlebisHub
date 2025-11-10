# frozen_string_literal: true

$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "plebis_votes/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "plebis_votes"
  spec.version     = PlebisVotes::VERSION
  spec.authors     = ["PlebisHub Team"]
  spec.email       = ["dev@plebis.io"]
  spec.homepage    = "https://github.com/podemos-info/plebis_hub"
  spec.summary     = "PlebisHub Votes Engine - Voting and Elections Module"
  spec.description = "Manages elections, votes, vote circles, and paper voting for PlebisHub platform"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  # Rails dependency
  spec.add_dependency "rails", "~> 7.2.3"

  # External dependencies used by this engine
  # Note: These are already in main Gemfile, but documented here for clarity
  # - flag_shih_tzu: Used by Election model for feature flags
  # - paperclip: Used by Election model for census file attachments
  # - paranoia: Used by Vote model for soft deletes
  # - carmen & carmen-rails: Used by VoteCircle for geography/territory details
  # - ransack: Used by VoteCircle for advanced searches
end
