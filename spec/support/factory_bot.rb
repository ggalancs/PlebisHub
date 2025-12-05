# frozen_string_literal: true

# Configure FactoryBot to load factories from test/factories and engine specs
# (spec/factories is included by default, so we only need to add test/factories and engine factories)
FactoryBot.definition_file_paths = [
  Rails.root.join('test/factories'),
  Rails.root.join('engines/plebis_gamification/spec/factories'),
  Rails.root.join('engines/plebis_cms/spec/factories'),
  Rails.root.join('engines/plebis_votes/spec/factories'),
  Rails.root.join('engines/plebis_proposals/spec/factories'),
  Rails.root.join('engines/plebis_collaborations/spec/factories'),
  Rails.root.join('engines/plebis_participation/spec/factories'),
  Rails.root.join('engines/plebis_microcredit/spec/factories'),
  Rails.root.join('engines/plebis_impulsa/spec/factories'),
  Rails.root.join('engines/plebis_verification/spec/factories')
]

# NOTE: FactoryBot automatically loads factories when Rails boots in test environment
# No need to call find_definitions manually here, as it would load them twice

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
