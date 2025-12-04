#!/usr/bin/env ruby
require 'json'

data = JSON.parse(File.read('/Users/gabriel/ggalancs/PlebisHub/coverage/.resultset.json'))
coverage = data['RSpec']['coverage']

# Find models in engines/plebis_cms/app/models/
cms_models = coverage.select { |path, _| path.include?('engines/plebis_cms/app/models/plebis_cms') && path.end_with?('.rb') }

if cms_models.empty?
  puts "No plebis_cms engine models found in coverage."
  puts "Searching for all model files..."

  # Find models that match the CMS models we care about
  models = %w[category notice post notice_registrar page]

  models.each do |model_name|
    matches = coverage.select { |path, _| path.downcase.include?("/#{model_name}.rb") && path.include?('/models/') }

    if matches.any?
      matches.each do |path, data_hash|
        next if path.include?('/concerns/')  # Skip concerns
        lines = data_hash['lines']
        executable = lines.select { |n| !n.nil? }
        total = executable.size
        covered = executable.select { |n| n.to_i > 0 }.size
        pct = total > 0 ? (covered * 100.0 / total).round(2) : 0
        puts "#{File.basename(path)} (#{File.dirname(path)}): #{pct}% (#{covered}/#{total} lines)"
      end
    end
  end
else
  cms_models.each do |path, data_hash|
    lines = data_hash['lines']
    executable = lines.select { |n| !n.nil? }
    total = executable.size
    covered = executable.select { |n| n.to_i > 0 }.size
    pct = total > 0 ? (covered * 100.0 / total).round(2) : 0
    puts "#{File.basename(path)}: #{pct}% (#{covered}/#{total} lines)"
  end
end
