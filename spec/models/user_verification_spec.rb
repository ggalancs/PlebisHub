# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserVerification, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates user_verification' do
      verification = build(:user_verification)
      # Factory skips validation since we can't create actual image files
      expect(verification).not_to be_nil
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates user_verification with valid attributes' do
      expect { create(:user_verification) }.to change(UserVerification, :count).by(1)
    end

    it 'updates user_verification attributes' do
      verification = create(:user_verification, status: :pending)

      verification.update_column(:status, 1) # accepted = 1

      expect(verification.reload.status).to eq("accepted")
      expect(verification).to be_accepted
    end

    it 'deletes user_verification' do
      verification = create(:user_verification)

      expect { verification.destroy }.to change(UserVerification, :count).by(-1)
    end
  end

  # ====================
  # ENUM TESTS
  # ====================

  describe 'enum' do
    it 'has status enum' do
      verification = create(:user_verification, status: :accepted)
      expect(verification.status).to eq("accepted")
      expect(verification).to be_accepted
    end

    it 'supports all status values' do
      %i[pending accepted issues rejected accepted_by_email discarded paused].each do |status|
        verification = build(:user_verification, status: status)
        expect(verification.status).to eq(status.to_s)
      end
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.verifying' do
      it 'returns pending, issues, and paused verifications' do
        pending = create(:user_verification, status: :pending)
        issues = create(:user_verification, status: :issues)
        paused = create(:user_verification, status: :paused)
        accepted = create(:user_verification, status: :accepted)
        rejected = create(:user_verification, status: :rejected)

        results = UserVerification.verifying

        expect(results).to include(pending)
        expect(results).to include(issues)
        expect(results).to include(paused)
        expect(results).not_to include(accepted)
        expect(results).not_to include(rejected)
      end
    end

    describe '.not_discarded' do
      it 'excludes discarded verifications' do
        pending = create(:user_verification, status: :pending)
        discarded = create(:user_verification, status: :discarded)

        results = UserVerification.not_discarded

        expect(results).to include(pending)
        expect(results).not_to include(discarded)
      end
    end

    describe '.discardable' do
      it 'returns pending and issues verifications' do
        pending = create(:user_verification, status: :pending)
        issues = create(:user_verification, status: :issues)
        accepted = create(:user_verification, status: :accepted)

        results = UserVerification.discardable

        expect(results).to include(pending)
        expect(results).to include(issues)
        expect(results).not_to include(accepted)
      end
    end

    describe '.not_sended' do
      it 'returns verifications wanting card without born_at' do
        not_sent = create(:user_verification, wants_card: true, born_at: nil)
        sent = create(:user_verification, wants_card: true, born_at: 20.years.ago)
        no_card = create(:user_verification, wants_card: false, born_at: nil)

        results = UserVerification.not_sended

        expect(results).to include(not_sent)
        expect(results).not_to include(sent)
        expect(results).not_to include(no_card)
      end
    end
  end

  # ====================
  # METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#discardable?' do
      it 'returns true for pending status' do
        verification = create(:user_verification, status: :pending)
        expect(verification).to be_discardable
      end

      it 'returns true for issues status' do
        verification = create(:user_verification, status: :issues)
        expect(verification).to be_discardable
      end

      it 'returns false for accepted status' do
        verification = create(:user_verification, status: :accepted)
        expect(verification).not_to be_discardable
      end
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to user' do
      verification = create(:user_verification)
      expect(verification).to respond_to(:user)
      expect(verification.user).to be_an_instance_of(User)
    end
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  describe 'combined scenarios' do
    it 'tracks verification lifecycle' do
      user = create(:user)
      verification = create(:user_verification, user: user, status: :pending)

      expect(verification).to be_pending
      expect(verification.processed_at).to be_nil

      verification.update_columns(status: 1, processed_at: Time.current) # accepted = 1

      expect(verification.reload).to be_accepted
      expect(verification.processed_at).not_to be_nil
    end
  end
end
