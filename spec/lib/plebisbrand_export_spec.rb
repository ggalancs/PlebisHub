# frozen_string_literal: true

require 'rails_helper'
require_relative '../../lib/plebisbrand_export'
require 'csv'

RSpec.describe 'PlebisbrandExport' do
  let(:temp_dir) { Dir.mktmpdir }

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe 'export_data' do
    let(:users) { [
      double('User', id: 1, email: 'user1@example.com', first_name: 'John'),
      double('User', id: 2, email: 'user2@example.com', first_name: 'Jane')
    ] }
    let(:query) { double('Query') }

    before do
      allow(query).to receive(:find_each).and_yield(users[0]).and_yield(users[1])
    end

    it 'exports data to CSV file' do
      export_data('test', query, folder: temp_dir) do |user|
        [user.id, user.email]
      end

      expect(File).to exist("#{temp_dir}/test.tsv")
    end

    it 'uses tab separator by default' do
      export_data('test', query, folder: temp_dir) do |user|
        [user.id, user.email]
      end

      content = File.read("#{temp_dir}/test.tsv")
      expect(content).to include("\t")
    end

    it 'creates CSV file when col_sep is comma' do
      export_data('test', query, folder: temp_dir, col_sep: ',') do |user|
        [user.id, user.email]
      end

      expect(File).to exist("#{temp_dir}/test.csv")
    end

    it 'writes headers when provided' do
      export_data('test', query, folder: temp_dir, headers: ['ID', 'Email']) do |user|
        [user.id, user.email]
      end

      content = File.read("#{temp_dir}/test.tsv")
      expect(content.lines.first).to include('ID')
      expect(content.lines.first).to include('Email')
    end

    it 'processes all records from query' do
      counter = 0
      export_data('test', query, folder: temp_dir) do |_user|
        counter += 1
        [counter]
      end

      expect(counter).to eq(2)
    end

    it 'skips nil results from block' do
      export_data('test', query, folder: temp_dir) do |user|
        user.id == 1 ? [user.email] : nil
      end

      content = File.read("#{temp_dir}/test.tsv")
      expect(content.lines.count).to eq(1)
    end

    it 'creates folder if it does not exist' do
      non_existent = File.join(temp_dir, 'deep/nested/folder')
      export_data('test', query, folder: non_existent) do |user|
        [user.id]
      end

      expect(File).to exist("#{non_existent}/test.tsv")
    end

    it 'uses force_quotes option' do
      export_data('test', query, folder: temp_dir, force_quotes: true) do |user|
        [user.email]
      end

      expect(File).to exist("#{temp_dir}/test.tsv")
    end
  end

  describe 'export_raw_data' do
    let(:data) { [
      { id: 1, name: 'Item 1' },
      { id: 2, name: 'Item 2' }
    ] }

    it 'exports raw data to file' do
      export_raw_data('test', data, folder: temp_dir) do |item|
        [item[:id], item[:name]]
      end

      expect(File).to exist("#{temp_dir}/test.tsv")
    end

    it 'creates CSV with comma separator' do
      export_raw_data('test', data, folder: temp_dir, col_sep: ',') do |item|
        [item[:id]]
      end

      expect(File).to exist("#{temp_dir}/test.csv")
    end

    it 'writes headers' do
      export_raw_data('test', data, folder: temp_dir, headers: ['ID', 'Name']) do |item|
        [item[:id], item[:name]]
      end

      content = File.read("#{temp_dir}/test.tsv")
      expect(content.lines.first).to include('ID')
    end

    it 'processes all data items' do
      counter = 0
      export_raw_data('test', data, folder: temp_dir) do |_item|
        counter += 1
        [counter]
      end

      expect(counter).to eq(2)
    end

    it 'skips nil results' do
      export_raw_data('test', data, folder: temp_dir) do |item|
        item[:id] == 1 ? [item[:name]] : nil
      end

      content = File.read("#{temp_dir}/test.tsv")
      expect(content.lines.count).to eq(1)
    end
  end

  describe 'fill_data' do
    let(:csv_data) { "document_vatid\tname\tage\n12345678A\tJohn\t\n87654321B\tJane\t" }
    let(:query) { double('Query') }
    let(:users) { [
      double('User', document_vatid: '12345678A', name: 'John Doe', age: 30),
      double('User', document_vatid: '87654321B', name: 'Jane Smith', age: 25)
    ] }

    before do
      allow(query).to receive(:where).and_return(query)
      allow(query).to receive(:find_each).and_yield(users[0]).and_yield(users[1])
    end

    it 'returns hash with results key' do
      result = fill_data(csv_data, query, col_sep: "\t")
      expect(result).to have_key('results')
    end

    it 'returns hash with search_field key' do
      result = fill_data(csv_data, query, col_sep: "\t")
      expect(result).to have_key('search_field')
      expect(result['search_field']).to eq('document_vatid')
    end

    it 'returns hash with processed key' do
      result = fill_data(csv_data, query, col_sep: "\t")
      expect(result).to have_key('processed')
      expect(result['processed']).to be_an(Array)
    end

    it 'fills data with values from database' do
      allow(users[0]).to receive(:respond_to?).with(:name).and_return(true)
      allow(users[0]).to receive(:respond_to?).with(:age).and_return(true)
      allow(users[0]).to receive(:send).with('document_vatid').and_return('12345678A')
      allow(users[0]).to receive(:send).with(:name).and_return('John Doe')
      allow(users[0]).to receive(:send).with(:age).and_return(30)
      allow(users[0]).to receive(:id).and_return(1)

      result = fill_data(csv_data, query, col_sep: "\t")
      expect(result['results']).to include('John Doe')
    end

    it 'generates CSV text' do
      result = fill_data(csv_data, query, col_sep: "\t")
      expect(result['results']).to be_a(String)
    end
  end
end
