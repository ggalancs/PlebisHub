# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../lib/plebis_core/engine_registry'

RSpec.describe PlebisCore::EngineRegistry do
  describe '.available_engines' do
    it 'returns array of engine names' do
      expect(described_class.available_engines).to be_an(Array)
    end

    it 'includes plebis_cms' do
      expect(described_class.available_engines).to include('plebis_cms')
    end

    it 'includes plebis_participation' do
      expect(described_class.available_engines).to include('plebis_participation')
    end

    it 'includes plebis_proposals' do
      expect(described_class.available_engines).to include('plebis_proposals')
    end

    it 'includes plebis_impulsa' do
      expect(described_class.available_engines).to include('plebis_impulsa')
    end

    it 'includes plebis_verification' do
      expect(described_class.available_engines).to include('plebis_verification')
    end

    it 'includes plebis_voting' do
      expect(described_class.available_engines).to include('plebis_voting')
    end

    it 'includes plebis_microcredit' do
      expect(described_class.available_engines).to include('plebis_microcredit')
    end

    it 'includes plebis_collaborations' do
      expect(described_class.available_engines).to include('plebis_collaborations')
    end

    it 'includes plebis_militant' do
      expect(described_class.available_engines).to include('plebis_militant')
    end
  end

  describe '.info' do
    context 'for plebis_cms' do
      let(:info) { described_class.info('plebis_cms') }

      it 'returns engine metadata' do
        expect(info).to be_a(Hash)
      end

      it 'has a name' do
        expect(info[:name]).to eq('Content Management')
      end

      it 'has a description' do
        expect(info[:description]).to eq('Blog posts, pages, and notifications')
      end

      it 'has a version' do
        expect(info[:version]).to eq('1.0.0')
      end

      it 'has models' do
        expect(info[:models]).to include('Post', 'Category', 'Page', 'Notice', 'NoticeRegistrar')
      end

      it 'has controllers' do
        expect(info[:controllers]).to include('BlogController', 'PageController', 'NoticeController')
      end

      it 'has dependencies' do
        expect(info[:dependencies]).to include('User')
      end

      it 'has default configuration' do
        expect(info[:default_config]).to be_a(Hash)
      end
    end

    context 'for plebis_voting' do
      let(:info) { described_class.info('plebis_voting') }

      it 'includes verification dependency' do
        expect(info[:dependencies]).to include('plebis_verification')
      end

      it 'includes User dependency' do
        expect(info[:dependencies]).to include('User')
      end

      it 'has voting-specific config' do
        expect(info[:default_config]).to have_key(:allow_paper_voting)
        expect(info[:default_config]).to have_key(:sms_verification_required)
      end
    end

    context 'for plebis_militant' do
      let(:info) { described_class.info('plebis_militant') }

      it 'has multiple engine dependencies' do
        expect(info[:dependencies]).to include('plebis_collaborations')
        expect(info[:dependencies]).to include('plebis_verification')
      end

      it 'has militant-specific config' do
        expect(info[:default_config]).to have_key(:min_militant_amount)
        expect(info[:default_config]).to have_key(:external_api_enabled)
      end
    end

    context 'for non-existent engine' do
      it 'returns empty hash' do
        expect(described_class.info('non_existent')).to eq({})
      end
    end
  end

  describe '.dependencies_for' do
    it 'returns dependencies for plebis_cms' do
      deps = described_class.dependencies_for('plebis_cms')
      expect(deps).to eq(['User'])
    end

    it 'returns dependencies for plebis_voting' do
      deps = described_class.dependencies_for('plebis_voting')
      expect(deps).to include('User', 'plebis_verification')
    end

    it 'returns dependencies for plebis_militant' do
      deps = described_class.dependencies_for('plebis_militant')
      expect(deps).to include('User', 'plebis_collaborations', 'plebis_verification')
    end

    it 'returns empty array for engine without dependencies' do
      allow(described_class).to receive(:info).and_return({})
      expect(described_class.dependencies_for('test')).to eq([])
    end

    it 'returns empty array for non-existent engine' do
      expect(described_class.dependencies_for('non_existent')).to eq([])
    end
  end

  describe '.can_enable?' do
    before do
      allow(EngineActivation).to receive(:enabled?).and_return(false)
    end

    context 'when all dependencies are met' do
      it 'returns true for engine with only User dependency' do
        allow(EngineActivation).to receive(:enabled?).with('User').and_return(true)
        expect(described_class.can_enable?('plebis_cms')).to be true
      end

      it 'returns true when dependent engines are enabled' do
        allow(EngineActivation).to receive(:enabled?).with('plebis_verification').and_return(true)
        allow(EngineActivation).to receive(:enabled?).with('User').and_return(true)
        expect(described_class.can_enable?('plebis_voting')).to be true
      end
    end

    context 'when dependencies are not met' do
      it 'returns false when required engine is not enabled' do
        allow(EngineActivation).to receive(:enabled?).with('plebis_verification').and_return(false)
        expect(described_class.can_enable?('plebis_voting')).to be false
      end

      it 'returns false when multiple dependencies are missing' do
        allow(EngineActivation).to receive(:enabled?).and_return(false)
        expect(described_class.can_enable?('plebis_militant')).to be false
      end
    end

    context 'when errors occur' do
      it 'returns false and logs error' do
        # Use plebis_voting which has plebis_verification as dependency (not just User)
        allow(EngineActivation).to receive(:enabled?).and_raise(StandardError.new('Test error'))
        allow(Rails.logger).to receive(:error).and_call_original
        result = described_class.can_enable?('plebis_voting')
        expect(result).to be false
        expect(Rails.logger).to have_received(:error).with(/Error checking if .* can be enabled/)
      end

      it 'handles missing EngineActivation gracefully' do
        # Use plebis_voting which has plebis_verification as dependency (not just User)
        allow(EngineActivation).to receive(:enabled?).and_raise(NameError.new('Test error'))
        allow(Rails.logger).to receive(:error).and_call_original
        result = described_class.can_enable?('plebis_voting')
        expect(result).to be false
        expect(Rails.logger).to have_received(:error)
      end
    end
  end

  describe '.default_config' do
    it 'returns default config for plebis_cms' do
      config = described_class.default_config('plebis_cms')
      expect(config).to have_key(:wordpress_api_enabled)
      expect(config).to have_key(:push_notifications_enabled)
    end

    it 'returns default config for plebis_collaborations' do
      config = described_class.default_config('plebis_collaborations')
      expect(config[:payment_gateway]).to eq('redsys')
      expect(config[:sepa_enabled]).to be true
      expect(config[:min_amount]).to eq(3)
    end

    it 'returns empty hash for engine without config' do
      config = described_class.default_config('plebis_participation')
      expect(config).to eq({})
    end

    it 'returns empty hash for non-existent engine' do
      expect(described_class.default_config('non_existent')).to eq({})
    end
  end

  describe '.exists?' do
    it 'returns true for existing engine' do
      expect(described_class.exists?('plebis_cms')).to be true
    end

    it 'returns true for all registered engines' do
      described_class.available_engines.each do |engine|
        expect(described_class.exists?(engine)).to be true
      end
    end

    it 'returns false for non-existent engine' do
      expect(described_class.exists?('non_existent')).to be false
    end

    it 'returns false for empty string' do
      expect(described_class.exists?('')).to be false
    end

    it 'returns false for nil' do
      expect(described_class.exists?(nil)).to be false
    end
  end

  describe '.dependents_of' do
    it 'returns engines that depend on plebis_verification' do
      dependents = described_class.dependents_of('plebis_verification')
      expect(dependents).to include('plebis_voting', 'plebis_militant')
    end

    it 'returns engines that depend on plebis_collaborations' do
      dependents = described_class.dependents_of('plebis_collaborations')
      expect(dependents).to include('plebis_militant')
    end

    it 'returns engines that depend on User' do
      dependents = described_class.dependents_of('User')
      expect(dependents.length).to be_positive
    end

    it 'returns empty array for engine with no dependents' do
      dependents = described_class.dependents_of('plebis_cms')
      expect(dependents).to be_an(Array)
    end

    it 'returns empty array for non-existent engine' do
      dependents = described_class.dependents_of('non_existent')
      expect(dependents).to eq([])
    end

    it 'handles nil dependencies gracefully' do
      allow(described_class).to receive(:info).and_return({ dependencies: nil })
      expect { described_class.dependents_of('test') }.not_to raise_error
    end
  end

  describe '.engines_by_status' do
    context 'when database is available' do
      before do
        # Clean up first to avoid test pollution
        EngineActivation.where(engine_name: %w[plebis_cms plebis_proposals plebis_voting]).destroy_all
        # Create actual engine activation records
        EngineActivation.find_or_create_by!(engine_name: 'plebis_cms', enabled: true)
        EngineActivation.find_or_create_by!(engine_name: 'plebis_proposals', enabled: true)
        EngineActivation.find_or_create_by!(engine_name: 'plebis_voting', enabled: false)
      end

      after do
        # Clean up to prevent test pollution with other specs
        EngineActivation.where(engine_name: %w[plebis_cms plebis_proposals plebis_voting]).destroy_all
      end

      it 'returns hash with enabled and disabled keys' do
        result = described_class.engines_by_status
        expect(result).to have_key(:enabled)
        expect(result).to have_key(:disabled)
      end

      it 'returns enabled engines' do
        result = described_class.engines_by_status
        expect(result[:enabled]).to include('plebis_cms', 'plebis_proposals')
      end

      it 'returns disabled engines' do
        result = described_class.engines_by_status
        expect(result[:disabled]).to include('plebis_voting')
      end
    end

    context 'when database is unavailable' do
      before do
        allow(EngineActivation).to receive(:where).and_raise(StandardError.new('Database error'))
      end

      it 'returns empty arrays on error' do
        allow(Rails.logger).to receive(:error).and_call_original
        result = described_class.engines_by_status
        expect(result[:enabled]).to eq([])
        expect(result[:disabled]).to eq([])
        expect(Rails.logger).to have_received(:error).with(/Error getting engines by status/)
      end

      it 'does not raise error' do
        allow(Rails.logger).to receive(:error).and_call_original
        expect { described_class.engines_by_status }.not_to raise_error
      end
    end
  end

  describe 'ENGINES constant' do
    it 'is frozen' do
      expect(described_class::ENGINES).to be_frozen
    end

    it 'contains valid engine definitions' do
      described_class::ENGINES.each do |_name, metadata|
        expect(metadata).to have_key(:name)
        expect(metadata).to have_key(:description)
        expect(metadata).to have_key(:version)
        expect(metadata).to have_key(:models)
        expect(metadata).to have_key(:controllers)
        expect(metadata).to have_key(:dependencies)
        expect(metadata).to have_key(:default_config)
      end
    end

    it 'has string keys' do
      expect(described_class::ENGINES.keys).to all(be_a(String))
    end
  end

  describe 'engine metadata completeness' do
    it 'all engines have required metadata fields' do
      described_class.available_engines.each do |engine_name|
        info = described_class.info(engine_name)
        expect(info[:name]).not_to be_nil
        expect(info[:description]).not_to be_nil
        expect(info[:version]).not_to be_nil
        expect(info[:models]).to be_an(Array)
        expect(info[:controllers]).to be_an(Array)
        expect(info[:dependencies]).to be_an(Array)
        expect(info[:default_config]).to be_a(Hash)
      end
    end
  end
end
