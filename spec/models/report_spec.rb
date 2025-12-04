# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report, type: :model do
  before do
    @report = Report.new
    @test_folder = Rails.root.join('tmp/test_report').to_s
    @raw_folder = "#{@test_folder}/raw"
    @rank_folder = "#{@test_folder}/rank"
    FileUtils.mkdir_p(@raw_folder)
    FileUtils.mkdir_p(@rank_folder)
  end

  after do
    FileUtils.rm_rf(@test_folder)
  end

  # PHASE 3 SECURITY REFACTORING TESTS

  # Test generate_rank_file method (replacement for shell command)
  describe '#generate_rank_file' do
    it 'processes file correctly' do
      # Create test data file
      File.open("#{@raw_folder}/1.dat", 'w:UTF-8') do |f|
        f.puts '001A Data1'
        f.puts '002A Data1'
        f.puts '003B Data2'
        f.puts '004A Data1'
        f.puts '005B Data2'
      end

      # Call the method
      @report.send(:generate_rank_file, @raw_folder, @rank_folder, 1, 3, 1, 0)

      # Verify rank file was created
      expect(File.exist?("#{@rank_folder}/1.dat")).to be_truthy

      # Verify content is sorted by count (descending)
      lines = File.readlines("#{@rank_folder}/1.dat", encoding: 'UTF-8')
      expect(lines.size).to eq(2)

      # First line should have count 3 (A Data1 appears 3 times)
      expect(lines[0]).to match(/^3 A Data1/)
      # Second line should have count 2 (B Data2 appears 2 times)
      expect(lines[1]).to match(/^2 B Data2/)
    end

    it 'handles empty file' do
      File.open("#{@raw_folder}/2.dat", 'w:UTF-8') { |f| }

      @report.send(:generate_rank_file, @raw_folder, @rank_folder, 2, 3, 1, 0)

      expect(File.exist?("#{@rank_folder}/2.dat")).to be_truthy
      expect(File.size("#{@rank_folder}/2.dat")).to eq(0)
    end

    it 'handles lines shorter than id_width' do
      File.open("#{@raw_folder}/3.dat", 'w:UTF-8') do |f|
        f.puts 'A' # Too short
        f.puts '001AB'
      end

      @report.send(:generate_rank_file, @raw_folder, @rank_folder, 3, 3, 1, 0)

      expect(File.exist?("#{@rank_folder}/3.dat")).to be_truthy
      lines = File.readlines("#{@rank_folder}/3.dat", encoding: 'UTF-8')
      expect(lines.size).to eq(1) # Only one valid line
    end

    # SECURITY: Path traversal prevention
    it 'rejects path traversal attempts' do
      malicious_path = '/tmp/../../etc'

      expect(Rails.logger).to receive(:error).with(/Invalid raw_file path/)

      @report.send(:generate_rank_file, malicious_path, @rank_folder, 1, 3, 1, 0)

      # Should not create any file outside Rails.root
      expect(File.exist?('/etc/1.dat')).to be_falsey
    end

    it 'handles file read errors gracefully' do
      # Non-existent file
      expect(Rails.logger).to receive(:error).with(/Invalid raw_file path/)

      @report.send(:generate_rank_file, @raw_folder, @rank_folder, 999, 3, 1, 0)

      # Should not raise exception
    end

    it 'handles write errors gracefully' do
      File.open("#{@raw_folder}/4.dat", 'w:UTF-8') { |f| f.puts '001Data' }

      # Make rank_folder read-only to trigger write error
      FileUtils.chmod(0o444, @rank_folder)

      # Should not raise exception even when write fails
      expect do
        @report.send(:generate_rank_file, @raw_folder, @rank_folder, 4, 3, 1, 0)
      end.not_to raise_error

      # Restore permissions
      FileUtils.chmod(0o755, @rank_folder)
    end
  end

  # Test grep_pattern_from_file method (replacement for shell command)
  describe '#grep_pattern_from_file' do
    it 'finds matching lines' do
      File.open("#{@raw_folder}/5.dat", 'w:UTF-8') do |f|
        f.puts '001GroupA data1'
        f.puts '002GroupB data2'
        f.puts '003GroupA data3'
        f.puts '004GroupA data4'
        f.puts '005GroupC data5'
      end

      results = @report.send(:grep_pattern_from_file, @raw_folder, 5, 3, '', 'GroupA', 10)

      expect(results.size).to eq(3)
      expect(results[0]).to include('001GroupA data1')
      expect(results[1]).to include('003GroupA data3')
      expect(results[2]).to include('004GroupA data4')
    end

    it 'respects max_lines limit' do
      File.open("#{@raw_folder}/6.dat", 'w:UTF-8') do |f|
        5.times { |i| f.puts "00#{i}TestX data#{i}" }
      end

      results = @report.send(:grep_pattern_from_file, @raw_folder, 6, 3, '', 'TestX', 2)

      expect(results.size).to eq(2) # Should stop at max_lines
    end

    it 'handles no matches' do
      File.open("#{@raw_folder}/7.dat", 'w:UTF-8') do |f|
        f.puts '001GroupA data1'
        f.puts '002GroupB data2'
      end

      results = @report.send(:grep_pattern_from_file, @raw_folder, 7, 3, '', 'GroupZ', 10)

      expect(results.size).to eq(0)
    end

    it 'handles main_group_name and group_name' do
      File.open("#{@raw_folder}/8.dat", 'w:UTF-8') do |f|
        f.puts '001MainX GroupY data1'
        f.puts '002MainX GroupZ data2'
        f.puts '003MainY GroupY data3'
      end

      results = @report.send(:grep_pattern_from_file, @raw_folder, 8, 3, 'MainX ', 'GroupY', 10)

      expect(results.size).to eq(1)
      expect(results[0]).to include('001MainX GroupY data1')
    end

    # SECURITY: Path traversal prevention
    it 'rejects path traversal attempts' do
      malicious_path = '/tmp/../../etc'

      expect(Rails.logger).to receive(:error).with(/Invalid raw_file path/)

      results = @report.send(:grep_pattern_from_file, malicious_path, 1, 3, '', 'test', 10)

      expect(results).to eq([])
    end

    it 'handles file read errors gracefully' do
      # Non-existent file
      expect(Rails.logger).to receive(:error).with(/Invalid raw_file path/)

      results = @report.send(:grep_pattern_from_file, @raw_folder, 999, 3, '', 'test', 10)

      expect(results).to eq([])
    end

    it 'handles empty file' do
      File.open("#{@raw_folder}/9.dat", 'w:UTF-8') { |f| }

      results = @report.send(:grep_pattern_from_file, @raw_folder, 9, 3, '', 'test', 10)

      expect(results.size).to eq(0)
    end
  end

  # Integration test: verify both methods work together
  describe 'integration' do
    it 'generate_rank_file and grep_pattern_from_file work together' do
      # Create realistic test data
      File.open("#{@raw_folder}/10.dat", 'w:UTF-8') do |f|
        f.puts '001Spain Madrid Some data here'
        f.puts '002Spain Barcelona Other data'
        f.puts '003Spain Madrid More data'
        f.puts '004France Paris French data'
        f.puts '005Spain Madrid Yet more'
      end

      # Generate rank file
      @report.send(:generate_rank_file, @raw_folder, @rank_folder, 10, 3, 6, 6)

      # Verify rank file
      expect(File.exist?("#{@rank_folder}/10.dat")).to be_truthy
      rank_lines = File.readlines("#{@rank_folder}/10.dat", encoding: 'UTF-8')

      # Should have grouped by country+city (first 12 chars after id)
      # Spain Madrid: 3 occurrences
      # Spain Barcelona: 1 occurrence
      # France Paris: 1 occurrence
      expect(rank_lines.any? { |line| line.start_with?('3 ') }).to be_truthy

      # Grep for Spain Madrid entries
      results = @report.send(:grep_pattern_from_file, @raw_folder, 10, 3, 'Spain ', 'Madrid', 10)

      expect(results.size).to eq(3)
      results.each do |line|
        expect(line).to include('Spain Madrid')
      end
    end
  end

  # Test serialize_relation_query class method
  describe '.serialize_relation_query' do
    it 'removes LIMIT and OFFSET' do
      sql = 'SELECT * FROM users WHERE active = true LIMIT 100 OFFSET 50'
      result = Report.serialize_relation_query(double(to_sql: sql))

      expect(result).not_to include('LIMIT')
      expect(result).not_to include('OFFSET')
      expect(result).to include('SELECT * FROM users WHERE active = true')
    end

    it 'handles query without LIMIT or OFFSET' do
      sql = 'SELECT * FROM users WHERE active = true'
      result = Report.serialize_relation_query(double(to_sql: sql))

      expect(result).to eq('SELECT * FROM users WHERE active = true')
    end
  end
end
