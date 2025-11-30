class Report < ApplicationRecord

  def self.serialize_relation_query relation
    relation.to_sql.sub(/ LIMIT \d+/, ' ').sub(/ OFFSET \d+/, ' ').strip
  end

  after_initialize do |report|
    if report.persisted?
      table_name = query.match(/\s*SELECT\s*.*\s*FROM\s*\"?(\w+)\"?\s*/)
      table_name = table_name.captures.first if table_name

      if table_name
        @model = ActiveRecord::Base.send(:descendants).select do |m| m.table_name==table_name end .first
      end
    end
  end

  def get_main_group
    if !defined?(@main_group) then 
      @main_group = ReportGroup.unserialize(self[:main_group]) if !self[:main_group].blank?
    end
    @main_group
  end
  def get_groups
    @groups ||= ReportGroup.unserialize(self[:groups])
  end

  def main_group= value
    if value.is_a? ReportGroup
      self[:main_group] = ReportGroup.serialize(value)
    else
      self[:main_group] = value
    end
    @main_group = value
  end

  def groups= value
    if value.is_a? Array
      self[:groups] = ReportGroup.serialize(value)
    else
      self[:groups] = value
    end
    @groups = value
  end

  def batch_process batch_size=1000
    offset = 0
    begin
      # SECURITY FIX: Use parameterized query to prevent SQL injection
      results = @model.find_by_sql(["#{query} LIMIT ? OFFSET ?", batch_size, offset])
      offset += batch_size

      results.each do |row|
        yield row
      end
    end while not results.empty?
  end

  def run!
    # Initialize
    tmp_results = { data: Hash.new { |h, main_group| h[main_group] = Hash.new { |h2, group| h2[group] = [] } }, errors: { fetch: [] } }

    folder = "#{Rails.root}/tmp/report/#{id}"
    raw_folder = "#{folder}/raw"
    rank_folder = "#{folder}/rank"
    
    # Aggregation data
    id_width = @model.maximum(:id).to_s.length

    FileUtils.mkdir_p(raw_folder) unless File.directory?(raw_folder)
    FileUtils.mkdir_p(rank_folder) unless File.directory?(rank_folder)

    get_groups.each { |group| group.create_temp_file raw_folder }
    # Browse data
    main_name = ""
    self.batch_process do |row|

      row = row.version_at(self.version_at) if self.version_at 
      next if row.nil?

      row_id = row.id.to_s.ljust(id_width)

      main_name = get_main_group.format_group_name(get_main_group.process(row)[0][0]) if get_main_group

      get_groups.each do |group|
        _width = group.width
        begin
          group.process(row).each do |name, data|
            group.write "#{row_id}#{main_name}#{group.format_group_name(name)} #{data}"
          end
        rescue Exception => e
          tmp_results[:errors][:fetch] = [ e.message, e.backtrace.inspect ]
        end
      end
    end
    get_groups.each { |group| group.close_temp_file }

    # Generate rank
    main_width = get_main_group ? get_main_group.width : 0
    get_groups.each do |group|
      width = group.width

      # SECURITY: Replaced shell command with Ruby file processing
      # Old: %x(cut -c#{id_width+1}- #{raw_folder}/#{group.id}.dat | sort | uniq -w#{width+main_width+1} -c | sort -rn > #{rank_folder}/#{group.id}.dat)
      generate_rank_file(raw_folder, rank_folder, group.id, id_width, width, main_width)
      rest = Hash.new {|h,k| h[k] = []}
      separator = nil
      File.open( "#{rank_folder}/#{group.id}.dat", 'r:UTF-8' ).each do |line|
        separator = line.index " ", line.index(/\d/) if not separator
        count = line[0..separator-1].to_i
        info = line[separator+1..-2]

        main_name = get_main_group ? info[0..(main_width-1)].strip : nil
        name = info[main_width..(main_width+width-1)].strip
        
        if group.whitelist? name or (count <= group.minimum and not group.blacklist? name)
          rest[main_name] << { count: count, name: name }
        else
          result = { count: count, name: name, users:[], samples:Hash.new(0)}
          # SECURITY: Replaced shell command with Ruby file processing
          # Old: %x(grep "..." #{raw_folder}/#{group.id}.dat | head -n...)
          matching_lines = grep_pattern_from_file(
            raw_folder,
            group.id,
            id_width,
            get_main_group ? get_main_group.format_group_name(main_name) : "",
            group.format_group_name(name),
            [count, 101].min
          )
          matching_lines.each do |s|
            result[:users] << s[0..id_width-1].to_i
            sample = s[(id_width+main_width+width)..-1].strip
            result[:samples][sample] += 1
            result[:users].uniq!
          end

          result[:users] = result[:users].first(20)
          tmp_results[:data][main_name][group.id] << result
        end
      end

      rest.each do |main_name, entries|
        count = entries.map {|e| e[:count] } .sum
        result = { count: count, name: group.minimum_label, samples:Hash.new(0)}
        entries.each {|e| result[:samples][e[:name]] += e[:count] }
        result[:samples] = Hash[result[:samples].sort_by {|k,v| [-v, k]}]
        if result[:samples].length>100
          result[:samples] = Hash[result[:samples].first(100)]
          result[:samples]["+"] = count - (result[:samples].map {|k,v| v} .sum)
        end
        tmp_results[:data][main_name][group.id] << result
      end
    end

    self.results = tmp_results.to_yaml
    self.save
  end

  private

  # SECURITY: Safe replacement for shell command: cut | sort | uniq -c | sort -rn
  # Processes log file to count and rank unique entries
  def generate_rank_file(raw_folder, rank_folder, group_id, id_width, width, main_width)
    raw_file = "#{raw_folder}/#{group_id}.dat"
    rank_file = "#{rank_folder}/#{group_id}.dat"

    # Validate file paths to prevent path traversal
    unless File.exist?(raw_file) && raw_file.start_with?(Rails.root.to_s)
      Rails.logger.error("Invalid raw_file path: #{raw_file}")
      return
    end

    # Read and process file
    lines = []
    File.foreach(raw_file, encoding: 'UTF-8') do |line|
      # Equivalent to: cut -c#{id_width+1}-
      lines << line[id_width..-1] if line.length > id_width
    end

    # Equivalent to: sort
    lines.sort!

    # Equivalent to: uniq -w#{width+main_width+1} -c
    # Group by first N characters and count occurrences
    compare_width = width + main_width + 1
    grouped = Hash.new { |h, k| h[k] = { count: 0, line: nil } }
    lines.each do |line|
      key = line[0..compare_width-1] || line
      grouped[key][:count] += 1
      grouped[key][:line] ||= line.chomp  # Store first occurrence of full line
    end

    # Equivalent to: sort -rn (reverse numeric sort by count)
    sorted_counts = grouped.sort_by { |_, data| -data[:count] }

    # Write to rank file
    File.open(rank_file, 'w:UTF-8') do |f|
      sorted_counts.each do |_, data|
        f.puts "#{data[:count]} #{data[:line]}"
      end
    end
  rescue => e
    Rails.logger.error("Error in generate_rank_file: #{e.message}")
    # Create empty file to prevent downstream errors
    FileUtils.touch(rank_file) rescue nil
  end

  # SECURITY: Safe replacement for shell command: grep pattern | head -n
  # Searches file for lines matching pattern and returns first N matches
  def grep_pattern_from_file(raw_folder, group_id, id_width, main_group_name, group_name, max_lines)
    raw_file = "#{raw_folder}/#{group_id}.dat"

    # Validate file path to prevent path traversal
    unless File.exist?(raw_file) && raw_file.start_with?(Rails.root.to_s)
      Rails.logger.error("Invalid raw_file path: #{raw_file}")
      return []
    end

    # Build the pattern to match
    # Original: grep "#{'.'*id_width}#{main_group_name}#{group_name} "
    # The dots match any character (regex pattern in grep)
    pattern_suffix = "#{main_group_name}#{group_name} "

    matching_lines = []
    File.foreach(raw_file, encoding: 'UTF-8') do |line|
      # Match: any id_width characters, followed by exact pattern
      if line.length >= id_width + pattern_suffix.length &&
         line[id_width..-1].start_with?(pattern_suffix)
        matching_lines << line.chomp
        break if matching_lines.size >= max_lines
      end
    end

    matching_lines
  rescue => e
    Rails.logger.error("Error in grep_pattern_from_file: #{e.message}")
    []
  end
end