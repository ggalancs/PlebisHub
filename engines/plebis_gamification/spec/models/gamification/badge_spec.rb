# frozen_string_literal: true

require 'rails_helper'

module Gamification
  RSpec.describe Badge, type: :model do
    describe 'associations' do
      it { is_expected.to have_many(:user_badges).class_name('Gamification::UserBadge') }
      it { is_expected.to have_many(:users).through(:user_badges) }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:key) }
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:icon) }
      
      describe 'uniqueness' do
        subject { create(:gamification_badge) }
        it { is_expected.to validate_uniqueness_of(:key) }
      end

      describe 'tier validation' do
        it 'allows valid tiers' do
          %w[bronze silver gold platinum diamond].each do |tier|
            badge = build(:gamification_badge, tier: tier)
            expect(badge).to be_valid
          end
        end

        it 'allows nil tier' do
          badge = build(:gamification_badge, tier: nil)
          expect(badge).to be_valid
        end

        it 'rejects invalid tier' do
          badge = build(:gamification_badge, tier: 'invalid')
          expect(badge).not_to be_valid
        end
      end
    end

    describe 'scopes' do
      describe '.by_category' do
        it 'filters by category' do
          proposals_badge = create(:gamification_badge, category: 'proposals')
          voting_badge = create(:gamification_badge, category: 'voting')

          result = Badge.by_category('proposals')
          expect(result).to include(proposals_badge)
          expect(result).not_to include(voting_badge)
        end
      end

      describe '.by_tier' do
        it 'filters by tier' do
          bronze = create(:gamification_badge, tier: 'bronze')
          gold = create(:gamification_badge, tier: 'gold')

          result = Badge.by_tier('bronze')
          expect(result).to include(bronze)
          expect(result).not_to include(gold)
        end
      end
    end

    describe 'table name' do
      it 'uses gamification_badges table' do
        expect(Badge.table_name).to eq('gamification_badges')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        badge = build(:gamification_badge)
        expect(badge).to be_valid
      end

      it 'creates a badge with all required attributes' do
        badge = create(:gamification_badge)
        expect(badge).to be_persisted
        expect(badge.key).to be_present
        expect(badge.name).to be_present
        expect(badge.icon).to be_present
      end
    end
  end
end
