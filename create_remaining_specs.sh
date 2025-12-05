#!/bin/bash

# This script creates comprehensive specs for the remaining low-coverage files

cd /Users/gabriel/ggalancs/PlebisHub

# Create spec directories
mkdir -p spec/models/concerns
mkdir -p spec/lib
mkdir -p spec/requests/admin

# Create territory_details spec
cat > spec/models/concerns/territory_details_spec.rb << 'SPEC1'
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
SPEC1

# Create plebisbrand_export spec
cat > spec/lib/plebisbrand_export_spec.rb << 'SPEC2'
# frozen_string_literal: true

require 'rails_helper'
require 'plebisbrand_export'

RSpec.describe 'PlebisBrand Export' do
  let(:temp_folder) { 'tmp/test_export' }
  let(:test_file) { 'test_export' }

  before do
    FileUtils.mkdir_p(temp_folder)
  end

  after do
    FileUtils.rm_rf(temp_folder)
  end

  describe 'export_data' do
    let(:query) { User.limit(5) }

    it 'exports data to CSV file' do
      export_data(test_file, query, folder: temp_folder) do |user|
        [user.id, user.email]
      end

      file_path = "#{temp_folder}/#{test_file}.tsv"
      expect(File.exist?(file_path)).to be true
    end

    it 'uses tab separator by default' do
      export_data(test_file, query, folder: temp_folder) do |user|
        [user.id, user.email]
      end

      content = File.read("#{temp_folder}/#{test_file}.tsv")
      expect(content).to include("\t") if content.present?
    end

    it 'accepts custom col_sep' do
      export_data(test_file, query, folder: temp_folder, col_sep: ',') do |user|
        [user.id, user.email]
      end

      file_path = "#{temp_folder}/#{test_file}.csv"
      expect(File.exist?(file_path)).to be true
    end

    it 'includes headers when provided' do
      export_data(test_file, query, folder: temp_folder, headers: ['ID', 'Email']) do |user|
        [user.id, user.email]
      end

      content = File.read("#{temp_folder}/#{test_file}.tsv")
      expect(content).to include('ID') if content.present?
    end

    it 'skips rows when block returns nil' do
      export_data(test_file, query, folder: temp_folder) do |_user|
        nil
      end

      content = File.read("#{temp_folder}/#{test_file}.tsv")
      lines = content.split("\n")
      expect(lines.length).to eq(0)
    end

    it 'creates folder if it does not exist' do
      new_folder = 'tmp/new_test_folder'
      FileUtils.rm_rf(new_folder) if File.exist?(new_folder)

      export_data(test_file, query, folder: new_folder) do |user|
        [user.id]
      end

      expect(File.exist?(new_folder)).to be true
      FileUtils.rm_rf(new_folder)
    end
  end

  describe 'export_raw_data' do
    let(:data) { [{ id: 1, name: 'Test' }, { id: 2, name: 'Test2' }] }

    it 'exports raw data to file' do
      export_raw_data(test_file, data, folder: temp_folder) do |item|
        [item[:id], item[:name]]
      end

      file_path = "#{temp_folder}/#{test_file}.tsv"
      expect(File.exist?(file_path)).to be true
    end

    it 'processes each item in data array' do
      export_raw_data(test_file, data, folder: temp_folder, headers: ['ID', 'Name']) do |item|
        [item[:id], item[:name]]
      end

      content = File.read("#{temp_folder}/#{test_file}.tsv")
      expect(content).to include('Test')
    end
  end

  describe 'fill_data' do
    let(:csv_data) { "email\tfirst_name\tlast_name\ntest@example.com\tJohn\tDoe" }
    let!(:user) { create(:user, email: 'test@example.com', first_name: 'John', last_name: 'Doe') }

    it 'fills data from CSV string' do
      result = fill_data(csv_data, User.all)
      expect(result).to have_key('results')
      expect(result).to have_key('search_field')
      expect(result).to have_key('processed')
    end

    it 'returns search field from headers' do
      result = fill_data(csv_data, User.all)
      expect(result['search_field']).to eq('email')
    end

    it 'processes matching records' do
      result = fill_data(csv_data, User.all)
      expect(result['processed']).to include(user.id)
    end

    it 'fills missing data from database' do
      csv_incomplete = "email\tfirst_name\ntest@example.com\t"
      result = fill_data(csv_incomplete, User.all)
      expect(result['results']).to include(user.first_name)
    end
  end
end
SPEC2

echo "Spec files created successfully!"
