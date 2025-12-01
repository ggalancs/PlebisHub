# frozen_string_literal: true

# Configure FactoryBot to load factories from test/factories only
# (spec/factories is included by default, so we only need to add test/factories)
FactoryBot.definition_file_paths = [
  Rails.root.join('test', 'factories')
]

# Note: FactoryBot automatically loads factories when Rails boots in test environment
# No need to call find_definitions manually here, as it would load them twice

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
