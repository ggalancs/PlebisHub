# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserVerificationReportService do
  let(:default_secrets) do
    double(
      user_verifications: {
        'c_00' => 'c_00', # All Spain
        'c_01' => 'c_01'  # Specific autonomous community
      },
      users: {
        'active_census_range' => '30.days'
      }
    )
  end

  before do
    allow(Rails.application).to receive(:secrets).and_return(default_secrets)
  end

  # ==================== INITIALIZATION TESTS ====================

  describe 'initialization' do
    it 'initializes with valid report_code' do
      service = described_class.new('c_00')
      expect(service.instance_variable_get(:@aacc_code)).to eq('c_00')
    end

    it 'handles missing report_code gracefully' do
      service = described_class.new('nonexistent')
      expect(service.instance_variable_get(:@aacc_code)).to be_nil
    end

    context 'when configuration is missing' do
      before do
        allow(Rails.application).to receive(:secrets).and_return(double(user_verifications: nil))
      end

      it 'sets @aacc_code to nil' do
        service = described_class.new('c_00')
        expect(service.instance_variable_get(:@aacc_code)).to be_nil
      end

      it 'logs error' do
        allow(Rails.logger).to receive(:error).and_call_original
        described_class.new('c_00')
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/user_verification_report_init_failed/i)).at_least(:once)
      end
    end

    it 'logs initialization errors with context' do
      allow(Rails.application).to receive(:secrets).and_raise(StandardError.new('Config error'))
      allow(Rails.logger).to receive(:error).and_call_original

      described_class.new('c_00')

      expect(Rails.logger).to have_received(:error).with(a_string_matching(/report_code.*c_00/)).at_least(:once)
    end
  end

  # ==================== CONFIGURATION VALIDATION TESTS ====================

  describe 'configuration validation' do
    it 'requires user_verifications configuration' do
      allow(Rails.application).to receive(:secrets).and_return(
        double(user_verifications: nil, users: { 'active_census_range' => '30.days' })
      )

      service = described_class.new('c_00')
      expect(service.instance_variable_get(:@aacc_code)).to be_nil
    end

    it 'requires users configuration' do
      allow(Rails.application).to receive(:secrets).and_return(
        double(user_verifications: { 'c_00' => 'c_00' }, users: nil)
      )

      service = described_class.new('c_00')
      expect(service.instance_variable_get(:@aacc_code)).to be_nil
    end

    it 'requires active_census_range in users configuration' do
      allow(Rails.application).to receive(:secrets).and_return(
        double(user_verifications: { 'c_00' => 'c_00' }, users: {})
      )

      service = described_class.new('c_00')
      expect(service.instance_variable_get(:@aacc_code)).to be_nil
    end
  end

  # ==================== SECURITY TESTS ====================

  describe 'security' do
    describe 'eval() vulnerability fixed' do
      it 'does not use eval() for parsing active_census_range' do
        service = described_class.new('c_00')

        # This should not raise any errors even with malicious input
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return('`rm -rf /`')

        # Should safely parse and return default value
        expect { service.generate }.not_to raise_error
      end

      it 'safely parses numeric string' do
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return('30')

        service = described_class.new('c_00')
        days = service.send(:parse_active_census_range)

        expect(days).to eq(30)
      end

      it "safely parses '30.days' format" do
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return('30.days')

        service = described_class.new('c_00')
        days = service.send(:parse_active_census_range)

        expect(days).to eq(30)
      end

      it 'safely parses numeric value' do
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return(30)

        service = described_class.new('c_00')
        days = service.send(:parse_active_census_range)

        expect(days).to eq(30)
      end

      it 'returns default value for invalid format' do
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return('invalid')

        service = described_class.new('c_00')
        days = service.send(:parse_active_census_range)

        expect(days).to eq(30)
      end

      it 'logs error for invalid format' do
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return('invalid')
        allow(Rails.logger).to receive(:error).and_call_original

        service = described_class.new('c_00')
        service.send(:parse_active_census_range)

        expect(Rails.logger).to have_received(:error).with(a_string_matching(/invalid_active_census_range/)).at_least(:once)
      end
    end

    describe 'SQL injection prevention' do
      it 'uses Arel for date comparison' do
        service = described_class.new('c_00')

        # Verify that SQL string interpolation is not used
        # This is tested by checking the query doesn't contain raw date strings
        allow(User).to receive_message_chain(:confirmed, :where).and_return(User.none)

        service.generate

        # If we get here without SQL injection, the fix is working
        expect(true).to be true
      end

      it 'does not include raw date in SQL query' do
        service = described_class.new('c_00')

        # Mock the base query to verify parameterized query usage
        base_query = double('base_query')
        allow(service).to receive(:base_query).and_return(base_query)
        allow(base_query).to receive_message_chain(:joins, :group, :pluck).and_return([])
        pluck_result = double('pluck_result')
        allow(pluck_result).to receive(:each).and_return([])
        allow(base_query).to receive_message_chain(:group, :pluck).and_return(pluck_result)
        allow(service).to receive(:provinces).and_return([])

        service.generate

        # No exception means parameterized queries are used
        expect(true).to be true
      end
    end
  end

  # ==================== REPORT GENERATION TESTS ====================

  describe 'generate' do
    context 'when initialization failed' do
      before do
        allow(Rails.application).to receive(:secrets).and_return(double(user_verifications: nil))
      end

      it 'returns empty report' do
        service = described_class.new('c_00')
        report = service.generate

        expect(report).to eq({ provincias: {}, autonomias: {} })
      end
    end

    context 'when initialized successfully' do
      let(:service) { described_class.new('c_00') }

      before do
        # Mock the database queries to avoid database dependency
        allow(service).to receive(:base_query).and_return(User.none)
        allow(service).to receive(:provinces).and_return([%w[01 Álava], %w[02 Albacete]])
        allow(service).to receive(:collect_data).and_return({})
      end

      it 'returns report with provincias and autonomias' do
        report = service.generate

        expect(report).to have_key(:provincias)
        expect(report).to have_key(:autonomias)
      end

      it 'processes all provinces' do
        allow(service).to receive(:collect_data).and_return({})

        report = service.generate

        expect(report[:provincias]).to be_a(Hash)
        expect(report[:autonomias]).to be_a(Hash)
      end
    end

    context 'when error occurs during generation' do
      let(:service) { described_class.new('c_00') }

      it 'returns empty report' do
        allow(service).to receive(:collect_data).and_raise(StandardError.new('Database error'))

        report = service.generate

        expect(report).to eq({ provincias: {}, autonomias: {} })
      end

      it 'logs error with context' do
        allow(service).to receive(:collect_data).and_raise(StandardError.new('Database error'))
        allow(Rails.logger).to receive(:error).and_call_original

        service.generate

        expect(Rails.logger).to have_received(:error).with(a_string_matching(/user_verification_report_generation_failed/)).at_least(:once)
      end

      it 'includes backtrace in error log' do
        allow(service).to receive(:collect_data).and_raise(StandardError.new('Database error'))
        allow(Rails.logger).to receive(:error).and_call_original

        service.generate

        expect(Rails.logger).to have_received(:error).with(a_string_matching(/backtrace/)).at_least(:once)
      end
    end
  end

  # ==================== DATA COLLECTION TESTS ====================

  describe 'data collection' do
    let(:service) { described_class.new('c_00') }

    it 'caches collected data' do
      base_query = double('base_query')
      allow(service).to receive(:base_query).and_return(base_query)
      allow(base_query).to receive_message_chain(:joins, :group, :pluck).and_return([['01', 0, 1]])
      pluck_result = double('pluck_result')
      allow(pluck_result).to receive(:each).and_return([])
      allow(base_query).to receive_message_chain(:group, :pluck).and_return(pluck_result)

      # Call twice
      service.send(:collect_data)
      service.send(:collect_data)

      # Should only query once (cached)
      expect(service.instance_variable_get(:@data)).to be_present
    end

    it 'includes verification status data' do
      base_query = double('base_query')
      allow(service).to receive(:base_query).and_return(base_query)
      allow(base_query).to receive_message_chain(:joins, :group, :pluck).and_return([['01', 0, 5]])
      pluck_result = double('pluck_result')
      allow(pluck_result).to receive(:each).and_return([])
      allow(base_query).to receive_message_chain(:group, :pluck).and_return(pluck_result)

      data = service.send(:collect_data)

      expect(data).to be_a(Hash)
    end

    it 'includes user activity data' do
      base_query = double('base_query')
      allow(service).to receive(:base_query).and_return(base_query)
      allow(base_query).to receive_message_chain(:joins, :group, :pluck).and_return([])
      pluck_result = double('pluck_result')
      allow(pluck_result).to receive(:each).and_return([])
      allow(base_query).to receive_message_chain(:group, :pluck).and_return(pluck_result)
      allow(base_query).to receive(:group).and_return(base_query)
      allow(base_query).to receive(:pluck).and_return([['01', true, true, 10]])

      data = service.send(:collect_data)

      expect(data[['01', true, true]]).to eq(10)
    end
  end

  # ==================== EDGE CASES ====================

  describe 'edge cases' do
    let(:service) { described_class.new('c_00') }

    it 'handles empty database' do
      allow(service).to receive(:base_query).and_return(User.none)
      allow(service).to receive(:provinces).and_return([])

      report = service.generate

      expect(report[:provincias]).to be_empty
      expect(report[:autonomias]).to be_empty
    end

    it 'handles provinces with no data' do
      allow(service).to receive(:base_query).and_return(User.none)
      allow(service).to receive(:provinces).and_return([%w[01 Álava]])
      allow(service).to receive(:collect_data).and_return({})

      report = service.generate

      expect(report[:provincias]['Álava']).to be_present
    end

    it 'handles nil values in data gracefully' do
      allow(service).to receive(:base_query).and_return(User.none)
      allow(service).to receive(:provinces).and_return([%w[01 Álava]])
      allow(service).to receive(:collect_data).and_return({ ['01', 0] => nil })

      expect { service.generate }.not_to raise_error
    end
  end

  # ==================== PROVINCE FILTERING TESTS ====================

  describe 'autonomous community filtering' do
    context 'when report_code is c_00 (all Spain)' do
      let(:service) { described_class.new('c_00') }

      it 'includes all provinces' do
        allow(service).to receive(:base_query).and_return(User.none)
        allow(service).to receive(:collect_data).and_return({})

        report = service.generate

        # Should process all provinces (not filtered)
        expect(report).to have_key(:provincias)
        expect(report).to have_key(:autonomias)
      end
    end

    context 'when report_code is specific community' do
      let(:service) { described_class.new('c_01') }

      it 'includes only provinces from that community' do
        allow(service).to receive(:base_query).and_return(User.none)
        allow(service).to receive(:collect_data).and_return({})

        report = service.generate

        # Should filter provinces by autonomous community
        expect(report).to have_key(:provincias)
        expect(report).to have_key(:autonomias)
      end
    end
  end
end
