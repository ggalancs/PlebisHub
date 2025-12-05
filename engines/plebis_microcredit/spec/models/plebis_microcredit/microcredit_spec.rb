# frozen_string_literal: true

require 'rails_helper'

module PlebisMicrocredit
  RSpec.describe Microcredit, type: :model do
    describe 'associations' do
      it { is_expected.to have_many(:loans).class_name('PlebisMicrocredit::MicrocreditLoan') }
      it { is_expected.to have_many(:microcredit_options).class_name('PlebisMicrocredit::MicrocreditOption').dependent(:destroy) }
    end

    describe 'scopes' do
      describe '.active' do
        it 'returns active microcredits' do
          active = create(:microcredit, starts_at: 1.day.ago, ends_at: 1.day.from_now)
          upcoming = create(:microcredit, starts_at: 1.day.from_now, ends_at: 2.days.from_now)

          expect(Microcredit.active).to include(active)
          expect(Microcredit.active).not_to include(upcoming)
        end
      end
    end

    describe '#is_active?' do
      it 'returns true when current time is between starts_at and ends_at' do
        microcredit = build(:microcredit, starts_at: 1.day.ago, ends_at: 1.day.from_now)
        expect(microcredit.is_active?).to be true
      end

      it 'returns false when current time is before starts_at' do
        microcredit = build(:microcredit, starts_at: 1.day.from_now, ends_at: 2.days.from_now)
        expect(microcredit.is_active?).to be false
      end
    end

    describe '#has_finished?' do
      it 'returns true when ends_at is in the past' do
        microcredit = build(:microcredit, ends_at: 1.day.ago)
        expect(microcredit.has_finished?).to be true
      end

      it 'returns false when ends_at is in the future' do
        microcredit = build(:microcredit, ends_at: 1.day.from_now)
        expect(microcredit.has_finished?).to be false
      end
    end

    describe 'table name' do
      it 'uses microcredits table' do
        expect(Microcredit.table_name).to eq('microcredits')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        microcredit = build(:microcredit)
        expect(microcredit).to be_valid
      end

      it 'creates a microcredit with required attributes' do
        microcredit = create(:microcredit)
        expect(microcredit).to be_persisted
      end
    end
  end
end
