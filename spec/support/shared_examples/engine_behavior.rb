# frozen_string_literal: true

# Shared examples for testing engine behavior
#
RSpec.shared_examples "an activatable engine" do |engine_name|
  let(:engine_activation) { EngineActivation.find_or_create_by!(engine_name: engine_name) }

  it "can be enabled" do
    engine_activation.update!(enabled: true)
    expect(EngineActivation.enabled?(engine_name)).to be true
  end

  it "can be disabled" do
    engine_activation.update!(enabled: false)
    expect(EngineActivation.enabled?(engine_name)).to be false
  end

  it "has metadata in registry" do
    info = PlebisCore::EngineRegistry.info(engine_name)
    expect(info).not_to be_empty
    expect(info[:name]).to be_present
    expect(info[:description]).to be_present
  end
end

RSpec.shared_examples "an engine with dependencies" do |engine_name, dependencies|
  it "lists its dependencies" do
    deps = PlebisCore::EngineRegistry.dependencies_for(engine_name)
    dependencies.each do |dep|
      expect(deps).to include(dep)
    end
  end

  it "can only be enabled when dependencies are met" do
    # Disable all engines
    EngineActivation.update_all(enabled: false)

    # Try to enable without dependencies
    activation = EngineActivation.find_or_create_by!(engine_name: engine_name)

    if dependencies.reject { |d| d == 'User' }.any?
      expect(PlebisCore::EngineRegistry.can_enable?(engine_name)).to be false

      # Enable dependencies
      dependencies.reject { |d| d == 'User' }.each do |dep|
        EngineActivation.find_or_create_by!(engine_name: dep).update!(enabled: true)
      end
    end

    # Now it should be possible to enable
    expect(PlebisCore::EngineRegistry.can_enable?(engine_name)).to be true
  end
end
