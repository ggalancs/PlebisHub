# frozen_string_literal: true

# Shared contexts for engine activation testing
#
RSpec.shared_context "with all engines disabled" do
  before do
    EngineActivation.update_all(enabled: false)
    Rails.cache.clear
  end
end

RSpec.shared_context "with all engines enabled" do
  before do
    EngineActivation.update_all(enabled: true)
    Rails.cache.clear
  end
end

RSpec.shared_context "with basic engines enabled" do
  before do
    EngineActivation.update_all(enabled: false)
    %w[plebis_cms plebis_participation].each do |engine|
      EngineActivation.find_or_create_by!(engine_name: engine).update!(enabled: true)
    end
    Rails.cache.clear
  end
end
