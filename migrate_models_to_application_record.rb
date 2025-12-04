#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to migrate models from ActiveRecord::Base to ApplicationRecord
# Per Rails 5.0 upgrade guide

require 'pathname'

project_root = Pathname.new(__dir__)
models_dir = project_root.join('app/models')

puts 'Migrating models from ActiveRecord::Base to ApplicationRecord...'
puts

count = 0

Dir.glob(models_dir.join('*.rb')).each do |file|
  next if file.include?('application_record.rb')
  next if file.include?('concerns/')

  content = File.read(file, encoding: 'UTF-8')
  original_content = content.dup

  # Replace ActiveRecord::Base with ApplicationRecord
  next unless content.match?(/class\s+\w+\s*<\s*ActiveRecord::Base/)

  content.gsub!(/(<\s*)ActiveRecord::Base/, '\1ApplicationRecord')

  next unless content != original_content

  File.write(file, content)
  relative_path = Pathname.new(file).relative_path_from(project_root)
  puts "✓ Updated: #{relative_path}"
  count += 1
end

puts
puts "Updated #{count} model(s)"
