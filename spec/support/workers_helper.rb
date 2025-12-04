# frozen_string_literal: true

# Helper to load workers for specs
# Workers and lib files aren't autoloaded by Zeitwerk in test environment

# Silence Zeitwerk expectations for lib files that don't define constants
module Zeitwerk
  class Loader
    alias_method :original_on_file_autoloaded, :on_file_autoloaded if method_defined?(:on_file_autoloaded)

    def on_file_autoloaded(file, _object, _is_dir)
      # Skip validation for lib files
      return if file.to_s.include?('/lib/plebisbrand')

      original_on_file_autoloaded(file, _object, _is_dir) if respond_to?(:original_on_file_autoloaded)
    end
  end
end

# Load lib files (define functions/classes)
unless defined?(export_data)
  load Rails.root.join('lib/plebisbrand_export.rb')
end

unless defined?(PlebisBrandImport)
  load Rails.root.join('lib/plebisbrand_import.rb')
end

# Load worker classes
[
  'plebisbrand_collaboration_worker',
  'plebisbrand_import_worker',
  'plebisbrand_report_worker'
].each do |worker_file|
  worker_class = worker_file.camelize.constantize rescue nil
  unless worker_class
    load Rails.root.join("app/workers/#{worker_file}.rb")
  end
end
