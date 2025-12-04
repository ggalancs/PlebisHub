# frozen_string_literal: true

require 'rails_helper'

module PlebisVotes
  RSpec.describe Election, type: :model do
    let(:election) do
      Election.create!(
        title: 'Test Election',
        starts_at: 1.day.ago,
        ends_at: 1.day.from_now,
        agora_election_id: 12_345,
        scope: 0
      )
    end

    describe 'validations' do
      it 'requires title' do
        election = Election.new(starts_at: Time.zone.now, ends_at: 1.day.from_now, agora_election_id: 1, scope: 0)
        expect(election.valid?).to be_falsey
        expect(election.errors[:title]).to include("can't be blank")
      end

      it 'requires starts_at' do
        election = Election.new(title: 'Test', ends_at: 1.day.from_now, agora_election_id: 1, scope: 0)
        expect(election.valid?).to be_falsey
        expect(election.errors[:starts_at]).to include("can't be blank")
      end

      it 'requires ends_at' do
        election = Election.new(title: 'Test', starts_at: Time.zone.now, agora_election_id: 1, scope: 0)
        expect(election.valid?).to be_falsey
        expect(election.errors[:ends_at]).to include("can't be blank")
      end

      it 'requires agora_election_id' do
        election = Election.new(title: 'Test', starts_at: Time.zone.now, ends_at: 1.day.from_now, scope: 0)
        expect(election.valid?).to be_falsey
        expect(election.errors[:agora_election_id]).to include("can't be blank")
      end

      it 'requires scope' do
        election = Election.new(title: 'Test', starts_at: Time.zone.now, ends_at: 1.day.from_now, agora_election_id: 1)
        expect(election.valid?).to be_falsey
        expect(election.errors[:scope]).to include("can't be blank")
      end

      it 'is valid with all required attributes' do
        election = Election.new(
          title: 'Test',
          starts_at: Time.zone.now,
          ends_at: 1.day.from_now,
          agora_election_id: 1,
          scope: 0
        )
        expect(election.valid?).to be_truthy
      end
    end

    describe 'census_file validations' do
      let(:election) do
        Election.new(
          title: 'Test',
          starts_at: Time.zone.now,
          ends_at: 1.day.from_now,
          agora_election_id: 1,
          scope: 0
        )
      end

      it 'accepts valid CSV file' do
        file = fixture_file_upload('test.csv', 'text/csv')
        election.census_file.attach(file)
        expect(election.valid?).to be_truthy
      end

      it 'rejects invalid content type' do
        file = fixture_file_upload('test_image.png', 'image/png')
        election.census_file.attach(file)
        expect(election.valid?).to be_falsey
        expect(election.errors[:census_file]).to include('No reconocido como CSV')
      end

      it 'rejects files over 10MB' do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(11.megabytes)
        file = fixture_file_upload('test.csv', 'text/csv')
        election.census_file.attach(file)
        expect(election.valid?).to be_falsey
        expect(election.errors[:census_file]).to include('debe ser menor de 10MB')
      end
    end

    describe 'associations' do
      it 'has many votes' do
        expect(election).to respond_to(:votes)
        expect(election.votes).to be_a(ActiveRecord::Relation)
      end

      it 'has many election_locations' do
        expect(election).to respond_to(:election_locations)
        expect(election.election_locations).to be_a(ActiveRecord::Relation)
      end

      it 'destroys dependent election_locations' do
        election.election_locations.create!(location: '01', agora_version: 1)
        expect { election.destroy }.to change(ElectionLocation, :count).by(-1)
      end
    end

    describe 'enums' do
      it 'defines election_type enum' do
        expect(Election.election_types).to eq('nvotes' => 0, 'external' => 1, 'paper' => 2)
      end

      it 'can set nvotes type' do
        election.nvotes!
        expect(election.nvotes?).to be_truthy
      end

      it 'can set external type' do
        election.external!
        expect(election.external?).to be_truthy
      end

      it 'can set paper type' do
        election.paper!
        expect(election.paper?).to be_truthy
      end
    end

    describe 'flags' do
      it 'has requires_sms_check flag' do
        expect(election).to respond_to(:requires_sms_check)
        expect(election).to respond_to(:requires_sms_check=)
        expect(election).to respond_to(:requires_sms_check?)
      end

      it 'has show_on_index flag' do
        expect(election).to respond_to(:show_on_index)
        expect(election).to respond_to(:show_on_index?)
      end

      it 'has ignore_multiple_territories flag' do
        expect(election).to respond_to(:ignore_multiple_territories)
        expect(election).to respond_to(:ignore_multiple_territories?)
      end

      it 'has requires_vatid_check flag' do
        expect(election).to respond_to(:requires_vatid_check)
        expect(election).to respond_to(:requires_vatid_check?)
      end

      it 'can set and unset flags' do
        election.requires_sms_check = true
        expect(election.requires_sms_check?).to be_truthy
        election.requires_sms_check = false
        expect(election.requires_sms_check?).to be_falsey
      end
    end

    describe 'callbacks' do
      it 'generates counter_key before create' do
        new_election = Election.new(
          title: 'Test',
          starts_at: Time.zone.now,
          ends_at: 1.day.from_now,
          agora_election_id: 1,
          scope: 0
        )
        new_election.save
        expect(new_election.counter_key).to be_present
        expect(new_election.counter_key.length).to be > 10
      end

      it 'does not override existing counter_key' do
        existing_key = 'existing_key_12345'
        new_election = Election.new(
          title: 'Test',
          starts_at: Time.zone.now,
          ends_at: 1.day.from_now,
          agora_election_id: 1,
          scope: 0,
          counter_key: existing_key
        )
        new_election.save
        expect(new_election.counter_key).to eq(existing_key)
      end
    end

    describe 'scopes' do
      before do
        Election.destroy_all
      end

      describe '.active' do
        it 'returns elections active now' do
          active = Election.create!(
            title: 'Active',
            starts_at: 1.hour.ago,
            ends_at: 1.hour.from_now,
            agora_election_id: 1,
            scope: 0,
            priority: 1
          )
          past = Election.create!(
            title: 'Past',
            starts_at: 2.days.ago,
            ends_at: 1.day.ago,
            agora_election_id: 2,
            scope: 0,
            priority: 2
          )
          results = Election.active
          expect(results).to include(active)
          expect(results).not_to include(past)
        end
      end

      describe '.future' do
        it 'returns elections ending in the future' do
          future = Election.create!(
            title: 'Future',
            starts_at: 1.hour.from_now,
            ends_at: 2.hours.from_now,
            agora_election_id: 1,
            scope: 0
          )
          past = Election.create!(
            title: 'Past',
            starts_at: 2.days.ago,
            ends_at: 1.day.ago,
            agora_election_id: 2,
            scope: 0
          )
          results = Election.future
          expect(results).to include(future)
          expect(results).not_to include(past)
        end
      end
    end

    describe '#to_s' do
      it 'delegates to title' do
        expect(election.to_s).to eq(election.title)
      end
    end

    describe '#is_active?' do
      it 'returns true when election is active' do
        election.starts_at = 1.hour.ago
        election.ends_at = 1.hour.from_now
        expect(election.is_active?).to be_truthy
      end

      it 'returns false when election has not started' do
        election.starts_at = 1.hour.from_now
        election.ends_at = 2.hours.from_now
        expect(election.is_active?).to be_falsey
      end

      it 'returns false when election has ended' do
        election.starts_at = 2.hours.ago
        election.ends_at = 1.hour.ago
        expect(election.is_active?).to be_falsey
      end
    end

    describe '#is_upcoming?' do
      it 'returns true when election starts soon' do
        election.starts_at = 6.hours.from_now
        election.ends_at = 12.hours.from_now
        expect(election.is_upcoming?).to be_truthy
      end

      it 'returns false when election is far in the future' do
        election.starts_at = 1.day.from_now
        election.ends_at = 2.days.from_now
        expect(election.is_upcoming?).to be_falsey
      end

      it 'returns false when election has started' do
        election.starts_at = 1.hour.ago
        election.ends_at = 1.hour.from_now
        expect(election.is_upcoming?).to be_falsey
      end
    end

    describe '#recently_finished?' do
      it 'returns true when election finished recently' do
        election.starts_at = 3.days.ago
        election.ends_at = 1.day.ago
        expect(election.recently_finished?).to be_truthy
      end

      it 'returns false when election is still active' do
        election.starts_at = 1.hour.ago
        election.ends_at = 1.hour.from_now
        expect(election.recently_finished?).to be_falsey
      end

      it 'returns false when election finished long ago' do
        election.starts_at = 5.days.ago
        election.ends_at = 3.days.ago
        expect(election.recently_finished?).to be_falsey
      end
    end

    describe '#scope_name' do
      it 'returns correct name for scope 0 (Estatal)' do
        election.scope = 0
        expect(election.scope_name).to eq('Estatal')
      end

      it 'returns correct name for scope 1 (Comunidad)' do
        election.scope = 1
        expect(election.scope_name).to eq('Comunidad')
      end

      it 'returns correct name for scope 6 (Círculos)' do
        election.scope = 6
        expect(election.scope_name).to eq('Círculos')
      end
    end

    describe '#multiple_territories?' do
      it 'returns true for scope 1 when not ignoring' do
        election.scope = 1
        election.ignore_multiple_territories = false
        expect(election.multiple_territories?).to be_truthy
      end

      it 'returns false when ignore_multiple_territories is true' do
        election.scope = 1
        election.ignore_multiple_territories = true
        expect(election.multiple_territories?).to be_falsey
      end

      it 'returns false for scope 0' do
        election.scope = 0
        election.ignore_multiple_territories = false
        expect(election.multiple_territories?).to be_falsey
      end
    end

    describe '#duration' do
      it 'calculates duration in hours' do
        election.starts_at = Time.zone.parse('2023-01-01 10:00:00')
        election.ends_at = Time.zone.parse('2023-01-01 14:00:00')
        expect(election.duration).to eq(4)
      end

      it 'handles fractional hours' do
        election.starts_at = Time.zone.parse('2023-01-01 10:00:00')
        election.ends_at = Time.zone.parse('2023-01-01 10:30:00')
        expect(election.duration).to eq(0)
      end
    end

    describe '#counter_token' do
      it 'generates a counter token' do
        expect(election.counter_token).to be_a(String)
        expect(election.counter_token.length).to eq(17)
      end

      it 'memoizes the token' do
        token1 = election.counter_token
        token2 = election.counter_token
        expect(token1).to eq(token2)
      end
    end

    describe '#generate_access_token' do
      it 'generates a token for given info' do
        token = election.generate_access_token('test_info')
        expect(token).to be_a(String)
        expect(token.length).to eq(17)
      end

      it 'generates different tokens for different info' do
        token1 = election.generate_access_token('info1')
        token2 = election.generate_access_token('info2')
        expect(token1).not_to eq(token2)
      end
    end

    describe '#locations=' do
      it 'creates election_locations from string' do
        election.locations = "01,1\n02,2"
        election.save
        expect(election.election_locations.count).to eq(2)
        expect(election.election_locations.map(&:location)).to contain_exactly('01', '02')
      end

      it 'handles override values' do
        election.locations = "01,1,override1"
        election.save
        location = election.election_locations.first
        expect(location.override).to eq('override1')
      end

      it 'skips empty lines' do
        election.locations = "01,1\n\n02,2"
        election.save
        expect(election.election_locations.count).to eq(2)
      end
    end

    describe '#locations' do
      it 'returns locations as string' do
        election.election_locations.create!(location: '01', agora_version: 1)
        election.election_locations.create!(location: '02', agora_version: 2)
        locations_str = election.locations
        expect(locations_str).to include('01,1')
        expect(locations_str).to include('02,2')
      end

      it 'includes override when present' do
        election.election_locations.create!(location: '01', agora_version: 1, override: 'test')
        expect(election.locations).to include('01,1,test')
      end
    end

    describe '.available_servers' do
      it 'returns available server keys' do
        expect(Election.available_servers).to be_a(Hash)
      end
    end

    describe '#server_shared_key' do
      it 'returns a shared key' do
        allow(Rails.application.secrets).to receive(:agora).and_return(
          'default' => 'test_server',
          'servers' => { 'test_server' => { 'shared_key' => 'test_key' } }
        )
        expect(election.server_shared_key).to eq('test_key')
      end
    end

    describe '#server_url' do
      it 'returns a server url' do
        allow(Rails.application.secrets).to receive(:agora).and_return(
          'default' => 'test_server',
          'servers' => { 'test_server' => { 'url' => 'http://test.com' } }
        )
        expect(election.server_url).to eq('http://test.com')
      end

      it 'returns empty string when url not found' do
        allow(Rails.application.secrets).to receive(:agora).and_return(
          'default' => 'test_server',
          'servers' => { 'test_server' => {} }
        )
        expect(election.server_url).to eq('')
      end
    end

    describe '#valid_votes_count' do
      it 'counts valid votes' do
        user = double('User', id: 1)
        allow(::User).to receive(:find).and_return(user)
        election.votes.create!(user_id: 1, voter_id: 'test1', agora_id: 1)
        election.votes.create!(user_id: 2, voter_id: 'test2', agora_id: 1)
        expect(election.valid_votes_count).to eq(2)
      end
    end

    describe 'has_one_attached :census_file' do
      it 'can attach a census file' do
        expect(election).to respond_to(:census_file)
        expect(election.census_file).to respond_to(:attach)
      end
    end

    describe 'SCOPE constant' do
      it 'defines all scope types' do
        expect(Election::SCOPE).to be_an(Array)
        expect(Election::SCOPE.length).to eq(7)
        expect(Election::SCOPE.first).to eq(['Estatal', 0])
        expect(Election::SCOPE.last).to eq(['Círculos', 6])
      end
    end
  end
end
