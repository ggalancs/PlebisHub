# frozen_string_literal: true

# User concern for location management and geographic helpers
module User::LocationHelpers
  extend ActiveSupport::Concern

  included do
    # Callbacks
    after_save :_clear_location_caches
  end

  # Location status checks
  def in_spain?
    country == 'ES'
  end

  def in_spanish_island?
    (in_spain? && PlebisBrand::GeoExtra::ISLANDS.key?(town)) || false
  end

  def vote_in_spanish_island?
    PlebisBrand::GeoExtra::ISLANDS.key?(vote_town) || false
  end

  def has_vote_town?
    vote_town.present? && vote_town[0].downcase == 'm' && (1..52).include?(vote_town[2, 2].to_i)
  end

  def has_verified_vote_town?
    has_vote_town? && vote_town[0] == 'm'
  end

  def vote_town_notice
    vote_town == 'NOTICE'
  end

  # Town type classification
  def urban_vote_town?
    vote_town.present? && PlebisBrand::GeoExtra::URBAN_TOWNS.member?(vote_town)
  end

  def semi_urban_vote_town?
    vote_town.present? && PlebisBrand::GeoExtra::SEMI_URBAN_TOWNS.member?(vote_town)
  end

  def rural_vote_town?
    !urban_vote_town? && !semi_urban_vote_town?
  end

  # Location change permissions
  def can_change_vote_location?
    # use database version if vote_town has changed
    !has_verified_vote_town? || !persisted? ||
      (Rails.application.secrets.users['allows_location_change'] && !self.class.blocked_provinces.member?(vote_province_persisted))
  end

  # Country helpers
  def country_name
    if _country
      _country.name
    else
      country || ''
    end
  end

  # Province helpers
  def province_name
    if _province
      _province.name
    else
      province || ''
    end
  end

  def province_code
    if in_spain? && _province
      format('p_%02d', +_province.index)
    else
      ''
    end
  end

  # Town helpers
  def town_name
    if in_spain? && _town
      _town.name
    else
      town || ''
    end
  end

  # Autonomy helpers
  def autonomy_code
    if in_spain? && _province
      PlebisBrand::GeoExtra::AUTONOMIES[province_code][0]
    else
      ''
    end
  end

  def autonomy_name
    if in_spain? && _province
      PlebisBrand::GeoExtra::AUTONOMIES[province_code][1]
    else
      ''
    end
  end

  # Island helpers
  def island_code
    if in_spanish_island?
      PlebisBrand::GeoExtra::ISLANDS[town][0]
    else
      ''
    end
  end

  def island_name
    if in_spanish_island?
      PlebisBrand::GeoExtra::ISLANDS[town][1]
    else
      ''
    end
  end

  # Vote location helpers
  def vote_autonomy_code
    if _vote_province
      PlebisBrand::GeoExtra::AUTONOMIES[vote_province_code][0]
    else
      ''
    end
  end

  def vote_autonomy_name
    if _vote_province
      PlebisBrand::GeoExtra::AUTONOMIES[vote_province_code][1]
    else
      ''
    end
  end

  def vote_town_name
    if _vote_town
      _vote_town.name
    else
      ''
    end
  end

  def vote_province_persisted
    prov = _vote_province
    if vote_town_changed?
      begin
        previous_province = Carmen::Country.coded('ES').subregions[vote_town_was[2, 2].to_i - 1]
        prov = previous_province if previous_province
      rescue StandardError
        # Ignore errors in retrieving previous province
      end
    end

    if prov
      prov.code
    else
      ''
    end
  end

  def vote_province
    if _vote_province
      _vote_province.code
    else
      ''
    end
  end

  def vote_province=(value)
    if value.blank? || (value == '-')
      self.vote_town = nil
    else
      prefix = format('m_%02d_', Carmen::Country.coded('ES').subregions.coded(value).index)
      self.vote_town = prefix if vote_town.nil? || (!vote_town.starts_with? prefix)
    end
  end

  def vote_province_code
    if _vote_province
      format('p_%02d', +_vote_province.index)
    else
      ''
    end
  end

  def vote_province_name
    if _vote_province
      _vote_province.name
    else
      ''
    end
  end

  def vote_island_code
    if vote_in_spanish_island?
      PlebisBrand::GeoExtra::ISLANDS[vote_town][0]
    else
      ''
    end
  end

  def vote_island_name
    if vote_in_spanish_island?
      PlebisBrand::GeoExtra::ISLANDS[vote_town][1]
    else
      ''
    end
  end

  # Numeric code helpers
  def vote_autonomy_numeric
    if _vote_province
      vote_autonomy_code[2..]
    else
      '-'
    end
  end

  def vote_province_numeric
    if _vote_province
      format('%02d', +_vote_province.index)
    else
      ''
    end
  end

  def vote_town_numeric
    if _vote_town
      _vote_town.code.split('_')[1, 3].join
    else
      ''
    end
  end

  def vote_island_numeric
    if vote_in_spanish_island?
      vote_island_code[2..]
    else
      ''
    end
  end

  # Location tracking timestamps
  def vote_autonomy_since
    vote_province_since
  end

  def vote_province_since
    last_vote_location_change
  end

  def vote_island_since
    last_vote_location_change
  end

  def vote_town_since
    last_vote_location_change
  end

  def last_vote_location_change
    return nil unless respond_to?(:versions) && versions.any?

    versions.where_object_changes(vote_town: nil).order(created_at: :desc).limit(1).first&.created_at
  rescue StandardError
    nil
  end

  # Location validation
  def verify_user_location
    return 'country' unless _country
    return 'province' if !_country.subregions.empty? && !_country.subregions.coded(province)

    'town' if in_spain? && !_town
  end

  # Class methods
  module ClassMethods
    def blocked_provinces
      Rails.application.secrets.users['blocked_provinces']
    end

    def get_location(current_user, params)
      # params from edit page
      user_location = { country: params[:user_country], province: params[:user_province], town: params[:user_town],
                        vote_town: params[:user_vote_town], vote_province: params[:user_vote_province] }

      # params from create page
      if params[:user]
        user_location[:country] ||= params[:user][:country]
        user_location[:province] ||= params[:user][:province]
        user_location[:town] ||= params[:user][:town]
        user_location[:vote_town] ||= params[:user][:vote_town]
        user_location[:vote_province] ||= params[:user][:vote_province]
      end

      # params from user profile
      if params[:no_profile].nil? && current_user&.persisted?
        user_location[:country] ||= current_user.country
        user_location[:province] ||= current_user.province
        user_location[:town] ||= current_user.town.downcase

        if current_user.has_vote_town? && current_user.vote_province
          user_location[:vote_town] ||= current_user.vote_town
          user_location[:vote_province] ||= Carmen::Country.coded('ES').subregions.coded(current_user.vote_province).code
        else
          user_location[:vote_town] ||= '-'
          user_location[:vote_province] ||= '-'
        end
      end

      # default country
      user_location[:country] ||= 'ES'

      user_location
    end
  end

  private

  # Cached location objects
  def _country
    @_country ||= Carmen::Country.coded(country)
  end

  def _province
    unless defined?(@province_cache)
      @province_cache = begin
        prov = nil
        if in_spain? && town&.downcase&.starts_with?('m_')
          prov = _country.subregions[town[2,
                                          2].to_i - 1]
        end
        prov = _country.subregions.coded(province) if prov.nil? && _country && province && !_country.subregions.empty?
        prov
      end
    end
    @province_cache
  end

  def _town
    unless defined?(@town_cache)
      @town_cache = begin
        t = nil
        t = _province.subregions.coded(town) if in_spain? && _province
        t
      end
    end
    @town_cache
  end

  def _vote_province
    unless defined?(@vote_province_cache)
      @vote_province_cache = begin
        prov = if has_vote_town?
                 Carmen::Country.coded('ES').subregions[vote_town[2, 2].to_i - 1]
               elsif country == 'ES'
                 _province
               end
        prov
      end
    end
    @vote_province_cache
  end

  def _vote_town
    unless defined?(@vote_town_cache)
      @vote_town_cache = begin
        t = nil
        if has_vote_town? && _vote_province
          t = _vote_province.subregions.coded(vote_town)
        elsif country == 'ES'
          t = _town
        end
        t
      end
    end
    @vote_town_cache
  end

  def _clear_location_caches
    remove_instance_variable(:@country_cache) if defined?(@country_cache)
    remove_instance_variable(:@province_cache) if defined?(@province_cache)
    remove_instance_variable(:@town_cache) if defined?(@town_cache)
    remove_instance_variable(:@vote_province_cache) if defined?(@vote_province_cache)
    remove_instance_variable(:@vote_town_cache) if defined?(@vote_town_cache)
  end
end
