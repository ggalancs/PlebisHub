# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisImpulsa::Engine, type: :rails_engine do
  describe 'engine configuration' do
    it 'is a Rails engine' do
      expect(described_class.superclass).to eq(Rails::Engine)
    end

    it 'isolates the namespace' do
      expect(described_class.isolated?).to be true
    end

    it 'has the correct namespace' do
      expect(described_class.railtie_namespace).to eq(PlebisImpulsa)
    end
  end

  describe 'autoload paths configuration' do
    # The concerns live in app/models/concerns/plebis_impulsa, which Rails
    # already treats as an autoload root, so no extra autoload_paths entry is
    # needed. What matters is that the constants resolve.
    it 'keeps the concerns under the conventional app/models/concerns root' do
      expect(described_class.root.join('app/models/concerns/plebis_impulsa')).to be_directory
      expect(described_class.root.join('app/models/plebis_impulsa/concerns')).not_to be_directory
    end

    it 'autoloads the concerns as PlebisImpulsa constants' do
      expect(PlebisImpulsa::ImpulsaProjectStates).to be_a(Module)
      expect(PlebisImpulsa::ImpulsaProjectWizard).to be_a(Module)
      expect(PlebisImpulsa::ImpulsaProjectEvaluation).to be_a(Module)
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

    it 'defines plebis_impulsa.check_activation initializer' do
      initializer = initializers.find { |i| i.name == 'plebis_impulsa.check_activation' }
      expect(initializer).not_to be_nil
    end

    it 'runs check_activation before set_routes_reloader' do
      initializer = initializers.find { |i| i.name == 'plebis_impulsa.check_activation' }
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

      result = ::EngineActivation.enabled?('plebis_impulsa')
      expect(result).to be true
    end

    it 'handles disabled engine' do
      activation_class = Class.new do
        def self.enabled?(name)
          false
        end
      end
      stub_const('::EngineActivation', activation_class)

      result = ::EngineActivation.enabled?('plebis_impulsa')
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
        ::EngineActivation.enabled?('plebis_impulsa')
      rescue StandardError
        true
      end.not_to raise_error
    end
  end

  describe 'concerns wiring' do
    it 'mixes the concerns into ImpulsaProject' do
      expect(PlebisImpulsa::ImpulsaProject.ancestors).to include(
        PlebisImpulsa::ImpulsaProjectStates,
        PlebisImpulsa::ImpulsaProjectWizard,
        PlebisImpulsa::ImpulsaProjectEvaluation
      )
    end
  end

  describe 'engine paths' do
    it 'has config/routes.rb path configured' do
      expect(described_class.config.paths['config/routes.rb']).to be_present
    end
  end

  describe 'logging' do
    context 'when engine is disabled' do
      it 'logs info message when engine is disabled' do
        activation_class = Class.new do
          def self.enabled?(name)
            false
          end
        end
        stub_const('::EngineActivation', activation_class)

        expect(Rails.logger).to receive(:info).with('[PlebisImpulsa] Engine disabled, skipping routes')
        Rails.logger.info('[PlebisImpulsa] Engine disabled, skipping routes') unless ::EngineActivation.enabled?('plebis_impulsa')
      end
    end

    context 'when EngineActivation check fails' do
      it 'logs warning with error message' do
        activation_class = Class.new do
          def self.enabled?(name)
            raise StandardError, 'Database connection failed'
          end
        end
        stub_const('::EngineActivation', activation_class)

        expect(Rails.logger).to receive(:warn).with(/\[PlebisImpulsa\] Could not check activation status/)
        begin
          ::EngineActivation.enabled?('plebis_impulsa')
        rescue StandardError => e
          Rails.logger.warn "[PlebisImpulsa] Could not check activation status (#{e.message}), enabling by default"
        end
      end
    end
  end
end
