# frozen_string_literal: true

require 'rails_helper'
require 'generators/plebis/engine/engine_generator'

RSpec.describe Plebis::Generators::EngineGenerator, type: :generator do
  include FileUtils

  let(:destination_root) { File.expand_path('../../../../../tmp/generator_test', __dir__) }

  before(:each) do
    rm_rf(destination_root) if File.exist?(destination_root)
    mkdir_p(destination_root)
  end

  after(:each) do
    rm_rf(destination_root) if File.exist?(destination_root)
  end

  def run_generator(args = [], options = {})
    silence_stream(STDOUT) do
      Plebis::Generators::EngineGenerator.start(args, { destination_root: destination_root }.merge(options))
    end
  rescue Thor::Error => e
    raise e
  rescue SystemExit
    # Generator may exit successfully
  end

  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen(File::NULL)
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
    old_stream.close
  end

  describe '#validate_engine_name' do
    context 'with valid engine name' do
      it 'accepts lowercase names' do
        expect { run_generator %w[cms] }.not_to raise_error
      end

      it 'accepts names with underscores' do
        expect { run_generator %w[my_engine] }.not_to raise_error
      end

      it 'accepts names with numbers' do
        expect { run_generator %w[cms2] }.not_to raise_error
      end
    end

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
    end

    context 'with invalid length' do
      it 'rejects names shorter than 2 characters' do
        expect { run_generator %w[c] }.to raise_error(Thor::Error, /too short/)
      end

      it 'rejects names longer than 30 characters' do
        long_name = 'a' * 31
        expect { run_generator [long_name] }.to raise_error(Thor::Error, /too long/)
      end

      it 'accepts 2 character names' do
        expect { run_generator %w[cm] }.not_to raise_error
      end

      it 'accepts 30 character names' do
        name = 'a' * 30
        expect { run_generator [name] }.not_to raise_error
      end
    end

    context 'with reserved names' do
      %w[test spec app lib config db public tmp log].each do |reserved|
        it "rejects reserved name: #{reserved}" do
          expect { run_generator [reserved] }.to raise_error(Thor::Error, /Reserved name/)
        end
      end
    end

    context 'when engine already exists' do
      before do
        FileUtils.mkdir_p(File.join(destination_root, 'engines/plebis_cms'))
      end

      it 'raises error for existing engine' do
        expect { run_generator %w[cms] }.to raise_error(Thor::Error, /already exists/)
      end
    end
  end

  describe '#create_engine_structure' do
    before do
      run_generator %w[cms]
    end

    it 'creates base engine directory' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms'))
    end

    it 'creates app/controllers directory' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/app/controllers/plebis_cms'))
    end

    it 'creates app/models directory' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/app/models/plebis_cms'))
    end

    it 'creates app/views directory' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/app/views/plebis_cms'))
    end

    it 'creates app/admin directory' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/app/admin'))
    end

    it 'creates app/services directory' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/app/services/plebis_cms'))
    end

    it 'creates app/abilities directory' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/app/abilities/plebis_cms'))
    end

    it 'creates config directory' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/config'))
    end

    it 'creates db/migrate directory' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/db/migrate'))
    end

    it 'creates lib directory' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/lib/plebis_cms'))
    end

    it 'creates spec directories' do
      %w[factories models controllers requests support].each do |dir|
        expect(File).to exist(File.join(destination_root, "engines/plebis_cms/spec/#{dir}"))
      end
    end

    it 'creates engine.rb file' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/lib/plebis_cms/engine.rb'))
    end

    it 'creates main lib file' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/lib/plebis_cms.rb'))
    end

    it 'creates gemspec file' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/plebis_cms.gemspec'))
    end

    it 'creates routes file' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/config/routes.rb'))
    end

    it 'creates README file' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/README.md'))
    end

    it 'creates spec_helper file' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/spec/spec_helper.rb'))
    end

    it 'creates rails_helper file' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/spec/rails_helper.rb'))
    end

    it 'creates version file' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/lib/plebis_cms/version.rb'))
    end

    it 'creates ability file' do
      expect(File).to exist(File.join(destination_root, 'engines/plebis_cms/app/abilities/plebis_cms/ability.rb'))
    end
  end

  describe '#add_to_gemfile' do
    before do
      File.write(File.join(destination_root, 'Gemfile'), "source 'https://rubygems.org'\n")
      run_generator %w[cms]
    end

    it 'adds gem to Gemfile' do
      gemfile = File.read(File.join(destination_root, 'Gemfile'))
      expect(gemfile).to include("gem 'plebis_cms'")
    end

    it 'adds gem with correct path' do
      gemfile = File.read(File.join(destination_root, 'Gemfile'))
      expect(gemfile).to include("path: 'engines/plebis_cms'")
    end

    it 'adds comment for engine' do
      gemfile = File.read(File.join(destination_root, 'Gemfile'))
      expect(gemfile).to include('# Engine: Cms')
    end
  end
end
