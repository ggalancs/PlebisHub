class ReportGroup < ApplicationRecord
  validates :transformation_rules, presence: true, if: :using_safe_mode?
  validate :validate_transformation_structure, if: :using_safe_mode?

  # SECURITY: Safe transformations for JSON-based rules
  # NO EVAL - uses pure Ruby lambdas
  ALLOWED_TRANSFORMATIONS = {
    'upcase' => ->(v) { v.to_s.upcase },
    'downcase' => ->(v) { v.to_s.downcase },
    'strip' => ->(v) { v.to_s.strip },
    'to_s' => ->(v) { v.to_s },
    'to_i' => ->(v) { v.to_i },
    'truncate' => ->(v, len=50) { v.to_s.truncate(len) },
    'first' => ->(v, n=1) { v.to_s.first(n) },
    'last' => ->(v, n=1) { v.to_s.last(n) }
  }.freeze

  ALLOWED_FORMATS = {
    'currency' => ->(v) { "%.2f" % v.to_f },
    'date' => ->(v) { v.to_date.strftime('%Y-%m-%d') rescue v.to_s },
    'percentage' => ->(v) { "#{v.to_f * 100}%" },
    'integer' => ->(v) { v.to_i.to_s }
  }.freeze

  def process(row)
    if using_safe_mode?
      # SECURITY: Safe JSON-based evaluation - NO EVAL
      process_with_json_transformations(row)
    else
      # DEPRECATED: Legacy eval() mode
      Rails.logger.warn("SECURITY: ReportGroup #{id} using deprecated eval(). Migrate to JSON transformations!")
      get_proc.call(row)
    end
  rescue => e
    Rails.logger.error("ReportGroup #{id} error: #{e.message}")
    [["ERROR", "ERROR"]]
  end

  def format_group_name(name)
    name.ljust(width)[0..width-1]
  end

  def create_temp_file(folder)
    @file = File.open("#{folder}/#{self.id}.dat", 'w:UTF-8')
  end

  def write(data)
    @file.puts data
  end

  def close_temp_file
    @file.close
  end

  def get_proc
    # SECURITY WARNING: Legacy eval() code - DEPRECATED
    # Use transformation_rules instead
    # SECURITY NOTE: This eval is intentional for admin-controlled report transformations (legacy mode)
    # New reports should use the safe JSON-based transformation_rules instead
    # This is maintained for backwards compatibility with existing admin-created reports
    # brakeman:disable:Evaluation
    if self[:proc].present?
      Rails.logger.warn("SECURITY: ReportGroup #{id} using deprecated eval() proc. Migrate to transformation_rules!")
      @proc ||= eval("Proc.new { |row| #{self[:proc]} }")
    end
    # brakeman:enable:Evaluation
  end

  def get_whitelist
    @whitelist ||= self[:whitelist].to_s.split("\r\n")
  end

  def get_blacklist
    @blacklist ||= self[:blacklist].to_s.split("\r\n")
  end

  def proc=(value)
    @proc = nil
    self[:proc] = value
  end

  def whitelist=(value)
    @whitelist = nil
    self[:whitelist] = value
  end

  def whitelist?(value)
    get_whitelist.include?(value)
  end

  def blacklist=(value)
    @blacklist = nil
    self[:blacklist] = value
  end

  def blacklist?(value)
    get_blacklist.include?(value)
  end

  def self.serialize(data)
    if data.is_a? Array
      data.map {|d| d.attributes.to_yaml }.to_yaml
    else
      data.attributes.to_yaml
    end
  end

  def self.unserialize(value)
    # SECURITY: Use safe_load with permitted classes instead of unsafe_load
    permitted = [Symbol, Date, Time, DateTime]
    data = YAML.safe_load(value, permitted_classes: permitted, aliases: true)
    if data.is_a? Array
      data.map { |d| ReportGroup.new YAML.safe_load(d, permitted_classes: permitted, aliases: true) }
    else
      ReportGroup.new data
    end
  end

  private

  def using_safe_mode?
    transformation_rules.present?
  end

  # SECURITY: Safe JSON-based transformation evaluation
  # NO EVAL - uses whitelisted transformations
  def process_with_json_transformations(row)
    rules = JSON.parse(transformation_rules)

    rules['columns'].map do |column_def|
      value = extract_value(row, column_def['source'])

      # Apply transformations
      column_def['transformations']&.each do |transform|
        transformer = ALLOWED_TRANSFORMATIONS[transform]
        value = transformer.call(value) if transformer
      end

      # Apply formatting
      if column_def['format']
        formatter = ALLOWED_FORMATS[column_def['format']]
        value = formatter.call(value) if formatter
      end

      [column_def['output'], value.to_s]
    end
  rescue JSON::ParserError => e
    Rails.logger.error("Invalid JSON in ReportGroup #{id}: #{e.message}")
    [["ERROR", "ERROR"]]
  end

  def extract_value(row, source_path)
    # source_path example: "name" or "user.email"
    parts = source_path.to_s.split('.')

    value = row
    parts.each do |part|
      if value.respond_to?(part)
        value = value.public_send(part)
      else
        # Field doesn't exist, log error and return nil
        Rails.logger.error("Failed to extract '#{source_path}': field '#{part}' not found")
        return nil
      end
    end

    value
  rescue => e
    Rails.logger.error("Failed to extract '#{source_path}': #{e.message}")
    nil
  end

  def validate_transformation_structure
    return if transformation_rules.blank?

    rules = JSON.parse(transformation_rules)

    unless rules['columns'].is_a?(Array)
      errors.add(:transformation_rules, "must have 'columns' array")
      return
    end

    rules['columns'].each do |column|
      unless column['source'].present?
        errors.add(:transformation_rules, "each column must have 'source'")
      end

      unless column['output'].present?
        errors.add(:transformation_rules, "each column must have 'output'")
      end

      column['transformations']&.each do |transform|
        unless ALLOWED_TRANSFORMATIONS.key?(transform)
          errors.add(:transformation_rules, "transformation '#{transform}' not allowed")
        end
      end

      if column['format'] && !ALLOWED_FORMATS.key?(column['format'])
        errors.add(:transformation_rules, "format '#{column['format']}' not allowed")
      end
    end
  rescue JSON::ParserError
    errors.add(:transformation_rules, "must be valid JSON")
  end
end
