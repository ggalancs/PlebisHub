# frozen_string_literal: true

module PlebisVerification
  # Service object to generate user verification reports by province and autonomy
  # Extracts complex query logic from UserVerificationsController
  #
  # SECURITY FIXES IMPLEMENTED:
  # - Replaced eval() with safe Integer() parsing
  # - Replaced SQL string interpolation with Arel for parameterized queries
  # - Added configuration validation
  # - Added error handling
  class UserVerificationReportService
    def initialize(report_code)
      validate_configuration!
      @aacc_code = Rails.application.secrets.user_verifications[report_code]
    rescue StandardError => e
      Rails.logger.error({
        event: 'user_verification_report_init_failed',
        report_code: report_code,
        error_class: e.class.name,
        error_message: e.message,
        timestamp: Time.current.iso8601
      }.to_json)
      @aacc_code = nil
    end

    def generate
      # Return empty report if initialization failed
      return empty_report unless @aacc_code

      report = {
        provincias: build_province_report,
        autonomias: build_autonomy_report
      }

      data = collect_data

      provinces.each do |province_num, province_name|
        autonomy_code = PlebisBrand::GeoExtra::AUTONOMIES["p_#{province_num}"].first
        autonomy_name = PlebisBrand::GeoExtra::AUTONOMIES["p_#{province_num}"].last

        next unless @aacc_code == 'c_00' || autonomy_code == @aacc_code

        process_province_data(report, data, province_num, province_name, autonomy_name)
      end

      report
    rescue StandardError => e
      Rails.logger.error({
        event: 'user_verification_report_generation_failed',
        aacc_code: @aacc_code,
        error_class: e.class.name,
        error_message: e.message,
        backtrace: e.backtrace&.first(5),
        timestamp: Time.current.iso8601
      }.to_json)
      empty_report
    end

    private

    def validate_configuration!
      unless Rails.application.secrets.user_verifications &&
             Rails.application.secrets.users &&
             Rails.application.secrets.users['active_census_range']
        raise 'Missing user_verifications or users configuration in secrets'
      end
    end

    def empty_report
      {
        provincias: {},
        autonomias: {}
      }
    end

    def build_province_report
      Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } }
    end

    def build_autonomy_report
      Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } }
    end

    def base_query
      @base_query ||= User.confirmed.where("vote_town ilike 'm\\___%'")
    end

    def collect_data
      return @data if @data

      @data = base_query.joins(:user_verifications)
                        .group(:prov, :status)
                        .pluck('right(left(vote_town,4),2) as prov', 'status', 'count(distinct users.id)')
                        .to_h { |prov, status, count| [[prov, status], count] }

      # Add users totals by prov
      # SECURITY FIX: Replace eval() with safe Integer() parsing
      active_census_days = parse_active_census_range
      active_date = Time.zone.today - active_census_days.days

      # SECURITY FIX: Use Arel for parameterized query instead of string interpolation
      users_table = User.arel_table
      base_query.group(:prov, :active, :verified).pluck(
        'right(left(vote_town,4),2) as prov',
        users_table[:current_sign_in_at].not_eq(nil)
          .and(users_table[:current_sign_in_at].gt(active_date))
          .to_sql.sub(/^"users"\./, '').concat(' as active'),
        "#{User.verified_condition} as verified",
        'count(distinct users.id)'
      ).each do |prov, active, verified, count|
        @data[[prov, active, verified]] = count
      end

      @data
    end

    # SECURITY FIX: Replace dangerous eval() with safe Integer() parsing
    def parse_active_census_range
      range_value = Rails.application.secrets.users['active_census_range']

      # Handle different formats: "30.days", "30", 30
      if range_value.is_a?(String)
        # Extract numeric part from strings like "30.days"
        numeric_match = range_value.match(/\d+/)
        unless numeric_match
          Rails.logger.error({
            event: 'invalid_active_census_range',
            value: range_value,
            error: 'No numeric value found in string',
            timestamp: Time.current.iso8601
          }.to_json)
          return 30 # Default fallback
        end
        Integer(numeric_match[0])
      else
        Integer(range_value)
      end
    rescue ArgumentError, TypeError => e
      Rails.logger.error({
        event: 'invalid_active_census_range',
        value: range_value,
        error: e.message,
        timestamp: Time.current.iso8601
      }.to_json)
      30 # Default fallback
    end

    def provinces
      @provinces ||= Carmen::Country.coded('ES').subregions.map { |p| ['%02d' % +p.index, p.name] }
    end

    def process_province_data(report, data, province_num, province_name, autonomy_name)
      total_sum = 0

      UserVerification.statuses.each do |name, status|
        count = data[[province_num, status]] || 0
        report[:provincias][province_name][name.to_sym] = count
        report[:autonomias][autonomy_name][name.to_sym] += count
        total_sum += count
      end

      report[:provincias][province_name][:total] = total_sum
      report[:autonomias][autonomy_name][:total] += total_sum

      add_user_counts(report, data, province_num, province_name, autonomy_name)
    end

    def add_user_counts(report, data, province_num, province_name, autonomy_name)
      active_verified = data[[province_num, true, true]] || 0
      active = active_verified + (data[[province_num, true, false]] || 0)
      inactive_verified = data[[province_num, false, true]] || 0
      inactive = inactive_verified + (data[[province_num, false, false]] || 0)

      report[:provincias][province_name][:users] = active + inactive
      report[:provincias][province_name][:verified] = active_verified + inactive_verified
      report[:autonomias][autonomy_name][:users] += active + inactive
      report[:autonomias][autonomy_name][:verified] += active_verified + inactive_verified
      report[:provincias][province_name][:active] = active
      report[:provincias][province_name][:active_verified] = active_verified
      report[:autonomias][autonomy_name][:active] += active
      report[:autonomias][autonomy_name][:active_verified] += active_verified
    end
  end
end
