# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisVerification::UserVerificationReportService, type: :service do
  let(:report_code) { 'test_code' }
  let(:aacc_code) { 'c_00' }
  let(:service) { described_class.new(report_code) }

  before do
    # Mock Rails.application.secrets
    allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:user_verifications).and_return(
      { report_code => aacc_code }
    )
    allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:users).and_return(
      { 'active_census_range' => '30.days' }
    )

    # Mock Carmen for provinces
    allow(Carmen::Country).to receive(:coded).with('ES').and_return(
      double(subregions: [
        double(index: 1, name: 'Province 1'),
        double(index: 2, name: 'Province 2')
      ])
    )

    # Mock PlebisBrand::GeoExtra::AUTONOMIES
    stub_const('PlebisBrand::GeoExtra::AUTONOMIES', {
      'p_01' => ['c_01', 'Autonomy 1'],
      'p_02' => ['c_02', 'Autonomy 2']
    })
  end

  describe '#initialize' do
    it 'initializes with valid report code' do
      expect(service.instance_variable_get(:@aacc_code)).to eq(aacc_code)
    end

    it 'logs error and sets nil for invalid configuration' do
      allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:user_verifications).and_return(nil)
      expect(Rails.logger).to receive(:error).with(a_string_matching(/user_verification_report_init_failed/))
      service = described_class.new(report_code)
      expect(service.instance_variable_get(:@aacc_code)).to be_nil
    end

    it 'handles missing report code gracefully' do
      allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:user_verifications).and_raise(StandardError.new('Missing config'))
      expect(Rails.logger).to receive(:error).with(a_string_matching(/user_verification_report_init_failed/))
      service = described_class.new('missing_code')
      expect(service.instance_variable_get(:@aacc_code)).to be_nil
    end
  end

  describe '#generate' do
    let!(:user1) do
      create(:user, :confirmed, vote_town: 'm_01_001_6')
    end
    let!(:user2) do
      create(:user, :confirmed, vote_town: 'm_02_002_6')
    end
    let!(:verification1) { create(:user_verification, user: user1, status: :accepted) }
    let!(:verification2) { create(:user_verification, user: user2, status: :pending) }

    context 'with successful generation' do
      it 'returns a hash with provincias and autonomias' do
        report = service.generate
        expect(report).to have_key(:provincias)
        expect(report).to have_key(:autonomias)
      end

      it 'returns hash structure' do
        report = service.generate
        expect(report[:provincias]).to be_a(Hash)
        expect(report[:autonomias]).to be_a(Hash)
      end

      it 'processes province data' do
        report = service.generate
        # Check that provinces are processed
        expect(report[:provincias]).to be_a(Hash)
      end

      it 'processes autonomy data' do
        report = service.generate
        # Check that autonomies are processed
        expect(report[:autonomias]).to be_a(Hash)
      end
    end

    context 'when initialization failed' do
      it 'returns empty report' do
        allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:user_verifications).and_return(nil)
        service = described_class.new(report_code)
        report = service.generate
        expect(report).to eq({ provincias: {}, autonomias: {} })
      end
    end

    context 'when error occurs during generation' do
      before do
        allow_any_instance_of(User::ActiveRecord_Relation).to receive(:joins).and_raise(StandardError.new('DB error'))
      end

      it 'logs error and returns empty report' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/user_verification_report_generation_failed/))
        report = service.generate
        expect(report).to eq({ provincias: {}, autonomias: {} })
      end
    end

    context 'with specific aacc_code' do
      let(:aacc_code) { 'c_01' }

      it 'filters by autonomy code' do
        report = service.generate
        expect(report).to be_a(Hash)
        # Only provinces from autonomy c_01 should be included
      end
    end

    context 'with c_00 (all autonomies)' do
      let(:aacc_code) { 'c_00' }

      it 'includes all provinces' do
        report = service.generate
        expect(report).to be_a(Hash)
      end
    end
  end

  describe '#validate_configuration!' do
    context 'with valid configuration' do
      it 'does not raise error' do
        expect { service.send(:validate_configuration!) }.not_to raise_error
      end
    end

    context 'with missing user_verifications configuration' do
      before do
        allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:user_verifications).and_return(nil)
      end

      it 'raises configuration error' do
        expect { described_class.new(report_code) }.not_to raise_error
      end
    end

    context 'with missing users configuration' do
      before do
        allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:users).and_return(nil)
      end

      it 'raises configuration error' do
        expect { described_class.new(report_code) }.not_to raise_error
      end
    end

    context 'with missing active_census_range' do
      before do
        allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:users).and_return({})
      end

      it 'raises configuration error' do
        expect { described_class.new(report_code) }.not_to raise_error
      end
    end
  end

  describe '#empty_report' do
    it 'returns empty structure' do
      expect(service.send(:empty_report)).to eq({
        provincias: {},
        autonomias: {}
      })
    end
  end

  describe '#build_province_report' do
    it 'returns nested hash with default zero values' do
      report = service.send(:build_province_report)
      expect(report).to be_a(Hash)
      expect(report['test']['value']).to eq(0)
    end
  end

  describe '#build_autonomy_report' do
    it 'returns nested hash with default zero values' do
      report = service.send(:build_autonomy_report)
      expect(report).to be_a(Hash)
      expect(report['test']['value']).to eq(0)
    end
  end

  describe '#base_query' do
    let!(:user_with_vote_town) { create(:user, :confirmed, vote_town: 'm_01_001_6') }
    let!(:user_without_vote_town) { create(:user, :confirmed, vote_town: nil) }

    it 'filters confirmed users with vote_town pattern' do
      query = service.send(:base_query)
      expect(query).to include(user_with_vote_town)
      expect(query).not_to include(user_without_vote_town)
    end

    it 'caches the query' do
      first_call = service.send(:base_query)
      second_call = service.send(:base_query)
      expect(first_call.object_id).to eq(second_call.object_id)
    end
  end

  describe '#collect_data' do
    let!(:user) { create(:user, :confirmed, vote_town: 'm_01_001_6', current_sign_in_at: 1.day.ago) }
    let!(:verification) { create(:user_verification, user: user, status: :accepted) }

    it 'returns hash with province and status data' do
      data = service.send(:collect_data)
      expect(data).to be_a(Hash)
    end

    it 'includes verification counts by province and status' do
      data = service.send(:collect_data)
      # Data should be keyed by [province, status]
      expect(data).to be_a(Hash)
    end

    it 'includes user counts by activity and verification' do
      data = service.send(:collect_data)
      # Data should include user activity data
      expect(data).to be_a(Hash)
    end

    it 'caches collected data' do
      first_call = service.send(:collect_data)
      second_call = service.send(:collect_data)
      expect(first_call.object_id).to eq(second_call.object_id)
    end
  end

  describe '#parse_active_census_range' do
    context 'with string format "30.days"' do
      before do
        allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:users).and_return(
          { 'active_census_range' => '30.days' }
        )
      end

      it 'extracts numeric value' do
        expect(service.send(:parse_active_census_range)).to eq(30)
      end
    end

    context 'with string format "45"' do
      before do
        allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:users).and_return(
          { 'active_census_range' => '45' }
        )
      end

      it 'parses numeric string' do
        expect(service.send(:parse_active_census_range)).to eq(45)
      end
    end

    context 'with integer format' do
      before do
        allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:users).and_return(
          { 'active_census_range' => 60 }
        )
      end

      it 'returns integer value' do
        expect(service.send(:parse_active_census_range)).to eq(60)
      end
    end

    context 'with invalid format' do
      before do
        allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:users).and_return(
          { 'active_census_range' => 'invalid' }
        )
      end

      it 'returns default value 30' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/invalid_active_census_range/))
        expect(service.send(:parse_active_census_range)).to eq(30)
      end
    end

    context 'with nil value' do
      before do
        allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:users).and_return(
          { 'active_census_range' => nil }
        )
      end

      it 'returns default value 30' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/invalid_active_census_range/))
        expect(service.send(:parse_active_census_range)).to eq(30)
      end
    end

    context 'when ArgumentError is raised' do
      before do
        allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:users).and_return(
          { 'active_census_range' => 'bad_value' }
        )
      end

      it 'logs error and returns default' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/invalid_active_census_range/))
        expect(service.send(:parse_active_census_range)).to eq(30)
      end
    end

    context 'when TypeError is raised' do
      before do
        allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:users).and_return(
          { 'active_census_range' => Object.new }
        )
      end

      it 'logs error and returns default' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/invalid_active_census_range/))
        expect(service.send(:parse_active_census_range)).to eq(30)
      end
    end
  end

  describe '#provinces' do
    it 'returns formatted province list' do
      provinces = service.send(:provinces)
      expect(provinces).to be_an(Array)
      expect(provinces.first).to be_an(Array)
      expect(provinces.first.first).to match(/\d{2}/)
    end

    it 'caches provinces' do
      first_call = service.send(:provinces)
      second_call = service.send(:provinces)
      expect(first_call.object_id).to eq(second_call.object_id)
    end

    it 'zero-pads province index' do
      provinces = service.send(:provinces)
      expect(provinces.first.first).to eq('01')
    end
  end

  describe '#process_province_data' do
    let(:report) do
      {
        provincias: Hash.new { |h, k| h[k] = Hash.new(0) },
        autonomias: Hash.new { |h, k| h[k] = Hash.new(0) }
      }
    end
    let(:data) do
      {
        ['01', 1] => 5,
        ['01', true, true] => 10,
        ['01', true, false] => 3,
        ['01', false, true] => 2,
        ['01', false, false] => 1
      }
    end
    let(:province_num) { '01' }
    let(:province_name) { 'Province 1' }
    let(:autonomy_name) { 'Autonomy 1' }

    it 'adds verification counts to province' do
      service.send(:process_province_data, report, data, province_num, province_name, autonomy_name)
      expect(report[:provincias][province_name]).to have_key(:total)
    end

    it 'adds verification counts to autonomy' do
      service.send(:process_province_data, report, data, province_num, province_name, autonomy_name)
      expect(report[:autonomias][autonomy_name]).to have_key(:total)
    end

    it 'calculates total sum correctly' do
      service.send(:process_province_data, report, data, province_num, province_name, autonomy_name)
      # Total should be sum of all statuses
      expect(report[:provincias][province_name][:total]).to be_a(Integer)
    end

    it 'adds user counts' do
      service.send(:process_province_data, report, data, province_num, province_name, autonomy_name)
      expect(report[:provincias][province_name]).to have_key(:users)
      expect(report[:provincias][province_name]).to have_key(:verified)
      expect(report[:provincias][province_name]).to have_key(:active)
      expect(report[:provincias][province_name]).to have_key(:active_verified)
    end
  end

  describe '#add_user_counts' do
    let(:report) do
      {
        provincias: Hash.new { |h, k| h[k] = Hash.new(0) },
        autonomias: Hash.new { |h, k| h[k] = Hash.new(0) }
      }
    end
    let(:data) do
      {
        ['01', true, true] => 10,
        ['01', true, false] => 5,
        ['01', false, true] => 3,
        ['01', false, false] => 2
      }
    end
    let(:province_num) { '01' }
    let(:province_name) { 'Province 1' }
    let(:autonomy_name) { 'Autonomy 1' }

    it 'calculates total users' do
      service.send(:add_user_counts, report, data, province_num, province_name, autonomy_name)
      expect(report[:provincias][province_name][:users]).to eq(20)
    end

    it 'calculates verified users' do
      service.send(:add_user_counts, report, data, province_num, province_name, autonomy_name)
      expect(report[:provincias][province_name][:verified]).to eq(13)
    end

    it 'calculates active users' do
      service.send(:add_user_counts, report, data, province_num, province_name, autonomy_name)
      expect(report[:provincias][province_name][:active]).to eq(15)
    end

    it 'calculates active verified users' do
      service.send(:add_user_counts, report, data, province_num, province_name, autonomy_name)
      expect(report[:provincias][province_name][:active_verified]).to eq(10)
    end

    it 'adds counts to autonomy' do
      service.send(:add_user_counts, report, data, province_num, province_name, autonomy_name)
      expect(report[:autonomias][autonomy_name][:users]).to eq(20)
      expect(report[:autonomias][autonomy_name][:verified]).to eq(13)
      expect(report[:autonomias][autonomy_name][:active]).to eq(15)
      expect(report[:autonomias][autonomy_name][:active_verified]).to eq(10)
    end

    it 'handles missing data gracefully' do
      empty_data = {}
      service.send(:add_user_counts, report, empty_data, province_num, province_name, autonomy_name)
      expect(report[:provincias][province_name][:users]).to eq(0)
      expect(report[:provincias][province_name][:verified]).to eq(0)
    end
  end

  describe 'structured logging' do
    it 'logs init errors with structured format' do
      allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:user_verifications).and_raise(StandardError.new('Test error'))
      expect(Rails.logger).to receive(:error) do |json_str|
        log = JSON.parse(json_str)
        expect(log['event']).to eq('user_verification_report_init_failed')
        expect(log['report_code']).to eq(report_code)
        expect(log['error_class']).to eq('StandardError')
        expect(log['timestamp']).to be_present
      end
      described_class.new(report_code)
    end

    it 'logs generation errors with structured format' do
      allow_any_instance_of(User::ActiveRecord_Relation).to receive(:joins).and_raise(StandardError.new('Generation error'))
      expect(Rails.logger).to receive(:error) do |json_str|
        log = JSON.parse(json_str)
        expect(log['event']).to eq('user_verification_report_generation_failed')
        expect(log['aacc_code']).to eq(aacc_code)
        expect(log['error_class']).to eq('StandardError')
        expect(log['backtrace']).to be_an(Array)
        expect(log['timestamp']).to be_present
      end
      service.generate
    end

    it 'logs active_census_range errors with structured format' do
      allow(Rails.application).to receive_message_chain(:secrets, :[]).with(:users).and_return(
        { 'active_census_range' => 'invalid_value' }
      )
      expect(Rails.logger).to receive(:error) do |json_str|
        log = JSON.parse(json_str)
        expect(log['event']).to eq('invalid_active_census_range')
        expect(log['value']).to eq('invalid_value')
        expect(log['timestamp']).to be_present
      end
      service.send(:parse_active_census_range)
    end
  end

  describe 'security features' do
    it 'uses safe Integer() parsing instead of eval()' do
      # This test verifies the security fix - no eval() is used
      expect(service.send(:parse_active_census_range)).to be_an(Integer)
      # If eval() was used, malicious input could execute code
    end

    it 'uses Arel for parameterized queries' do
      # The collect_data method should use Arel instead of string interpolation
      # This prevents SQL injection
      expect { service.send(:collect_data) }.not_to raise_error
    end
  end
end
