require "logger" # Required for Rails 6.0+ with concurrent-ruby >= 1.3.5

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
