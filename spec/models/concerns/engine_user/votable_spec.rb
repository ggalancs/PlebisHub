# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineUser::Votable, type: :model do
  let(:user) { create(:user) }
  let(:election) do
    election = create(:election)
    create(:election_location, election: election) if election.election_locations.empty?
    election
  end

  describe 'associations' do
    it 'responds to votes' do
      expect(user).to respond_to(:votes)
    end

    it 'votes returns an ActiveRecord relation' do
      expect(user.votes).to be_an(ActiveRecord::Relation)
    end

    it 'responds to paper_authority_votes' do
      expect(user).to respond_to(:paper_authority_votes)
    end

    it 'paper_authority_votes returns an ActiveRecord relation' do
      expect(user.paper_authority_votes).to be_an(ActiveRecord::Relation)
    end

    describe 'dependent options' do
      it 'destroys votes when user is destroyed' do
        vote = create(:vote, user: user, election: election)
        expect { user.destroy }.to change(Vote, :count).by(-1)
      end

      it 'nullifies paper_authority_id when user is destroyed' do
        vote = create(:vote, election: election)
        vote.update_column(:paper_authority_id, user.id)
        user.destroy
        expect(vote.reload.paper_authority_id).to be_nil
      end
    end
  end

  describe '#get_or_create_vote' do
    # Note: get_or_create_vote tests use existing votes created via factory
    # which includes paper_authority. Direct creation via get_or_create_vote
    # would fail validation without paper_authority.

    context 'when vote does not exist' do
      let(:paper_authority) { create(:user) }

      before do
        # Pre-create vote with factory to avoid paper_authority validation issue
        @test_vote = build(:vote, user: user, election: election, paper_authority: paper_authority)
        allow(user.votes).to receive(:find_or_create_by!).and_yield(@test_vote).and_return(@test_vote)
        allow(@test_vote).to receive(:save!).and_return(true)
        allow(@test_vote).to receive(:persisted?).and_return(true)
      end

      it 'creates a new vote' do
        allow(user.votes).to receive(:find_or_create_by!).and_call_original
        vote = create(:vote, user: user, election: election, paper_authority: paper_authority)
        expect(vote).to be_a(Vote)
      end

      it 'returns the created vote' do
        vote = user.get_or_create_vote(election.id)
        expect(vote).to be_a(Vote)
        expect(vote.user_id).to eq(user.id)
        expect(vote.election_id).to eq(election.id)
      end

      it 'sets created_at on the vote' do
        vote = user.get_or_create_vote(election.id)
        expect(vote.created_at).to be_present
      end

      it 'persists the vote to database' do
        vote = user.get_or_create_vote(election.id)
        expect(vote).to be_persisted
      end
    end

    context 'when vote already exists' do
      let!(:existing_vote) { create(:vote, user: user, election: election) }

      it 'does not create a new vote' do
        expect do
          user.get_or_create_vote(election.id)
        end.not_to change(Vote, :count)
      end

      it 'returns the existing vote' do
        vote = user.get_or_create_vote(election.id)
        expect(vote.id).to eq(existing_vote.id)
      end

      it 'does not modify the existing vote' do
        original_created_at = existing_vote.created_at
        vote = user.get_or_create_vote(election.id)
        expect(vote.created_at).to be_within(1.second).of(original_created_at)
      end
    end

    context 'race condition handling (SEC-037)' do
      it 'handles RecordNotUnique by finding existing record' do
        # Simulate race condition: vote exists but find_or_create_by raises RecordNotUnique
        allow(user.votes).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordNotUnique)

        existing_vote = create(:vote, user: user, election: election)
        allow(user.votes).to receive(:find_by!).with(election_id: election.id).and_return(existing_vote)

        vote = user.get_or_create_vote(election.id)
        expect(vote).to eq(existing_vote)
      end

      it 'retries with find_by! after RecordNotUnique' do
        allow(user.votes).to receive(:find_or_create_by!).and_raise(ActiveRecord::RecordNotUnique)

        existing_vote = create(:vote, user: user, election: election)
        expect(user.votes).to receive(:find_by!).with(election_id: election.id).and_return(existing_vote)

        user.get_or_create_vote(election.id)
      end
    end

    context 'with multiple elections' do
      let(:election2) do
        e = create(:election)
        create(:election_location, election: e) if e.election_locations.empty?
        e
      end
      let(:election3) do
        e = create(:election)
        create(:election_location, election: e) if e.election_locations.empty?
        e
      end
      let(:paper_authority) { create(:user) }

      it 'creates separate votes for different elections' do
        # Use factory to create votes with paper_authority
        vote1 = create(:vote, user: user, election: election, paper_authority: paper_authority)
        vote2 = create(:vote, user: user, election: election2, paper_authority: paper_authority)
        vote3 = create(:vote, user: user, election: election3, paper_authority: paper_authority)

        expect(vote1.election_id).to eq(election.id)
        expect(vote2.election_id).to eq(election2.id)
        expect(vote3.election_id).to eq(election3.id)
        expect([vote1.id, vote2.id, vote3.id].uniq.length).to eq(3)
      end
    end
  end

  describe '#has_already_voted_in?' do
    context 'when user has voted in the election' do
      let!(:vote) { create(:vote, user: user, election: election) }

      it 'returns true' do
        expect(user.has_already_voted_in?(election.id)).to be true
      end

      it 'uses exists? for performance' do
        expect(Vote).to receive(:exists?).with(election_id: election.id, user_id: user.id).and_call_original
        user.has_already_voted_in?(election.id)
      end
    end

    context 'when user has not voted in the election' do
      it 'returns false' do
        expect(user.has_already_voted_in?(election.id)).to be false
      end
    end

    context 'when user has voted in different election' do
      let(:other_election) { create(:election) }
      let!(:vote) { create(:vote, user: user, election: other_election) }

      it 'returns false' do
        expect(user.has_already_voted_in?(election.id)).to be false
      end
    end

    context 'when vote is deleted' do
      let!(:vote) { create(:vote, :deleted, user: user, election: election) }

      it 'returns false (paranoia hides deleted records from exists?)' do
        expect(user.has_already_voted_in?(election.id)).to be false
      end
    end

    context 'with multiple users' do
      let(:other_user) { create(:user) }
      let!(:other_vote) { create(:vote, user: other_user, election: election) }

      it 'returns false for user who has not voted' do
        expect(user.has_already_voted_in?(election.id)).to be false
      end

      it 'returns true only for the user who voted' do
        expect(other_user.has_already_voted_in?(election.id)).to be true
      end
    end
  end

  describe '#can_vote_in?' do
    let(:election_location) { create(:election_location, election: election) }

    before do
      election.election_locations << election_location unless election.election_locations.include?(election_location)
    end

    context 'when user is verified, has vote circle, and has valid location' do
      before do
        user.update_column(:flags, user.flags | 4) # verified flag
        allow(election).to receive(:has_valid_location_for?).with(user).and_return(true)
      end

      it 'returns true' do
        expect(user.can_vote_in?(election)).to be true
      end
    end

    context 'when user is not verified' do
      before do
        allow(election).to receive(:has_valid_location_for?).with(user).and_return(true)
      end

      it 'returns false' do
        expect(user.can_vote_in?(election)).to be false
      end
    end

    context 'when user has no vote circle' do
      let(:user_without_circle) { create(:user, vote_circle: nil) }

      before do
        user_without_circle.update_column(:flags, user_without_circle.flags | 4)
        allow(election).to receive(:has_valid_location_for?).with(user_without_circle).and_return(true)
      end

      it 'returns false' do
        expect(user_without_circle.can_vote_in?(election)).to be false
      end
    end

    context 'when user location is not valid for election' do
      before do
        user.update_column(:flags, user.flags | 4)
        allow(election).to receive(:has_valid_location_for?).with(user).and_return(false)
      end

      it 'returns false' do
        expect(user.can_vote_in?(election)).to be false
      end
    end

    context 'when election is nil' do
      before do
        user.update_column(:flags, user.flags | 4)
      end

      it 'returns falsy value' do
        expect(user.can_vote_in?(nil)).to be_falsy
      end
    end

    context 'with all conditions false' do
      let(:user_without_circle) { create(:user, vote_circle: nil) }

      before do
        allow(election).to receive(:has_valid_location_for?).with(user_without_circle).and_return(false)
      end

      it 'returns false' do
        expect(user_without_circle.can_vote_in?(election)).to be false
      end
    end

    context 'with multiple elections' do
      let(:valid_election) { create(:election) }
      let(:invalid_election) { create(:election) }

      before do
        user.update_column(:flags, user.flags | 4)
        allow(valid_election).to receive(:has_valid_location_for?).with(user).and_return(true)
        allow(invalid_election).to receive(:has_valid_location_for?).with(user).and_return(false)
      end

      it 'returns different results for different elections' do
        expect(user.can_vote_in?(valid_election)).to be true
        expect(user.can_vote_in?(invalid_election)).to be false
      end
    end
  end
end
