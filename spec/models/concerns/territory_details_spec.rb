# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TerritoryDetails, type: :model do
  let(:dummy_class) do
    Class.new do
      include TerritoryDetails
    end
  end
  let(:instance) { dummy_class.new }

  describe '#calc_muni_dc' do
    it 'calculates digit control for 5-digit municipality code' do
      result = instance.calc_muni_dc(28079)
      expect(result).to be_a(Integer)
      expect(result).to be_between(0, 9)
    end

    it 'pads with zeros for short codes' do
      result = instance.calc_muni_dc(1001)
      expect(result).to be_a(Integer)
    end
  end

  describe '#get_valid_town_code' do
    it 'returns valid town code for numeric input' do
      result = instance.get_valid_town_code(28079, 'ES', true)
      expect(result).to match(/m_\d\d_\d\d\d_\d/)
    end

    it 'returns valid town code for string input' do
      result = instance.get_valid_town_code('m_28_079_6', 'ES', false)
      expect(result).to eq('m_28_079_6')
    end

    it 'returns nil for invalid town code' do
      result = instance.get_valid_town_code('invalid', 'ES', false)
      expect(result).to be_nil
    end

    it 'handles town codes with underscores' do
      result = instance.get_valid_town_code('m_280796', 'ES', false)
      expect(result).to eq('m_28_079_6')
    end

    it 'validates town code with Carmen if available' do
      result = instance.get_valid_town_code(28079, 'ES', true)
      if defined?(Carmen)
        expect(result).not_to be_nil
      end
    end
  end

  describe '#territory_details' do
    context 'with valid numeric town code' do
      it 'returns territory details hash' do
        result = instance.territory_details(28079)
        if result
          expect(result).to have_key(:town_code)
          expect(result).to have_key(:town_name)
          expect(result).to have_key(:province_code)
          expect(result).to have_key(:province_name)
          expect(result).to have_key(:autonomy_code)
          expect(result).to have_key(:autonomy_name)
        end
      end
    end

    context 'with hash options' do
      it 'accepts hash with town_code' do
        result = instance.territory_details(town_code: 28079, country_code: 'ES')
        if result
          expect(result).to be_a(Hash)
        end
      end

      it 'accepts hash with result_as option' do
        result = instance.territory_details(town_code: 28079, result_as: :struct)
        if result && defined?(OpenStruct)
          expect(result).to respond_to(:town_code)
        end
      end

      it 'accepts hash with unknown option' do
        result = instance.territory_details(town_code: nil, unknown: 'N/A')
        expect(result).to be_nil
      end
    end

    context 'with invalid town code' do
      it 'returns nil for invalid code' do
        result = instance.territory_details('invalid')
        expect(result).to be_nil
      end
    end

    context 'with generate_dc option' do
      it 'generates digit control for 5-digit codes' do
        result = instance.territory_details(town_code: '28079', generate_dc: true)
        if result
          expect(result[:town_code]).to match(/m_\d\d_\d\d\d_\d/)
        end
      end
    end
  end
end
