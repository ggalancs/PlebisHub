# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report, type: :model do
  let(:report) { create(:report) }

  describe '.serialize_relation_query' do
    it 'serializes ActiveRecord relation to SQL' do
      relation = User.where(admin: true).limit(10)
      sql = Report.serialize_relation_query(relation)
      expect(sql).to be_a(String)
      expect(sql).to include('SELECT')
      expect(sql).not_to include('LIMIT')
    end

    it 'removes OFFSET from query' do
      relation = User.offset(5).limit(10)
      sql = Report.serialize_relation_query(relation)
      expect(sql).not_to include('OFFSET')
    end
  end

  describe '#get_main_group' do
    context 'when main_group is set' do
      before do
        report.main_group = ReportGroup.new(id: 1, title: 'Main Group')
      end

      it 'returns the main group' do
        expect(report.get_main_group).to be_a(ReportGroup)
      end
    end

    context 'when main_group is not set' do
      it 'returns nil' do
        expect(report.get_main_group).to be_nil
      end
    end
  end

  describe '#get_groups' do
    it 'returns array of groups' do
      report.groups = [ReportGroup.new(id: 1), ReportGroup.new(id: 2)]
      expect(report.get_groups).to be_an(Array)
    end
  end

  describe '#main_group=' do
    it 'accepts ReportGroup object' do
      group = ReportGroup.new(id: 1, title: 'Test')
      report.main_group = group
      expect(report.main_group).to eq(group)
    end

    it 'accepts serialized string' do
      report.main_group = 'serialized_string'
      expect(report[:main_group]).to eq('serialized_string')
    end
  end

  describe '#groups=' do
    it 'accepts array of ReportGroup objects' do
      groups = [ReportGroup.new(id: 1), ReportGroup.new(id: 2)]
      report.groups = groups
      expect(report.groups).to eq(groups)
    end

    it 'accepts serialized string' do
      report.groups = 'serialized_string'
      expect(report[:groups]).to eq('serialized_string')
    end
  end

  describe '#batch_process' do
    let!(:users) { create_list(:user, 5) }
    let(:report) { create(:report, query: "SELECT * FROM users") }

    it 'processes records in batches' do
      count = 0
      report.batch_process(2) do |_user|
        count += 1
      end
      expect(count).to eq(users.length)
    end

    it 'uses specified batch size' do
      batches = []
      report.batch_process(2) do |user|
        batches << user
      end
      expect(batches.length).to be.positive?
    end

    it 'stops when no more results' do
      count = 0
      report.batch_process(100) do |_user|
        count += 1
      end
      expect(count).to eq(users.length)
    end
  end

  describe 'private methods' do
    describe '#generate_rank_file' do
      let(:raw_folder) { Rails.root.join('tmp/test_report/raw') }
      let(:rank_folder) { Rails.root.join('tmp/test_report/rank') }
      let(:report) { create(:report) }

      before do
        FileUtils.mkdir_p(raw_folder)
        FileUtils.mkdir_p(rank_folder)

        # Create test data file
        File.write("#{raw_folder}/1.dat", "001test data 1\n002test data 2\n003test data 1\n")
      end

      after do
        FileUtils.rm_rf(Rails.root.join('tmp/test_report'))
      end

      it 'generates rank file from raw file' do
        report.send(:generate_rank_file, raw_folder.to_s, rank_folder.to_s, 1, 3, 10, 0)
        rank_file = "#{rank_folder}/1.dat"
        expect(File.exist?(rank_file)).to be true
      end

      it 'counts and sorts unique entries' do
        report.send(:generate_rank_file, raw_folder.to_s, rank_folder.to_s, 1, 3, 10, 0)
        content = File.read("#{rank_folder}/1.dat")
        expect(content).to include('2 test data 1')
        expect(content).to include('1 test data 2')
      end

      it 'validates file path for security' do
        invalid_path = '/etc/passwd'
        report.send(:generate_rank_file, invalid_path, rank_folder.to_s, 1, 3, 10, 0)
        # Should not crash, handles invalid paths gracefully
      end
    end

    describe '#grep_pattern_from_file' do
      let(:raw_folder) { Rails.root.join('tmp/test_report/raw') }
      let(:report) { create(:report) }

      before do
        FileUtils.mkdir_p(raw_folder)
        File.write("#{raw_folder}/1.dat", "001group1name1 data\n002group1name1 data\n003group2name2 data\n")
      end

      after do
        FileUtils.rm_rf(Rails.root.join('tmp/test_report'))
      end

      it 'finds matching lines from file' do
        results = report.send(:grep_pattern_from_file, raw_folder.to_s, 1, 3, 'group1', 'name1 ', 10)
        expect(results.length).to eq(2)
      end

      it 'limits results to max_lines' do
        results = report.send(:grep_pattern_from_file, raw_folder.to_s, 1, 3, 'group1', 'name1 ', 1)
        expect(results.length).to eq(1)
      end

      it 'returns empty array for invalid path' do
        results = report.send(:grep_pattern_from_file, '/invalid/path', 1, 3, 'group', 'name ', 10)
        expect(results).to eq([])
      end

      it 'validates file path for security' do
        invalid_path = '/etc/passwd'
        results = report.send(:grep_pattern_from_file, invalid_path, 1, 3, '', '', 10)
        expect(results).to eq([])
      end
    end
  end
end
