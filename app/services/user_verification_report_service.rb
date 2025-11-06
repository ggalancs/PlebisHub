# frozen_string_literal: true

# Service object to generate user verification reports by province and autonomy
# Extracts complex query logic from UserVerificationsController
class UserVerificationReportService
  def initialize(report_code)
    @aacc_code = Rails.application.secrets.user_verifications[report_code]
  end

  def generate
    {
      provincias: build_province_report,
      autonomias: build_autonomy_report
    }
  end

  private

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

    @data = Hash[
      base_query.joins(:user_verifications)
                .group(:prov, :status)
                .pluck("right(left(vote_town,4),2) as prov", "status", "count(distinct users.id)")
                .map { |prov, status, count| [[prov, status], count] }
    ]

    # Add users totals by prov
    active_date = Date.today - eval(Rails.application.secrets.users["active_census_range"])
    base_query.group(:prov, :active, :verified).pluck(
      "right(left(vote_town,4),2) as prov",
      "(current_sign_in_at IS NOT NULL AND current_sign_in_at > '#{active_date.to_datetime.iso8601}') as active",
      "#{User.verified_condition} as verified",
      "count(distinct users.id)"
    ).each do |prov, active, verified, count|
      @data[[prov, active, verified]] = count
    end

    @data
  end

  def provinces
    @provinces ||= Carmen::Country.coded("ES").subregions.map { |p| ["%02d" % +p.index, p.name] }
  end

  def generate
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
