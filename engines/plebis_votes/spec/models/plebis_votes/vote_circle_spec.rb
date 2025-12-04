# frozen_string_literal: true

require 'rails_helper'

module PlebisVotes
  RSpec.describe VoteCircle, type: :model do
    let(:vote_circle) do
      VoteCircle.create!(
        name: 'Test Circle',
        code: 'TM010101001',
        kind: :municipal
      )
    end

    describe 'enums' do
      it 'defines kind enum' do
        expect(VoteCircle.kinds).to eq(
          'interno' => 0,
          'barrial' => 1,
          'municipal' => 2,
          'comarcal' => 3,
          'exterior' => 4
        )
      end

      it 'can set interno kind' do
        vote_circle.interno!
        expect(vote_circle.interno?).to be_truthy
      end

      it 'can set barrial kind' do
        vote_circle.barrial!
        expect(vote_circle.barrial?).to be_truthy
      end

      it 'can set municipal kind' do
        vote_circle.municipal!
        expect(vote_circle.municipal?).to be_truthy
      end

      it 'can set comarcal kind' do
        vote_circle.comarcal!
        expect(vote_circle.comarcal?).to be_truthy
      end

      it 'can set exterior kind' do
        vote_circle.exterior!
        expect(vote_circle.exterior?).to be_truthy
      end
    end

    describe 'scopes' do
      before do
        VoteCircle.destroy_all
      end

      describe '.in_spain' do
        it 'includes barrial circles' do
          barrial = VoteCircle.create!(name: 'Barrial', code: 'TB01', kind: :barrial)
          expect(VoteCircle.in_spain).to include(barrial)
        end

        it 'includes municipal circles' do
          municipal = VoteCircle.create!(name: 'Municipal', code: 'TM01', kind: :municipal)
          expect(VoteCircle.in_spain).to include(municipal)
        end

        it 'includes comarcal circles' do
          comarcal = VoteCircle.create!(name: 'Comarcal', code: 'TC01', kind: :comarcal)
          expect(VoteCircle.in_spain).to include(comarcal)
        end

        it 'excludes interno circles' do
          interno = VoteCircle.create!(name: 'Interno', code: 'IN01', kind: :interno)
          expect(VoteCircle.in_spain).not_to include(interno)
        end

        it 'excludes exterior circles' do
          exterior = VoteCircle.create!(name: 'Exterior', code: 'EX01', kind: :exterior)
          expect(VoteCircle.in_spain).not_to include(exterior)
        end
      end

      describe '.not_interno' do
        it 'excludes interno circles' do
          interno = VoteCircle.create!(name: 'Interno', code: 'IN01', kind: :interno)
          expect(VoteCircle.not_interno).not_to include(interno)
        end

        it 'includes all other kinds' do
          barrial = VoteCircle.create!(name: 'Barrial', code: 'TB01', kind: :barrial)
          municipal = VoteCircle.create!(name: 'Municipal', code: 'TM01', kind: :municipal)
          expect(VoteCircle.not_interno).to include(barrial, municipal)
        end
      end
    end

    describe '#is_active?' do
      it 'returns true for non-interno circles' do
        vote_circle.kind = :municipal
        expect(vote_circle.is_active?).to be_truthy
      end

      it 'returns false for interno circles' do
        vote_circle.kind = :interno
        expect(vote_circle.is_active?).to be_falsey
      end
    end

    describe '#in_spain?' do
      it 'returns true for barrial' do
        vote_circle.kind = :barrial
        expect(vote_circle.in_spain?).to be_truthy
      end

      it 'returns true for municipal' do
        vote_circle.kind = :municipal
        expect(vote_circle.in_spain?).to be_truthy
      end

      it 'returns true for comarcal' do
        vote_circle.kind = :comarcal
        expect(vote_circle.in_spain?).to be_truthy
      end

      it 'returns false for interno' do
        vote_circle.kind = :interno
        expect(vote_circle.in_spain?).to be_falsey
      end

      it 'returns false for exterior' do
        vote_circle.kind = :exterior
        expect(vote_circle.in_spain?).to be_falsey
      end
    end

    describe '#code_in_spain?' do
      it 'returns true for TB code' do
        vote_circle.code = 'TB01010100101'
        expect(vote_circle.code_in_spain?).to be_truthy
      end

      it 'returns true for TM code' do
        vote_circle.code = 'TM01010100101'
        expect(vote_circle.code_in_spain?).to be_truthy
      end

      it 'returns true for TC code' do
        vote_circle.code = 'TC01010100101'
        expect(vote_circle.code_in_spain?).to be_truthy
      end

      it 'returns false for other codes' do
        vote_circle.code = 'XX01010100101'
        expect(vote_circle.code_in_spain?).to be_falsey
      end
    end

    describe '#get_type_circle_from_original_code' do
      it 'returns original code prefix when in spain' do
        vote_circle.kind = :municipal
        vote_circle.original_code = 'TM01'
        expect(vote_circle.get_type_circle_from_original_code).to eq('TM')
      end

      it 'returns "00" when not in spain' do
        vote_circle.kind = :exterior
        expect(vote_circle.get_type_circle_from_original_code).to eq('00')
      end
    end

    describe '#island_name' do
      it 'returns island name when island_code is set' do
        vote_circle.island_code = 'i_07'
        expect(vote_circle.island_name).to be_a(String)
      end

      it 'returns empty string when no island data' do
        vote_circle.island_code = nil
        vote_circle.town = nil
        expect(vote_circle.island_name).to eq('')
      end
    end

    describe '#town_name' do
      it 'returns town name for valid code' do
        vote_circle.town = 'm_28_079_6'
        name = vote_circle.town_name
        expect(name).to be_a(String)
        expect(name).not_to be_empty
      end

      it 'returns error message for invalid code' do
        vote_circle.town = 'm_99_999_9'
        expect(vote_circle.town_name).to include('no es un municipio válido')
      end

      it 'returns empty string when town is nil' do
        vote_circle.town = nil
        expect(vote_circle.town_name).to eq('')
      end
    end

    describe '#province_name' do
      it 'returns province name for valid code' do
        vote_circle.province_code = 'p_28'
        name = vote_circle.province_name
        expect(name).to be_a(String)
        expect(name).not_to be_empty
      end

      it 'returns empty string when province_code is nil' do
        vote_circle.province_code = nil
        expect(vote_circle.province_name).to eq('')
      end
    end

    describe '#autonomy_name' do
      it 'returns autonomy name for valid province code' do
        vote_circle.province_code = 'p_28'
        name = vote_circle.autonomy_name
        expect(name).to be_a(String)
        expect(name).not_to be_empty
      end

      it 'returns empty string when province_code is nil' do
        vote_circle.province_code = nil
        expect(vote_circle.autonomy_name).to eq('')
      end
    end

    describe '#country_name' do
      it 'returns country name for valid code' do
        vote_circle.country_code = 'ES'
        expect(vote_circle.country_name).to eq('Spain')
      end

      it 'returns empty string for invalid code' do
        vote_circle.country_code = 'INVALID'
        expect(vote_circle.country_name).to eq('')
      end
    end

    describe '#get_code_circle' do
      it 'generates TM code for municipal circle' do
        code = vote_circle.get_code_circle('m_28_079_6', 'TM')
        expect(code).to start_with('TM')
        expect(code.length).to be > 5
      end

      it 'generates TB code for barrial circle' do
        code = vote_circle.get_code_circle('m_28_079_6', 'TB')
        expect(code).to start_with('TB')
      end

      it 'generates TC code for comarcal circle' do
        code = vote_circle.get_code_circle('m_28_079_6', 'TC')
        expect(code).to start_with('TC')
      end

      it 'returns "00" for exterior circles' do
        code = vote_circle.get_code_circle('m_28_079_6', '00')
        expect(code).to eq('00')
      end
    end

    describe 'ransackable attributes' do
      it 'defines ransackable_attributes' do
        attrs = VoteCircle.ransackable_attributes
        expect(attrs).to be_an(Array)
        expect(attrs).to include('name', 'code', 'kind')
      end
    end

    describe 'ransackers' do
      it 'defines vote_circle_province_id ransacker' do
        expect(VoteCircle._ransackers).to have_key('vote_circle_province_id')
      end

      it 'defines vote_circle_autonomy_id ransacker' do
        expect(VoteCircle._ransackers).to have_key('vote_circle_autonomy_id')
      end
    end

    describe 'concern inclusion' do
      it 'includes TerritoryDetails' do
        expect(VoteCircle.included_modules).to include(PlebisVotes::TerritoryDetails)
      end
    end

    describe 'circle_type accessor' do
      it 'has circle_type accessor' do
        expect(vote_circle).to respond_to(:circle_type)
        expect(vote_circle).to respond_to(:circle_type=)
      end

      it 'can set and get circle_type' do
        vote_circle.circle_type = 'TM'
        expect(vote_circle.circle_type).to eq('TM')
      end
    end
  end
end
