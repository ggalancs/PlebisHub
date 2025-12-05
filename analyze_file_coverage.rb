require 'json'

if ARGV.length < 1
  puts "Usage: ruby analyze_file_coverage.rb <file_path>"
  exit 1
end

file_path = ARGV[0]

if File.exist?('coverage/.resultset.json')
  data = JSON.parse(File.read('coverage/.resultset.json'))
  coverage = data.dig('RSpec', 'coverage')

  # Find the full path in coverage
  matching_paths = coverage.keys.select { |k| k.include?(file_path) }

  if matching_paths.empty?
    puts "No coverage data found for: #{file_path}"
    puts "\nSimilar files:"
    coverage.keys.select { |k| k.include?('app/') }.sort.each do |k|
      puts k if k.downcase.include?(File.basename(file_path, '.rb').downcase)
    end
    exit 1
  end

  matching_paths.each do |full_path|
    lines = coverage[full_path]['lines']

    puts "Coverage for: #{full_path}"
    puts "=" * 80

    # Read the actual file
    if File.exist?(full_path)
      source_lines = File.readlines(full_path)

      uncovered_lines = []
      lines.each_with_index do |count, idx|
        line_num = idx + 1
        if count == 0 && source_lines[idx]
          line_content = source_lines[idx].strip
          # Skip empty lines, comments, and certain keywords
          next if line_content.empty?
          next if line_content.start_with?('#')
          next if ['end', 'else', 'elsif', 'when', 'rescue', 'ensure', 'private', 'public', 'protected'].include?(line_content)

          uncovered_lines << [line_num, source_lines[idx].chomp]
        end
      end

      total = lines.compact.size
      covered = lines.compact.count { |c| c > 0 }
      pct = total > 0 ? (covered.to_f / total * 100).round(2) : 0

      puts "Total executable lines: #{total}"
      puts "Covered lines: #{covered}"
      puts "Coverage: #{pct}%"
      puts "\nUncovered lines (#{uncovered_lines.size}):"
      puts "-" * 80

      uncovered_lines.each do |line_num, content|
        puts "Line #{line_num}: #{content}"
      end
    else
      puts "Source file not found: #{full_path}"
    end

    puts "\n"
  end
else
  puts "No coverage file found at coverage/.resultset.json"
end
