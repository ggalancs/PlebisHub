# frozen_string_literal: true

# Manually load gamification engine models for testing
# This is needed because the engine doesn't use isolate_namespace
# and Rails autoloading doesn't pick up the models automatically in tests

gamification_models_path = Rails.root.join('engines/plebis_gamification/app/models/gamification')

if gamification_models_path.exist?
  # Load models in dependency order
  load Rails.root.join('engines/plebis_gamification/app/models/gamification/badge.rb').to_s
  load Rails.root.join('engines/plebis_gamification/app/models/gamification/point.rb').to_s
  load Rails.root.join('engines/plebis_gamification/app/models/gamification/user_badge.rb').to_s
  load Rails.root.join('engines/plebis_gamification/app/models/gamification/user_stats.rb').to_s
end
