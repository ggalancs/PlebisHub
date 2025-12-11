# frozen_string_literal: true

# Manually load gamification engine models for testing
# This is needed because the engine doesn't use isolate_namespace
# and Rails autoloading doesn't pick up the models automatically in tests
#
# NOTE: Using require_relative instead of load to ensure SimpleCov
# properly tracks coverage. Using load causes models to be reloaded
# after SimpleCov starts tracking, which breaks coverage collection.

gamification_models_path = Rails.root.join('engines/plebis_gamification/app/models/gamification')

if gamification_models_path.exist?
  # Load models in dependency order using require_relative for proper coverage tracking
  require_relative '../../engines/plebis_gamification/app/models/gamification/badge'
  require_relative '../../engines/plebis_gamification/app/models/gamification/point'
  require_relative '../../engines/plebis_gamification/app/models/gamification/user_badge'
  require_relative '../../engines/plebis_gamification/app/models/gamification/user_stats'
end
