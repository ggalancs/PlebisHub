# frozen_string_literal: true

module PlebisVerification
  # Service object to generate user verification reports for users outside Spain
  # Extracts complex query logic from UserVerificationsController
  #
  # SECURITY FIXES IMPLEMENTED:
  # - Replaced eval() with safe Integer() parsing
  # - Replaced SQL string interpolation with Arel for parameterized queries
  # - Added configuration validation
  # - Added error handling
  class ExteriorVerificationReportService
    def initialize(report_code)
      validate_configuration!
      @aacc_code = Rails.application.secrets.user_verifications[report_code]
    rescue StandardError => e
      Rails.logger.error({
        event: "exterior_verification_report_init_failed",
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

      # Only generate report for exterior code (c_99)
      return empty_report unless @aacc_code == 'c_99'

      report = {
        paises: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } }
      }

      data = collect_data

      countries.each do |country_cod, country_name|
        process_country_data(report, data, country_cod, country_name)
      end

      report
    rescue StandardError => e
      Rails.logger.error({
        event: "exterior_verification_report_generation_failed",
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
             Rails.application.secrets.users["active_census_range"]
        raise "Missing user_verifications or users configuration in secrets"
      end
    end

    def empty_report
      { paises: {} }
    end

    def base_query
      @base_query ||= User.confirmed.where("country <> 'ES'")
    end

    def collect_data
      return @data if @data

      @data = Hash[
        base_query.joins(:user_verifications)
                  .group(:country, :status)
                  .pluck("country", "status", "count(distinct users.id)")
                  .map { |country, status, count| [[country, status], count] }
      ]

      add_user_data(@data)
      @data
    end

    def add_user_data(data)
      # SECURITY FIX: Replace eval() with safe Integer() parsing
      active_census_days = parse_active_census_range
      active_date = Date.today - active_census_days.days

      # SECURITY FIX: Use Arel for parameterized query instead of string interpolation
      users_table = User.arel_table
      base_query.group(:country, :active, :verified).pluck(
        "country",
        users_table[:current_sign_in_at].not_eq(nil)
          .and(users_table[:current_sign_in_at].gt(active_date))
          .to_sql.sub(/^"users"\./, '').concat(' as active'),
        "#{User.verified_condition} as verified",
        "count(distinct users.id)"
      ).each do |country, active, verified, count|
        data[[country, active, verified]] = count
      end
    end

    # SECURITY FIX: Replace dangerous eval() with safe Integer() parsing
    def parse_active_census_range
      range_value = Rails.application.secrets.users["active_census_range"]

      # Handle different formats: "30.days", "30", 30
      if range_value.is_a?(String)
        # Extract numeric part from strings like "30.days"
        numeric_match = range_value.match(/\d+/)
        raise "Invalid active_census_range format: #{range_value}" unless numeric_match
        Integer(numeric_match[0])
      else
        Integer(range_value)
      end
    rescue ArgumentError, TypeError => e
      Rails.logger.error({
        event: "invalid_active_census_range",
        value: range_value,
        error: e.message,
        timestamp: Time.current.iso8601
      }.to_json)
      30 # Default fallback
    end

    def countries
      @countries ||= begin
        result = Hash[Carmen::Country.all.map { |c| [c.code, c.name] }]
        result["Desconocido"] = [0] * 4
        result
      end
    end

    def process_country_data(report, data, country_cod, country_name)
      total_sum = 0

      UserVerification.statuses.each do |name, status|
        count = data[[country_cod, status]] || 0
        report[:paises][country_name][name.to_sym] = count
        total_sum += count
      end

      report[:paises][country_name][:total] = total_sum
      add_country_user_counts(report, data, country_cod, country_name)
    end

    def add_country_user_counts(report, data, country_cod, country_name)
      active_verified = data[[country_cod, true, true]] || 0
      active = active_verified + (data[[country_cod, true, false]] || 0)
      inactive_verified = data[[country_cod, false, true]] || 0
      inactive = inactive_verified + (data[[country_cod, false, false]] || 0)

      report[:paises][country_name][:users] = active + inactive
      report[:paises][country_name][:verified] = active_verified + inactive_verified
      report[:paises][country_name][:active] = active
      report[:paises][country_name][:active_verified] = active_verified
    end
  end
end
