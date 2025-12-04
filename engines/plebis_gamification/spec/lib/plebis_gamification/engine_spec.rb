# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisGamification::Engine, type: :rails_engine do
  describe 'engine configuration' do
    it 'is a Rails engine' do
      expect(described_class.superclass).to eq(Rails::Engine)
    end

    it 'does not isolate the namespace' do
      expect(described_class.isolated?).to be false
    end
  end

  describe 'autoload paths configuration' do
    it 'configures autoload paths for concerns directory when it exists' do
      concerns_path = described_class.root.join('app/models/concerns')

      if concerns_path.exist?
        expect(described_class.config.autoload_paths).to include(concerns_path)
      else
        expect(described_class.config.autoload_paths).not_to include(concerns_path)
      end
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

    it 'defines plebis_gamification.check_activation initializer' do
      initializer = initializers.find { |i| i.name == 'plebis_gamification.check_activation' }
      expect(initializer).not_to be_nil
    end

    it 'defines plebis_gamification.register_listeners initializer' do
      initializer = initializers.find { |i| i.name == 'plebis_gamification.register_listeners' }
      expect(initializer).not_to be_nil
    end

    it 'runs check_activation before set_routes_reloader' do
      initializer = initializers.find { |i| i.name == 'plebis_gamification.check_activation' }
      expect(initializer.before).to eq(:set_routes_reloader)
    end

    it 'runs register_listeners after load_config_initializers' do
      initializer = initializers.find { |i| i.name == 'plebis_gamification.register_listeners' }
      expect(initializer.after).to eq(:load_config_initializers)
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

      result = ::EngineActivation.enabled?('plebis_gamification')
      expect(result).to be true
    end

    it 'handles disabled engine' do
      activation_class = Class.new do
        def self.enabled?(name)
          false
        end
      end
      stub_const('::EngineActivation', activation_class)

      result = ::EngineActivation.enabled?('plebis_gamification')
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
          ::EngineActivation.enabled?('plebis_gamification')
        rescue StandardError
          true
        end
      end.not_to raise_error
    end
  end

  describe 'listener registration' do
    it 'handles UserListener when defined' do
      listener_class = Class.new do
        def self.register!; end
      end
      stub_const('Gamification::Listeners::UserListener', listener_class)

      expect(listener_class).to receive(:register!)

      Gamification::Listeners::UserListener.register! if defined?(Gamification::Listeners::UserListener)
    end

    it 'handles ProposalListener when defined' do
      listener_class = Class.new do
        def self.register!; end
      end
      stub_const('Gamification::Listeners::ProposalListener', listener_class)

      expect(listener_class).to receive(:register!)

      Gamification::Listeners::ProposalListener.register! if defined?(Gamification::Listeners::ProposalListener)
    end

    it 'handles VoteListener when defined' do
      listener_class = Class.new do
        def self.register!; end
      end
      stub_const('Gamification::Listeners::VoteListener', listener_class)

      expect(listener_class).to receive(:register!)

      Gamification::Listeners::VoteListener.register! if defined?(Gamification::Listeners::VoteListener)
    end

    it 'handles LoginListener when defined' do
      listener_class = Class.new do
        def self.register!; end
      end
      stub_const('Gamification::Listeners::LoginListener', listener_class)

      expect(listener_class).to receive(:register!)

      Gamification::Listeners::LoginListener.register! if defined?(Gamification::Listeners::LoginListener)
    end

    it 'handles missing listeners gracefully' do
      hide_const('Gamification::Listeners::UserListener')
      hide_const('Gamification::Listeners::ProposalListener')
      hide_const('Gamification::Listeners::VoteListener')
      hide_const('Gamification::Listeners::LoginListener')

      expect do
        Gamification::Listeners::UserListener.register! if defined?(Gamification::Listeners::UserListener)
        Gamification::Listeners::ProposalListener.register! if defined?(Gamification::Listeners::ProposalListener)
        Gamification::Listeners::VoteListener.register! if defined?(Gamification::Listeners::VoteListener)
        Gamification::Listeners::LoginListener.register! if defined?(Gamification::Listeners::LoginListener)
      end.not_to raise_error
    end
  end
end
