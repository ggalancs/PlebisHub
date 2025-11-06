# frozen_string_literal: true

# Service object to generate user verification reports for users outside Spain
# Extracts complex query logic from UserVerificationsController
class ExteriorVerificationReportService
  def initialize(report_code)
    @aacc_code = Rails.application.secrets.user_verifications[report_code]
  end

  def generate
    return { paises: {} } unless @aacc_code == 'c_99'

    report = {
      paises: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } }
    }

    data = collect_data

    countries.each do |country_cod, country_name|
      process_country_data(report, data, country_cod, country_name)
    end

    report
  end

  private

  def base_query
    @base_query ||= User.confirmed.where("country <> 'ES'")
  end

  def collect_data
    data = Hash[
      base_query.joins(:user_verifications)
                .group(:country, :status)
                .pluck("country", "status", "count(distinct users.id)")
                .map { |country, status, count| [[country, status], count] }
    ]

    add_user_data(data)
    data
  end

  def add_user_data(data)
    active_date = Date.today - eval(Rails.application.secrets.users["active_census_range"])

    base_query.group(:country, :active, :verified).pluck(
      "country",
      "(current_sign_in_at IS NOT NULL AND current_sign_in_at > '#{active_date.to_datetime.iso8601}') as active",
      "#{User.verified_condition} as verified",
      "count(distinct users.id)"
    ).each do |country, active, verified, count|
      data[[country, active, verified]] = count
    end
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
