# frozen_string_literal: true

require 'rails_helper'

module PlebisVotes
  RSpec.describe ElectionLocation, type: :model do
    let(:election) do
      Election.create!(
        title: 'Test Election',
        starts_at: 1.day.ago,
        ends_at: 1.day.from_now,
        agora_election_id: 12_345,
        scope: 0
      )
    end

    let(:election_location) do
      ElectionLocation.create!(
        election: election,
        location: '01',
        agora_version: 0,
        title: 'Test Location',
        layout: 'simple',
        theme: 'default'
      )
    end

    describe 'associations' do
      it 'belongs to election' do
        expect(election_location.election).to eq(election)
      end

      it 'has many election_location_questions' do
        expect(election_location).to respond_to(:election_location_questions)
        expect(election_location.election_location_questions).to be_a(ActiveRecord::Relation)
      end

      it 'destroys dependent questions' do
        election_location.election_location_questions.create!(
          title: 'Question',
          voting_system: 'plurality-at-large',
          winners: 1,
          minimum: 0,
          maximum: 1,
          totals: 'over-total-valid-votes',
          options: 'Option 1'
        )
        expect { election_location.destroy }.to change(ElectionLocationQuestion, :count).by(-1)
      end
    end

    describe 'validations' do
      context 'when has_voting_info is true' do
        before do
          election_location.has_voting_info = true
        end

        it 'requires title' do
          election_location.title = nil
          expect(election_location.valid?).to be_falsey
          expect(election_location.errors[:title]).to include("can't be blank")
        end

        it 'requires layout' do
          election_location.layout = nil
          expect(election_location.valid?).to be_falsey
          expect(election_location.errors[:layout]).to include("can't be blank")
        end

        it 'requires theme' do
          election_location.theme = nil
          expect(election_location.valid?).to be_falsey
          expect(election_location.errors[:theme]).to include("can't be blank")
        end
      end

      context 'when has_voting_info is false' do
        before do
          election_location.has_voting_info = false
        end

        it 'does not require title' do
          election_location.title = nil
          expect(election_location).to be_valid
        end
      end
    end

    describe 'callbacks' do
      describe 'after_initialize' do
        it 'sets default agora_version for new record' do
          new_location = ElectionLocation.new(election: election)
          expect(new_location.agora_version).to eq(0)
        end

        it 'sets default new_agora_version' do
          new_location = ElectionLocation.new(election: election)
          expect(new_location.new_agora_version).to eq(0)
        end

        it 'sets default location' do
          new_location = ElectionLocation.new(election: election)
          expect(new_location.location).to eq('00')
        end

        it 'sets default has_voting_info to false' do
          new_location = ElectionLocation.new(election: election)
          expect(new_location.instance_variable_get(:@has_voting_info)).to be_falsey
        end

        it 'sets default layout' do
          new_location = ElectionLocation.new(election: election)
          expect(new_location.layout).to eq('simple')
        end

        it 'updates has_voting_info based on title presence' do
          new_location = ElectionLocation.new(election: election, title: 'Test')
          expect(new_location.instance_variable_get(:@has_voting_info)).to be_truthy
        end
      end

      describe 'before_save' do
        it 'clears voting data when has_voting_info is false' do
          election_location.has_voting_info = false
          election_location.save
          expect(election_location.title).to be_nil
          expect(election_location.layout).to be_nil
          expect(election_location.description).to be_nil
        end

        it 'preserves voting data when has_voting_info is true' do
          election_location.has_voting_info = true
          original_title = election_location.title
          election_location.save
          expect(election_location.title).to eq(original_title)
        end
      end
    end

    describe '#has_voting_info=' do
      it 'sets to true for true' do
        election_location.has_voting_info = true
        expect(election_location.instance_variable_get(:@has_voting_info)).to be_truthy
      end

      it 'sets to true for "true"' do
        election_location.has_voting_info = 'true'
        expect(election_location.instance_variable_get(:@has_voting_info)).to be_truthy
      end

      it 'sets to true for "1"' do
        election_location.has_voting_info = '1'
        expect(election_location.instance_variable_get(:@has_voting_info)).to be_truthy
      end

      it 'sets to false for false' do
        election_location.has_voting_info = false
        expect(election_location.instance_variable_get(:@has_voting_info)).to be_falsey
      end

      it 'sets to false for other values' do
        election_location.has_voting_info = 'other'
        expect(election_location.instance_variable_get(:@has_voting_info)).to be_falsey
      end
    end

    describe '#clear_voting' do
      it 'clears title, layout, description, share_text, and theme' do
        election_location.description = 'Test desc'
        election_location.share_text = 'Share this'
        election_location.clear_voting
        expect(election_location.title).to be_nil
        expect(election_location.layout).to be_nil
        expect(election_location.description).to be_nil
        expect(election_location.share_text).to be_nil
        expect(election_location.theme).to be_nil
      end

      it 'destroys all election_location_questions' do
        election_location.election_location_questions.create!(
          title: 'Q1',
          voting_system: 'plurality-at-large',
          winners: 1,
          minimum: 0,
          maximum: 1,
          totals: 'over-total-valid-votes',
          options: 'Opt1'
        )
        expect { election_location.clear_voting }.to change(ElectionLocationQuestion, :count).by(-1)
      end
    end

    describe '#territory' do
      it 'returns "Estatal" for scope 0' do
        election.scope = 0
        election_location.location = '00'
        expect(election_location.territory).to include('Estatal')
      end

      it 'returns location code' do
        election.scope = 0
        election_location.location = '01'
        result = election_location.territory
        expect(result).to include('(01)')
      end

      it 'handles errors gracefully' do
        election.scope = 999
        expect { election_location.territory }.not_to raise_error
      end
    end

    describe '#new_version_pending' do
      it 'returns true when versions differ' do
        election_location.agora_version = 1
        election_location.new_agora_version = 2
        expect(election_location.new_version_pending).to be_truthy
      end

      it 'returns false when versions are same' do
        election_location.agora_version = 1
        election_location.new_agora_version = 1
        expect(election_location.new_version_pending).to be_falsey
      end
    end

    describe '#vote_location' do
      it 'returns first 5 chars for scope 3' do
        election.scope = 3
        election_location.location = '0101001'
        expect(election_location.vote_location).to eq('01010')
      end

      it 'returns full location for other scopes' do
        election.scope = 1
        election_location.location = '01'
        expect(election_location.vote_location).to eq('01')
      end
    end

    describe '#vote_id' do
      it 'calculates vote_id from election and location data' do
        election.agora_election_id = 100
        election_location.location = '01'
        election_location.agora_version = 2
        expected = '100012'.to_i
        expect(election_location.vote_id).to eq(expected)
      end

      it 'uses override when present' do
        election.agora_election_id = 100
        election_location.override = '99'
        election_location.agora_version = 2
        expected = '100992'.to_i
        expect(election_location.vote_id).to eq(expected)
      end
    end

    describe '#new_vote_id' do
      it 'calculates new_vote_id using new_agora_version' do
        election.agora_election_id = 100
        election_location.location = '01'
        election_location.new_agora_version = 3
        expected = '100013'.to_i
        expect(election_location.new_vote_id).to eq(expected)
      end
    end

    describe '#link' do
      it 'returns booth vote link' do
        allow(election).to receive(:server_url).and_return('http://test.com/')
        link = election_location.link
        expect(link).to start_with('http://test.com/booth/')
        expect(link).to end_with('/vote')
      end
    end

    describe '#new_link' do
      it 'returns booth vote link with new_vote_id' do
        allow(election).to receive(:server_url).and_return('http://test.com/')
        link = election_location.new_link
        expect(link).to start_with('http://test.com/booth/')
        expect(link).to end_with('/vote')
      end
    end

    describe '#election_layout' do
      it 'returns layout if it is an election layout' do
        election_location.layout = 'pcandidates-election'
        expect(election_location.election_layout).to eq('pcandidates-election')
      end

      it 'returns empty string for non-election layouts' do
        election_location.layout = 'simple'
        expect(election_location.election_layout).to eq('')
      end
    end

    describe '#valid_votes_count' do
      it 'counts valid votes for this location' do
        vote_id = election_location.vote_id
        election.votes.create!(user_id: 1, voter_id: 'v1', agora_id: vote_id)
        election.votes.create!(user_id: 2, voter_id: 'v2', agora_id: vote_id)
        expect(election_location.valid_votes_count).to eq(2)
      end
    end

    describe '#counter_token' do
      it 'generates a counter token' do
        token = election_location.counter_token
        expect(token).to be_a(String)
        expect(token.length).to eq(17)
      end

      it 'memoizes the token' do
        token1 = election_location.counter_token
        token2 = election_location.counter_token
        expect(token1).to eq(token2)
      end
    end

    describe '#paper_token' do
      it 'generates a paper token' do
        token = election_location.paper_token
        expect(token).to be_a(String)
        expect(token.length).to eq(17)
      end
    end

    describe 'nested attributes' do
      it 'accepts nested attributes for election_location_questions' do
        expect(ElectionLocation.nested_attributes_options).to have_key(:election_location_questions)
      end

      it 'can create questions via nested attributes' do
        location = ElectionLocation.new(
          election: election,
          location: '01',
          agora_version: 0,
          election_location_questions_attributes: [
            {
              title: 'Q1',
              voting_system: 'plurality-at-large',
              winners: 1,
              minimum: 0,
              maximum: 1,
              totals: 'over-total-valid-votes',
              options: 'Opt1'
            }
          ]
        )
        location.save!
        expect(location.election_location_questions.count).to eq(1)
      end
    end

    describe 'constants' do
      it 'defines LAYOUTS' do
        expect(ElectionLocation::LAYOUTS).to be_a(Hash)
        expect(ElectionLocation::LAYOUTS).to include('simple')
      end

      it 'defines ELECTION_LAYOUTS' do
        expect(ElectionLocation::ELECTION_LAYOUTS).to be_an(Array)
        expect(ElectionLocation::ELECTION_LAYOUTS).to include('pcandidates-election')
      end
    end

    describe '.themes' do
      it 'returns themes from configuration' do
        expect(ElectionLocation.themes).to be_an(Array)
      end
    end
  end
end
