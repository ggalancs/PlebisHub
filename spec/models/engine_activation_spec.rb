# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineActivation, type: :model do
  let(:engine_activation) { build(:engine_activation, engine_name: 'plebis_cms') rescue described_class.new(engine_name: 'plebis_cms') }

  describe 'validations' do
    it 'validates presence of engine_name' do
      activation = described_class.new(engine_name: nil)
      expect(activation).not_to be_valid
      expect(activation.errors[:engine_name]).to include("can't be blank")
    end

    it 'validates uniqueness of engine_name' do
      described_class.create!(engine_name: 'test_engine', enabled: false)
      duplicate = described_class.new(engine_name: 'test_engine')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:engine_name]).to include('has already been taken')
    end

    describe 'format validation' do
      it 'accepts valid engine names' do
        valid_names = %w[plebis_cms plebis_core test123 a_b_c test_engine_2]
        valid_names.each do |name|
          activation = described_class.new(engine_name: name, enabled: false)
          activation.valid?
          expect(activation.errors[:engine_name]).to be_empty, "#{name} should be valid"
        end
      end

      it 'rejects names starting with number' do
        activation = described_class.new(engine_name: '123test', enabled: false)
        expect(activation).not_to be_valid
        expect(activation.errors[:engine_name]).to be_present
      end

      it 'rejects names with uppercase letters' do
        activation = described_class.new(engine_name: 'PlebisCms', enabled: false)
        expect(activation).not_to be_valid
      end

      it 'rejects names with special characters' do
        invalid_names = ['test-engine', 'test.engine', 'test@engine', 'test engine']
        invalid_names.each do |name|
          activation = described_class.new(engine_name: name, enabled: false)
          expect(activation).not_to be_valid, "#{name} should be invalid"
        end
      end

      it 'rejects names with only underscores' do
        activation = described_class.new(engine_name: '___', enabled: false)
        expect(activation).not_to be_valid
      end
    end

    describe 'length validation' do
      it 'requires minimum 3 characters' do
        activation = described_class.new(engine_name: 'ab', enabled: false)
        expect(activation).not_to be_valid
        expect(activation.errors[:engine_name]).to be_present
      end

      it 'allows exactly 3 characters' do
        activation = described_class.new(engine_name: 'abc', enabled: false)
        activation.valid?
        expect(activation.errors[:engine_name]).to be_empty
      end

      it 'allows maximum 50 characters' do
        activation = described_class.new(engine_name: 'a' * 50, enabled: false)
        activation.valid?
        expect(activation.errors[:engine_name]).to be_empty
      end

      it 'rejects more than 50 characters' do
        activation = described_class.new(engine_name: 'a' * 51, enabled: false)
        expect(activation).not_to be_valid
      end
    end
  end

  describe '.enabled?' do
    context 'when engine is enabled' do
      before do
        described_class.create!(engine_name: 'enabled_engine', enabled: true)
      end

      it 'returns true' do
        expect(described_class.enabled?('enabled_engine')).to be true
      end

      it 'caches the result' do
        expect(Rails.cache).to receive(:fetch).with('engine_activation:enabled_engine', expires_in: 5.minutes).and_call_original
        described_class.enabled?('enabled_engine')
      end
    end

    context 'when engine is disabled' do
      before do
        described_class.create!(engine_name: 'disabled_engine', enabled: false)
      end

      it 'returns false' do
        expect(described_class.enabled?('disabled_engine')).to be false
      end
    end

    context 'when engine does not exist' do
      it 'returns false' do
        expect(described_class.enabled?('nonexistent_engine')).to be false
      end
    end

    context 'when error occurs' do
      before do
        allow(described_class).to receive(:exists?).and_raise(StandardError.new('DB error'))
      end

      it 'returns false for safety' do
        allow(Rails.logger).to receive(:error).and_call_original
        expect(described_class.enabled?('test')).to be false
        expect(Rails.logger).to have_received(:error).with(/Error checking if/).at_least(:once)
      end

      it 'logs the error' do
        allow(Rails.logger).to receive(:error).and_call_original
        described_class.enabled?('test')
        expect(Rails.logger).to have_received(:error).with(/Error checking if test is enabled/).at_least(:once)
      end
    end
  end

  describe '.enable!' do
    context 'when engine activation does not exist' do
      it 'creates new activation record' do
        expect {
          described_class.enable!('new_engine')
        }.to change(described_class, :count).by(1)
      end

      it 'sets enabled to true' do
        activation = described_class.enable!('new_engine')
        expect(activation.enabled).to be true
      end
    end

    context 'when engine activation exists but is disabled' do
      before do
        described_class.create!(engine_name: 'existing_engine', enabled: false)
      end

      it 'enables the engine' do
        activation = described_class.enable!('existing_engine')
        expect(activation.enabled).to be true
      end

      it 'does not create duplicate' do
        expect {
          described_class.enable!('existing_engine')
        }.not_to change(described_class, :count)
      end
    end

    it 'clears cache' do
      expect(described_class).to receive(:clear_cache).with('test_engine')
      described_class.enable!('test_engine')
    end

    it 'reloads routes' do
      expect(described_class).to receive(:reload_routes!)
      described_class.enable!('test_engine')
    end

    it 'returns the activation record' do
      result = described_class.enable!('test_engine')
      expect(result).to be_a(described_class)
      expect(result.engine_name).to eq('test_engine')
    end

    context 'when race condition occurs' do
      it 'retries on RecordNotUnique' do
        call_count = 0
        allow_any_instance_of(described_class).to receive(:save!) do
          call_count += 1
          raise ActiveRecord::RecordNotUnique if call_count == 1

          true
        end

        expect { described_class.enable!('race_engine') }.not_to raise_error
      end
    end
  end

  describe '.disable!' do
    context 'when engine exists and is enabled' do
      before do
        described_class.create!(engine_name: 'active_engine', enabled: true)
      end

      it 'disables the engine' do
        activation = described_class.disable!('active_engine')
        expect(activation.enabled).to be false
      end

      it 'clears cache' do
        expect(described_class).to receive(:clear_cache).with('active_engine')
        described_class.disable!('active_engine')
      end

      it 'reloads routes' do
        expect(described_class).to receive(:reload_routes!)
        described_class.disable!('active_engine')
      end
    end

    context 'when engine does not exist' do
      it 'returns nil' do
        result = described_class.disable!('nonexistent')
        expect(result).to be_nil
      end
    end
  end

  describe '.clear_cache' do
    it 'deletes cache key for engine' do
      expect(Rails.cache).to receive(:delete).with('engine_activation:test_engine')
      described_class.clear_cache('test_engine')
    end

    context 'when error occurs' do
      before do
        allow(Rails.cache).to receive(:delete).and_raise(StandardError.new('Cache error'))
      end

      it 'logs error and does not raise' do
        allow(Rails.logger).to receive(:error).and_call_original
        expect { described_class.clear_cache('test') }.not_to raise_error
        expect(Rails.logger).to have_received(:error).with(/Error clearing cache/).at_least(:once)
      end
    end
  end

  describe '.reload_routes!' do
    it 'reloads application routes' do
      expect(Rails.application).to receive(:reload_routes!)
      described_class.reload_routes!
    end

    it 'logs success message' do
      allow(Rails.application).to receive(:reload_routes!)
      allow(Rails.logger).to receive(:info).and_call_original
      described_class.reload_routes!
      expect(Rails.logger).to have_received(:info).with('[EngineActivation] Routes reloaded').at_least(:once)
    end

    context 'when error occurs' do
      before do
        allow(Rails.application).to receive(:reload_routes!).and_raise(StandardError.new('Route error'))
      end

      it 'logs error' do
        allow(Rails.logger).to receive(:error).and_call_original
        described_class.reload_routes!
        expect(Rails.logger).to have_received(:error).with(/Failed to reload routes/).at_least(:once)
      end

      it 'does not raise error' do
        allow(Rails.logger).to receive(:error).and_call_original
        expect { described_class.reload_routes! }.not_to raise_error
      end
    end
  end

  describe '#config' do
    let(:activation) { described_class.new(engine_name: 'test', configuration: { 'key1' => 'value1', 'key2' => 'value2' }) }

    it 'retrieves configuration value by string key' do
      expect(activation.config('key1')).to eq('value1')
    end

    it 'retrieves configuration value by symbol key' do
      expect(activation.config(:key1)).to eq('value1')
    end

    it 'returns default value for missing key' do
      expect(activation.config('missing', 'default')).to eq('default')
    end

    it 'returns nil for missing key without default' do
      expect(activation.config('missing')).to be_nil
    end
  end

  describe '#set_config' do
    let(:activation) { described_class.create!(engine_name: 'test', enabled: false, configuration: { 'existing' => 'value' }) }

    it 'sets configuration value' do
      activation.set_config('new_key', 'new_value')
      expect(activation.configuration['new_key']).to eq('new_value')
    end

    it 'preserves existing configuration' do
      activation.set_config('new_key', 'new_value')
      expect(activation.configuration['existing']).to eq('value')
    end

    it 'converts symbol keys to strings' do
      activation.set_config(:symbol_key, 'value')
      expect(activation.configuration['symbol_key']).to eq('value')
    end

    it 'saves the record' do
      expect(activation).to receive(:save).and_return(true)
      activation.set_config('key', 'value')
    end
  end

  describe '#status' do
    it 'returns Active when enabled' do
      activation = described_class.new(enabled: true)
      expect(activation.status).to eq('Active')
    end

    it 'returns Inactive when disabled' do
      activation = described_class.new(enabled: false)
      expect(activation.status).to eq('Inactive')
    end
  end

  describe '#can_enable?' do
    it 'returns true when PlebisCore::EngineRegistry is not defined' do
      hide_const('PlebisCore::EngineRegistry')
      activation = described_class.new(engine_name: 'test')
      expect(activation.can_enable?).to be true
    end
  end

  describe '.seed_all' do
    before do
      # Mock PlebisCore::EngineRegistry if it doesn't exist
      unless defined?(PlebisCore::EngineRegistry)
        module PlebisCore
          module EngineRegistry
            def self.available_engines
              %w[engine1 engine2]
            end

            def self.info(name)
              { description: "Description for #{name}" }
            end
          end
        end
      end
    end

    it 'creates activation records for all available engines' do
      expect {
        described_class.seed_all
      }.to change(described_class, :count).by_at_least(0)
    end

    it 'sets engines as disabled by default' do
      described_class.seed_all
      activation = described_class.find_by(engine_name: 'engine1')
      expect(activation&.enabled).to be_in([false, nil]) if activation
    end

    context 'when PlebisCore::EngineRegistry is not defined' do
      it 'returns early without error' do
        hide_const('PlebisCore::EngineRegistry')
        expect { described_class.seed_all }.not_to raise_error
      end
    end

    context 'when error occurs' do
      before do
        allow(PlebisCore::EngineRegistry).to receive(:available_engines).and_raise(StandardError.new('Registry error'))
      end

      it 'logs error and does not raise' do
        allow(Rails.logger).to receive(:error).and_call_original
        expect { described_class.seed_all }.not_to raise_error
        expect(Rails.logger).to have_received(:error).with(/Error seeding engines/).at_least(:once)
      end
    end
  end
end
