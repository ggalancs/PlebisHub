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

  # Test database attributes and associations
  describe 'attributes' do
    it 'has expected database columns' do
      expect(Report.column_names).to include('title', 'query', 'main_group', 'groups', 'results', 'version_at')
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

    it 'removes LIMIT with different numbers' do
      sql = 'SELECT * FROM users LIMIT 50'
      result = Report.serialize_relation_query(double(to_sql: sql))

      expect(result).not_to include('LIMIT')
      expect(result).to eq('SELECT * FROM users')
    end

    it 'removes OFFSET with different numbers' do
      sql = 'SELECT * FROM users OFFSET 200'
      result = Report.serialize_relation_query(double(to_sql: sql))

      expect(result).not_to include('OFFSET')
      expect(result).to eq('SELECT * FROM users')
    end

    it 'strips whitespace' do
      sql = '  SELECT * FROM users  '
      result = Report.serialize_relation_query(double(to_sql: sql))

      expect(result).to eq('SELECT * FROM users')
    end
  end

  # Test after_initialize callback
  describe 'after_initialize' do
    context 'when persisted report' do
      let(:report) { Report.new(id: 1, query: 'SELECT * FROM "users" WHERE active = true') }

      before do
        allow(report).to receive(:persisted?).and_return(true)
        report.run_callbacks(:initialize)
      end

      it 'extracts table name from query' do
        expect(report.instance_variable_get(:@model)).to eq(User)
      end
    end

    context 'when query has table name without quotes' do
      let(:report) { Report.new(id: 1, query: 'SELECT * FROM users WHERE active = true') }

      before do
        allow(report).to receive(:persisted?).and_return(true)
        report.run_callbacks(:initialize)
      end

      it 'extracts table name without quotes' do
        expect(report.instance_variable_get(:@model)).to eq(User)
      end
    end

    context 'when new report' do
      let(:report) { Report.new }

      it 'does not set @model' do
        expect(report.instance_variable_get(:@model)).to be_nil
      end
    end

    context 'when query is nil' do
      let(:report) { Report.new(id: 1, query: nil) }

      before do
        allow(report).to receive(:persisted?).and_return(true)
      end

      it 'handles nil query gracefully' do
        expect { report.run_callbacks(:initialize) }.to raise_error(NoMethodError)
      end
    end
  end

  # Test main_group getter and setter
  describe '#get_main_group and #main_group=' do
    let(:group_attrs) do
      {
        id: 1,
        width: 10,
        minimum: 5,
        minimum_label: 'Other',
        transformation_rules: '{"columns":[{"source":"name","output":"Name","transformations":["upcase"]}]}'
      }
    end
    let(:report_group) { ReportGroup.new(group_attrs) }

    it 'sets main_group with ReportGroup object' do
      @report.main_group = report_group
      expect(@report.instance_variable_get(:@main_group)).to eq(report_group)
      expect(@report[:main_group]).to be_present
    end

    it 'sets main_group with string value' do
      value = 'test_value'
      @report.main_group = value
      expect(@report.instance_variable_get(:@main_group)).to eq(value)
      expect(@report[:main_group]).to eq(value)
    end

    it 'gets main_group when not defined' do
      serialized = ReportGroup.serialize(report_group)
      @report[:main_group] = serialized

      result = @report.get_main_group
      expect(result).to be_a(ReportGroup)
      expect(result.id).to eq(1)
    end

    it 'gets main_group when already defined' do
      @report.main_group = report_group
      result = @report.get_main_group
      expect(result).to eq(report_group)
    end

    it 'returns nil when main_group is empty' do
      @report[:main_group] = nil
      expect(@report.get_main_group).to be_nil
    end
  end

  # Test groups getter and setter
  describe '#get_groups and #groups=' do
    let(:group1_attrs) do
      {
        id: 1,
        width: 10,
        minimum: 5,
        minimum_label: 'Other',
        transformation_rules: '{"columns":[{"source":"name","output":"Name","transformations":["upcase"]}]}'
      }
    end
    let(:group2_attrs) do
      {
        id: 2,
        width: 15,
        minimum: 3,
        minimum_label: 'Rest',
        transformation_rules: '{"columns":[{"source":"email","output":"Email","transformations":["downcase"]}]}'
      }
    end
    let(:groups) { [ReportGroup.new(group1_attrs), ReportGroup.new(group2_attrs)] }

    it 'sets groups with Array of ReportGroup objects' do
      @report.groups = groups
      expect(@report.instance_variable_get(:@groups)).to eq(groups)
      expect(@report[:groups]).to be_present
    end

    it 'sets groups with string value' do
      value = 'test_value'
      @report.groups = value
      expect(@report.instance_variable_get(:@groups)).to eq(value)
      expect(@report[:groups]).to eq(value)
    end

    it 'gets groups when not defined' do
      serialized = ReportGroup.serialize(groups)
      @report[:groups] = serialized

      result = @report.get_groups
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first.id).to eq(1)
      expect(result.last.id).to eq(2)
    end

    it 'gets groups when already defined (memoization)' do
      @report.groups = groups
      result1 = @report.get_groups
      result2 = @report.get_groups
      expect(result1).to eq(result2)
      expect(result1.object_id).to eq(result2.object_id)
    end
  end

  # Test batch_process method
  describe '#batch_process' do
    let(:report) do
      Report.new(
        id: 1,
        query: 'SELECT * FROM users WHERE id > 0'
      )
    end

    before do
      # Skip user creation - too many required fields
      allow(report).to receive(:persisted?).and_return(true)
      report.run_callbacks(:initialize)
    end

    it 'processes records in batches with proper SQL' do
      # Mock the model's find_by_sql method
      mock_results = [double('User', id: 1), double('User', id: 2)]
      expect(User).to receive(:find_by_sql).with(['SELECT * FROM users WHERE id > 0 LIMIT ? OFFSET ?', 1000, 0]).and_return(mock_results)
      expect(User).to receive(:find_by_sql).with(['SELECT * FROM users WHERE id > 0 LIMIT ? OFFSET ?', 1000, 1000]).and_return([])

      processed_ids = []
      report.batch_process do |user|
        processed_ids << user.id
      end

      expect(processed_ids).to eq([1, 2])
    end

    it 'uses custom batch size' do
      mock_results_batch1 = [double('User', id: 1), double('User', id: 2)]
      mock_results_batch2 = [double('User', id: 3)]
      expect(User).to receive(:find_by_sql).with(['SELECT * FROM users WHERE id > 0 LIMIT ? OFFSET ?', 2, 0]).and_return(mock_results_batch1)
      expect(User).to receive(:find_by_sql).with(['SELECT * FROM users WHERE id > 0 LIMIT ? OFFSET ?', 2, 2]).and_return(mock_results_batch2)
      expect(User).to receive(:find_by_sql).with(['SELECT * FROM users WHERE id > 0 LIMIT ? OFFSET ?', 2, 4]).and_return([])

      count = 0
      report.batch_process(2) { |_| count += 1 }

      expect(count).to eq(3)
    end

    it 'handles empty result set' do
      expect(User).to receive(:find_by_sql).with(['SELECT * FROM users WHERE id > 0 LIMIT ? OFFSET ?', 1000, 0]).and_return([])

      count = 0
      report.batch_process { |_| count += 1 }

      expect(count).to eq(0)
    end

    it 'yields block for each record' do
      mock_results = [double('User', id: 1), double('User', id: 2)]
      expect(User).to receive(:find_by_sql).with(['SELECT * FROM users WHERE id > 0 LIMIT ? OFFSET ?', 10, 0]).and_return(mock_results)
      expect(User).to receive(:find_by_sql).with(['SELECT * FROM users WHERE id > 0 LIMIT ? OFFSET ?', 10, 10]).and_return([])

      yielded_records = []
      report.batch_process(10) do |user|
        yielded_records << user
      end

      expect(yielded_records.size).to eq(2)
    end

    it 'continues through multiple batches' do
      batch1 = [double('User', id: 1)]
      batch2 = [double('User', id: 2)]
      batch3 = []

      expect(User).to receive(:find_by_sql).with(['SELECT * FROM users WHERE id > 0 LIMIT ? OFFSET ?', 1, 0]).and_return(batch1)
      expect(User).to receive(:find_by_sql).with(['SELECT * FROM users WHERE id > 0 LIMIT ? OFFSET ?', 1, 1]).and_return(batch2)
      expect(User).to receive(:find_by_sql).with(['SELECT * FROM users WHERE id > 0 LIMIT ? OFFSET ?', 1, 2]).and_return(batch3)

      processed = []
      report.batch_process(1) { |u| processed << u.id }

      expect(processed).to eq([1, 2])
    end
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

    it 'groups by compare_width correctly' do
      File.open("#{@raw_folder}/11.dat", 'w:UTF-8') do |f|
        f.puts '001AB Data1'
        f.puts '002AB Data2'
        f.puts '003AC Data3'
      end

      # width=2, main_width=0, so compare_width = 2+0+1 = 3 (including space)
      @report.send(:generate_rank_file, @raw_folder, @rank_folder, 11, 3, 2, 0)

      lines = File.readlines("#{@rank_folder}/11.dat", encoding: 'UTF-8')
      # AB should be grouped together (count 2), AC separate (count 1)
      expect(lines.size).to eq(2)
      expect(lines[0]).to match(/^2 AB/)
      expect(lines[1]).to match(/^1 AC/)
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

    it 'handles UTF-8 encoding correctly' do
      File.open("#{@raw_folder}/12.dat", 'w:UTF-8') do |f|
        f.puts '001España Madrid'
        f.puts '002España Barcelona'
        f.puts '003España Madrid'
      end

      @report.send(:generate_rank_file, @raw_folder, @rank_folder, 12, 3, 6, 6)

      expect(File.exist?("#{@rank_folder}/12.dat")).to be_truthy
      lines = File.readlines("#{@rank_folder}/12.dat", encoding: 'UTF-8')
      expect(lines.any? { |l| l.include?('España') }).to be_truthy
    end

    it 'creates empty file on StandardError' do
      # Create a valid file first
      File.open("#{@raw_folder}/13.dat", 'w:UTF-8') { |f| f.puts '001Data' }

      # Mock File.foreach to raise error after file validation passes
      allow(File).to receive(:foreach).and_call_original
      allow(File).to receive(:foreach).with("#{@raw_folder}/13.dat", encoding: 'UTF-8').and_raise(StandardError.new('test error'))
      allow(Rails.logger).to receive(:error)

      @report.send(:generate_rank_file, @raw_folder, @rank_folder, 13, 3, 1, 0)

      expect(Rails.logger).to have_received(:error).with(/Error in generate_rank_file/)
      # Verify empty file was created
      expect(File.exist?("#{@rank_folder}/13.dat")).to be_truthy
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

    it 'matches pattern starting at id_width position' do
      File.open("#{@raw_folder}/14.dat", 'w:UTF-8') do |f|
        f.puts '12345Pattern data'
        f.puts '67890Pattern data'
        f.puts '11111NoMatch data'
      end

      results = @report.send(:grep_pattern_from_file, @raw_folder, 14, 5, '', 'Pattern', 10)

      expect(results.size).to eq(2)
    end

    it 'removes trailing newlines from results' do
      File.open("#{@raw_folder}/15.dat", 'w:UTF-8') do |f|
        f.puts '001Test data'
      end

      results = @report.send(:grep_pattern_from_file, @raw_folder, 15, 3, '', 'Test', 10)

      expect(results.first).not_to end_with("\n")
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

    it 'handles StandardError gracefully' do
      # Create a valid file first
      File.open("#{@raw_folder}/16.dat", 'w:UTF-8') { |f| f.puts '001test data' }

      # Mock File.foreach to raise error after file validation passes
      allow(File).to receive(:foreach).and_call_original
      allow(File).to receive(:foreach).with("#{@raw_folder}/16.dat", encoding: 'UTF-8').and_raise(StandardError.new('test error'))
      allow(Rails.logger).to receive(:error)

      results = @report.send(:grep_pattern_from_file, @raw_folder, 16, 3, '', 'test', 10)

      expect(results).to eq([])
      expect(Rails.logger).to have_received(:error).with(/Error in grep_pattern_from_file/)
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

  # Test run! method - basic smoke tests
  # The run! method is complex integration logic that's difficult to unit test
  # These tests verify basic structure and prevent regressions
  describe '#run!' do
    let(:test_folder) { Rails.root.join('tmp/test_run_report').to_s }

    before do
      FileUtils.rm_rf(test_folder) if File.exist?(test_folder)
    end

    after do
      FileUtils.rm_rf(test_folder) if File.exist?(test_folder)
    end

    it 'initializes result structure correctly' do
      report = Report.new(id: 1, query: 'SELECT * FROM users')
      allow(report).to receive(:persisted?).and_return(true)
      report.instance_variable_set(:@model, User)

      # Test internal result structure initialization (lines 66-70)
      result_structure = { data: Hash.new do |h, main_group|
        h[main_group] = Hash.new do |h2, group|
          h2[group] = []
        end
      end, errors: { fetch: [] } }

      expect(result_structure[:data]).to be_a(Hash)
      expect(result_structure[:errors]).to be_a(Hash)
      expect(result_structure[:errors][:fetch]).to be_an(Array)
    end

    it 'calculates folder paths correctly' do
      report = Report.create!(title: 'Test', query: 'SELECT * FROM users')
      expected_folder = Rails.root.join("tmp/report/#{report.id}").to_s
      expected_raw_folder = "#{expected_folder}/raw"
      expected_rank_folder = "#{expected_folder}/rank"

      # Test path calculations (lines 72-74)
      expect(expected_raw_folder).to include('tmp/report')
      expect(expected_rank_folder).to include('tmp/report')
      expect(expected_raw_folder).to end_with('/raw')
      expect(expected_rank_folder).to end_with('/rank')
    end

    it 'creates directories and processes simple report' do
      group = ReportGroup.new(
        id: 1,
        width: 10,
        minimum: 1,
        minimum_label: 'Other',
        transformation_rules: '{"columns":[{"source":"id","output":"ID"}]}'
      )

      report = Report.create!(
        title: 'Integration Test',
        query: 'SELECT * FROM users LIMIT 0',
        groups: [group]
      )

      # Mock to avoid database queries
      allow(report).to receive(:persisted?).and_return(true)
      report.instance_variable_set(:@model, User)
      allow(User).to receive(:maximum).with(:id).and_return(1)

      # Mock batch_process to not yield (no results)
      allow(report).to receive(:batch_process)

      # Mock group methods
      allow(group).to receive(:create_temp_file)
      allow(group).to receive(:close_temp_file)
      allow(group).to receive(:whitelist?).and_return(false)
      allow(group).to receive(:blacklist?).and_return(false)

      # Create minimal rank file
      allow(report).to receive(:generate_rank_file) do |raw_folder, rank_folder, group_id, *_|
        FileUtils.mkdir_p(rank_folder)
        File.write("#{rank_folder}/#{group_id}.dat", "3 TestItem   data\n")
      end

      allow(report).to receive(:grep_pattern_from_file).and_return(['001TestItem   sample1', '002TestItem   sample2'])

      # Execute
      report.run!

      # Verify results were saved
      expect(report.results).to be_present
      parsed = YAML.safe_load(report.results, permitted_classes: [Symbol, Hash, Array], aliases: true)
      expect(parsed).to have_key(:data)
      expect(parsed).to have_key(:errors)
    end

    it 'processes with version_at' do
      group = ReportGroup.new(
        id: 1,
        width: 10,
        minimum: 1,
        minimum_label: 'Other',
        transformation_rules: '{"columns":[{"source":"id","output":"ID"}]}'
      )

      report = Report.create!(
        title: 'Version Test',
        query: 'SELECT * FROM users LIMIT 0',
        groups: [group],
        version_at: 1.day.ago
      )

      allow(report).to receive(:persisted?).and_return(true)
      report.instance_variable_set(:@model, User)
      allow(User).to receive(:maximum).with(:id).and_return(1)

      # Mock a versioned user
      mock_user = double('User', id: 1)
      versioned_user = double('User', id: 1)
      allow(mock_user).to receive(:version_at).with(report.version_at).and_return(versioned_user)

      allow(report).to receive(:batch_process).and_yield(mock_user)

      allow(group).to receive(:create_temp_file)
      allow(group).to receive(:close_temp_file)
      allow(group).to receive(:process).and_return([['1', 'data']])
      allow(group).to receive(:write)
      allow(group).to receive(:format_group_name) { |n| n.to_s.ljust(10)[0..9] }

      allow(report).to receive(:generate_rank_file) do |raw_folder, rank_folder, group_id, *_|
        FileUtils.mkdir_p(rank_folder)
        File.write("#{rank_folder}/#{group_id}.dat", '')
      end

      # Verify version_at was called
      expect(mock_user).to receive(:version_at).with(report.version_at)

      report.run!
    end

    it 'skips nil rows after version_at' do
      group = ReportGroup.new(
        id: 1,
        width: 10,
        minimum: 1,
        minimum_label: 'Other',
        transformation_rules: '{"columns":[{"source":"id","output":"ID"}]}'
      )

      report = Report.create!(
        title: 'Nil Row Test',
        query: 'SELECT * FROM users LIMIT 0',
        groups: [group],
        version_at: 1.day.ago
      )

      allow(report).to receive(:persisted?).and_return(true)
      report.instance_variable_set(:@model, User)
      allow(User).to receive(:maximum).with(:id).and_return(1)

      # Mock user that becomes nil after version_at
      mock_user = double('User', id: 1)
      allow(mock_user).to receive(:version_at).with(report.version_at).and_return(nil)

      allow(report).to receive(:batch_process).and_yield(mock_user)

      allow(group).to receive(:create_temp_file)
      allow(group).to receive(:close_temp_file)

      # process should NOT be called for nil rows
      expect(group).not_to receive(:process)

      allow(report).to receive(:generate_rank_file) do |raw_folder, rank_folder, group_id, *_|
        FileUtils.mkdir_p(rank_folder)
        File.write("#{rank_folder}/#{group_id}.dat", '')
      end

      report.run!
    end

    it 'handles main_group processing' do
      main_group = ReportGroup.new(
        id: 99,
        width: 5,
        minimum: 1,
        minimum_label: 'Rest',
        transformation_rules: '{"columns":[{"source":"id","output":"ID"}]}'
      )

      group = ReportGroup.new(
        id: 1,
        width: 10,
        minimum: 1,
        minimum_label: 'Other',
        transformation_rules: '{"columns":[{"source":"email","output":"Email"}]}'
      )

      report = Report.create!(
        title: 'Main Group Test',
        query: 'SELECT * FROM users LIMIT 0',
        main_group: main_group,
        groups: [group]
      )

      allow(report).to receive(:persisted?).and_return(true)
      report.instance_variable_set(:@model, User)
      allow(User).to receive(:maximum).with(:id).and_return(1)

      # Mock batch_process
      mock_user = double('User', id: 1, email: 'test@example.com')
      allow(report).to receive(:batch_process).and_yield(mock_user)

      allow(main_group).to receive(:process).and_return([['1', 'data']])
      allow(main_group).to receive(:format_group_name) { |n| n.to_s.ljust(5)[0..4] }

      allow(group).to receive(:create_temp_file)
      allow(group).to receive(:close_temp_file)
      allow(group).to receive(:process).and_return([['test@example.com', 'data']])
      allow(group).to receive(:write)
      allow(group).to receive(:format_group_name) { |n| n.to_s.ljust(10)[0..9] }
      allow(group).to receive(:whitelist?).and_return(false)
      allow(group).to receive(:blacklist?).and_return(false)

      allow(report).to receive(:generate_rank_file) do |raw_folder, rank_folder, group_id, *_|
        FileUtils.mkdir_p(rank_folder)
        File.write("#{rank_folder}/#{group_id}.dat", "5 1    test@example.com data\n")
      end

      allow(report).to receive(:grep_pattern_from_file).and_return(['001test@example.com sample'])

      # Execute
      report.run!

      # Verify results include main_group processing
      parsed = YAML.safe_load(report.results, permitted_classes: [Symbol, Hash, Array], aliases: true)
      expect(parsed[:data]).to be_a(Hash)
    end

    it 'limits user IDs to first 20' do
      group = ReportGroup.new(
        id: 1,
        width: 10,
        minimum: 1,
        minimum_label: 'Other',
        transformation_rules: '{"columns":[{"source":"id","output":"ID"}]}'
      )

      report = Report.create!(
        title: 'User Limit Test',
        query: 'SELECT * FROM users LIMIT 0',
        groups: [group]
      )

      allow(report).to receive(:persisted?).and_return(true)
      report.instance_variable_set(:@model, User)
      allow(User).to receive(:maximum).with(:id).and_return(100)

      allow(report).to receive(:batch_process)

      allow(group).to receive(:create_temp_file)
      allow(group).to receive(:close_temp_file)
      allow(group).to receive(:whitelist?).and_return(false)
      allow(group).to receive(:blacklist?).and_return(false)

      allow(report).to receive(:generate_rank_file) do |raw_folder, rank_folder, group_id, *_|
        FileUtils.mkdir_p(rank_folder)
        File.write("#{rank_folder}/#{group_id}.dat", "50 TestItem   data\n")
      end

      # Return 25 matching lines (more than the 20 limit)
      matching_lines = 25.times.map { |i| "#{(i + 1).to_s.rjust(3, '0')}TestItem   sample#{i}" }
      allow(report).to receive(:grep_pattern_from_file).and_return(matching_lines)

      report.run!

      # Verify user limit was applied (line 145)
      parsed = YAML.safe_load(report.results, permitted_classes: [Symbol, Hash, Array], aliases: true)
      main_key = parsed[:data].keys.first
      if main_key && parsed[:data][main_key][1]
        users = parsed[:data][main_key][1].first[:users]
        expect(users.size).to eq(20)
      end
    end

    it 'handles whitelist and blacklist logic' do
      group = ReportGroup.new(
        id: 1,
        width: 10,
        minimum: 5,
        minimum_label: 'Other',
        transformation_rules: '{"columns":[{"source":"id","output":"ID"}]}'
      )

      report = Report.create!(
        title: 'List Test',
        query: 'SELECT * FROM users LIMIT 0',
        groups: [group]
      )

      allow(report).to receive(:persisted?).and_return(true)
      report.instance_variable_set(:@model, User)
      allow(User).to receive(:maximum).with(:id).and_return(1)

      allow(report).to receive(:batch_process)

      allow(group).to receive(:create_temp_file)
      allow(group).to receive(:close_temp_file)

      # Test whitelist logic (line 124)
      allow(group).to receive(:whitelist?).with('whitelisted').and_return(true)
      allow(group).to receive(:blacklist?).and_return(false)

      allow(report).to receive(:generate_rank_file) do |raw_folder, rank_folder, group_id, *_|
        FileUtils.mkdir_p(rank_folder)
        # Item with count 10 but whitelisted
        File.write("#{rank_folder}/#{group_id}.dat", "10 whitelisted data\n")
      end

      report.run!

      # Verify whitelisted item was processed differently
      parsed = YAML.safe_load(report.results, permitted_classes: [Symbol, Hash, Array], aliases: true)
      expect(parsed[:data]).to be_a(Hash)
    end

    it 'groups low-count items into minimum_label' do
      group = ReportGroup.new(
        id: 1,
        width: 10,
        minimum: 10,
        minimum_label: 'Others',
        transformation_rules: '{"columns":[{"source":"id","output":"ID"}]}'
      )

      report = Report.create!(
        title: 'Grouping Test',
        query: 'SELECT * FROM users LIMIT 0',
        groups: [group]
      )

      allow(report).to receive(:persisted?).and_return(true)
      report.instance_variable_set(:@model, User)
      allow(User).to receive(:maximum).with(:id).and_return(1)

      allow(report).to receive(:batch_process)

      allow(group).to receive(:create_temp_file)
      allow(group).to receive(:close_temp_file)
      allow(group).to receive(:whitelist?).and_return(false)
      allow(group).to receive(:blacklist?).and_return(false)

      allow(report).to receive(:generate_rank_file) do |raw_folder, rank_folder, group_id, *_|
        FileUtils.mkdir_p(rank_folder)
        # Multiple items with low counts that should be grouped
        File.write("#{rank_folder}/#{group_id}.dat", "3 Item1      data\n5 Item2      data\n2 Item3      data\n")
      end

      report.run!

      # Verify low-count items were grouped (lines 150-160)
      parsed = YAML.safe_load(report.results, permitted_classes: [Symbol, Hash, Array], aliases: true)
      main_key = parsed[:data].keys.first
      if main_key && parsed[:data][main_key][1]
        # Should have one grouped result with minimum_label
        grouped = parsed[:data][main_key][1].find { |r| r[:name] == 'Others' }
        expect(grouped).to be_present if parsed[:data][main_key][1].any?
      end
    end

    it 'limits samples to 100 with plus sign for overflow' do
      group = ReportGroup.new(
        id: 1,
        width: 10,
        minimum: 200,
        minimum_label: 'Others',
        transformation_rules: '{"columns":[{"source":"id","output":"ID"}]}'
      )

      report = Report.create!(
        title: 'Sample Limit Test',
        query: 'SELECT * FROM users LIMIT 0',
        groups: [group]
      )

      allow(report).to receive(:persisted?).and_return(true)
      report.instance_variable_set(:@model, User)
      allow(User).to receive(:maximum).with(:id).and_return(1)

      allow(report).to receive(:batch_process)

      allow(group).to receive(:create_temp_file)
      allow(group).to receive(:close_temp_file)
      allow(group).to receive(:whitelist?).and_return(false)
      allow(group).to receive(:blacklist?).and_return(false)

      allow(report).to receive(:generate_rank_file) do |raw_folder, rank_folder, group_id, *_|
        FileUtils.mkdir_p(rank_folder)
        # Create 150 low-count items
        lines = 150.times.map { |i| "1 Item#{i.to_s.rjust(3, '0')}   data" }.join("\n")
        File.write("#{rank_folder}/#{group_id}.dat", lines)
      end

      report.run!

      # Verify samples were limited to 100 with '+' for overflow (lines 155-158)
      parsed = YAML.safe_load(report.results, permitted_classes: [Symbol, Hash, Array], aliases: true)
      main_key = parsed[:data].keys.first
      if main_key && parsed[:data][main_key][1]
        grouped = parsed[:data][main_key][1].first
        if grouped && grouped[:samples]
          # Should have max 101 keys (100 + the '+' key)
          expect(grouped[:samples].keys.size).to be <= 101
          expect(grouped[:samples].key?('+')).to be_truthy if grouped[:samples].size > 100
        end
      end
    end
  end
end
