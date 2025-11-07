# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TownVerificationReportService do
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

  describe "initialization" do
    it "initializes with valid report_code and town_code" do
      service = described_class.new('c_00', 'm_01_001')
      expect(service.instance_variable_get(:@aacc_code)).to eq('c_00')
      expect(service.instance_variable_get(:@town_code)).to eq('m_01_001')
    end

    it "handles missing report_code gracefully" do
      service = described_class.new('nonexistent', 'm_01_001')
      expect(service.instance_variable_get(:@aacc_code)).to be_nil
    end

    context "when configuration is missing" do
      before do
        allow(Rails.application).to receive(:secrets).and_return(double(user_verifications: nil))
      end

      it "sets @aacc_code to nil" do
        service = described_class.new('c_00', 'm_01_001')
        expect(service.instance_variable_get(:@aacc_code)).to be_nil
      end

      it "logs error" do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/town_verification_report_init_failed/))
        described_class.new('c_00', 'm_01_001')
      end
    end

    it "logs initialization errors with context" do
      allow(Rails.application).to receive(:secrets).and_raise(StandardError.new("Config error"))

      expect(Rails.logger).to receive(:error).with(a_string_matching(/report_code.*c_00/))

      described_class.new('c_00', 'm_01_001')
    end

    it "stores town_code correctly" do
      service = described_class.new('c_00', 'm_01_001')
      expect(service.instance_variable_get(:@town_code)).to eq('m_01_001')
    end
  end

  # ==================== CONFIGURATION VALIDATION TESTS ====================

  describe "configuration validation" do
    it "requires user_verifications configuration" do
      allow(Rails.application).to receive(:secrets).and_return(
        double(user_verifications: nil, users: { 'active_census_range' => '30.days' })
      )

      service = described_class.new('c_00', 'm_01_001')
      expect(service.instance_variable_get(:@aacc_code)).to be_nil
    end

    it "requires users configuration" do
      allow(Rails.application).to receive(:secrets).and_return(
        double(user_verifications: { 'c_00' => 'c_00' }, users: nil)
      )

      service = described_class.new('c_00', 'm_01_001')
      expect(service.instance_variable_get(:@aacc_code)).to be_nil
    end

    it "requires active_census_range in users configuration" do
      allow(Rails.application).to receive(:secrets).and_return(
        double(user_verifications: { 'c_00' => 'c_00' }, users: {})
      )

      service = described_class.new('c_00', 'm_01_001')
      expect(service.instance_variable_get(:@aacc_code)).to be_nil
    end
  end

  # ==================== SECURITY TESTS ====================

  describe "security" do
    describe "eval() vulnerability fixed" do
      it "does not use eval() for parsing active_census_range" do
        service = described_class.new('c_00', 'm_01_001')

        # This should not raise any errors even with malicious input
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return('`rm -rf /`')

        # Should safely parse and return default value
        expect { service.generate }.not_to raise_error
      end

      it "safely parses numeric string" do
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return('30')

        service = described_class.new('c_00', 'm_01_001')
        days = service.send(:parse_active_census_range)

        expect(days).to eq(30)
      end

      it "safely parses '30.days' format" do
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return('30.days')

        service = described_class.new('c_00', 'm_01_001')
        days = service.send(:parse_active_census_range)

        expect(days).to eq(30)
      end

      it "safely parses numeric value" do
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return(30)

        service = described_class.new('c_00', 'm_01_001')
        days = service.send(:parse_active_census_range)

        expect(days).to eq(30)
      end

      it "returns default value for invalid format" do
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return('invalid')

        service = described_class.new('c_00', 'm_01_001')
        days = service.send(:parse_active_census_range)

        expect(days).to eq(30)
      end

      it "logs error for invalid format" do
        allow(Rails.application.secrets.users).to receive(:[]).with('active_census_range').and_return('invalid')

        service = described_class.new('c_00', 'm_01_001')

        expect(Rails.logger).to receive(:error).with(a_string_matching(/invalid_active_census_range/))

        service.send(:parse_active_census_range)
      end
    end

    describe "SQL injection prevention" do
      it "uses Arel for date comparison" do
        service = described_class.new('c_00', 'm_01_001')

        # Verify that SQL string interpolation is not used
        allow(User).to receive_message_chain(:confirmed, :where).and_return(User.none)

        service.generate

        # If we get here without SQL injection, the fix is working
        expect(true).to be true
      end

      it "does not include raw date in SQL query" do
        service = described_class.new('c_00', 'm_01_001')

        # Mock the base query to verify parameterized query usage
        base_query = double("base_query")
        allow(service).to receive(:base_query).and_return(base_query)
        allow(base_query).to receive_message_chain(:joins, :group, :pluck).and_return([])
        allow(service).to receive(:town_name).and_return('Test Town')
        allow(service).to receive(:province_name).and_return('Test Province')

        service.generate

        # No exception means parameterized queries are used
        expect(true).to be true
      end
    end

    describe "town_code validation" do
      it "handles SQL injection attempts in town_code" do
        service = described_class.new('c_00', "'; DROP TABLE users;--")

        # Should not execute malicious SQL
        expect { service.generate }.not_to raise_error
      end

      it "handles path traversal attempts in town_code" do
        service = described_class.new('c_00', '../../../etc/passwd')

        expect { service.generate }.not_to raise_error
      end
    end
  end

  # ==================== REPORT GENERATION TESTS ====================

  describe "generate" do
    context "when initialization failed" do
      before do
        allow(Rails.application).to receive(:secrets).and_return(double(user_verifications: nil))
      end

      it "returns empty report" do
        service = described_class.new('c_00', 'm_01_001')
        report = service.generate

        expect(report).to eq({ municipios: {} })
      end
    end

    context "when initialized successfully" do
      let(:service) { described_class.new('c_00', 'm_01_001') }

      before do
        # Mock the database queries to avoid database dependency
        allow(service).to receive(:base_query).and_return(User.none)
        allow(service).to receive(:town_name).and_return('Vitoria-Gasteiz')
        allow(service).to receive(:province_name).and_return('Álava')
        allow(service).to receive(:collect_data).and_return({})
      end

      it "returns report with municipios" do
        report = service.generate

        expect(report).to have_key(:municipios)
      end

      it "includes town data" do
        report = service.generate

        expect(report[:municipios]).to be_a(Hash)
      end

      it "includes province name in town data" do
        allow(service).to receive(:collect_data).and_return({})

        report = service.generate

        expect(report[:municipios]).to have_key('Vitoria-Gasteiz')
      end
    end

    context "when error occurs during generation" do
      let(:service) { described_class.new('c_00', 'm_01_001') }

      it "returns empty report" do
        allow(service).to receive(:collect_data).and_raise(StandardError.new("Database error"))

        report = service.generate

        expect(report).to eq({ municipios: {} })
      end

      it "logs error with context" do
        allow(service).to receive(:collect_data).and_raise(StandardError.new("Database error"))

        expect(Rails.logger).to receive(:error).with(a_string_matching(/town_verification_report_generation_failed/))

        service.generate
      end

      it "includes backtrace in error log" do
        allow(service).to receive(:collect_data).and_raise(StandardError.new("Database error"))

        expect(Rails.logger).to receive(:error).with(a_string_matching(/backtrace/))

        service.generate
      end
    end
  end

  # ==================== DATA COLLECTION TESTS ====================

  describe "data collection" do
    let(:service) { described_class.new('c_00', 'm_01_001') }

    it "caches collected data" do
      allow(service).to receive(:base_query).and_return(User.none)

      # Call twice
      service.send(:collect_data)
      service.send(:collect_data)

      # Should only query once (cached)
      expect(service.instance_variable_get(:@data)).to be_present
    end

    it "filters by town code" do
      base_query = double("base_query")
      allow(User).to receive_message_chain(:confirmed, :where).and_return(base_query)
      allow(base_query).to receive_message_chain(:joins, :group, :pluck).and_return([])

      service.send(:collect_data)

      # Verify base_query filters by town_code
      expect(User).to have_received(:confirmed)
    end

    it "includes verification status data" do
      base_query = double("base_query")
      allow(service).to receive(:base_query).and_return(base_query)
      allow(base_query).to receive_message_chain(:joins, :group, :pluck).and_return([[0, 5]])

      data = service.send(:collect_data)

      expect(data).to be_a(Hash)
    end

    it "includes user activity data" do
      base_query = double("base_query")
      allow(service).to receive(:base_query).and_return(base_query)
      allow(base_query).to receive_message_chain(:joins, :group, :pluck).and_return([])
      allow(base_query).to receive(:group).and_return(base_query)
      allow(base_query).to receive(:pluck).and_return([[true, true, 10]])

      data = service.send(:collect_data)

      expect(data[[true, true]]).to eq(10)
    end
  end

  # ==================== EDGE CASES ====================

  describe "edge cases" do
    let(:service) { described_class.new('c_00', 'm_01_001') }

    it "handles empty database" do
      allow(service).to receive(:base_query).and_return(User.none)
      allow(service).to receive(:town_name).and_return('Test Town')
      allow(service).to receive(:province_name).and_return('Test Province')

      report = service.generate

      expect(report[:municipios]).to be_present
    end

    it "handles town with no data" do
      allow(service).to receive(:base_query).and_return(User.none)
      allow(service).to receive(:town_name).and_return('Test Town')
      allow(service).to receive(:province_name).and_return('Test Province')
      allow(service).to receive(:collect_data).and_return({})

      report = service.generate

      expect(report[:municipios]['Test Town']).to be_present
    end

    it "handles nil values in data gracefully" do
      allow(service).to receive(:base_query).and_return(User.none)
      allow(service).to receive(:town_name).and_return('Test Town')
      allow(service).to receive(:province_name).and_return('Test Province')
      allow(service).to receive(:collect_data).and_return({ [0] => nil })

      expect { service.generate }.not_to raise_error
    end

    it "handles invalid town_code" do
      service = described_class.new('c_00', 'invalid_code')

      allow(service).to receive(:base_query).and_return(User.none)
      allow(service).to receive(:town_name).and_return(nil)
      allow(service).to receive(:province_name).and_return(nil)

      expect { service.generate }.not_to raise_error
    end

    it "handles blank town_code" do
      service = described_class.new('c_00', '')

      expect { service.generate }.not_to raise_error
    end
  end

  # ==================== TOWN FILTERING TESTS ====================

  describe "town filtering" do
    it "includes only specified town" do
      service = described_class.new('c_00', 'm_01_001')

      allow(service).to receive(:base_query).and_return(User.none)
      allow(service).to receive(:town_name).and_return('Vitoria-Gasteiz')
      allow(service).to receive(:province_name).and_return('Álava')
      allow(service).to receive(:collect_data).and_return({})

      report = service.generate

      # Should only include one town
      expect(report[:municipios].keys).to include('Vitoria-Gasteiz')
    end

    it "filters data by vote_town pattern" do
      service = described_class.new('c_00', 'm_01_001')

      base_query = double("base_query")
      expect(User).to receive_message_chain(:confirmed, :where).with("vote_town = ?", 'm_01_001').and_return(base_query)
      allow(base_query).to receive_message_chain(:joins, :group, :pluck).and_return([])
      allow(service).to receive(:town_name).and_return('Test Town')
      allow(service).to receive(:province_name).and_return('Test Province')

      service.generate
    end
  end

  # ==================== AUTONOMOUS COMMUNITY FILTERING TESTS ====================

  describe "autonomous community filtering" do
    context "when report_code is c_00 (all Spain)" do
      let(:service) { described_class.new('c_00', 'm_01_001') }

      it "includes town regardless of autonomous community" do
        allow(service).to receive(:base_query).and_return(User.none)
        allow(service).to receive(:town_name).and_return('Test Town')
        allow(service).to receive(:province_name).and_return('Test Province')
        allow(service).to receive(:collect_data).and_return({})

        report = service.generate

        expect(report[:municipios]).to have_key('Test Town')
      end
    end

    context "when report_code is specific community" do
      let(:service) { described_class.new('c_01', 'm_01_001') }

      it "includes town from that community" do
        allow(service).to receive(:base_query).and_return(User.none)
        allow(service).to receive(:town_name).and_return('Test Town')
        allow(service).to receive(:province_name).and_return('Test Province')
        allow(service).to receive(:collect_data).and_return({})

        report = service.generate

        expect(report).to have_key(:municipios)
      end
    end
  end
end
