# frozen_string_literal: true

require 'rails_helper'
require 'generators/plebis/engine/engine_generator'

RSpec.describe Plebis::Generators::EngineGenerator, type: :generator do
  include FileUtils

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

      it 'shows proper error message for invalid format' do
        generator = described_class.new(%w[Invalid_Name], destination_root: destination_root)
        expect do
          # Capture output to suppress messages
          capture_output { generator.validate_engine_name }
        end.to raise_error(Thor::Error, /Invalid engine name/)
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

      it 'shows proper error for short names' do
        generator = described_class.new(%w[x], destination_root: destination_root)
        expect do
          capture_output { generator.validate_engine_name }
        end.to raise_error(Thor::Error, /too short/)
      end

      it 'shows proper error for long names' do
        generator = described_class.new(['a' * 31], destination_root: destination_root)
        expect do
          capture_output { generator.validate_engine_name }
        end.to raise_error(Thor::Error, /too long/)
      end
    end

    context 'with reserved names' do
      %w[test spec app lib config db public tmp log].each do |reserved|
        it "rejects reserved name: #{reserved}" do
          expect { run_generator [reserved] }.to raise_error(Thor::Error, /Reserved name/)
        end
      end

      it 'shows proper error for reserved names' do
        generator = described_class.new(%w[test], destination_root: destination_root)
        expect do
          capture_output { generator.validate_engine_name }
        end.to raise_error(Thor::Error, /Reserved name/)
      end
    end

    context 'when engine already exists in project' do
      # plebis_cms exists in the real project
      it 'raises error for existing engine' do
        expect { run_generator %w[cms] }.to raise_error(Thor::Error, /already exists/)
      end
    end

    context 'with valid name' do
      it 'accepts lowercase alphanumeric with underscores' do
        # This will fail at next step (existing engine), but passes validation
        generator = described_class.new(%w[my_cool_engine], destination_root: destination_root)
        # Mock the directory check to return false (engine doesn't exist)
        allow(File).to receive(:directory?).and_call_original
        allow(File).to receive(:directory?).with(/plebis_my_cool_engine/).and_return(false)

        # Should not raise validation error
        expect { capture_output { generator.validate_engine_name } }.not_to raise_error
      end

      it 'sets instance variables for engine name and module' do
        generator = described_class.new(%w[voting], destination_root: destination_root)
        allow(File).to receive(:directory?).and_call_original
        allow(File).to receive(:directory?).with(/plebis_voting/).and_return(false)

        capture_output { generator.validate_engine_name }

        expect(generator.instance_variable_get(:@module_name)).to eq('Voting')
        expect(generator.instance_variable_get(:@engine_name)).to eq('plebis_voting')
        expect(generator.instance_variable_get(:@engine_path)).to eq('engines/plebis_voting')
      end
    end
  end

  describe 'generator class' do
    it 'inherits from Rails::Generators::NamedBase' do
      expect(described_class.superclass).to eq(Rails::Generators::NamedBase)
    end

    it 'has templates directory' do
      expect(File.directory?(described_class.source_root)).to be true
    end

    it 'responds to generator methods' do
      expect(described_class.instance_methods).to include(:validate_engine_name)
      expect(described_class.instance_methods).to include(:create_engine_structure)
      expect(described_class.instance_methods).to include(:add_to_gemfile)
      expect(described_class.instance_methods).to include(:show_next_steps)
    end
  end

  describe 'template files' do
    let(:template_dir) { described_class.source_root }

    it 'has engine.rb template' do
      expect(File.exist?(File.join(template_dir, 'engine.rb.tt'))).to be true
    end

    it 'has lib.rb template' do
      expect(File.exist?(File.join(template_dir, 'lib.rb.tt'))).to be true
    end

    it 'has gemspec template' do
      expect(File.exist?(File.join(template_dir, 'gemspec.tt'))).to be true
    end

    it 'has routes.rb template' do
      expect(File.exist?(File.join(template_dir, 'routes.rb.tt'))).to be true
    end

    it 'has README.md template' do
      expect(File.exist?(File.join(template_dir, 'README.md.tt'))).to be true
    end

    it 'has spec_helper.rb template' do
      expect(File.exist?(File.join(template_dir, 'spec_helper.rb.tt'))).to be true
    end

    it 'has rails_helper.rb template' do
      expect(File.exist?(File.join(template_dir, 'rails_helper.rb.tt'))).to be true
    end

    it 'has version.rb template' do
      expect(File.exist?(File.join(template_dir, 'version.rb.tt'))).to be true
    end

    it 'has ability.rb template' do
      expect(File.exist?(File.join(template_dir, 'ability.rb.tt'))).to be true
    end

    it 'engine template contains valid ERB with module placeholder' do
      content = File.read(File.join(template_dir, 'engine.rb.tt'))
      expect(content).to include('module')
      expect(content).to include('Engine')
    end

    it 'gemspec template contains required gem metadata' do
      content = File.read(File.join(template_dir, 'gemspec.tt'))
      expect(content).to include('Gem::Specification')
      expect(content).to include('.name')
      expect(content).to include('.version')
    end

    it 'routes template contains engine routing setup' do
      content = File.read(File.join(template_dir, 'routes.rb.tt'))
      expect(content).to include('Engine.routes.draw')
    end

    it 'README template contains setup instructions' do
      content = File.read(File.join(template_dir, 'README.md.tt'))
      expect(content).to include('Installation')
    end

    it 'version template contains VERSION constant' do
      content = File.read(File.join(template_dir, 'version.rb.tt'))
      expect(content).to include('VERSION')
    end

    it 'ability template contains ability class definition' do
      content = File.read(File.join(template_dir, 'ability.rb.tt'))
      expect(content).to include('Ability')
    end
  end

  describe '#show_next_steps' do
    it 'outputs next steps instructions' do
      generator = described_class.new(%w[myengine], destination_root: destination_root)
      generator.instance_variable_set(:@engine_name, 'plebis_myengine')
      generator.instance_variable_set(:@engine_path, 'engines/plebis_myengine')

      output = capture_output { generator.show_next_steps }

      expect(output[:stdout]).to include('created successfully')
      expect(output[:stdout]).to include('bundle install')
      expect(output[:stdout]).to include('EngineActivation.create')
      expect(output[:stdout]).to include('plebis_myengine')
    end

    it 'includes all necessary setup instructions' do
      generator = described_class.new(%w[voting], destination_root: destination_root)
      generator.instance_variable_set(:@engine_name, 'plebis_voting')
      generator.instance_variable_set(:@engine_path, 'engines/plebis_voting')

      output = capture_output { generator.show_next_steps }

      expect(output[:stdout]).to include('Next steps')
      expect(output[:stdout]).to include('engines:enable')
      expect(output[:stdout]).to include('spec/')
    end

    it 'includes description placeholder in EngineActivation example' do
      generator = described_class.new(%w[analytics], destination_root: destination_root)
      generator.instance_variable_set(:@engine_name, 'plebis_analytics')
      generator.instance_variable_set(:@engine_path, 'engines/plebis_analytics')

      output = capture_output { generator.show_next_steps }

      expect(output[:stdout]).to include('description:')
      expect(output[:stdout]).to include('Description of your engine')
    end
  end

  # NOTE: #create_engine_structure and #add_to_gemfile are not tested here as they
  # require complex filesystem isolation and would modify real project files.
  # These methods are tested via manual integration testing:
  #   rails generate plebis:engine test_engine --dry-run
  #
  # The validation and template tests above cover the critical logic paths.
  # Coverage for create_engine_structure (lines 63-93) and add_to_gemfile (lines 95-99)
  # is intentionally excluded from automated tests to avoid filesystem side effects.
end
