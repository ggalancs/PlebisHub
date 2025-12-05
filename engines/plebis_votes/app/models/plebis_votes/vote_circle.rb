# frozen_string_literal: true

module PlebisVotes
  class VoteCircle < ApplicationRecord
    self.table_name = 'vote_circles'

    include PlebisVotes::TerritoryDetails

    enum :kind, { interno: 0, barrial: 1, municipal: 2, comarcal: 3, exterior: 4 }

    scope :in_spain, -> { where(kind: [kinds[:barrial], kinds[:municipal], kinds[:comarcal]]) }
    scope :not_interno, -> { where.not(kind: kinds[:interno]) }

    attr_accessor :circle_type

    def self.ransackable_attributes(_auth_object = nil)
      %w[autonomy_code code country_code created_at id id_value island_code kind name
         original_code original_name province_code region_area_id town updated_at vote_circle_autonomy_id vote_circle_province_id]
    end

    ransacker :vote_circle_province_id, formatter: proc { |value|
      VoteCircle.where('code like ?', value).map(&:code).uniq
    } do |parent|
      parent.table[:code]
    end

    ransacker :vote_circle_autonomy_id, formatter: proc { |value|
      VoteCircle.where('code like ?', value).map(&:code).uniq
    } do |parent|
      parent.table[:code]
    end

    def is_active?
      !interno?
    end

    def get_code_circle(muni_code, circle_type = 'TM')
      result = ''
      if %w[TM TB].include?(circle_type)
        options = { town_code: muni_code, country_code: 'ES', generate_dc: true, result_as: :struct }
        td = territory_details options
        ccaa = td.autonomy_code[2..3]
        prov = td.province_code[2..3]
        mun = td.town_code[5..7]
        code = "#{ccaa}#{prov}#{mun}"
        ind = get_next_circle_id code
        result = "#{circle_type}#{ccaa}#{prov}#{mun}#{ind}"
      elsif circle_type == 'TC'
        result = get_next_circle_region_id muni_code
      elsif circle_type == '00'
        # exterior circle creation not contemplated
        result = '00'
      end
      result
    end

    def in_spain?
      [VoteCircle.kinds[:barrial], VoteCircle.kinds[:municipal], VoteCircle.kinds[:comarcal]].include? kind
    end

    def code_in_spain?
      circle_type = code[0, 2]
      %w[TB TM TC].include?(circle_type)
    end

    def get_type_circle_from_original_code
      in_spain? ? original_code[0, 2] : '00'
    end

    def island_name
      unless (island_code && PlebisBrand::GeoExtra::ISLANDS[island_code]) || (town && PlebisBrand::GeoExtra::ISLANDS[town])
        return ''
      end

      code = town if town.present?
      code ||= island_code if island_code
      PlebisBrand::GeoExtra::ISLANDS[code][1]
    end

    def town_name
      if town
        prov = Carmen::Country.coded('ES').subregions[town[2, 2].to_i - 1]
        carmen_town = prov.subregions.coded(town.strip)
        carmen_town.present? ? carmen_town.name : "#{town} no es un municipio válido"
      else
        ''
      end
    end

    def province_name
      province_code ? Carmen::Country.coded('ES').subregions[province_code[2, 2].to_i - 1].name : ''
    end

    def autonomy_name
      province_code ? PlebisBrand::GeoExtra::AUTONOMIES[province_code][1] : ''
    end

    def country_name
      Carmen::Country.coded(country_code) ? Carmen::Country.coded(country_code).name : ''
    end

    private

    def get_next_circle_id(territory_code, circle_type = 'TM')
      num_circles = VoteCircle.where('code like ?', "#{circle_type}#{territory_code}%").count
      (num_circles + 1).to_s.rjust(2, '0')
    end

    def get_next_circle_region_id(muni_code, country_code = 'ES')
      Carmen::Country.coded(country_code)
      town_code = muni_code[5..7].to_i.positive? ? muni_code[5..7] : '000'
      province_code = muni_code[2, 2]
      autonomy_code = PlebisBrand::GeoExtra::AUTONOMIES["p_#{province_code}"][0]
      region_code = "#{autonomy_code[2, 2]}#{province_code}#{town_code}"
      last_code = VoteCircle.where('code like ?', "TC#{region_code}%").order(:code).pluck(:code).last
      ind = last_code.present? ? (last_code[9..].to_i + 1).to_s.rjust(2, '0') : '01'
      "TC#{region_code}#{ind}"
    end
  end
end
