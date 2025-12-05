# frozen_string_literal: true

require 'rails_helper'

module PlebisVerification
  RSpec.describe UserVerification, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:user) }
    end

    describe 'enum' do
      it { is_expected.to define_enum_for(:status).with_values(pending: 0, accepted: 1, issues: 2, rejected: 3, accepted_by_email: 4, discarded: 5, paused: 6) }
    end

    describe 'scopes' do
      describe '.verifying' do
        it 'returns verifications with status pending, issues, or paused' do
          pending = create(:user_verification, status: :pending)
          issues = create(:user_verification, status: :issues)
          accepted = create(:user_verification, status: :accepted)

          result = UserVerification.verifying
          expect(result).to include(pending, issues)
          expect(result).not_to include(accepted)
        end
      end

      describe '.not_discarded' do
        it 'excludes discarded verifications' do
          active = create(:user_verification, status: :pending)
          discarded = create(:user_verification, status: :discarded)

          result = UserVerification.not_discarded
          expect(result).to include(active)
          expect(result).not_to include(discarded)
        end
      end
    end

    describe '#discardable?' do
      it 'returns true for pending status' do
        verification = build(:user_verification, status: :pending)
        expect(verification.discardable?).to be true
      end

      it 'returns true for issues status' do
        verification = build(:user_verification, status: :issues)
        expect(verification.discardable?).to be true
      end

      it 'returns false for accepted status' do
        verification = build(:user_verification, status: :accepted)
        expect(verification.discardable?).to be false
      end
    end

    describe 'table name' do
      it 'uses user_verifications table' do
        expect(UserVerification.table_name).to eq('user_verifications')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        verification = build(:user_verification)
        expect(verification).to be_valid
      end

      it 'creates a verification with required attributes' do
        verification = create(:user_verification)
        expect(verification).to be_persisted
      end
    end
  end
end
