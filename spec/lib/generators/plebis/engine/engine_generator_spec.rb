# frozen_string_literal: true

require 'rails_helper'
require 'generators/plebis/engine/engine_generator'

RSpec.describe Plebis::Generators::EngineGenerator, type: :generator do
  include FileUtils

  # NOTE: Full generator tests require Rails::Generators::TestCase which provides
  # proper filesystem isolation. These specs focus on validation logic and
  # generator behavior that can be tested without full isolation.

  before(:each) do
    setup_generator_destination
  end

  after(:each) do
    cleanup_generator_destination
  end

  def run_generator(args = [], options = {})
    run_generator_silently(described_class, args, options)
  end

  describe '#validate_engine_name' do
    context 'with invalid format' do
      it 'rejects names starting with number' do
        expect { run_generator %w[2cms] }.to raise_error(Thor::Error, /Invalid engine name/)
      end

      it 'rejects names with uppercase' do
        expect { run_generator %w[Cms] }.to raise_error(Thor::Error, /Invalid engine name/)
      end

      it 'rejects names with hyphens' do
        expect { run_generator %w[my-engine] }.to raise_error(Thor::Error, /Invalid engine name/)
      end

      it 'rejects names with spaces' do
        expect { run_generator(['my engine']) }.to raise_error(Thor::Error, /Invalid engine name/)
      end

      it 'rejects names with special characters' do
        expect { run_generator %w[my@engine] }.to raise_error(Thor::Error, /Invalid engine name/)
      end
    end

    context 'with invalid length' do
      it 'rejects names shorter than 2 characters' do
        expect { run_generator %w[c] }.to raise_error(Thor::Error, /too short/)
      end

      it 'rejects names longer than 30 characters' do
        long_name = 'a' * 31
        expect { run_generator [long_name] }.to raise_error(Thor::Error, /too long/)
      end
    end

    context 'with reserved names' do
      %w[test spec app lib config db public tmp log].each do |reserved|
        it "rejects reserved name: #{reserved}" do
          expect { run_generator [reserved] }.to raise_error(Thor::Error, /Reserved name/)
        end
      end
    end

    context 'when engine already exists in project' do
      # This tests the existing engine check works correctly
      # plebis_cms exists in the real project
      it 'raises error for existing engine' do
        expect { run_generator %w[cms] }.to raise_error(Thor::Error, /already exists/)
      end
    end
  end

  describe 'generator class' do
    it 'inherits from Rails::Generators::NamedBase' do
      expect(described_class.superclass).to eq(Rails::Generators::NamedBase)
    end

    it 'has templates directory' do
      File.expand_path('templates', described_class.source_root)
      expect(File.directory?(described_class.source_root)).to be true
    end

    it 'responds to generator methods' do
      expect(described_class.instance_methods).to include(:validate_engine_name)
      expect(described_class.instance_methods).to include(:create_engine_structure)
      expect(described_class.instance_methods).to include(:add_to_gemfile)
      expect(described_class.instance_methods).to include(:show_next_steps)
    end
  end

  # File creation tests are skipped because Rails generators check Rails.root
  # for existing engines, not the custom destination_root.
  # To properly test file creation, use Rails::Generators::TestCase which provides
  # complete filesystem isolation through its prepare_destination method.
  describe '#create_engine_structure', skip: 'Requires Rails::Generators::TestCase for proper filesystem isolation' do
    it 'creates all engine directories and files'
  end

  describe '#add_to_gemfile', skip: 'Requires Rails::Generators::TestCase for proper filesystem isolation' do
    it 'modifies Gemfile correctly'
  end
end
