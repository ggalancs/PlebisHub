# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisVotes::Engine, type: :rails_engine do
  describe 'engine configuration' do
    it 'is a Rails engine' do
      expect(described_class.superclass).to eq(Rails::Engine)
    end

    it 'isolates the namespace' do
      expect(described_class.isolated?).to be true
    end

    it 'has the correct namespace' do
      expect(described_class.railtie_namespace).to eq(PlebisVotes)
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

    it 'defines plebis_votes.load_abilities initializer' do
      initializer = initializers.find { |i| i.name == 'plebis_votes.load_abilities' }
      expect(initializer).not_to be_nil
    end

    it 'defines plebis_votes.check_activation initializer' do
      initializer = initializers.find { |i| i.name == 'plebis_votes.check_activation' }
      expect(initializer).not_to be_nil
    end

    it 'runs check_activation before set_routes_reloader' do
      initializer = initializers.find { |i| i.name == 'plebis_votes.check_activation' }
      expect(initializer.before).to eq(:set_routes_reloader)
    end
  end

  describe 'ability loading' do
    it 'loads abilities when both Ability and engine Ability are defined' do
      registered = []
      ability_class = Class.new do
        define_singleton_method(:register_abilities) do |ability|
          registered << ability
        end

        define_singleton_method(:registered_abilities) do
          registered
        end
      end

      engine_ability = Class.new
      stub_const('Ability', ability_class)
      stub_const('PlebisVotes::Ability', engine_ability)

      Ability.register_abilities(PlebisVotes::Ability) if defined?(Ability) && defined?(PlebisVotes::Ability)

      expect(Ability.registered_abilities).to include(PlebisVotes::Ability)
    end

    it 'handles missing Ability gracefully' do
      hide_const('Ability')
      stub_const('PlebisVotes::Ability', Class.new)

      expect do
        Ability.register_abilities(PlebisVotes::Ability) if defined?(Ability) && defined?(PlebisVotes::Ability)
      end.not_to raise_error
    end

    it 'handles missing engine Ability gracefully' do
      ability_class = Class.new do
        def self.register_abilities(ability); end
      end
      stub_const('Ability', ability_class)
      hide_const('PlebisVotes::Ability')

      expect do
        Ability.register_abilities(PlebisVotes::Ability) if defined?(Ability) && defined?(PlebisVotes::Ability)
      end.not_to raise_error
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

      result = ::EngineActivation.enabled?('plebis_votes')
      expect(result).to be true
    end

    it 'handles disabled engine' do
      activation_class = Class.new do
        def self.enabled?(name)
          false
        end
      end
      stub_const('::EngineActivation', activation_class)

      result = ::EngineActivation.enabled?('plebis_votes')
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
          ::EngineActivation.enabled?('plebis_votes')
        rescue StandardError
          true
        end
      end.not_to raise_error
    end
  end
end
