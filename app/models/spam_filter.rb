class SpamFilter < ApplicationRecord
  scope :active, -> { where(active:true) }

  validates :rules_json, presence: true, if: :using_safe_mode?
  validate :validate_rules_structure, if: :using_safe_mode?

  # SECURITY: Safe operators for JSON-based rules
  # NO EVAL - uses pure Ruby lambdas
  OPERATORS = {
    'equals' => ->(a, b) { a.to_s == b.to_s },
    'not_equals' => ->(a, b) { a.to_s != b.to_s },
    'contains' => ->(a, b) { a.to_s.include?(b.to_s) },
    'not_contains' => ->(a, b) { !a.to_s.include?(b.to_s) },
    'matches' => ->(a, b) { a.to_s.match?(Regexp.new(b.to_s)) rescue false },
    'in_list' => ->(a, list) { list.include?(a.to_s) },
    'less_than' => ->(a, b) { a.to_i < b.to_i },
    'greater_than' => ->(a, b) { a.to_i > b.to_i },
    'less_than_days_ago' => ->(a, days) {
      a.is_a?(Time) && a > days.to_i.days.ago
    }
  }.freeze

  # SECURITY: Whitelist of allowed user fields
  ALLOWED_FIELDS = %w[
    email phone first_name last_name
    document_vatid postal_code country
    created_at updated_at confirmed_at
  ].freeze

  after_initialize do |filter|
    # Initialization moved to lazy loading in process method
    # to support test scenarios where id is set after initialization
  end

  def process(user)
    if using_safe_mode?
      # SECURITY: Safe JSON-based evaluation - NO EVAL
      process_with_json_rules(user)
    else
      # DEPRECATED: Legacy eval() mode - initialize lazily
      initialize_legacy_mode unless @proc
      Rails.logger.warn("SECURITY: SpamFilter #{id} using deprecated eval(). Migrate to JSON rules!")
      @proc.call(user, @data)
    end
  rescue => e
    Rails.logger.error("SpamFilter #{id} error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    false
  end

  def query_count
    User.confirmed.not_verified.not_banned.where(query).count
  end

  def run(offset, limit)
    matches = []
    User.confirmed.not_verified.not_banned.where(query).offset(offset).limit(limit).each do |user|
      matches << user if process(user)
    end
    matches
  end

  def self.any?(user)
    SpamFilter.active.each do |filter|
      return filter.name if filter.process(user)
    end
    false
  end

  private

  def using_safe_mode?
    rules_json.present?
  end

  def initialize_legacy_mode
    # SECURITY WARNING: Legacy eval() code - DEPRECATED
    # Use rules_json instead
    if code.present? && rules_json.blank?
      @proc = eval("Proc.new { |user, data| #{code} }")
      @data = data.to_s.split(/\r?\n/)
    end
  end

  # SECURITY: Safe JSON-based rule evaluation
  # NO EVAL - uses whitelisted operators and fields
  def process_with_json_rules(user)
    rules = JSON.parse(rules_json)
    evaluate_rules(user, rules)
  rescue JSON::ParserError => e
    Rails.logger.error("Invalid JSON in SpamFilter #{id}: #{e.message}")
    false
  end

  def evaluate_rules(user, rules)
    conditions = rules['conditions'] || []
    logic = rules['logic'] || 'AND'

    # Empty conditions should return false (no rules to match)
    return false if conditions.empty?

    results = conditions.map { |cond| evaluate_condition(user, cond) }

    logic == 'AND' ? results.all? : results.any?
  end

  def evaluate_condition(user, condition)
    field = condition['field']
    operator = condition['operator']
    value = condition['value']

    # SECURITY: Only allow whitelisted fields and operators
    return false unless ALLOWED_FIELDS.include?(field)
    return false unless OPERATORS.key?(operator)

    field_value = user.public_send(field)

    # Special case: replace with data list from data field
    value = data_list if value == 'DATA_LIST'

    OPERATORS[operator].call(field_value, value)
  rescue => e
    Rails.logger.error("Condition evaluation error in SpamFilter #{id}: #{e.message}")
    false
  end

  def data_list
    @data ||= data.to_s.split(/\r?\n/)
  end

  def validate_rules_structure
    return if rules_json.blank?

    rules = JSON.parse(rules_json)

    unless rules['conditions'].is_a?(Array)
      errors.add(:rules_json, "must have 'conditions' array")
      return
    end

    rules['conditions'].each do |cond|
      unless ALLOWED_FIELDS.include?(cond['field'])
        errors.add(:rules_json, "field '#{cond['field']}' not allowed")
      end

      unless OPERATORS.key?(cond['operator'])
        errors.add(:rules_json, "operator '#{cond['operator']}' not allowed")
      end
    end
  rescue JSON::ParserError
    errors.add(:rules_json, "must be valid JSON")
  end
end