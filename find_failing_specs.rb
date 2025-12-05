#!/usr/bin/env ruby

require 'json'

# Get all spec files
spec_files = Dir.glob('spec/**/*_spec.rb')

failures = []
spec_files.each do |spec_file|
  puts "Testing: #{spec_file}"
  result = `bundle exec rspec #{spec_file} --format json 2>&1`

  begin
    json = JSON.parse(result.lines.last)
    failed_count = json['summary']['failure_count']

    if failed_count > 0
      failures << {
        file: spec_file,
        failed_count: failed_count,
        examples: json['examples'].select { |e| e['status'] == 'failed' }.map { |e| e['full_description'] }
      }
    end
  rescue JSON::ParserError
    # If we can't parse JSON, it's likely a load error
    if result.include?('Error') || result.include?('error')
      failures << {
        file: spec_file,
        failed_count: 'ERROR',
        error: result.lines.grep(/Error|error/).first(5)
      }
    end
  end
end

puts "\n\n=== SUMMARY OF FAILURES ==="
failures.each do |f|
  puts "\n#{f[:file]}: #{f[:failed_count]} failures"
  if f[:examples]
    f[:examples].each { |ex| puts "  - #{ex}" }
  elsif f[:error]
    f[:error].each { |err| puts "  #{err}" }
  end
end

puts "\n\nTotal files with failures: #{failures.count}"
