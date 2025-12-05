require 'json'

if File.exist?('coverage/.resultset.json')
  data = JSON.parse(File.read('coverage/.resultset.json'))
  coverage = data.dig('RSpec', 'coverage')

  files = coverage.keys.select { |f| f.include?('app/') && !f.include?('spec/') }.map do |f|
    lines = coverage[f]['lines']
    total = lines.compact.size
    covered = lines.compact.count { |c| c > 0 }
    pct = total > 0 ? (covered.to_f / total * 100).round(2) : 0
    [f, pct, total, covered]
  end.select { |f, pct, _, _| pct >= 60 && pct < 80 }.sort_by { |_, pct| pct }

  files.each do |f, pct, total, covered|
    puts "#{pct}% (#{covered}/#{total}) - #{f}"
  end
else
  puts "No coverage file found"
end
