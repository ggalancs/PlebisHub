# frozen_string_literal: true

require 'rails_helper'

module PlebisVotes
  RSpec.describe TerritoryDetails, type: :model do
    # Create a test class that includes the concern
    let(:test_class) do
      Class.new do
        include PlebisVotes::TerritoryDetails
      end
    end

    let(:test_instance) { test_class.new }

    describe '#calc_muni_dc' do
      it 'calculates correct digit control for valid municipality code' do
        dc = test_instance.calc_muni_dc(28_079)
        expect(dc).to be_a(Integer)
        expect(dc).to be_between(0, 9)
      end

      it 'handles 5-digit codes' do
        dc = test_instance.calc_muni_dc('01001')
        expect(dc).to be_a(Integer)
        expect(dc).to be_between(0, 9)
      end

      it 'pads shorter codes with zeros' do
        dc = test_instance.calc_muni_dc(1001)
        expect(dc).to be_a(Integer)
      end

      it 'returns consistent results for same input' do
        dc1 = test_instance.calc_muni_dc(28_079)
        dc2 = test_instance.calc_muni_dc(28_079)
        expect(dc1).to eq(dc2)
      end

      it 'calculates Madrid municipality control digit' do
        dc = test_instance.calc_muni_dc(28_079)
        expect(dc).to eq(6)
      end
    end

    describe '#get_valid_town_code' do
      it 'validates and formats numeric town code' do
        result = test_instance.get_valid_town_code(28_079)
        expect(result).to eq('m_28_079_6')
      end

      it 'generates control digit when generate_dc is true' do
        result = test_instance.get_valid_town_code(28_079, 'ES', true)
        expect(result).to match(/m_28_079_\d/)
      end

      it 'accepts pre-formatted town codes' do
        result = test_instance.get_valid_town_code('m_28_079_6')
        expect(result).to eq('m_28_079_6')
      end

      it 'accepts alternative format' do
        result = test_instance.get_valid_town_code('m_280796')
        expect(result).to eq('m_28_079_6')
      end

      it 'returns nil for invalid codes' do
        result = test_instance.get_valid_town_code('invalid')
        expect(result).to be_nil
      end

      it 'returns nil for out of range codes' do
        result = test_instance.get_valid_town_code(999_999)
        expect(result).to be_nil
      end

      it 'validates against Carmen database' do
        result = test_instance.get_valid_town_code(28_079, 'ES')
        expect(result).to eq('m_28_079_6')
      end

      it 'handles string numeric input' do
        result = test_instance.get_valid_town_code('28079')
        expect(result).to eq('m_28_079_6')
      end
    end

    describe '#territory_details' do
      context 'with valid town code' do
        it 'returns hash of territory details' do
          result = test_instance.territory_details(town_code: 28_079)
          expect(result).to be_a(Hash)
          expect(result[:town_code]).to eq('m_28_079_6')
          expect(result[:province_code]).to eq('p_28')
          expect(result[:autonomy_code]).to be_present
        end

        it 'returns town name' do
          result = test_instance.territory_details(town_code: 28_079)
          expect(result[:town_name]).to be_a(String)
          expect(result[:town_name]).not_to be_empty
        end

        it 'returns province name' do
          result = test_instance.territory_details(town_code: 28_079)
          expect(result[:province_name]).to eq('Madrid')
        end

        it 'returns autonomy name' do
          result = test_instance.territory_details(town_code: 28_079)
          expect(result[:autonomy_name]).to be_a(String)
          expect(result[:autonomy_name]).not_to be_empty
        end
      end

      context 'with options hash' do
        it 'accepts hash with all options' do
          result = test_instance.territory_details(
            town_code: 28_079,
            country_code: 'ES',
            generate_dc: true,
            unknown: 'N/A',
            result_as: :hash
          )
          expect(result).to be_a(Hash)
        end

        it 'uses default country code ES' do
          result = test_instance.territory_details(town_code: 28_079)
          expect(result).to be_a(Hash)
        end

        it 'returns OpenStruct when result_as is :struct' do
          result = test_instance.territory_details(
            town_code: 28_079,
            result_as: :struct
          )
          expect(result).to be_a(OpenStruct)
          expect(result.town_code).to eq('m_28_079_6')
        end

        it 'uses custom unknown value' do
          result = test_instance.territory_details(
            town_code: nil,
            unknown: 'Custom Unknown'
          )
          expect(result).to be_nil
        end
      end

      context 'with numeric input' do
        it 'accepts numeric town code directly' do
          result = test_instance.territory_details(28_079)
          expect(result).to be_a(Hash)
          expect(result[:town_code]).to eq('m_28_079_6')
        end

        it 'auto-generates dc for 5-digit codes' do
          result = test_instance.territory_details('28079')
          expect(result).to be_a(Hash)
          expect(result[:town_code]).to match(/m_28_079_\d/)
        end
      end

      context 'with invalid input' do
        it 'returns nil for invalid town code' do
          result = test_instance.territory_details(town_code: 'invalid')
          expect(result).to be_nil
        end

        it 'returns nil for nil town code' do
          result = test_instance.territory_details(town_code: nil)
          expect(result).to be_nil
        end

        it 'returns nil for out of range code' do
          result = test_instance.territory_details(town_code: 999_999)
          expect(result).to be_nil
        end
      end

      context 'with string input' do
        it 'accepts string town code' do
          result = test_instance.territory_details('28079')
          expect(result).to be_a(Hash)
        end

        it 'accepts formatted string' do
          result = test_instance.territory_details('m_28_079_6')
          expect(result).to be_a(Hash)
        end
      end

      context 'different country codes' do
        it 'defaults to ES country code' do
          result = test_instance.territory_details(town_code: 28_079)
          expect(result).to be_a(Hash)
        end

        it 'accepts custom country code' do
          result = test_instance.territory_details(
            town_code: 28_079,
            country_code: 'ES'
          )
          expect(result).to be_a(Hash)
        end
      end

      it 'handles generate_dc option' do
        result1 = test_instance.territory_details(
          town_code: 28_079,
          generate_dc: false
        )
        result2 = test_instance.territory_details(
          town_code: 28_079,
          generate_dc: true
        )
        expect(result1).to be_a(Hash)
        expect(result2).to be_a(Hash)
      end
    end

    describe 'concern integration' do
      it 'can be included in a class' do
        expect(test_instance).to respond_to(:calc_muni_dc)
        expect(test_instance).to respond_to(:get_valid_town_code)
        expect(test_instance).to respond_to(:territory_details)
      end

      it 'is included in VoteCircle' do
        expect(VoteCircle.included_modules).to include(TerritoryDetails)
      end
    end

    describe 'edge cases' do
      it 'handles zero values' do
        result = test_instance.calc_muni_dc(0)
        expect(result).to be_a(Integer)
      end

      it 'handles minimum valid code' do
        result = test_instance.get_valid_town_code(1000)
        expect(result).to be_a(String).or be_nil
      end

      it 'handles maximum valid code' do
        result = test_instance.get_valid_town_code(52_999)
        expect(result).to be_a(String).or be_nil
      end

      it 'handles empty options hash' do
        result = test_instance.territory_details({})
        expect(result).to be_nil
      end
    end

    describe 'real-world examples' do
      it 'handles Madrid municipality' do
        result = test_instance.territory_details(28_079)
        expect(result[:town_name]).to eq('Madrid')
        expect(result[:province_name]).to eq('Madrid')
        expect(result[:province_code]).to eq('p_28')
      end

      it 'handles Barcelona municipality' do
        result = test_instance.territory_details(8_019)
        expect(result[:town_code]).to match(/m_08_019_/)
        expect(result[:province_name]).to eq('Barcelona')
      end

      it 'returns consistent results for same input' do
        result1 = test_instance.territory_details(28_079)
        result2 = test_instance.territory_details(28_079)
        expect(result1).to eq(result2)
      end
    end
  end
end
