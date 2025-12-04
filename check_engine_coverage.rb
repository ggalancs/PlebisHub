#!/usr/bin/env ruby
require 'json'

data = JSON.parse(File.read('/Users/gabriel/ggalancs/PlebisHub/coverage/.resultset.json'))
coverage = data['RSpec']['coverage']

# Get the actual PlebisCms models by their paths
paths = [
  '/Users/gabriel/ggalancs/PlebisHub/engines/plebis_cms/app/models/plebis_cms/category.rb',
  '/Users/gabriel/ggalancs/PlebisHub/engines/plebis_cms/app/models/plebis_cms/notice.rb',
  '/Users/gabriel/ggalancs/PlebisHub/engines/plebis_cms/app/models/plebis_cms/post.rb',
  '/Users/gabriel/ggalancs/PlebisHub/engines/plebis_cms/app/models/plebis_cms/notice_registrar.rb',
  '/Users/gabriel/ggalancs/PlebisHub/engines/plebis_cms/app/models/plebis_cms/page.rb'
]

total_covered = 0
total_lines = 0
models_count = 0
models_below_95 = []

puts "Coverage for PlebisCms engine models:"
puts "=" * 60

paths.each do |path|
  if coverage[path]
    data_hash = coverage[path]
    lines = data_hash['lines']
    executable = lines.reject(&:nil?)
    total = executable.size
    covered = executable.count { |n| n > 0 }
    pct = total > 0 ? (covered * 100.0 / total).round(2) : 0

    total_covered += covered
    total_lines += total
    models_count += 1

    status = pct >= 95.0 ? '✓' : '✗'
    puts "#{status} #{File.basename(path).ljust(25)} #{pct.to_s.rjust(6)}% (#{covered}/#{total} lines)"

    models_below_95 << File.basename(path) if pct < 95.0
  else
    puts "✗ #{File.basename(path).ljust(25)} NOT IN COVERAGE"
    models_below_95 << File.basename(path)
  end
end

puts "=" * 60
avg_coverage = total_lines > 0 ? (total_covered * 100.0 / total_lines).round(2) : 0
puts "Average Coverage: #{avg_coverage}%"
puts "Total: #{models_count} models, #{total_lines} lines, #{total_covered} covered"

if models_below_95.any?
  puts "\nModels with <95% coverage:"
  models_below_95.each { |m| puts "  - #{m}" }
end
