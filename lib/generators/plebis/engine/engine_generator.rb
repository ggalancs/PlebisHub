# frozen_string_literal: true

module Plebis
  module Generators
    # Engine Generator
    #
    # Generates a new Rails engine with the standard PlebisHub structure.
    #
    # Usage:
    #   rails generate plebis:engine cms
    #   rails generate plebis:engine voting
    #
    # This will create:
    #   - engines/plebis_[name]/ directory structure
    #   - Engine class with standard configuration
    #   - Gemspec file
    #   - Spec setup
    #   - README template
    #
    class EngineGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates', __dir__)

      def create_engine_structure
        @module_name = name.camelize
        @engine_name = "plebis_#{name}"
        @engine_path = "engines/#{@engine_name}"

        say "Creating engine: #{@engine_name}", :green
        say "Module name: #{@module_name}", :green

        # Create directory structure
        empty_directory "#{@engine_path}/app/controllers/#{@engine_name}"
        empty_directory "#{@engine_path}/app/models/#{@engine_name}"
        empty_directory "#{@engine_path}/app/views/#{@engine_name}"
        empty_directory "#{@engine_path}/app/admin"
        empty_directory "#{@engine_path}/app/services/#{@engine_name}"
        empty_directory "#{@engine_path}/app/abilities/#{@engine_name}"
        empty_directory "#{@engine_path}/config"
        empty_directory "#{@engine_path}/db/migrate"
        empty_directory "#{@engine_path}/lib/#{@engine_name}"
        empty_directory "#{@engine_path}/spec/factories"
        empty_directory "#{@engine_path}/spec/models"
        empty_directory "#{@engine_path}/spec/controllers"
        empty_directory "#{@engine_path}/spec/requests"
        empty_directory "#{@engine_path}/spec/support"

        # Create files from templates
        template "engine.rb.tt", "#{@engine_path}/lib/#{@engine_name}/engine.rb"
        template "lib.rb.tt", "#{@engine_path}/lib/#{@engine_name}.rb"
        template "gemspec.tt", "#{@engine_path}/#{@engine_name}.gemspec"
        template "routes.rb.tt", "#{@engine_path}/config/routes.rb"
        template "README.md.tt", "#{@engine_path}/README.md"
        template "spec_helper.rb.tt", "#{@engine_path}/spec/spec_helper.rb"
        template "rails_helper.rb.tt", "#{@engine_path}/spec/rails_helper.rb"
        template "version.rb.tt", "#{@engine_path}/lib/#{@engine_name}/version.rb"
        template "ability.rb.tt", "#{@engine_path}/app/abilities/#{@engine_name}/ability.rb"
      end

      def add_to_gemfile
        append_to_file "Gemfile", "\n# Engine: #{@module_name}\n"
        append_to_file "Gemfile", "gem '#{@engine_name}', path: 'engines/#{@engine_name}'\n"
        say "Added #{@engine_name} to Gemfile", :green
      end

      def show_next_steps
        say "\n" + "="*80, :green
        say "Engine '#{@engine_name}' created successfully!", :green
        say "="*80, :green
        say "\nNext steps:", :yellow
        say "  1. Run: bundle install", :yellow
        say "  2. Create engine activation record:", :yellow
        say "     EngineActivation.create!(", :yellow
        say "       engine_name: '#{@engine_name}',", :yellow
        say "       enabled: false,", :yellow
        say "       description: 'Description of your engine'", :yellow
        say "     )", :yellow
        say "  3. Implement your models, controllers, and views in:", :yellow
        say "     #{@engine_path}/", :yellow
        say "  4. Write tests in:", :yellow
        say "     #{@engine_path}/spec/", :yellow
        say "  5. Enable the engine:", :yellow
        say "     rake engines:enable[#{@engine_name}]", :yellow
        say "="*80, :green
      end
    end
  end
end
