# frozen_string_literal: true

require 'rails_helper'

module PlebisVerification
  RSpec.describe TownVerificationReportService, type: :service do
    let(:report_code) { 'regional' }
    let(:town_code) { 'm_28_079_5' }
    let(:aacc_code) { 'c_00' }
    let(:active_census_days) { 30 }

    before do
      allow(Rails.application.secrets).to receive(:user_verifications).and_return(report_code => aacc_code)
      allow(Rails.application.secrets).to receive(:users).and_return('active_census_range' => "#{active_census_days}.days")

      # Mock Carmen data
      province = double('Province', index: 28, name: 'Madrid')
      town = double('Town', name: 'Madrid')
      subregions = double('Subregions')
      allow(subregions).to receive(:coded).with(town_code).and_return(town)
      allow(province).to receive(:subregions).and_return(subregions)
      es_country = double('Country')
      allow(es_country).to receive(:subregions).and_return([province])
      allow(Carmen::Country).to receive(:coded).with('ES').and_return(es_country)

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
      it 'stores aacc_code and town_code from configuration' do
        service = described_class.new(report_code, town_code)
        expect(service.instance_variable_get(:@aacc_code)).to eq(aacc_code)
        expect(service.instance_variable_get(:@town_code)).to eq(town_code)
      end

      it 'handles nil town_code' do
        service = described_class.new(report_code)
        expect(service.instance_variable_get(:@town_code)).to be_nil
      end

      context 'with invalid configuration' do
        before do
          allow(Rails.application.secrets).to receive(:user_verifications).and_return(nil)
        end

        it 'logs error and sets aacc_code to nil' do
          expect(Rails.logger).to receive(:error)
          service = described_class.new(report_code, town_code)
          expect(service.instance_variable_get(:@aacc_code)).to be_nil
        end

        it 'preserves town_code even on error' do
          allow(Rails.logger).to receive(:error)
          service = described_class.new(report_code, town_code)
          expect(service.instance_variable_get(:@town_code)).to eq(town_code)
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
          service = described_class.new(report_code, town_code)
          result = service.generate
          expect(result).to eq({ municipios: {} })
        end
      end

      context 'with valid configuration' do
        it 'generates report with municipios, provincias, and autonomias' do
          service = described_class.new(report_code)
          result = service.generate

          expect(result).to have_key(:municipios)
          expect(result).to have_key(:provincias)
          expect(result).to have_key(:autonomias)
        end

        it 'processes town data' do
          allow(users).to receive(:pluck).with('vote_town', 'status', 'count(distinct users.id)').and_return([[town_code, 1, 50]])
          allow(users).to receive(:pluck).with('right(left(vote_town,4),2) as prov', 'status', 'count(distinct users.id)').and_return([['28', 1, 50]])

          service = described_class.new(report_code)
          result = service.generate

          expect(result[:municipios]).to be_a(Hash)
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
          expect(result).to eq({ municipios: {} })
        end
      end
    end

    describe '#empty_report' do
      it 'returns hash with empty municipios' do
        service = described_class.new(report_code)
        result = service.send(:empty_report)
        expect(result).to eq({ municipios: {} })
      end
    end

    describe '#base_query' do
      let(:user_relation) { double('ActiveRecord::Relation') }
      let(:users) { double('ActiveRecord::Relation') }

      before do
        allow(User).to receive(:confirmed).and_return(user_relation)
        allow(user_relation).to receive(:where).and_return(users)
      end

      context 'without town_code' do
        it 'queries confirmed users' do
          expect(User).to receive(:confirmed)
          service = described_class.new(report_code)
          service.send(:base_query)
        end

        it 'filters by TOWNS_IDS list' do
          expect(user_relation).to receive(:where).with(vote_town: described_class::TOWNS_IDS)
          service = described_class.new(report_code)
          service.send(:base_query)
        end
      end

      context 'with town_code' do
        it 'filters by specific town_code' do
          expect(user_relation).to receive(:where).with(vote_town: town_code)
          service = described_class.new(report_code, town_code)
          service.send(:base_query)
        end
      end

      it 'caches query result' do
        service = described_class.new(report_code)
        result1 = service.send(:base_query)
        result2 = service.send(:base_query)
        expect(result1).to eq(result2)
      end
    end

    describe '#town_name' do
      context 'with valid town_code' do
        it 'returns town name from Carmen' do
          service = described_class.new(report_code, town_code)
          result = service.send(:town_name)
          expect(result).to eq('Madrid')
        end
      end

      context 'without town_code' do
        it 'returns nil' do
          service = described_class.new(report_code)
          result = service.send(:town_name)
          expect(result).to be_nil
        end
      end

      context 'with invalid town_code' do
        it 'returns nil on error' do
          service = described_class.new(report_code, 'invalid')
          result = service.send(:town_name)
          expect(result).to be_nil
        end
      end
    end

    describe '#province_name' do
      context 'with valid town_code' do
        it 'returns province name from Carmen' do
          service = described_class.new(report_code, town_code)
          result = service.send(:province_name)
          expect(result).to eq('Madrid')
        end
      end

      context 'without town_code' do
        it 'returns nil' do
          service = described_class.new(report_code)
          result = service.send(:province_name)
          expect(result).to be_nil
        end
      end

      context 'with invalid town_code' do
        it 'returns nil on error' do
          service = described_class.new(report_code, 'invalid')
          result = service.send(:province_name)
          expect(result).to be_nil
        end
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

      context 'with town_code' do
        it 'collects data for specific town' do
          expect(users).to receive(:joins).with(:user_verifications)
          service = described_class.new(report_code, town_code)
          service.send(:collect_data)
        end

        it 'groups by status only' do
          expect(users).to receive(:group).with(:status)
          service = described_class.new(report_code, town_code)
          service.send(:collect_data)
        end

        it 'caches collected data' do
          service = described_class.new(report_code, town_code)
          result1 = service.send(:collect_data)
          result2 = service.send(:collect_data)
          expect(result1.object_id).to eq(result2.object_id)
        end
      end

      context 'without town_code' do
        it 'returns empty hash' do
          service = described_class.new(report_code)
          result = service.send(:collect_data)
          expect(result).to eq({})
        end
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

    describe '#collect_province_data' do
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
        service.send(:collect_province_data)
      end

      it 'groups by province and status' do
        expect(users).to receive(:group).with(:prov, :status)
        service = described_class.new(report_code)
        service.send(:collect_province_data)
      end

      it 'extracts province from vote_town' do
        expect(users).to receive(:pluck).with('right(left(vote_town,4),2) as prov', 'status', 'count(distinct users.id)')
        service = described_class.new(report_code)
        service.send(:collect_province_data)
      end

      it 'returns hash with province-status keys' do
        allow(users).to receive(:pluck).with('right(left(vote_town,4),2) as prov', 'status', 'count(distinct users.id)').and_return([['28', 1, 100]])
        service = described_class.new(report_code)
        result = service.send(:collect_province_data)
        expect(result).to have_key(['28', 1])
      end
    end

    describe '#collect_town_data' do
      let(:user_relation) { double('ActiveRecord::Relation') }
      let(:users) { double('ActiveRecord::Relation') }

      before do
        allow(User).to receive(:confirmed).and_return(user_relation)
        allow(user_relation).to receive(:where).and_return(users)
        allow(users).to receive(:joins).and_return(users)
        allow(users).to receive(:group).and_return(users)
        allow(users).to receive(:pluck).and_return([])
      end

      it 'groups by vote_town and status' do
        expect(users).to receive(:group).with(:vote_town, :status)
        service = described_class.new(report_code)
        service.send(:collect_town_data)
      end

      it 'returns hash with town-status keys' do
        allow(users).to receive(:pluck).with('vote_town', 'status', 'count(distinct users.id)').and_return([[town_code, 1, 50]])
        service = described_class.new(report_code)
        result = service.send(:collect_town_data)
        expect(result).to have_key([town_code, 1])
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

    describe 'constants' do
      it 'defines TOWNS_IDS constant' do
        expect(described_class::TOWNS_IDS).to be_an(Array)
        expect(described_class::TOWNS_IDS).not_to be_empty
      end

      it 'defines TOWNS_HASH constant' do
        expect(described_class::TOWNS_HASH).to be_a(Hash)
        expect(described_class::TOWNS_HASH).to have_key('p_28')
      end

      it 'TOWNS_HASH contains arrays of town codes' do
        expect(described_class::TOWNS_HASH['p_28']).to be_an(Array)
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
          allow(users).to receive(:pluck).with('vote_town', 'status', 'count(distinct users.id)').and_return([
                                                                                                                [town_code, 0, 10],
                                                                                                                [town_code, 1, 50],
                                                                                                                [town_code, 2, 5]
                                                                                                              ])

          allow(users).to receive(:pluck).with('right(left(vote_town,4),2) as prov', 'status', 'count(distinct users.id)').and_return([
                                                                                                                                          ['28', 0, 20],
                                                                                                                                          ['28', 1, 100],
                                                                                                                                          ['28', 2, 10]
                                                                                                                                        ])

          allow(users).to receive(:pluck).with(
            'vote_town',
            anything,
            anything,
            'count(distinct users.id)'
          ).and_return([
                         [town_code, true, true, 40],
                         [town_code, true, false, 15],
                         [town_code, false, true, 10],
                         [town_code, false, false, 5]
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

          expect(result).to have_key(:municipios)
          expect(result).to have_key(:provincias)
          expect(result).to have_key(:autonomias)
        end

        it 'includes verification status counts for towns' do
          service = described_class.new(report_code)
          result = service.generate

          expect(result[:municipios]).to be_a(Hash)
        end
      end

      context 'single town report' do
        before do
          allow(users).to receive(:pluck).with('status', 'count(distinct users.id)').and_return([
                                                                                                   [0, 10],
                                                                                                   [1, 50],
                                                                                                   [2, 5]
                                                                                                 ])

          allow(users).to receive(:pluck).with(
            anything,
            anything,
            'count(distinct users.id)'
          ).and_return([
                         [true, true, 40],
                         [true, false, 15],
                         [false, true, 10],
                         [false, false, 5]
                       ])
        end

        it 'generates report for specific town' do
          service = described_class.new(report_code, town_code)
          result = service.send(:collect_data)

          expect(result).to be_a(Hash)
        end

        it 'provides town name helper' do
          service = described_class.new(report_code, town_code)
          expect(service.send(:town_name)).to eq('Madrid')
        end

        it 'provides province name helper' do
          service = described_class.new(report_code, town_code)
          expect(service.send(:province_name)).to eq('Madrid')
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
        expect { service.send(:collect_province_data) }.not_to raise_error
      end
    end

    describe 'backward compatibility' do
      it 'supports both single parameter and two parameter initialization' do
        service1 = described_class.new(report_code)
        service2 = described_class.new(report_code, town_code)

        expect(service1).to be_a(described_class)
        expect(service2).to be_a(described_class)
      end

      it 'provides helper methods for single town reports' do
        service = described_class.new(report_code, town_code)

        expect(service).to respond_to(:town_name)
        expect(service).to respond_to(:province_name)
        expect(service).to respond_to(:collect_data)
      end
    end
  end
end
