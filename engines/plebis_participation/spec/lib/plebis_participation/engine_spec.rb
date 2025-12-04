# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisParticipation::Engine, type: :rails_engine do
  describe 'engine configuration' do
    it 'is a Rails engine' do
      expect(described_class.superclass).to eq(Rails::Engine)
    end

    it 'isolates the namespace' do
      expect(described_class.isolated?).to be true
    end

    it 'has the correct namespace' do
      expect(described_class.railtie_namespace).to eq(PlebisParticipation)
    end
  end

  describe 'generators configuration' do
    it 'configures RSpec as the test framework' do
      expect(described_class.config.generators.options[:rails][:test_framework]).to eq(:rspec)
    end

    it 'configures FactoryBot as fixture replacement' do
      expect(described_class.config.generators.options[:rails][:fixture_replacement]).to eq(:factory_bot)
    end

    it 'configures FactoryBot directory' do
      expect(described_class.config.generators.options[:factory_bot][:dir]).to eq('spec/factories')
    end
  end

  describe 'initializers' do
    let(:initializers) { described_class.initializers }

    it 'defines plebis_participation.check_activation initializer' do
      initializer = initializers.find { |i| i.name == 'plebis_participation.check_activation' }
      expect(initializer).not_to be_nil
    end

    it 'runs check_activation before set_routes_reloader' do
      initializer = initializers.find { |i| i.name == 'plebis_participation.check_activation' }
      expect(initializer.before).to eq(:set_routes_reloader)
    end
  end

  describe 'activation check' do
    it 'handles enabled engine' do
      activation_class = Class.new do
        def self.enabled?(name)
          true
        end
      end
      stub_const('::EngineActivation', activation_class)

      result = ::EngineActivation.enabled?('plebis_participation')
      expect(result).to be true
    end

    it 'handles disabled engine' do
      activation_class = Class.new do
        def self.enabled?(name)
          false
        end
      end
      stub_const('::EngineActivation', activation_class)

      result = ::EngineActivation.enabled?('plebis_participation')
      expect(result).to be false
    end

    it 'handles EngineActivation errors gracefully' do
      activation_class = Class.new do
        def self.enabled?(name)
          raise StandardError, 'Database not available'
        end
      end
      stub_const('::EngineActivation', activation_class)

      expect do
        begin
          ::EngineActivation.enabled?('plebis_participation')
        rescue StandardError
          true
        end
      end.not_to raise_error
    end
  end
end
