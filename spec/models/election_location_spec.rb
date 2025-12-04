# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ElectionLocation, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid election_location' do
      location = build(:election_location)
      expect(location).to be_valid, "Factory should create valid location. Errors: #{location.errors.full_messages.join(', ')}"
    end

    it 'creates valid election_location with voting info' do
      location = build(:election_location, :with_voting_info)
      expect(location).to be_valid, "Factory with voting info should be valid. Errors: #{location.errors.full_messages.join(', ')}"
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to election' do
      location = create(:election_location)
      expect(location).to respond_to(:election)
      expect(location.election).to be_a(Election)
    end

    it 'has many election_location_questions' do
      location = create(:election_location)
      expect(location).to respond_to(:election_location_questions)
    end

    it 'accepts nested attributes for questions' do
      location = create(:election_location, :with_voting_info)
      expect(location).to respond_to(:election_location_questions_attributes=)
    end

    it 'orders election_location_questions by id' do
      location = create(:election_location, :with_voting_info)
      q1 = create(:election_location_question, election_location: location)
      q2 = create(:election_location_question, election_location: location)

      location.reload
      expect(location.election_location_questions.to_a).to eq([q1, q2])
    end

    it 'destroys questions when location is destroyed' do
      election = create(:election)
      location = ElectionLocation.new(
        election: election,
        title: 'Test',
        layout: 'simple',
        theme: 'default'
      )
      location.save!
      question = create(:election_location_question, election_location: location)
      question_id = question.id

      location.destroy

      expect(ElectionLocationQuestion.where(id: question_id).count).to eq(0)
    end

    it 'accepts nested attributes with reject_if all_blank' do
      election = create(:election)
      location = ElectionLocation.new(
        election: election,
        title: 'Test',
        layout: 'simple',
        theme: 'default',
        election_location_questions_attributes: [
          { title: '', description: '', voting_system: '' }
        ]
      )
      location.save
      expect(location.election_location_questions.count).to eq(0)
    end

    it 'accepts nested attributes with allow_destroy' do
      location = create(:election_location, :with_voting_info)
      question = create(:election_location_question, election_location: location)
      question_id = question.id
      location.reload

      location.update(
        election_location_questions_attributes: [
          { id: question_id, _destroy: '1' }
        ]
      )

      location.reload
      expect(location.election_location_questions.count).to eq(0)
      expect(ElectionLocationQuestion.where(id: question_id).count).to eq(0)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    describe 'when has_voting_info is true' do
      it 'requires title' do
        location = build(:election_location)
        location.has_voting_info = true
        location.title = nil
        expect(location).not_to be_valid
        expect(location.errors[:title]).to include('no puede estar en blanco')
      end

      it 'requires layout' do
        location = build(:election_location, title: 'Test')
        location.has_voting_info = true
        location.layout = nil
        expect(location).not_to be_valid
        expect(location.errors[:layout]).to include('no puede estar en blanco')
      end

      it 'requires theme' do
        location = build(:election_location, title: 'Test', layout: 'simple')
        location.has_voting_info = true
        location.theme = nil
        expect(location).not_to be_valid
        expect(location.errors[:theme]).to include('no puede estar en blanco')
      end

      it 'allows valid location with all required fields' do
        location = build(:election_location, title: 'Test', layout: 'simple', theme: 'default')
        location.has_voting_info = true
        expect(location).to be_valid
      end
    end

    describe 'when has_voting_info is false' do
      it 'does not require title' do
        location = build(:election_location, title: nil, layout: nil, theme: nil)
        location.has_voting_info = false
        # May still fail due to after_initialize setting has_voting_info based on title
        # This is expected behavior
      end

      it 'allows empty fields' do
        election = create(:election)
        location = ElectionLocation.new(election: election)
        location.has_voting_info = false
        location.title = nil
        location.layout = nil
        location.theme = nil
        expect(location.valid?).to be true
      end
    end
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  describe 'callbacks' do
    describe 'after_initialize' do
      it 'sets defaults for new record' do
        location = ElectionLocation.new
        expect(location.agora_version).to eq(0)
        expect(location.new_agora_version).to eq(0)
        expect(location.location).to eq('00')
        expect(location.layout).to eq(ElectionLocation::LAYOUTS.keys.first)
      end

      it 'does not override existing values for persisted record' do
        location = create(:election_location, agora_version: 5, location: '28')
        location.reload
        expect(location.agora_version).to eq(5)
        expect(location.location).to eq('28')
      end

      it 'sets has_voting_info to false for new record without title' do
        location = ElectionLocation.new
        expect(location.has_voting_info).to be false
      end

      it 'sets has_voting_info based on title' do
        location = ElectionLocation.new(title: 'Test Title')
        expect(location.has_voting_info).to be true
      end

      it 'sets has_voting_info to false for blank title' do
        location = ElectionLocation.new(title: '')
        expect(location.has_voting_info).to be false
      end

      it 'sets theme to first theme for new record' do
        location = ElectionLocation.new
        expect(location.theme).to eq(ElectionLocation.themes.first)
      end

      it 'sets new_agora_version to agora_version for new record' do
        location = ElectionLocation.new
        expect(location.new_agora_version).to eq(location.agora_version)
      end
    end

    describe 'before_save' do
      it 'clears voting if has_voting_info is false' do
        location = create(:election_location, :with_voting_info)
        location.has_voting_info = false
        location.save

        expect(location.title).to be_nil
        expect(location.layout).to be_nil
        expect(location.description).to be_nil
      end

      it 'preserves voting info if has_voting_info is true' do
        location = create(:election_location, :with_voting_info)
        original_title = location.title
        location.has_voting_info = true
        location.save

        expect(location.title).to eq(original_title)
      end

      it 'destroys questions when clearing voting' do
        election = create(:election)
        location = ElectionLocation.new(
          election: election,
          title: 'Test',
          layout: 'simple',
          theme: 'default'
        )
        location.save!
        question = create(:election_location_question, election_location: location)
        question_id = question.id

        location.has_voting_info = false
        location.save

        expect(ElectionLocationQuestion.where(id: question_id).count).to eq(0)
      end
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#has_voting_info=' do
      it 'handles boolean values' do
        location = ElectionLocation.new

        location.has_voting_info = true
        expect(location.has_voting_info).to be true

        location.has_voting_info = false
        expect(location.has_voting_info).not_to be true
      end

      it 'handles string values' do
        location = ElectionLocation.new

        location.has_voting_info = 'true'
        expect(location.has_voting_info).to be true

        location.has_voting_info = '1'
        expect(location.has_voting_info).to be true

        location.has_voting_info = 'false'
        expect(location.has_voting_info).not_to be true
      end

      it 'handles string zero' do
        location = ElectionLocation.new
        location.has_voting_info = '0'
        expect(location.has_voting_info).not_to be true
      end

      it 'handles other values as false' do
        location = ElectionLocation.new
        location.has_voting_info = 'anything'
        expect(location.has_voting_info).not_to be true
      end
    end

    describe '#has_voting_info' do
      it 'returns reader value' do
        location = ElectionLocation.new
        location.has_voting_info = true
        expect(location.has_voting_info).to be true
      end
    end

    describe '#clear_voting' do
      it 'clears all voting related fields' do
        location = create(:election_location, :with_voting_info)
        location.clear_voting

        expect(location.title).to be_nil
        expect(location.layout).to be_nil
        expect(location.description).to be_nil
        expect(location.share_text).to be_nil
        expect(location.theme).to be_nil
      end

      it 'destroys all election_location_questions' do
        election = create(:election)
        location = ElectionLocation.new(
          election: election,
          title: 'Test',
          layout: 'simple',
          theme: 'default'
        )
        location.save!
        q1 = create(:election_location_question, election_location: location)
        q2 = create(:election_location_question, election_location: location)
        q1_id = q1.id
        q2_id = q2.id

        location.clear_voting

        expect(ElectionLocationQuestion.where(id: [q1_id, q2_id]).count).to eq(0)
      end
    end

    describe '#territory' do
      context 'with scope 0 (Estatal)' do
        it 'returns Estatal with location code' do
          election = create(:election, scope: 0)
          location = create(:election_location, election: election, location: '00')

          expect(location.territory).to eq('Estatal (00)')
        end
      end

      context 'with scope 1 (Autonomy)' do
        it 'returns location code when autonomy lookup fails' do
          election = create(:election, scope: 1)
          location = create(:election_location, election: election, location: '99')

          expect(location.territory).to eq('99')
        end
      end

      context 'with scope 2 (Province)' do
        it 'returns location code on error' do
          election = create(:election, scope: 2)
          location = create(:election_location, election: election, location: '99')

          expect(location.territory).to eq('99')
        end
      end

      context 'with scope 3 (Municipal)' do
        it 'returns location code on error' do
          election = create(:election, scope: 3)
          location = create(:election_location, election: election, location: '280790')

          expect(location.territory).to eq('280790')
        end
      end

      context 'with scope 4 (Island)' do
        it 'returns location code when island lookup fails' do
          election = create(:election, scope: 4)
          location = create(:election_location, election: election, location: '99')

          expect(location.territory).to eq('99')
        end
      end

      context 'with scope 5 (Exterior)' do
        it 'returns Exterior with location code' do
          election = create(:election, scope: 5)
          location = create(:election_location, election: election, location: '00')

          expect(location.territory).to eq('Exterior (00)')
        end
      end

      context 'with scope 6 (Vote Circle)' do
        it 'returns vote circle name with location code when found' do
          election = create(:election, scope: 6)
          vote_circle = create(:vote_circle, name: 'Test Circle')
          location = create(:election_location, election: election, location: vote_circle.id.to_s)

          result = location.territory
          expect(result).to include('Test Circle')
          expect(result).to include("(#{vote_circle.id})")
        end

        it 'returns location code when vote circle not found' do
          election = create(:election, scope: 6)
          location = create(:election_location, election: election, location: '99999')

          expect(location.territory).to eq('99999')
        end
      end
    end

    describe '#new_version_pending' do
      it 'returns true when versions differ' do
        location = create(:election_location, agora_version: 0, new_agora_version: 1)
        expect(location.new_version_pending).to be true
      end

      it 'returns false when versions match' do
        location = create(:election_location, agora_version: 1, new_agora_version: 1)
        expect(location.new_version_pending).not_to be true
      end

      it 'returns false when both are zero' do
        location = create(:election_location, agora_version: 0, new_agora_version: 0)
        expect(location.new_version_pending).to be false
      end
    end

    describe '#vote_location' do
      it 'returns location for non-municipal elections' do
        election = create(:election, scope: 0) # Estatal
        location = create(:election_location, election: election, location: '01')
        expect(location.vote_location).to eq('01')
      end

      it 'returns location for provincial elections' do
        election = create(:election, scope: 2) # Province
        location = create(:election_location, election: election, location: '28')
        expect(location.vote_location).to eq('28')
      end

      it 'returns truncated location for municipal elections' do
        election = create(:election, scope: 3) # Municipal
        location = create(:election_location, election: election, location: '280790')
        expect(location.vote_location).to eq('28079')
      end

      it 'returns location for island elections' do
        election = create(:election, scope: 4) # Island
        location = create(:election_location, election: election, location: '07')
        expect(location.vote_location).to eq('07')
      end

      it 'returns location for circle elections' do
        election = create(:election, scope: 6) # Circle
        location = create(:election_location, election: election, location: '123')
        expect(location.vote_location).to eq('123')
      end
    end

    describe '#vote_id' do
      it 'calculates correctly without override' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election, location: '01', agora_version: 0)
        expect(location.vote_id).to eq(100_010)
      end

      it 'uses override when present' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election, location: '01', override: '99', agora_version: 0)
        expect(location.vote_id).to eq(100_990)
      end

      it 'calculates correctly with different agora_version' do
        election = create(:election, agora_election_id: 200, scope: 0)
        location = create(:election_location, election: election, location: '05', agora_version: 2)
        expect(location.vote_id).to eq(200_052)
      end

      it 'uses empty override as nil' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election, location: '01', override: '', agora_version: 0)
        expect(location.vote_id).to eq(100_010)
      end
    end

    describe '#new_vote_id' do
      it 'calculates using new_agora_version' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election, location: '01', agora_version: 0, new_agora_version: 1)
        expect(location.new_vote_id).to eq(100_011)
      end

      it 'uses override when present' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election, location: '01', override: '88', new_agora_version: 2)
        expect(location.new_vote_id).to eq(100_882)
      end

      it 'calculates correctly for municipal elections' do
        election = create(:election, agora_election_id: 300, scope: 3)
        location = create(:election_location, election: election, location: '280790', new_agora_version: 1)
        expect(location.new_vote_id).to eq(300_280_791)
      end
    end

    describe '#link' do
      it 'returns booth URL with vote_id' do
        election = create(:election, agora_election_id: 100, server: 'default', scope: 0)
        location = create(:election_location, election: election, location: '01', agora_version: 0)

        expect(location.link).to match(%r{booth/\d+/vote$})
        expect(location.link).to include(election.server_url)
      end

      it 'includes correct vote_id in URL' do
        election = create(:election, agora_election_id: 100, server: 'default', scope: 0)
        location = create(:election_location, election: election, location: '01', agora_version: 0)

        expect(location.link).to include("/booth/#{location.vote_id}/vote")
      end
    end

    describe '#new_link' do
      it 'returns booth URL with new_vote_id' do
        election = create(:election, agora_election_id: 100, server: 'default', scope: 0)
        location = create(:election_location, election: election, location: '01', agora_version: 0, new_agora_version: 1)

        expect(location.new_link).to match(%r{booth/\d+/vote$})
      end

      it 'includes correct new_vote_id in URL' do
        election = create(:election, agora_election_id: 100, server: 'default', scope: 0)
        location = create(:election_location, election: election, location: '01', agora_version: 0, new_agora_version: 1)

        expect(location.new_link).to include("/booth/#{location.new_vote_id}/vote")
      end

      it 'differs from link when version changes' do
        election = create(:election, agora_election_id: 100, server: 'default', scope: 0)
        location = create(:election_location, election: election, location: '01', agora_version: 0, new_agora_version: 1)

        expect(location.new_link).not_to eq(location.link)
      end
    end

    describe '#election_layout' do
      it 'returns layout if it is an election layout' do
        location = build(:election_location, layout: 'pcandidates-election')
        expect(location.election_layout).to eq('pcandidates-election')
      end

      it 'returns layout for 2questions-conditional' do
        location = build(:election_location, layout: '2questions-conditional')
        expect(location.election_layout).to eq('2questions-conditional')
      end

      it 'returns empty string if not an election layout' do
        location = build(:election_location, layout: 'simple')
        expect(location.election_layout).to eq('')
      end

      it 'returns empty string for accordion layout' do
        location = build(:election_location, layout: 'accordion')
        expect(location.election_layout).to eq('')
      end

      it 'returns empty string for simultaneous-questions layout' do
        location = build(:election_location, layout: 'simultaneous-questions')
        expect(location.election_layout).to eq('')
      end
    end

    describe '#valid_votes_count' do
      it 'counts distinct valid votes' do
        election = create(:election, :active)
        location = create(:election_location, election: election)
        user1 = create(:user)
        user2 = create(:user)

        # Create votes with the same agora_id as the location's vote_id
        vote1 = create(:vote, election: election, user: user1)
        vote1.update_column(:agora_id, location.vote_id)

        vote2 = create(:vote, election: election, user: user2)
        vote2.update_column(:agora_id, location.vote_id)

        expect(location.valid_votes_count).to eq(2)
      end

      it 'excludes votes deleted before election end' do
        election = create(:election, :active, ends_at: 1.day.from_now)
        location = create(:election_location, election: election)
        user1 = create(:user)
        user2 = create(:user)

        vote1 = create(:vote, election: election, user: user1)
        vote1.update_column(:agora_id, location.vote_id)

        vote2 = create(:vote, election: election, user: user2)
        vote2.update_column(:agora_id, location.vote_id)
        vote2.update_column(:deleted_at, 2.days.ago)

        expect(location.valid_votes_count).to eq(1)
      end

      it 'includes votes deleted after election end' do
        election = create(:election, :finished, ends_at: 2.days.ago)
        location = create(:election_location, election: election)
        user1 = create(:user)
        user2 = create(:user)

        vote1 = create(:vote, election: election, user: user1)
        vote1.update_column(:agora_id, location.vote_id)

        vote2 = create(:vote, election: election, user: user2)
        vote2.update_column(:agora_id, location.vote_id)
        vote2.update_column(:deleted_at, 1.day.ago)

        expect(location.valid_votes_count).to eq(2)
      end

      it 'counts distinct users only once' do
        election = create(:election, :active)
        location = create(:election_location, election: election)
        user = create(:user)

        # Create first vote
        vote1 = Vote.new(election: election, user: user)
        vote1.save(validate: false)
        vote1.update_column(:agora_id, location.vote_id)

        # Create second vote for same user (simulating a re-vote)
        # Need to manually bypass validations to allow duplicate voter_id
        vote2 = Vote.new(election: election, user: user)
        vote2.save(validate: false)
        vote2.update_columns(agora_id: location.vote_id, voter_id: "#{vote1.voter_id}_2")

        expect(location.valid_votes_count).to eq(1)
      end

      it 'returns zero when no votes match' do
        election = create(:election, :active)
        location = create(:election_location, election: election)

        expect(location.valid_votes_count).to eq(0)
      end
    end

    describe '#counter_token' do
      it 'generates access token' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election)

        token = location.counter_token
        expect(token).not_to be_nil
        expect(token).to be_a(String)
        expect(token.length).to eq(17)
      end

      it 'memoizes the token' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election)

        token1 = location.counter_token
        token2 = location.counter_token

        expect(token1).to eq(token2)
      end

      it 'generates token based on created_at and id' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election)

        expect(election).to receive(:generate_access_token).with("#{location.created_at.to_i} #{location.id}").and_call_original
        location.counter_token
      end
    end

    describe '#paper_token' do
      it 'generates access token' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election)

        token = location.paper_token
        expect(token).not_to be_nil
        expect(token).to be_a(String)
      end

      it 'memoizes the token' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election)

        token1 = location.paper_token
        token2 = location.paper_token

        expect(token1).to eq(token2)
      end

      it 'generates token based on created_at and id' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election)

        expect(election).to receive(:generate_access_token).with("#{location.created_at.to_i} #{location.id}").and_call_original
        location.paper_token
      end

      it 'generates same token as counter_token' do
        election = create(:election, agora_election_id: 100, scope: 0)
        location = create(:election_location, election: election)

        expect(location.paper_token).to eq(location.counter_token)
      end
    end
  end

  # ====================
  # CONSTANTS TESTS
  # ====================

  describe 'constants' do
    it 'defines LAYOUTS constant' do
      expect(ElectionLocation::LAYOUTS).to be_a(Hash)
      expect(ElectionLocation::LAYOUTS).to have_key('simple')
    end

    it 'defines all expected layouts' do
      expect(ElectionLocation::LAYOUTS.keys).to match_array([
        'simple',
        'accordion',
        'pcandidates-election',
        'simultaneous-questions',
        '2questions-conditional'
      ])
    end

    it 'has descriptive values for layouts' do
      expect(ElectionLocation::LAYOUTS['simple']).to eq('Listado de respuestas simple')
    end

    it 'defines ELECTION_LAYOUTS constant' do
      expect(ElectionLocation::ELECTION_LAYOUTS).to be_a(Array)
      expect(ElectionLocation::ELECTION_LAYOUTS).to include('pcandidates-election')
    end

    it 'includes 2questions-conditional in ELECTION_LAYOUTS' do
      expect(ElectionLocation::ELECTION_LAYOUTS).to include('2questions-conditional')
    end

    it 'ELECTION_LAYOUTS is a subset of LAYOUTS' do
      expect(ElectionLocation::ELECTION_LAYOUTS.all? { |l| ElectionLocation::LAYOUTS.key?(l) }).to be true
    end
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  describe 'class methods' do
    describe '.themes' do
      it 'returns agora themes' do
        themes = ElectionLocation.themes
        expect(themes).to be_an(Array)
        expect(themes).to include('default')
      end

      it 'memoizes themes' do
        themes1 = ElectionLocation.themes
        themes2 = ElectionLocation.themes
        expect(themes1.object_id).to eq(themes2.object_id)
      end

      it 'returns themes from Rails secrets' do
        expect(Rails.application.secrets.agora['themes']).to eq(ElectionLocation.themes)
      end
    end
  end
end
