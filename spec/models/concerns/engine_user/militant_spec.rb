# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineUser::Militant, type: :model do
  let(:vote_circle) { create(:vote_circle) }
  let(:user) { create(:user, vote_circle: vote_circle, document_type: 1, document_vatid: '12345678Z') }

  describe 'associations' do
    it 'has many militant_records with dependent destroy' do
      association = user.class.reflect_on_association(:militant_records)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe '#still_militant?' do
    context 'when all conditions are met' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns true' do
        expect(user.still_militant?).to be true
      end
    end

    context 'when user is not verified' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
      end

      it 'returns false' do
        expect(user.still_militant?).to be false
      end
    end

    context 'when user is not in vote circle' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
      end

      it 'returns false' do
        expect(user.still_militant?).to be false
      end
    end

    context 'when user has no collaboration and is not exempt' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns false' do
        expect(user.still_militant?).to be false
      end
    end

    context 'when user is exempt from payment' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(true)
      end

      it 'returns true' do
        expect(user.still_militant?).to be true
      end
    end
  end

  describe '#militant_at?' do
    let(:test_date) { Date.new(2024, 6, 1) }

    context 'when all conditions were met at the given date' do
      before do
        user.update(
          vote_circle_id: vote_circle.id,
          vote_circle_changed_at: test_date - 10.days
        )
        create(:user_verification, user: user, status: 'accepted', updated_at: test_date - 5.days)
        create(:collaboration, user: user, amount: 500, frequency: 1, status: 0, created_at: test_date - 3.days)
      end

      it 'returns true' do
        expect(user.militant_at?(test_date)).to be true
      end
    end

    context 'when user had no vote circle at that date' do
      before do
        user.update(vote_circle_id: nil, vote_circle_changed_at: nil)
      end

      it 'returns false' do
        expect(user.militant_at?(test_date)).to be false
      end
    end

    context 'with different collaboration statuses' do
      before do
        user.update(
          vote_circle_id: vote_circle.id,
          vote_circle_changed_at: test_date - 10.days
        )
        create(:user_verification, user: user, status: 'accepted', updated_at: test_date - 5.days)
      end

      it 'returns true for status 0 (incomplete)' do
        create(:collaboration, user: user, amount: 500, frequency: 1, status: 0, created_at: test_date - 3.days)
        expect(user.militant_at?(test_date)).to be true
      end

      it 'returns true for status 2 (unconfirmed)' do
        create(:collaboration, user: user, amount: 500, frequency: 1, status: 2, created_at: test_date - 3.days)
        expect(user.militant_at?(test_date)).to be true
      end

      it 'returns true for status 3 (active)' do
        create(:collaboration, user: user, amount: 500, frequency: 1, status: 3, created_at: test_date - 3.days)
        expect(user.militant_at?(test_date)).to be true
      end
    end
  end

  describe '#get_not_militant_detail' do
    context 'when user is already militant' do
      before do
        user.update(militant: true)
        allow(user).to receive(:still_militant?).and_return(true)
      end

      it 'returns nil' do
        expect(user.get_not_militant_detail).to be_nil
      end
    end

    context 'when user is not verified' do
      before do
        allow(user).to receive(:still_militant?).and_return(false)
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns verification error' do
        expect(user.get_not_militant_detail).to include('No esta verificado')
      end
    end

    context 'when user is not in a circle' do
      before do
        allow(user).to receive(:still_militant?).and_return(false)
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns circle error' do
        expect(user.get_not_militant_detail).to include('No esta inscrito en un circulo')
      end
    end

    context 'when user has no collaboration and is not exempt' do
      before do
        allow(user).to receive(:still_militant?).and_return(false)
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns collaboration error' do
        expect(user.get_not_militant_detail).to include('No tiene colaboración económica periódica')
      end
    end

    context 'when multiple conditions are not met' do
      before do
        allow(user).to receive(:still_militant?).and_return(false)
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'returns combined errors with proper formatting' do
        result = user.get_not_militant_detail
        expect(result).to include('No esta verificado')
        expect(result).to include('No esta inscrito en un circulo')
        expect(result).to include(' y ')
      end
    end
  end

  describe '#process_militant_data' do
    let(:mailer_double) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

    before do
      allow(UsersMailer).to receive(:new_militant_email).and_return(mailer_double)
    end

    context 'when becoming militant for the first time' do
      before do
        allow(user).to receive(:still_militant?).and_return(true)
        user.militant_records.destroy_all
      end

      it 'sends militant email' do
        expect(UsersMailer).to receive(:new_militant_email).with(user.id)
        user.process_militant_data
      end
    end

    context 'when losing militant status' do
      before do
        allow(user).to receive(:still_militant?).and_return(false)
        create(:militant_record, user: user, is_militant: true)
      end

      it 'does not send email' do
        expect(UsersMailer).not_to receive(:new_militant_email)
        user.process_militant_data
      end
    end

    context 'when regaining militant status' do
      before do
        allow(user).to receive(:still_militant?).and_return(true)
        create(:militant_record, user: user, is_militant: false)
      end

      it 'sends militant email' do
        expect(UsersMailer).to receive(:new_militant_email).with(user.id)
        user.process_militant_data
      end
    end

    context 'when remaining militant' do
      before do
        allow(user).to receive(:still_militant?).and_return(true)
        create(:militant_record, user: user, is_militant: true)
      end

      it 'does not send email' do
        expect(UsersMailer).not_to receive(:new_militant_email)
        user.process_militant_data
      end
    end
  end

  describe '#militant_records_management' do
    let(:now) { DateTime.now }

    before do
      allow(DateTime).to receive(:now).and_return(now)
    end

    context 'when user is verified' do
      before do
        user.update(verified: true)
        allow(user).to receive(:verified_for_militant?).and_return(true)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
        create(:user_verification, user: user, updated_at: 1.day.ago)
      end

      it 'sets begin_verified date' do
        user.militant_records_management(false)
        record = user.militant_records.order(id: :desc).first
        expect(record.begin_verified).not_to be_nil
      end

      it 'keeps end_verified as nil' do
        user.militant_records_management(false)
        record = user.militant_records.order(id: :desc).first
        expect(record.end_verified).to be_nil
      end
    end

    context 'when user loses verification' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
        create(:militant_record, user: user, begin_verified: 1.week.ago, end_verified: nil)
      end

      it 'sets end_verified date' do
        user.militant_records_management(false)
        record = user.militant_records.order(id: :desc).first
        expect(record.end_verified).not_to be_nil
      end
    end

    context 'when user is in vote circle' do
      before do
        user.update(vote_circle: vote_circle, vote_circle_changed_at: 1.week.ago)
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(true)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
      end

      it 'sets begin_in_vote_circle date' do
        user.militant_records_management(false)
        record = user.militant_records.order(id: :desc).first
        expect(record.begin_in_vote_circle).not_to be_nil
      end

      it 'stores vote circle name' do
        user.militant_records_management(false)
        record = user.militant_records.order(id: :desc).first
        expect(record.vote_circle_name).to eq(vote_circle.name)
      end
    end

    context 'when user is exempt from payment' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(false)
        allow(user).to receive(:exempt_from_payment?).and_return(true)
      end

      it 'sets payment_type to 0' do
        user.militant_records_management(true)
        record = user.militant_records.order(id: :desc).first
        expect(record.payment_type).to eq(0)
      end

      it 'sets amount to 0' do
        user.militant_records_management(true)
        record = user.militant_records.order(id: :desc).first
        expect(record.amount).to eq(0)
      end
    end

    context 'when user has active collaboration' do
      before do
        allow(user).to receive(:verified_for_militant?).and_return(false)
        allow(user).to receive(:in_vote_circle?).and_return(false)
        allow(user).to receive(:collaborator_for_militant?).and_return(true)
        allow(user).to receive(:exempt_from_payment?).and_return(false)
        create(:collaboration, user: user, amount: 500, frequency: 1, status: 3, created_at: 1.week.ago)
      end

      it 'sets payment_type to 1' do
        user.militant_records_management(true)
        record = user.militant_records.order(id: :desc).first
        expect(record.payment_type).to eq(1)
      end

      it 'stores collaboration amount' do
        user.militant_records_management(true)
        record = user.militant_records.order(id: :desc).first
        expect(record.amount).to eq(500)
      end
    end
  end
end
