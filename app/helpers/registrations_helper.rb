# frozen_string_literal: true

module RegistrationsHelper
  require 'ffi-icu'

  def self.region_comparer
    @collator ||= ICU::Collation::Collator.new('es_ES')
    @region_comparer ||= ->(a, b) { @collator.compare(a.name, b.name) }
  end

  # lists of countries, current country provinces and current province towns, sorted with spanish collation
  def get_countries
    Carmen::Country.all.sort(&RegistrationsHelper.region_comparer)
  end

  def get_provinces(country)
    c = Carmen::Country.coded(country)
    if c&.subregions
      c.subregions.sort(&RegistrationsHelper.region_comparer)
    else
      []
    end
  end

  def get_towns(country, province)
    p = (Carmen::Country.coded('ES').subregions.coded(province) if province && country == 'ES')

    if p&.subregions
      p.subregions.sort(&RegistrationsHelper.region_comparer)
    else
      []
    end
  end

  def get_vote_circles
    result = VoteCircle.where("code like 'IP%'").sort
    result += VoteCircle.where.not("code like 'IP%'").order(:original_name)
    result
  end
end
