# frozen_string_literal: true

require 'rails_helper'

module Gamification
  RSpec.describe BadgeAwarder, type: :service do
    let(:user) { double('User', id: 1) }
    let(:user_stats) { double('UserStats') }
    let(:badge) do
      double('Badge',
             id: 1,
             name: 'Test Badge',
             description: 'A test badge',
             icon: '🏆',
             points_reward: 100)
    end
    let(:notification_class) { class_double('Notification').as_stubbed_const }

    before do
      allow(UserStats).to receive(:for_user).with(user).and_return(user_stats)
      allow(notification_class).to receive(:create!)
      allow_any_instance_of(Object).to receive(:publish_event)
    end

    describe '.check_and_award!' do
      let(:badge1) do
        double('Badge',
               id: 1,
               name: 'Badge 1',
               description: 'First badge',
               icon: '🥇',
               points_reward: 50)
      end
      let(:badge2) do
        double('Badge',
               id: 2,
               name: 'Badge 2',
               description: 'Second badge',
               icon: '🥈',
               points_reward: 30)
      end
      let(:user_badge1) { double('UserBadge', id: 1, user: user, badge: badge1) }
      let(:user_badge2) { double('UserBadge', id: 2, user: user, badge: badge2) }

      before do
        allow(Badge).to receive(:find_each).and_yield(badge1).and_yield(badge2)
      end

      it 'checks all badges for user' do
        allow(UserBadge).to receive(:exists?).and_return(false)
        allow(badge1).to receive(:criteria_met?).with(user).and_return(false)
        allow(badge2).to receive(:criteria_met?).with(user).and_return(false)

        expect(Badge).to receive(:find_each)
        described_class.check_and_award!(user)
      end

      it 'skips badges user already has' do
        allow(UserBadge).to receive(:exists?).with(user_id: user.id, badge_id: badge1.id).and_return(true)
        allow(UserBadge).to receive(:exists?).with(user_id: user.id, badge_id: badge2.id).and_return(false)
        allow(badge2).to receive(:criteria_met?).with(user).and_return(false)

        expect(badge1).not_to receive(:criteria_met?)
        described_class.check_and_award!(user)
      end

      it 'skips badges whose criteria are not met' do
        allow(UserBadge).to receive(:exists?).and_return(false)
        allow(badge1).to receive(:criteria_met?).with(user).and_return(false)
        allow(badge2).to receive(:criteria_met?).with(user).and_return(true)
        allow(UserBadge).to receive(:create!).and_return(user_badge2)
        allow(user_stats).to receive(:earn_points!)
        allow(notification_class).to receive(:create!)
        allow_any_instance_of(Object).to receive(:publish_event)

        expect(UserBadge).not_to receive(:create!).with(hash_including(badge: badge1))
        described_class.check_and_award!(user)
      end

      it 'awards badges whose criteria are met' do
        allow(UserBadge).to receive(:exists?).and_return(false)
        allow(badge1).to receive(:criteria_met?).with(user).and_return(true)
        allow(badge2).to receive(:criteria_met?).with(user).and_return(false)
        allow(UserBadge).to receive(:create!).and_return(user_badge1)
        allow(user_stats).to receive(:earn_points!)
        allow(notification_class).to receive(:create!)
        allow_any_instance_of(Object).to receive(:publish_event)

        result = described_class.check_and_award!(user)
        expect(result).to include(user_badge1)
      end

      it 'returns array of awarded badges' do
        allow(UserBadge).to receive(:exists?).and_return(false)
        allow(badge1).to receive(:criteria_met?).with(user).and_return(true)
        allow(badge2).to receive(:criteria_met?).with(user).and_return(true)
        allow(UserBadge).to receive(:create!).and_return(user_badge1, user_badge2)
        allow(user_stats).to receive(:earn_points!)
        allow(notification_class).to receive(:create!)
        allow_any_instance_of(Object).to receive(:publish_event)

        result = described_class.check_and_award!(user)
        expect(result).to match_array([user_badge1, user_badge2])
      end

      it 'creates user stats for user' do
        allow(UserBadge).to receive(:exists?).and_return(false)
        allow(badge1).to receive(:criteria_met?).and_return(false)
        allow(badge2).to receive(:criteria_met?).and_return(false)

        expect(UserStats).to receive(:for_user).with(user)
        described_class.check_and_award!(user)
      end
    end

    describe '.award_badge!' do
      let(:user_badge) { double('UserBadge', id: 1, user: user, badge: badge) }

      context 'when user does not have badge' do
        before do
          allow(UserBadge).to receive(:exists?).with(user_id: user.id, badge_id: badge.id).and_return(false)
        end

        it 'creates user badge record' do
          expect(UserBadge).to receive(:create!).with(
            user: user,
            badge: badge,
            earned_at: kind_of(ActiveSupport::TimeWithZone)
          ).and_return(user_badge)

          allow(user_stats).to receive(:earn_points!)
          allow(notification_class).to receive(:create!)
          allow_any_instance_of(Object).to receive(:publish_event)

          described_class.award_badge!(user, badge)
        end

        it 'awards bonus points when badge has points reward' do
          allow(UserBadge).to receive(:create!).and_return(user_badge)
          allow(badge).to receive(:points_reward).and_return(100)
          allow(notification_class).to receive(:create!)
          allow_any_instance_of(Object).to receive(:publish_event)

          expect(user_stats).to receive(:earn_points!).with(
            100,
            reason: "Badge earned: #{badge.name}",
            source: badge
          )

          described_class.award_badge!(user, badge)
        end

        it 'does not award points when badge has no points reward' do
          allow(UserBadge).to receive(:create!).and_return(user_badge)
          allow(badge).to receive(:points_reward).and_return(0)
          allow(notification_class).to receive(:create!)
          allow_any_instance_of(Object).to receive(:publish_event)

          expect(user_stats).not_to receive(:earn_points!)

          described_class.award_badge!(user, badge)
        end

        it 'publishes badge earned event' do
          allow(UserBadge).to receive(:create!).and_return(user_badge)
          allow(user_stats).to receive(:earn_points!)
          allow(notification_class).to receive(:create!)

          expect_any_instance_of(Object).to receive(:publish_event).with(
            'gamification.badge_earned',
            {
              user_id: user.id,
              badge_id: badge.id,
              badge_name: badge.name,
              points_reward: badge.points_reward
            }
          )

          described_class.award_badge!(user, badge)
        end

        it 'creates notification for user' do
          allow(UserBadge).to receive(:create!).and_return(user_badge)
          allow(user_stats).to receive(:earn_points!)
          allow_any_instance_of(Object).to receive(:publish_event)

          expect(notification_class).to receive(:create!).with(
            user: user,
            notification_type: 'badge_earned',
            title: "¡Badge desbloqueado! #{badge.icon}",
            body: "Has ganado el badge '#{badge.name}': #{badge.description}",
            notifiable: user_badge,
            channels: %w[push in_app]
          )

          described_class.award_badge!(user, badge)
        end

        it 'returns created user badge' do
          allow(UserBadge).to receive(:create!).and_return(user_badge)
          allow(user_stats).to receive(:earn_points!)
          allow(notification_class).to receive(:create!)
          allow_any_instance_of(Object).to receive(:publish_event)

          result = described_class.award_badge!(user, badge)
          expect(result).to eq(user_badge)
        end
      end

      context 'when user already has badge' do
        before do
          allow(UserBadge).to receive(:exists?).with(user_id: user.id, badge_id: badge.id).and_return(true)
        end

        it 'returns nil' do
          result = described_class.award_badge!(user, badge)
          expect(result).to be_nil
        end

        it 'does not create user badge' do
          expect(UserBadge).not_to receive(:create!)
          described_class.award_badge!(user, badge)
        end

        it 'does not award points' do
          expect(user_stats).not_to receive(:earn_points!)
          described_class.award_badge!(user, badge)
        end

        it 'does not publish event' do
          expect_any_instance_of(Object).not_to receive(:publish_event)
          described_class.award_badge!(user, badge)
        end

        it 'does not create notification' do
          expect(notification_class).not_to receive(:create!)
          described_class.award_badge!(user, badge)
        end
      end

      context 'error handling' do
        before do
          allow(UserBadge).to receive(:exists?).and_return(false)
        end

        it 'raises error when user badge creation fails' do
          allow(UserBadge).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new)

          expect do
            described_class.award_badge!(user, badge)
          end.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'raises error when notification creation fails' do
          allow(UserBadge).to receive(:create!).and_return(user_badge)
          allow(user_stats).to receive(:earn_points!)
          allow_any_instance_of(Object).to receive(:publish_event)
          allow(notification_class).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new)

          expect do
            described_class.award_badge!(user, badge)
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    describe '.user_has_badge?' do
      it 'returns true when user has badge' do
        allow(UserBadge).to receive(:exists?).with(user_id: user.id, badge_id: badge.id).and_return(true)

        result = described_class.send(:user_has_badge?, user, badge)
        expect(result).to be true
      end

      it 'returns false when user does not have badge' do
        allow(UserBadge).to receive(:exists?).with(user_id: user.id, badge_id: badge.id).and_return(false)

        result = described_class.send(:user_has_badge?, user, badge)
        expect(result).to be false
      end
    end

    describe 'integration scenarios' do
      let(:bronze_badge) do
        double('Badge',
               id: 1,
               name: 'Bronze',
               description: '10 points',
               icon: '🥉',
               points_reward: 10)
      end
      let(:silver_badge) do
        double('Badge',
               id: 2,
               name: 'Silver',
               description: '50 points',
               icon: '🥈',
               points_reward: 50)
      end
      let(:gold_badge) do
        double('Badge',
               id: 3,
               name: 'Gold',
               description: '100 points',
               icon: '🥇',
               points_reward: 100)
      end

      it 'awards multiple badges in sequence' do
        allow(Badge).to receive(:find_each).and_yield(bronze_badge).and_yield(silver_badge).and_yield(gold_badge)
        allow(UserBadge).to receive(:exists?).and_return(false)
        allow(bronze_badge).to receive(:criteria_met?).and_return(true)
        allow(silver_badge).to receive(:criteria_met?).and_return(true)
        allow(gold_badge).to receive(:criteria_met?).and_return(false)

        bronze_user_badge = double('UserBadge', id: 1)
        silver_user_badge = double('UserBadge', id: 2)

        allow(UserBadge).to receive(:create!).and_return(bronze_user_badge, silver_user_badge)
        allow(user_stats).to receive(:earn_points!)
        allow(notification_class).to receive(:create!)
        allow_any_instance_of(Object).to receive(:publish_event)

        result = described_class.check_and_award!(user)
        expect(result.length).to eq(2)
      end

      it 'tracks total points awarded from badges' do
        allow(Badge).to receive(:find_each).and_yield(bronze_badge).and_yield(silver_badge)
        allow(UserBadge).to receive(:exists?).and_return(false)
        allow(bronze_badge).to receive(:criteria_met?).and_return(true)
        allow(silver_badge).to receive(:criteria_met?).and_return(true)
        allow(UserBadge).to receive(:create!)
          .and_return(double('UserBadge', id: 1), double('UserBadge', id: 2))
        allow(notification_class).to receive(:create!)
        allow_any_instance_of(Object).to receive(:publish_event)

        expect(user_stats).to receive(:earn_points!).with(10, anything).once
        expect(user_stats).to receive(:earn_points!).with(50, anything).once

        described_class.check_and_award!(user)
      end
    end
  end
end
