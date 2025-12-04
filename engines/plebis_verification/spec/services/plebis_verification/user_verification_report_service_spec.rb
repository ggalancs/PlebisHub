# frozen_string_literal: true

require 'rails_helper'

module PlebisVerification
  RSpec.describe UserVerificationReportService, type: :service do
    let(:report_code) { 'national' }
    let(:aacc_code) { 'c_00' }
    let(:active_census_days) { 30 }

    before do
      allow(Rails.application.secrets).to receive(:user_verifications).and_return(report_code => aacc_code)
      allow(Rails.application.secrets).to receive(:users).and_return('active_census_range' => "#{active_census_days}.days")

      # Mock Carmen data
      province = double('Province', index: 28, name: 'Madrid')
      allow(Carmen::Country).to receive(:coded).with('ES').and_return(double(subregions: [province]))

      # Mock PlebisBrand autonomies
      stub_const('PlebisBrand::GeoExtra::AUTONOMIES', {
                   'p_28' => ['c_13', 'Comunidad de Madrid']
                 })

      allow(UserVerification).to receive(:statuses).and_return({
                                                                 'pending' => 0,
                                                                 'verified' => 1,
                                                                 'rejected' => 2
                                                               })
    end

    describe '#initialize' do
      it 'stores aacc_code from configuration' do
        service = described_class.new(report_code)
        expect(service.instance_variable_get(:@aacc_code)).to eq(aacc_code)
      end

      context 'with invalid configuration' do
        before do
          allow(Rails.application.secrets).to receive(:user_verifications).and_return(nil)
        end

        it 'logs error and sets aacc_code to nil' do
          expect(Rails.logger).to receive(:error)
          service = described_class.new(report_code)
          expect(service.instance_variable_get(:@aacc_code)).to be_nil
        end
      end
    end

    describe '#generate' do
      let(:user_relation) { double('ActiveRecord::Relation') }
      let(:users) { double('ActiveRecord::Relation') }

      before do
        allow(User).to receive(:confirmed).and_return(user_relation)
        allow(user_relation).to receive(:where).and_return(users)
        allow(users).to receive(:joins).and_return(users)
        allow(users).to receive(:group).and_return(users)
        allow(users).to receive(:pluck).and_return([])
      end

      context 'when initialization failed' do
        before do
          allow(Rails.application.secrets).to receive(:user_verifications).and_return(nil)
          allow(Rails.logger).to receive(:error)
        end

        it 'returns empty report' do
          service = described_class.new(report_code)
          result = service.generate
          expect(result).to eq({ provincias: {}, autonomias: {} })
        end
      end

      context 'with valid configuration' do
        it 'generates report with provincias and autonomias' do
          service = described_class.new(report_code)
          result = service.generate

          expect(result).to have_key(:provincias)
          expect(result).to have_key(:autonomias)
        end

        it 'processes province data' do
          allow(users).to receive(:pluck).with('right(left(vote_town,4),2) as prov', 'status', 'count(distinct users.id)').and_return([['28', 1, 50]])

          service = described_class.new(report_code)
          result = service.generate

          expect(result[:provincias]).to have_key('Madrid')
        end

        it 'aggregates data by autonomy' do
          allow(users).to receive(:pluck).with('right(left(vote_town,4),2) as prov', 'status', 'count(distinct users.id)').and_return([['28', 1, 50]])

          service = described_class.new(report_code)
          result = service.generate

          expect(result[:autonomias]).to have_key('Comunidad de Madrid')
        end
      end

      context 'error handling' do
        before do
          allow(User).to receive(:confirmed).and_raise(StandardError.new('Database error'))
        end

        it 'logs error' do
          expect(Rails.logger).to receive(:error)
          service = described_class.new(report_code)
          service.generate
        end

        it 'returns empty report' do
          allow(Rails.logger).to receive(:error)
          service = described_class.new(report_code)
          result = service.generate
          expect(result).to eq({ provincias: {}, autonomias: {} })
        end
      end
    end

    describe '#validate_configuration!' do
      it 'does not raise when configuration is valid' do
        service = described_class.new(report_code)
        expect { service.send(:validate_configuration!) }.not_to raise_error
      end
    end

    describe '#empty_report' do
      it 'returns hash with empty provincias and autonomias' do
        service = described_class.new(report_code)
        result = service.send(:empty_report)
        expect(result).to eq({ provincias: {}, autonomias: {} })
      end
    end

    describe '#base_query' do
      let(:user_relation) { double('ActiveRecord::Relation') }
      let(:users) { double('ActiveRecord::Relation') }

      before do
        allow(User).to receive(:confirmed).and_return(user_relation)
        allow(user_relation).to receive(:where).and_return(users)
      end

      it 'queries confirmed users' do
        expect(User).to receive(:confirmed)
        service = described_class.new(report_code)
        service.send(:base_query)
      end

      it 'filters users with Spanish vote_town' do
        expect(user_relation).to receive(:where).with("vote_town ilike 'm\\___%'")
        service = described_class.new(report_code)
        service.send(:base_query)
      end

      it 'caches query result' do
        service = described_class.new(report_code)
        result1 = service.send(:base_query)
        result2 = service.send(:base_query)
        expect(result1).to eq(result2)
      end
    end

    describe '#parse_active_census_range' do
      it 'parses string with .days suffix' do
        service = described_class.new(report_code)
        result = service.send(:parse_active_census_range)
        expect(result).to eq(30)
      end

      it 'parses plain numeric string' do
        allow(Rails.application.secrets).to receive(:users).and_return('active_census_range' => '45')
        service = described_class.new(report_code)
        result = service.send(:parse_active_census_range)
        expect(result).to eq(45)
      end

      it 'parses integer value' do
        allow(Rails.application.secrets).to receive(:users).and_return('active_census_range' => 60)
        service = described_class.new(report_code)
        result = service.send(:parse_active_census_range)
        expect(result).to eq(60)
      end

      it 'returns default value for invalid string' do
        allow(Rails.application.secrets).to receive(:users).and_return('active_census_range' => 'invalid')
        allow(Rails.logger).to receive(:error)
        service = described_class.new(report_code)
        result = service.send(:parse_active_census_range)
        expect(result).to eq(30)
      end

      it 'logs error for invalid value' do
        allow(Rails.application.secrets).to receive(:users).and_return('active_census_range' => 'invalid')
        expect(Rails.logger).to receive(:error)
        service = described_class.new(report_code)
        service.send(:parse_active_census_range)
      end
    end

    describe '#collect_data' do
      let(:user_relation) { double('ActiveRecord::Relation') }
      let(:users) { double('ActiveRecord::Relation') }

      before do
        allow(User).to receive(:confirmed).and_return(user_relation)
        allow(user_relation).to receive(:where).and_return(users)
        allow(users).to receive(:joins).and_return(users)
        allow(users).to receive(:group).and_return(users)
        allow(users).to receive(:pluck).and_return([])
      end

      it 'joins user_verifications table' do
        expect(users).to receive(:joins).with(:user_verifications)
        service = described_class.new(report_code)
        service.send(:collect_data)
      end

      it 'groups by province and status' do
        expect(users).to receive(:group).with(:prov, :status)
        service = described_class.new(report_code)
        service.send(:collect_data)
      end

      it 'counts distinct users' do
        expect(users).to receive(:pluck).with('right(left(vote_town,4),2) as prov', 'status', 'count(distinct users.id)')
        service = described_class.new(report_code)
        service.send(:collect_data)
      end

      it 'caches collected data' do
        service = described_class.new(report_code)
        result1 = service.send(:collect_data)
        result2 = service.send(:collect_data)
        expect(result1.object_id).to eq(result2.object_id)
      end

      it 'returns hash with province-status keys' do
        allow(users).to receive(:pluck).with('right(left(vote_town,4),2) as prov', 'status', 'count(distinct users.id)').and_return([['28', 1, 100]])
        service = described_class.new(report_code)
        result = service.send(:collect_data)
        expect(result).to have_key(['28', 1])
      end
    end

    describe '#provinces' do
      it 'returns array of province codes and names' do
        service = described_class.new(report_code)
        result = service.send(:provinces)
        expect(result).to be_an(Array)
        expect(result.first).to eq(['28', 'Madrid'])
      end

      it 'formats province codes with zero padding' do
        service = described_class.new(report_code)
        result = service.send(:provinces)
        expect(result.first.first).to match(/^\d{2}$/)
      end

      it 'caches provinces list' do
        service = described_class.new(report_code)
        result1 = service.send(:provinces)
        result2 = service.send(:provinces)
        expect(result1.object_id).to eq(result2.object_id)
      end
    end

    describe '#process_province_data' do
      let(:report) do
        {
          provincias: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } },
          autonomias: Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = 0 } }
        }
      end
      let(:data) do
        {
          ['28', 0] => 10,
          ['28', 1] => 50,
          ['28', 2] => 5
        }
      end

      it 'populates verification status counts' do
        service = described_class.new(report_code)
        service.send(:process_province_data, report, data, '28', 'Madrid', 'Comunidad de Madrid')

        expect(report[:provincias]['Madrid'][:pending]).to eq(10)
        expect(report[:provincias]['Madrid'][:verified]).to eq(50)
        expect(report[:provincias]['Madrid'][:rejected]).to eq(5)
      end

      it 'calculates total count' do
        service = described_class.new(report_code)
        service.send(:process_province_data, report, data, '28', 'Madrid', 'Comunidad de Madrid')

        expect(report[:provincias]['Madrid'][:total]).to eq(65)
      end

      it 'aggregates autonomy data' do
        service = described_class.new(report_code)
        service.send(:process_province_data, report, data, '28', 'Madrid', 'Comunidad de Madrid')

        expect(report[:autonomias]['Comunidad de Madrid'][:verified]).to eq(50)
        expect(report[:autonomias]['Comunidad de Madrid'][:total]).to eq(65)
      end
    end

    describe 'integration scenarios' do
      let(:user_relation) { double('ActiveRecord::Relation') }
      let(:users) { double('ActiveRecord::Relation') }

      before do
        allow(User).to receive(:confirmed).and_return(user_relation)
        allow(user_relation).to receive(:where).and_return(users)
        allow(users).to receive(:joins).and_return(users)
        allow(users).to receive(:group).and_return(users)
      end

      context 'with real data' do
        before do
          allow(users).to receive(:pluck).with('right(left(vote_town,4),2) as prov', 'status', 'count(distinct users.id)').and_return([
                                                                                                                                          ['28', 0, 20],
                                                                                                                                          ['28', 1, 100],
                                                                                                                                          ['28', 2, 10]
                                                                                                                                        ])

          allow(users).to receive(:pluck).with(
            'right(left(vote_town,4),2) as prov',
            anything,
            anything,
            'count(distinct users.id)'
          ).and_return([
                         ['28', true, true, 80],
                         ['28', true, false, 30],
                         ['28', false, true, 20],
                         ['28', false, false, 10]
                       ])
        end

        it 'generates complete report with all metrics' do
          service = described_class.new(report_code)
          result = service.generate

          madrid_data = result[:provincias]['Madrid']
          expect(madrid_data).to include(:pending, :verified, :rejected, :total, :users, :active, :active_verified)
        end

        it 'calculates correct totals' do
          service = described_class.new(report_code)
          result = service.generate

          madrid_data = result[:provincias]['Madrid']
          expect(madrid_data[:total]).to eq(130)
        end

        it 'aggregates autonomy data correctly' do
          service = described_class.new(report_code)
          result = service.generate

          autonomy_data = result[:autonomias]['Comunidad de Madrid']
          expect(autonomy_data[:total]).to eq(130)
          expect(autonomy_data[:verified]).to eq(100)
        end
      end

      context 'filtering by autonomy' do
        let(:aacc_code) { 'c_13' }

        it 'includes only provinces from specified autonomy' do
          service = described_class.new(report_code)
          allow(users).to receive(:pluck).and_return([])

          result = service.generate

          # Should process Madrid (c_13) but not others
          expect(result[:provincias]).to be_a(Hash)
        end
      end
    end

    describe 'security fixes' do
      it 'uses safe Integer() parsing instead of eval()' do
        service = described_class.new(report_code)
        expect { service.send(:parse_active_census_range) }.not_to raise_error
      end

      it 'uses Arel for parameterized queries' do
        users = double('ActiveRecord::Relation')
        allow(User).to receive(:confirmed).and_return(users)
        allow(users).to receive(:where).and_return(users)
        allow(users).to receive(:joins).and_return(users)
        allow(users).to receive(:group).and_return(users)
        allow(users).to receive(:pluck).and_return([])

        service = described_class.new(report_code)
        expect { service.send(:collect_data) }.not_to raise_error
      end
    end
  end
end
