# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineUser::Verifiable, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it 'responds to user_verifications' do
      expect(user).to respond_to(:user_verifications)
    end

    it 'returns an ActiveRecord relation' do
      expect(user.user_verifications).to be_an(ActiveRecord::Relation)
    end
  end

  describe '#pass_vatid_check?' do
    context 'when user is verified' do
      before do
        user.update_column(:flags, user.flags | 4) # verified flag
      end

      it 'returns true' do
        expect(user.pass_vatid_check?).to be true
      end
    end

    context 'when user has pending verification' do
      let!(:verification) { create(:user_verification, user: user, status: :pending) }

      it 'returns true' do
        expect(user.pass_vatid_check?).to be true
      end
    end

    context 'when user is verified and has pending verification' do
      let!(:verification) { create(:user_verification, user: user, status: :pending) }

      before do
        user.update_column(:flags, user.flags | 4)
      end

      it 'returns true' do
        expect(user.pass_vatid_check?).to be true
      end
    end

    context 'when user has no verifications and is not verified' do
      it 'returns false' do
        expect(user.pass_vatid_check?).to be false
      end
    end

    context 'when user has rejected verification' do
      let!(:verification) { create(:user_verification, user: user, status: :rejected) }

      it 'returns false' do
        expect(user.pass_vatid_check?).to be false
      end
    end
  end

  describe '#has_not_verification_accepted?' do
    context 'when user has no verifications' do
      it 'returns true' do
        expect(user.has_not_verification_accepted?).to be true
      end
    end

    context 'when user has accepted verification' do
      let!(:verification) { create(:user_verification, user: user, status: :accepted) }

      it 'returns false' do
        expect(user.has_not_verification_accepted?).to be false
      end
    end

    context 'when user has accepted_by_email verification' do
      let!(:verification) { create(:user_verification, user: user, status: :accepted_by_email) }

      it 'returns false' do
        expect(user.has_not_verification_accepted?).to be false
      end
    end

    context 'when user has pending verification' do
      let!(:verification) { create(:user_verification, user: user, status: :pending) }

      it 'returns true' do
        expect(user.has_not_verification_accepted?).to be true
      end
    end

    context 'when user has rejected verification' do
      let!(:verification) { create(:user_verification, user: user, status: :rejected) }

      it 'returns true' do
        expect(user.has_not_verification_accepted?).to be true
      end
    end

    context 'when user has multiple verifications including accepted' do
      let!(:rejected) { create(:user_verification, user: user, status: :rejected) }
      let!(:accepted) { create(:user_verification, user: user, status: :accepted) }

      it 'returns false' do
        expect(user.has_not_verification_accepted?).to be false
      end
    end
  end

  describe '#imperative_verification' do
    context 'when user is verified' do
      before do
        user.update_column(:flags, user.flags | 4)
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns nil' do
        expect(user.imperative_verification).to be_nil
      end
    end

    context 'when user has no future verified elections' do
      before do
        allow(user).to receive(:has_future_verified_elections?).and_return(false)
      end

      it 'returns nil' do
        expect(user.imperative_verification).to be_nil
      end
    end

    context 'when user is not verified but has future verified elections' do
      let!(:pending_verification) { create(:user_verification, user: user, status: :pending) }

      before do
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns the pending verification' do
        expect(user.imperative_verification).to eq(pending_verification)
      end
    end

    context 'when user has issues verification' do
      let!(:issues_verification) { create(:user_verification, user: user, status: :issues) }

      before do
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns the issues verification' do
        expect(user.imperative_verification).to eq(issues_verification)
      end
    end

    context 'when user has paused verification' do
      let!(:paused_verification) { create(:user_verification, user: user, status: :paused) }

      before do
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns the paused verification' do
        expect(user.imperative_verification).to eq(paused_verification)
      end
    end

    context 'when user has accepted verification' do
      let!(:accepted_verification) { create(:user_verification, user: user, status: :accepted) }

      before do
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns nil' do
        expect(user.imperative_verification).to be_nil
      end
    end
  end

  describe '#photos_unnecessary?' do
    context 'when user has future verified elections, is verified, and has no verifications' do
      before do
        user.update_column(:flags, user.flags | 4)
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns true' do
        expect(user.photos_unnecessary?).to be true
      end
    end

    context 'when user has accepted_by_email verification' do
      let!(:verification) { create(:user_verification, user: user, status: :accepted_by_email) }

      before do
        user.update_column(:flags, user.flags | 4)
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns true' do
        expect(user.photos_unnecessary?).to be true
      end
    end

    context 'when user is not verified' do
      before do
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns false' do
        expect(user.photos_unnecessary?).to be false
      end
    end

    context 'when user has no future verified elections' do
      before do
        user.update_column(:flags, user.flags | 4)
        allow(user).to receive(:has_future_verified_elections?).and_return(false)
      end

      it 'returns false' do
        expect(user.photos_unnecessary?).to be false
      end
    end

    context 'when user has regular accepted verification' do
      let!(:verification) { create(:user_verification, user: user, status: :accepted) }

      before do
        user.update_column(:flags, user.flags | 4)
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns false' do
        expect(user.photos_unnecessary?).to be false
      end
    end
  end

  describe '#photos_necessary?' do
    context 'when user has future verified elections but is not verified' do
      before do
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns true' do
        expect(user.photos_necessary?).to be true
      end
    end

    context 'when user has regular accepted verification' do
      let!(:verification) { create(:user_verification, user: user, status: :accepted) }

      before do
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns true' do
        expect(user.photos_necessary?).to be true
      end
    end

    context 'when user is verified and has no verifications' do
      before do
        user.update_column(:flags, user.flags | 4)
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns false' do
        expect(user.photos_necessary?).to be false
      end
    end

    context 'when user has accepted_by_email verification' do
      let!(:verification) { create(:user_verification, user: user, status: :accepted_by_email) }

      before do
        user.update_column(:flags, user.flags | 4)
        allow(user).to receive(:has_future_verified_elections?).and_return(true)
      end

      it 'returns false' do
        expect(user.photos_necessary?).to be false
      end
    end

    context 'when user has no future verified elections' do
      before do
        allow(user).to receive(:has_future_verified_elections?).and_return(false)
      end

      it 'returns false' do
        expect(user.photos_necessary?).to be false
      end
    end
  end

  describe '#has_future_verified_elections?' do
    let(:election_location) { create(:election_location) }

    context 'when there are future elections requiring vatid check' do
      let!(:election) do
        create(:election, :future, :requires_vatid_check).tap do |e|
          e.election_locations << election_location
        end
      end

      before do
        allow_any_instance_of(Election).to receive(:has_valid_location_for?).with(user).and_return(true)
      end

      it 'returns true' do
        expect(user.has_future_verified_elections?).to be true
      end
    end

    context 'when there are no future elections' do
      let!(:election) { create(:election, :finished, :requires_vatid_check) }

      it 'returns false' do
        expect(user.has_future_verified_elections?).to be false
      end
    end

    context 'when elections do not require vatid check' do
      let!(:election) { create(:election, :future) }

      it 'returns false' do
        expect(user.has_future_verified_elections?).to be false
      end
    end

    context 'when user location is not valid for election' do
      let!(:election) do
        create(:election, :future, :requires_vatid_check).tap do |e|
          e.election_locations << election_location
        end
      end

      before do
        allow_any_instance_of(Election).to receive(:has_valid_location_for?).with(user).and_return(false)
      end

      it 'returns false' do
        expect(user.has_future_verified_elections?).to be false
      end
    end
  end

  describe '#has_not_future_verified_elections?' do
    it 'returns the opposite of has_future_verified_elections?' do
      allow(user).to receive(:has_future_verified_elections?).and_return(true)
      expect(user.has_not_future_verified_elections?).to be false

      allow(user).to receive(:has_future_verified_elections?).and_return(false)
      expect(user.has_not_future_verified_elections?).to be true
    end
  end

  describe '#verified_for_militant?' do
    context 'when user is verified' do
      before do
        user.update_column(:flags, user.flags | 4)
      end

      it 'returns true' do
        expect(user.verified_for_militant?).to be true
      end
    end

    context 'when user has pending verification' do
      let!(:verification) { create(:user_verification, user: user, status: :pending) }

      it 'returns true' do
        expect(user.verified_for_militant?).to be true
      end
    end

    context 'when user has accepted verification' do
      let!(:verification) { create(:user_verification, user: user, status: :accepted) }

      it 'returns true' do
        expect(user.verified_for_militant?).to be true
      end
    end

    context 'when user has accepted_by_email verification' do
      let!(:verification) { create(:user_verification, user: user, status: :accepted_by_email) }

      it 'returns true' do
        expect(user.verified_for_militant?).to be true
      end
    end

    context 'when user has rejected verification' do
      let!(:verification) { create(:user_verification, user: user, status: :rejected) }

      it 'returns false' do
        expect(user.verified_for_militant?).to be false
      end
    end

    context 'when user has no verifications and is not verified' do
      it 'returns false' do
        expect(user.verified_for_militant?).to be false
      end
    end

    context 'when user has issues verification' do
      let!(:verification) { create(:user_verification, user: user, status: :issues) }

      it 'returns false' do
        expect(user.verified_for_militant?).to be false
      end
    end

    context 'when user has multiple verifications' do
      let!(:rejected) { create(:user_verification, user: user, status: :rejected) }
      let!(:pending) { create(:user_verification, user: user, status: :pending) }

      it 'checks the last verification status' do
        expect(user.verified_for_militant?).to be true
      end
    end
  end
end
