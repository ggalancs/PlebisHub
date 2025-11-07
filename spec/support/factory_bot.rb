# frozen_string_literal: true

# Configure FactoryBot to load factories from both directories
FactoryBot.definition_file_paths = [
  'test/factories',
  'spec/factories'
]

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
