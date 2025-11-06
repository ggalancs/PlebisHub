require "test_helper"

class ReportTest < ActiveSupport::TestCase
  setup do
    @report = Report.new
    @test_folder = "#{Rails.root}/tmp/test_report"
    @raw_folder = "#{@test_folder}/raw"
    @rank_folder = "#{@test_folder}/rank"
    FileUtils.mkdir_p(@raw_folder)
    FileUtils.mkdir_p(@rank_folder)
  end

  teardown do
    FileUtils.rm_rf(@test_folder) if File.exist?(@test_folder)
  end

  # PHASE 3 SECURITY REFACTORING TESTS

  # Test generate_rank_file method (replacement for shell command)
  test "generate_rank_file should process file correctly" do
    # Create test data file
    File.open("#{@raw_folder}/1.dat", 'w:UTF-8') do |f|
      f.puts "001A Data1"
      f.puts "002A Data1"
      f.puts "003B Data2"
      f.puts "004A Data1"
      f.puts "005B Data2"
    end

    # Call the method
    @report.send(:generate_rank_file, @raw_folder, @rank_folder, 1, 3, 1, 0)

    # Verify rank file was created
    assert File.exist?("#{@rank_folder}/1.dat")

    # Verify content is sorted by count (descending)
    lines = File.readlines("#{@rank_folder}/1.dat", encoding: 'UTF-8')
    assert_equal 2, lines.size

    # First line should have count 3 (A Data1 appears 3 times)
    assert_match /^3 A Data1/, lines[0]
    # Second line should have count 2 (B Data2 appears 2 times)
    assert_match /^2 B Data2/, lines[1]
  end

  test "generate_rank_file should handle empty file" do
    File.open("#{@raw_folder}/2.dat", 'w:UTF-8') { |f| }

    @report.send(:generate_rank_file, @raw_folder, @rank_folder, 2, 3, 1, 0)

    assert File.exist?("#{@rank_folder}/2.dat")
    assert_equal 0, File.size("#{@rank_folder}/2.dat")
  end

  test "generate_rank_file should handle lines shorter than id_width" do
    File.open("#{@raw_folder}/3.dat", 'w:UTF-8') do |f|
      f.puts "A" # Too short
      f.puts "001AB"
    end

    @report.send(:generate_rank_file, @raw_folder, @rank_folder, 3, 3, 1, 0)

    assert File.exist?("#{@rank_folder}/3.dat")
    lines = File.readlines("#{@rank_folder}/3.dat", encoding: 'UTF-8')
    assert_equal 1, lines.size # Only one valid line
  end

  # SECURITY: Path traversal prevention
  test "generate_rank_file should reject path traversal attempts" do
    malicious_path = "/tmp/../../etc"

    Rails.logger.expects(:error).with(regexp_matches(/Invalid raw_file path/))

    @report.send(:generate_rank_file, malicious_path, @rank_folder, 1, 3, 1, 0)

    # Should not create any file outside Rails.root
    refute File.exist?("/etc/1.dat")
  end

  test "generate_rank_file should handle file read errors gracefully" do
    # Non-existent file
    Rails.logger.expects(:error).with(regexp_matches(/Invalid raw_file path/))

    @report.send(:generate_rank_file, @raw_folder, @rank_folder, 999, 3, 1, 0)

    # Should not raise exception
  end

  test "generate_rank_file should handle write errors gracefully" do
    File.open("#{@raw_folder}/4.dat", 'w:UTF-8') { |f| f.puts "001Data" }

    # Make rank_folder read-only to trigger write error
    FileUtils.chmod(0444, @rank_folder)

    Rails.logger.expects(:error).with(regexp_matches(/Error in generate_rank_file/))

    @report.send(:generate_rank_file, @raw_folder, @rank_folder, 4, 3, 1, 0)

    # Restore permissions
    FileUtils.chmod(0755, @rank_folder)
  end

  # Test grep_pattern_from_file method (replacement for shell command)
  test "grep_pattern_from_file should find matching lines" do
    File.open("#{@raw_folder}/5.dat", 'w:UTF-8') do |f|
      f.puts "001GroupA data1"
      f.puts "002GroupB data2"
      f.puts "003GroupA data3"
      f.puts "004GroupA data4"
      f.puts "005GroupC data5"
    end

    results = @report.send(:grep_pattern_from_file, @raw_folder, 5, 3, "", "GroupA", 10)

    assert_equal 3, results.size
    assert_includes results[0], "001GroupA data1"
    assert_includes results[1], "003GroupA data3"
    assert_includes results[2], "004GroupA data4"
  end

  test "grep_pattern_from_file should respect max_lines limit" do
    File.open("#{@raw_folder}/6.dat", 'w:UTF-8') do |f|
      5.times { |i| f.puts "00#{i}TestX data#{i}" }
    end

    results = @report.send(:grep_pattern_from_file, @raw_folder, 6, 3, "", "TestX", 2)

    assert_equal 2, results.size # Should stop at max_lines
  end

  test "grep_pattern_from_file should handle no matches" do
    File.open("#{@raw_folder}/7.dat", 'w:UTF-8') do |f|
      f.puts "001GroupA data1"
      f.puts "002GroupB data2"
    end

    results = @report.send(:grep_pattern_from_file, @raw_folder, 7, 3, "", "GroupZ", 10)

    assert_equal 0, results.size
  end

  test "grep_pattern_from_file should handle main_group_name and group_name" do
    File.open("#{@raw_folder}/8.dat", 'w:UTF-8') do |f|
      f.puts "001MainX GroupY data1"
      f.puts "002MainX GroupZ data2"
      f.puts "003MainY GroupY data3"
    end

    results = @report.send(:grep_pattern_from_file, @raw_folder, 8, 3, "MainX ", "GroupY", 10)

    assert_equal 1, results.size
    assert_includes results[0], "001MainX GroupY data1"
  end

  # SECURITY: Path traversal prevention
  test "grep_pattern_from_file should reject path traversal attempts" do
    malicious_path = "/tmp/../../etc"

    Rails.logger.expects(:error).with(regexp_matches(/Invalid raw_file path/))

    results = @report.send(:grep_pattern_from_file, malicious_path, 1, 3, "", "test", 10)

    assert_equal [], results
  end

  test "grep_pattern_from_file should handle file read errors gracefully" do
    # Non-existent file
    Rails.logger.expects(:error).with(regexp_matches(/Invalid raw_file path/))

    results = @report.send(:grep_pattern_from_file, @raw_folder, 999, 3, "", "test", 10)

    assert_equal [], results
  end

  test "grep_pattern_from_file should handle empty file" do
    File.open("#{@raw_folder}/9.dat", 'w:UTF-8') { |f| }

    results = @report.send(:grep_pattern_from_file, @raw_folder, 9, 3, "", "test", 10)

    assert_equal 0, results.size
  end

  # Integration test: verify both methods work together
  test "generate_rank_file and grep_pattern_from_file integration" do
    # Create realistic test data
    File.open("#{@raw_folder}/10.dat", 'w:UTF-8') do |f|
      f.puts "001Spain Madrid Some data here"
      f.puts "002Spain Barcelona Other data"
      f.puts "003Spain Madrid More data"
      f.puts "004France Paris French data"
      f.puts "005Spain Madrid Yet more"
    end

    # Generate rank file
    @report.send(:generate_rank_file, @raw_folder, @rank_folder, 10, 3, 6, 6)

    # Verify rank file
    assert File.exist?("#{@rank_folder}/10.dat")
    rank_lines = File.readlines("#{@rank_folder}/10.dat", encoding: 'UTF-8')

    # Should have grouped by country+city (first 12 chars after id)
    # Spain Madrid: 3 occurrences
    # Spain Barcelona: 1 occurrence
    # France Paris: 1 occurrence
    assert rank_lines.any? { |line| line.start_with?("3 ") }

    # Grep for Spain Madrid entries
    results = @report.send(:grep_pattern_from_file, @raw_folder, 10, 3, "Spain ", "Madrid", 10)

    assert_equal 3, results.size
    results.each do |line|
      assert_includes line, "Spain Madrid"
    end
  end

  # Test serialize_relation_query class method
  test "serialize_relation_query should remove LIMIT and OFFSET" do
    sql = "SELECT * FROM users WHERE active = true LIMIT 100 OFFSET 50"
    result = Report.serialize_relation_query(double(to_sql: sql))

    refute_includes result, "LIMIT"
    refute_includes result, "OFFSET"
    assert_includes result, "SELECT * FROM users WHERE active = true"
  end

  test "serialize_relation_query should handle query without LIMIT or OFFSET" do
    sql = "SELECT * FROM users WHERE active = true"
    result = Report.serialize_relation_query(double(to_sql: sql))

    assert_equal "SELECT * FROM users WHERE active = true", result
  end
end
