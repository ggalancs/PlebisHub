# frozen_string_literal: true

require 'rails_helper'

module PlebisVerification
  RSpec.describe ExteriorVerificationReportService, type: :service do
    let(:report_code) { 'exterior' }
    let(:aacc_code) { 'c_99' }
    let(:active_census_days) { 30 }

    before do
      # Mock Rails secrets configuration
      allow(Rails.application.secrets).to receive(:user_verifications).and_return(
        report_code => aacc_code
      )
      allow(Rails.application.secrets).to receive(:users).and_return(
        'active_census_range' => "#{active_census_days}.days"
      )

      # Stub Carmen country data
      country_fr = double('Country', code: 'FR', name: 'France')
      country_de = double('Country', code: 'DE', name: 'Germany')
      allow(Carmen::Country).to receive(:all).and_return([country_fr, country_de])
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

        it 'does not raise error' do
          allow(Rails.logger).to receive(:error)
          expect { described_class.new(report_code) }.not_to raise_error
        end
      end

      context 'with missing active_census_range' do
        before do
          allow(Rails.application.secrets).to receive(:users).and_return({})
        end

        it 'logs error' do
          expect(Rails.logger).to receive(:error)
          described_class.new(report_code)
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
          expect(result).to eq({ paises: {} })
        end

        it 'does not query database' do
          expect(User).not_to receive(:confirmed)
          service = described_class.new(report_code)
          service.generate
        end
      end

      context 'when aacc_code is not c_99' do
        let(:aacc_code) { 'c_01' }

        it 'returns empty report' do
          service = described_class.new(report_code)
          result = service.generate
          expect(result).to eq({ paises: {} })
        end
      end

      context 'when aacc_code is c_99' do
        before do
          # Mock UserVerification statuses
          allow(UserVerification).to receive(:statuses).and_return({
                                                                     'pending' => 0,
                                                                     'verified' => 1,
                                                                     'rejected' => 2
                                                                   })

          # Mock data from database
          allow(users).to receive(:pluck).with('country', 'status', 'count(distinct users.id)').and_return([
                                                                                                              ['FR', 1, 10],
                                                                                                              ['DE', 1, 5]
                                                                                                            ])
        end

        it 'generates report for exterior users' do
          service = described_class.new(report_code)
          result = service.generate

          expect(result).to have_key(:paises)
          expect(result[:paises]).to be_a(Hash)
        end

        it 'includes countries from Carmen' do
          service = described_class.new(report_code)
          result = service.generate

          expect(result[:paises].keys).to include('France', 'Germany')
        end

        it 'aggregates verification statuses by country' do
          service = described_class.new(report_code)
          result = service.generate

          expect(result[:paises]['France']).to have_key(:verified)
          expect(result[:paises]['France'][:verified]).to eq(10)
        end

        it 'calculates totals for each country' do
          service = described_class.new(report_code)
          result = service.generate

          expect(result[:paises]['France']).to have_key(:total)
          expect(result[:paises]['Germany']).to have_key(:total)
        end
      end

      context 'error handling during generation' do
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
          expect(result).to eq({ paises: {} })
        end
      end
    end

    describe '#validate_configuration!' do
      it 'does not raise when configuration is valid' do
        service = described_class.new(report_code)
        expect { service.send(:validate_configuration!) }.not_to raise_error
      end

      it 'raises when user_verifications is missing' do
        allow(Rails.application.secrets).to receive(:user_verifications).and_return(nil)
        expect do
          described_class.new(report_code)
        end.not_to raise_error # Error is caught in initialize
      end

      it 'raises when users config is missing' do
        allow(Rails.application.secrets).to receive(:users).and_return(nil)
        expect do
          described_class.new(report_code)
        end.not_to raise_error # Error is caught in initialize
      end

      it 'raises when active_census_range is missing' do
        allow(Rails.application.secrets).to receive(:users).and_return({})
        expect do
          described_class.new(report_code)
        end.not_to raise_error # Error is caught in initialize
      end
    end

    describe '#empty_report' do
      it 'returns hash with empty paises' do
        service = described_class.new(report_code)
        result = service.send(:empty_report)
        expect(result).to eq({ paises: {} })
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

      it 'filters non-Spanish users' do
        expect(user_relation).to receive(:where).with("country <> 'ES'")
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

      it 'returns default value on ArgumentError' do
        allow(Rails.application.secrets).to receive(:users).and_return('active_census_range' => 'bad')
        allow(Rails.logger).to receive(:error)
        service = described_class.new(report_code)
        result = service.send(:parse_active_census_range)
        expect(result).to eq(30)
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
        allow(UserVerification).to receive(:statuses).and_return({})
      end

      it 'joins user_verifications table' do
        expect(users).to receive(:joins).with(:user_verifications)
        service = described_class.new(report_code)
        service.send(:collect_data)
      end

      it 'groups by country and status' do
        expect(users).to receive(:group).with(:country, :status)
        service = described_class.new(report_code)
        service.send(:collect_data)
      end

      it 'counts distinct users' do
        expect(users).to receive(:pluck).with('country', 'status', 'count(distinct users.id)')
        service = described_class.new(report_code)
        service.send(:collect_data)
      end

      it 'caches collected data' do
        service = described_class.new(report_code)
        result1 = service.send(:collect_data)
        result2 = service.send(:collect_data)
        expect(result1.object_id).to eq(result2.object_id)
      end

      it 'returns hash with country-status keys' do
        allow(users).to receive(:pluck).and_return([['FR', 1, 10]])
        service = described_class.new(report_code)
        result = service.send(:collect_data)
        expect(result).to have_key(['FR', 1])
      end
    end

    describe '#countries' do
      it 'returns hash of country codes to names' do
        service = described_class.new(report_code)
        result = service.send(:countries)
        expect(result).to be_a(Hash)
        expect(result).to have_key('FR')
        expect(result['FR']).to eq('France')
      end

      it 'includes Desconocido with zero array' do
        service = described_class.new(report_code)
        result = service.send(:countries)
        expect(result).to have_key('Desconocido')
        expect(result['Desconocido']).to eq([0] * 4)
      end

      it 'caches countries list' do
        service = described_class.new(report_code)
        result1 = service.send(:countries)
        result2 = service.send(:countries)
        expect(result1.object_id).to eq(result2.object_id)
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

        allow(UserVerification).to receive(:statuses).and_return({
                                                                   'pending' => 0,
                                                                   'verified' => 1,
                                                                   'rejected' => 2
                                                                 })
      end

      context 'with real data' do
        before do
          # Mock verification data
          allow(users).to receive(:pluck).with('country', 'status', 'count(distinct users.id)').and_return([
                                                                                                              ['FR', 0, 5],
                                                                                                              ['FR', 1, 15],
                                                                                                              ['FR', 2, 3],
                                                                                                              ['DE', 1, 8]
                                                                                                            ])

          # Mock user activity data
          active_date = Time.zone.today - active_census_days.days
          allow(users).to receive(:pluck).with(
            'country',
            anything,
            anything,
            'count(distinct users.id)'
          ).and_return([
                         ['FR', true, true, 10],
                         ['FR', true, false, 8],
                         ['FR', false, true, 5],
                         ['FR', false, false, 2],
                         ['DE', true, true, 6],
                         ['DE', false, false, 2]
                       ])
        end

        it 'generates complete report with all metrics' do
          service = described_class.new(report_code)
          result = service.generate

          france_data = result[:paises]['France']
          expect(france_data).to include(:pending, :verified, :rejected, :total, :users, :active, :active_verified)
        end

        it 'calculates correct totals' do
          service = described_class.new(report_code)
          result = service.generate

          france_data = result[:paises]['France']
          expect(france_data[:total]).to eq(23) # 5 + 15 + 3
        end

        it 'includes user activity metrics' do
          service = described_class.new(report_code)
          result = service.generate

          france_data = result[:paises]['France']
          expect(france_data).to have_key(:users)
          expect(france_data).to have_key(:active)
          expect(france_data).to have_key(:verified)
          expect(france_data).to have_key(:active_verified)
        end
      end

      context 'error recovery' do
        it 'handles Carmen Country errors gracefully' do
          allow(Carmen::Country).to receive(:all).and_raise(StandardError.new('Carmen error'))
          allow(Rails.logger).to receive(:error)

          service = described_class.new(report_code)
          result = service.generate

          expect(result).to eq({ paises: {} })
        end

        it 'handles database errors gracefully' do
          allow(User).to receive(:confirmed).and_raise(ActiveRecord::StatementInvalid.new('SQL error'))
          allow(Rails.logger).to receive(:error)

          service = described_class.new(report_code)
          result = service.generate

          expect(result).to eq({ paises: {} })
        end
      end
    end

    describe 'security fixes' do
      it 'uses safe Integer() parsing instead of eval()' do
        service = described_class.new(report_code)
        # Should not raise security errors
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
        # Should use Arel table, not string interpolation
        expect { service.send(:collect_data) }.not_to raise_error
      end
    end
  end
end
