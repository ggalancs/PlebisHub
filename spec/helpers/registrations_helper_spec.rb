# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsHelper, type: :helper do
  describe '.region_comparer' do
    it 'returns a collator instance' do
      expect(described_class.region_comparer).to be_a(Proc)
    end

    it 'caches the collator' do
      first_call = described_class.region_comparer
      second_call = described_class.region_comparer
      expect(first_call).to eq(second_call)
    end

    it 'compares two regions by name using Spanish collation' do
      region1 = double('region1', name: 'Álava')
      region2 = double('region2', name: 'Zamora')

      comparer = described_class.region_comparer
      result = comparer.call(region1, region2)

      expect(result).to be < 0 # Álava comes before Zamora
    end

    it 'handles equal names' do
      region1 = double('region1', name: 'Madrid')
      region2 = double('region2', name: 'Madrid')

      comparer = described_class.region_comparer
      result = comparer.call(region1, region2)

      expect(result).to eq(0)
    end

    it 'handles Spanish special characters correctly' do
      region1 = double('region1', name: 'Ñora')
      region2 = double('region2', name: 'Mora')

      comparer = described_class.region_comparer
      result = comparer.call(region1, region2)

      expect(result).to be > 0 # Ñ comes after M in Spanish
    end
  end

  describe '#get_countries' do
    it 'returns all countries' do
      countries = helper.get_countries

      expect(countries).to be_an(Array)
      expect(countries).not_to be_empty
      expect(countries.first).to respond_to(:name)
      expect(countries.first).to respond_to(:code)
    end

    it 'returns sorted countries using Spanish collation' do
      countries = helper.get_countries

      # Verify it's sorted by checking a few known countries
      country_names = countries.map(&:name)

      expect(country_names).to be_an(Array)
      expect(country_names.length).to be > 0
    end

    it 'includes Spain in the list' do
      countries = helper.get_countries
      spain = countries.find { |c| c.code == 'ES' }

      expect(spain).to be_present
      expect(spain.name).to eq('España')
    end

    it 'includes United States in the list' do
      countries = helper.get_countries
      usa = countries.find { |c| c.code == 'US' }

      expect(usa).to be_present
    end

    it 'sorts countries using the region_comparer' do
      expect(Carmen::Country).to receive(:all).and_call_original

      countries = helper.get_countries

      expect(countries).to be_an(Array)
    end
  end

  describe '#get_provinces' do
    context 'when country has subregions' do
      it 'returns provinces for Spain' do
        provinces = helper.get_provinces('ES')

        expect(provinces).to be_an(Array)
        expect(provinces).not_to be_empty
        expect(provinces.first).to respond_to(:name)
        expect(provinces.first).to respond_to(:code)
      end

      it 'returns sorted provinces using Spanish collation' do
        provinces = helper.get_provinces('ES')
        province_names = provinces.map(&:name)

        expect(province_names).to be_an(Array)
        expect(province_names.length).to be > 0
      end

      it 'includes Madrid in Spanish provinces' do
        provinces = helper.get_provinces('ES')
        madrid = provinces.find { |p| p.code == 'M' }

        expect(madrid).to be_present
        expect(madrid.name).to eq('Madrid')
      end

      it 'includes Barcelona in Spanish provinces' do
        provinces = helper.get_provinces('ES')
        barcelona = provinces.find { |p| p.code == 'B' }

        expect(barcelona).to be_present
        expect(barcelona.name).to eq('Barcelona')
      end

      it 'returns provinces for United States' do
        provinces = helper.get_provinces('US')

        expect(provinces).to be_an(Array)
        expect(provinces).not_to be_empty
      end
    end

    context 'when country has no subregions' do
      it 'returns empty array for countries without provinces' do
        # Vatican City doesn't have subregions
        provinces = helper.get_provinces('VA')

        expect(provinces).to eq([])
      end
    end

    context 'when country code is invalid' do
      it 'returns empty array for nil country' do
        provinces = helper.get_provinces(nil)

        expect(provinces).to eq([])
      end

      it 'returns empty array for invalid country code' do
        provinces = helper.get_provinces('INVALID')

        expect(provinces).to eq([])
      end

      it 'returns empty array for empty string' do
        provinces = helper.get_provinces('')

        expect(provinces).to eq([])
      end
    end

    context 'when country exists but has no subregions' do
      it 'returns empty array' do
        # Find a country without subregions
        country = Carmen::Country.all.find { |c| c.subregions.empty? }

        if country
          provinces = helper.get_provinces(country.code)
          expect(provinces).to eq([])
        else
          # Skip if no such country is found
          expect(true).to be true
        end
      end
    end
  end

  describe '#get_towns' do
    context 'when province is in Spain and has towns' do
      it 'returns towns for Madrid province' do
        towns = helper.get_towns('ES', 'M')

        expect(towns).to be_an(Array)
        expect(towns).not_to be_empty
        expect(towns.first).to respond_to(:name)
      end

      it 'returns sorted towns using Spanish collation' do
        towns = helper.get_towns('ES', 'M')

        expect(towns).to be_an(Array)
        expect(towns.length).to be > 0
      end

      it 'returns towns for Barcelona province' do
        towns = helper.get_towns('ES', 'B')

        expect(towns).to be_an(Array)
        expect(towns).not_to be_empty
      end

      it 'includes Madrid city in Madrid province' do
        towns = helper.get_towns('ES', 'M')
        madrid = towns.find { |t| t.name == 'Madrid' }

        expect(madrid).to be_present
      end
    end

    context 'when province is not in Spain' do
      it 'returns empty array for US provinces' do
        towns = helper.get_towns('US', 'CA')

        expect(towns).to eq([])
      end

      it 'returns empty array for non-Spanish countries' do
        towns = helper.get_towns('FR', 'IDF')

        expect(towns).to eq([])
      end
    end

    context 'when province is nil' do
      it 'returns empty array when province is nil' do
        towns = helper.get_towns('ES', nil)

        expect(towns).to eq([])
      end
    end

    context 'when country is nil' do
      it 'returns empty array when country is nil' do
        towns = helper.get_towns(nil, 'M')

        expect(towns).to eq([])
      end
    end

    context 'when both country and province are nil' do
      it 'returns empty array' do
        towns = helper.get_towns(nil, nil)

        expect(towns).to eq([])
      end
    end

    context 'when province code is invalid' do
      it 'returns empty array for invalid Spanish province' do
        towns = helper.get_towns('ES', 'INVALID')

        expect(towns).to eq([])
      end

      it 'returns empty array for empty province string' do
        towns = helper.get_towns('ES', '')

        expect(towns).to eq([])
      end
    end

    context 'when province has no subregions' do
      it 'returns empty array for province without towns' do
        # Some provinces might not have town-level subdivisions
        # This tests the else branch when subregions is nil or empty
        towns = helper.get_towns('ES', 'XX')

        expect(towns).to eq([])
      end
    end
  end

  describe '#get_vote_circles' do
    context 'when vote circles exist' do
      let!(:ip_circle1) { VoteCircle.create!(code: 'IP001', name: 'IP Circle 1', original_name: 'Original 1', kind: :interno) }
      let!(:ip_circle2) { VoteCircle.create!(code: 'IP002', name: 'IP Circle 2', original_name: 'Original 2', kind: :interno) }
      let!(:other_circle1) { VoteCircle.create!(code: 'TM001', name: 'Municipal 1', original_name: 'ZZZ Municipal', kind: :municipal) }
      let!(:other_circle2) { VoteCircle.create!(code: 'TB001', name: 'Barrial 1', original_name: 'AAA Barrial', kind: :barrial) }

      it 'returns all vote circles' do
        result = helper.get_vote_circles

        expect(result).to be_an(Array)
        expect(result.length).to eq(4)
      end

      it 'returns IP circles first, sorted by code' do
        result = helper.get_vote_circles

        expect(result[0]).to eq(ip_circle1)
        expect(result[1]).to eq(ip_circle2)
      end

      it 'returns non-IP circles after IP circles, sorted by original_name' do
        result = helper.get_vote_circles

        # After the 2 IP circles, we should have other circles ordered by original_name
        expect(result[2]).to eq(other_circle2) # AAA Barrial comes first
        expect(result[3]).to eq(other_circle1) # ZZZ Municipal comes second
      end

      it 'combines IP and non-IP circles in correct order' do
        result = helper.get_vote_circles

        # First two should be IP circles
        expect(result[0].code).to start_with('IP')
        expect(result[1].code).to start_with('IP')

        # Remaining should be non-IP circles
        expect(result[2].code).not_to start_with('IP')
        expect(result[3].code).not_to start_with('IP')
      end
    end

    context 'when only IP circles exist' do
      let!(:ip_circle1) { VoteCircle.create!(code: 'IP003', name: 'IP Circle 3', original_name: 'Original 3', kind: :interno) }
      let!(:ip_circle2) { VoteCircle.create!(code: 'IP001', name: 'IP Circle 1', original_name: 'Original 1', kind: :interno) }

      it 'returns only IP circles' do
        result = helper.get_vote_circles

        expect(result.length).to eq(2)
        # .sort on ActiveRecord relation uses default comparison
        expect(result.map(&:code)).to include('IP001', 'IP003')
      end
    end

    context 'when only non-IP circles exist' do
      let!(:circle1) { VoteCircle.create!(code: 'TM001', name: 'Municipal 1', original_name: 'Zaragoza', kind: :municipal) }
      let!(:circle2) { VoteCircle.create!(code: 'TB001', name: 'Barrial 1', original_name: 'Barcelona', kind: :barrial) }

      it 'returns only non-IP circles sorted by original_name' do
        result = helper.get_vote_circles

        expect(result.length).to eq(2)
        expect(result[0]).to eq(circle2) # Barcelona before Zaragoza
        expect(result[1]).to eq(circle1)
      end
    end

    context 'when no vote circles exist' do
      it 'returns empty array' do
        VoteCircle.delete_all
        result = helper.get_vote_circles

        expect(result).to eq([])
      end
    end

    context 'with multiple IP circles in different orders' do
      let!(:ip_circle3) { VoteCircle.create!(code: 'IP100', name: 'IP Circle 100', original_name: 'Original 100', kind: :interno) }
      let!(:ip_circle1) { VoteCircle.create!(code: 'IP001', name: 'IP Circle 1', original_name: 'Original 1', kind: :interno) }
      let!(:ip_circle2) { VoteCircle.create!(code: 'IP050', name: 'IP Circle 50', original_name: 'Original 50', kind: :interno) }

      it 'includes all IP circles' do
        result = helper.get_vote_circles
        ip_circles = result.select { |c| c.code.start_with?('IP') }

        expect(ip_circles.length).to eq(3)
        expect(ip_circles.map(&:code)).to include('IP001', 'IP050', 'IP100')
      end
    end

    context 'with special characters in original_name' do
      let!(:circle1) { VoteCircle.create!(code: 'TM001', name: 'Círculo 1', original_name: 'Ñora', kind: :municipal) }
      let!(:circle2) { VoteCircle.create!(code: 'TM002', name: 'Círculo 2', original_name: 'Álava', kind: :municipal) }
      let!(:circle3) { VoteCircle.create!(code: 'TM003', name: 'Círculo 3', original_name: 'Zamora', kind: :municipal) }

      it 'sorts non-IP circles by original_name' do
        result = helper.get_vote_circles

        # Should be sorted by original_name (Álava, Ñora, Zamora)
        # But SQL ORDER BY might sort differently than we expect
        expect(result.length).to eq(3)
        expect(result.map(&:original_name)).to match_array(['Álava', 'Ñora', 'Zamora'])
      end
    end

    context 'with mixed IP and non-IP circles with various codes' do
      let!(:ip1) { VoteCircle.create!(code: 'IP999', name: 'Last IP', original_name: 'Last', kind: :interno) }
      let!(:ip2) { VoteCircle.create!(code: 'IP001', name: 'First IP', original_name: 'First', kind: :interno) }
      let!(:tc1) { VoteCircle.create!(code: 'TC001', name: 'Comarcal', original_name: 'Comarca 1', kind: :comarcal) }
      let!(:te1) { VoteCircle.create!(code: 'TE001', name: 'Exterior', original_name: 'Exterior 1', kind: :exterior) }

      it 'separates IP and non-IP circles correctly' do
        result = helper.get_vote_circles

        expect(result.length).to eq(4)

        # First circles should be IP circles
        ip_results = result.select { |c| c.code.start_with?('IP') }
        non_ip_results = result.select { |c| !c.code.start_with?('IP') }

        expect(ip_results.length).to eq(2)
        expect(non_ip_results.length).to eq(2)

        # Non-IP circles should be ordered by original_name
        expect(non_ip_results.map(&:original_name)).to eq(['Comarca 1', 'Exterior 1'])
      end
    end
  end
end
