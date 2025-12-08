# frozen_string_literal: true

# Helper module for testing Rails generators
# Provides proper filesystem isolation and output silencing
module GeneratorHelpers
  extend ActiveSupport::Concern

  included do
    let(:destination_root) { File.expand_path('../../tmp/generator_test', __dir__) }
  end

  # Silences stdout and stderr during block execution
  # Compatible with Ruby 3.x (doesn't use deprecated silence_stream)
  def capture_output
    original_stdout = $stdout
    original_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new
    yield
    { stdout: $stdout.string, stderr: $stderr.string }
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end

  # Runs a generator with proper output silencing
  # @param generator_class [Class] The generator class to run
  # @param args [Array] Arguments to pass to the generator
  # @param options [Hash] Options to pass to the generator
  # @return [Hash] Output captured during execution
  def run_generator_silently(generator_class, args = [], options = {})
    merged_options = { destination_root: destination_root }.merge(options)

    capture_output do
      generator = generator_class.new(args, merged_options)
      generator.invoke_all
    end
  rescue SystemExit => e
    # Generator may exit, capture the exit status
    { exit_status: e.status }
  end

  # Sets up the temporary directory for generator tests
  def setup_generator_destination
    FileUtils.rm_rf(destination_root) if File.exist?(destination_root)
    FileUtils.mkdir_p(destination_root)
  end

  # Cleans up the temporary directory after generator tests
  def cleanup_generator_destination
    FileUtils.rm_rf(destination_root) if File.exist?(destination_root)
  end

  # Creates a minimal Gemfile in the destination for testing
  def create_test_gemfile
    File.write(File.join(destination_root, 'Gemfile'), "source 'https://rubygems.org'\n")
  end

  # Checks if a file exists relative to destination_root
  def destination_file_exists?(path)
    File.exist?(File.join(destination_root, path))
  end

  # Reads a file from destination_root
  def read_destination_file(path)
    File.read(File.join(destination_root, path))
  end
end

RSpec.configure do |config|
  config.include GeneratorHelpers, type: :generator
end
