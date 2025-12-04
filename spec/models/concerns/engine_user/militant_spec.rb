# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineUser::Militant, type: :model do
  let(:user) { create(:user, :with_dni) }
  # NOTE: MIN_MILITANT_AMOUNT is in euros (e.g. 3), but amount is stored in cents
  # The concern code compares them directly which may be a bug, but we test actual behavior
  let(:min_amount) { User::MIN_MILITANT_AMOUNT } # This is in euros, not cents!

  describe 'associations' do
    it 'responds to militant_records' do
      expect(user).to respond_to(:militant_records)
    end

    it 'returns an ActiveRecord relation' do
      expect(user.militant_records).to be_an(ActiveRecord::Relation)
    end
  end

  describe '#still_militant?' do
    context 'when all conditions are met' do
      before do
        # Set verified flag
        user.update_column(:flags, user.flags | 4)
        # User already has vote_circle from factory
        # Create active collaboration
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns true' do
        expect(user.still_militant?).to be true
      end
    end

    context 'when user is not verified' do
      before do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns false' do
        expect(user.still_militant?).to be false
      end
    end

    context 'when user is not in vote circle' do
      let(:user_no_circle) { create(:user, vote_circle: nil) }

      before do
        user_no_circle.update_column(:flags, user_no_circle.flags | 4)
        create(:collaboration, user: user_no_circle, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns false' do
        expect(user_no_circle.still_militant?).to be false
      end
    end

    context 'when user has no collaboration and is not exempt' do
      before do
        user.update_column(:flags, user.flags | 4)
      end

      it 'returns false' do
        expect(user.still_militant?).to be false
      end
    end

    context 'when user is exempt from payment' do
      before do
        user.update_column(:flags, user.flags | 4 | 512) # verified + exempt_from_payment
      end

      it 'returns true' do
        expect(user.still_militant?).to be true
      end
    end

    context 'when user has pending collaboration' do
      before do
        user.update_column(:flags, user.flags | 4)
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 2) # pending
        end
      end

      it 'returns true' do
        expect(user.still_militant?).to be true
      end
    end
  end

  describe '#militant_at?' do
    let(:check_date) { 1.month.ago }

    context 'when user has all requirements at specified date' do
      before do
        user.update_columns(
          vote_circle_changed_at: 2.months.ago,
          flags: user.flags | 4 # verified
        )
        create(:user_verification, user: user, status: :accepted).tap do |v|
          v.update_column(:updated_at, 2.months.ago)
        end
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_columns(status: 3, created_at: 2.months.ago)
        end
      end

      it 'returns true' do
        expect(user.militant_at?(check_date)).to be true
      end
    end

    context 'when user vote circle was set after the date' do
      before do
        user.update_columns(
          vote_circle_changed_at: 1.week.ago,
          flags: user.flags | 4
        )
        create(:user_verification, user: user, status: :accepted).tap do |v|
          v.update_column(:updated_at, 2.months.ago)
        end
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_columns(status: 3, created_at: 2.months.ago)
        end
      end

      it 'returns false' do
        expect(user.militant_at?(check_date)).to be false
      end
    end

    context 'when user verification was set after the date' do
      before do
        user.update_columns(
          vote_circle_changed_at: 2.months.ago,
          flags: user.flags | 4
        )
        create(:user_verification, user: user, status: :accepted).tap do |v|
          v.update_column(:updated_at, 1.week.ago)
        end
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_columns(status: 3, created_at: 2.months.ago)
        end
      end

      it 'returns false' do
        expect(user.militant_at?(check_date)).to be false
      end
    end

    context 'when user collaboration was created after the date' do
      before do
        user.update_columns(
          vote_circle_changed_at: 2.months.ago,
          flags: user.flags | 4
        )
        create(:user_verification, user: user, status: :accepted).tap do |v|
          v.update_column(:updated_at, 2.months.ago)
        end
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_columns(status: 3, created_at: 1.week.ago)
        end
      end

      it 'returns false' do
        expect(user.militant_at?(check_date)).to be false
      end
    end

    context 'when user is exempt from payment' do
      before do
        user.update_columns(
          vote_circle_changed_at: 2.months.ago,
          flags: user.flags | 4 | 512 # verified + exempt_from_payment
        )
        create(:user_verification, user: user, status: :accepted).tap do |v|
          v.update_column(:updated_at, 2.months.ago)
        end
        create(:militant_record, user: user, payment_type: 0, begin_payment: 2.months.ago)
      end

      it 'returns true' do
        expect(user.militant_at?(check_date)).to be true
      end
    end

    context 'when user has no vote circle' do
      let(:user_no_circle) { create(:user, vote_circle: nil) }

      before do
        user_no_circle.update_column(:flags, user_no_circle.flags | 4)
        create(:user_verification, user: user_no_circle, status: :accepted).tap do |v|
          v.update_column(:updated_at, 2.months.ago)
        end
        create(:collaboration, user: user_no_circle, frequency: 1, amount: min_amount).tap do |c|
          c.update_columns(status: 3, created_at: 2.months.ago)
        end
      end

      it 'returns false' do
        expect(user_no_circle.militant_at?(check_date)).to be false
      end
    end

    context 'when user has no verifications' do
      before do
        user.update_columns(vote_circle_changed_at: 2.months.ago)
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_columns(status: 3, created_at: 2.months.ago)
        end
      end

      it 'returns false' do
        expect(user.militant_at?(check_date)).to be false
      end
    end

    context 'when user has no collaboration and is not exempt' do
      before do
        user.update_columns(
          vote_circle_changed_at: 2.months.ago,
          flags: user.flags | 4
        )
        create(:user_verification, user: user, status: :accepted).tap do |v|
          v.update_column(:updated_at, 2.months.ago)
        end
      end

      it 'returns false' do
        expect(user.militant_at?(check_date)).to be false
      end
    end

    context 'with pending verification status' do
      before do
        user.update_columns(
          vote_circle_changed_at: 2.months.ago,
          flags: user.flags & ~4 # not verified flag
        )
        create(:user_verification, user: user, status: :pending).tap do |v|
          v.update_column(:updated_at, 2.months.ago)
        end
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_columns(status: 3, created_at: 2.months.ago)
        end
      end

      it 'returns true' do
        expect(user.militant_at?(check_date)).to be true
      end
    end
  end

  describe '#get_not_militant_detail' do
    context 'when user is already militant and still meets requirements' do
      before do
        user.update_column(:flags, user.flags | 4 | 256) # verified + militant
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns nil' do
        expect(user.get_not_militant_detail).to be_nil
      end
    end

    context 'when user is not militant but meets all requirements' do
      before do
        user.update_column(:flags, user.flags | 4) # verified but not militant
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'updates militant flag and returns nil' do
        result = user.get_not_militant_detail
        expect(result).to be_nil
        user.reload
        expect(user.militant?).to be true
      end
    end

    context 'when user is not verified' do
      before do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns verification message' do
        result = user.get_not_militant_detail
        expect(result).to include('No esta verificado')
      end
    end

    context 'when user is not in vote circle' do
      let(:user_no_circle) { create(:user, vote_circle: nil) }

      before do
        user_no_circle.update_column(:flags, user_no_circle.flags | 4)
        create(:collaboration, user: user_no_circle, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns circle message' do
        result = user_no_circle.get_not_militant_detail
        expect(result).to include('No esta inscrito en un circulo')
      end
    end

    context 'when user has no collaboration' do
      before do
        user.update_column(:flags, user.flags | 4)
      end

      it 'returns collaboration message' do
        result = user.get_not_militant_detail
        expect(result).to include('colaboración económica')
      end
    end

    context 'when user fails multiple requirements' do
      let(:user_no_circle) { create(:user, vote_circle: nil) }

      it 'returns combined message with y' do
        result = user_no_circle.get_not_militant_detail
        expect(result).to include('y')
      end
    end
  end

  describe '#process_militant_data' do
    before do
      # Mock the mailer to avoid actual email sending
      allow(UsersMailer).to receive(:new_militant_email).and_return(double(deliver_now: true))
    end

    context 'when user becomes militant for the first time' do
      before do
        user.update_column(:flags, user.flags | 4)
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'sends militant email' do
        expect(UsersMailer).to receive(:new_militant_email).with(user.id).and_return(double(deliver_now: true))
        user.process_militant_data
      end

      it 'creates militant record' do
        expect do
          user.process_militant_data
        end.to change(MilitantRecord, :count).by(1)
      end
    end

    context 'when user is already militant' do
      let!(:existing_record) { create(:militant_record, user: user, is_militant: true) }

      before do
        user.update_column(:flags, user.flags | 4)
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'does not send email' do
        expect(UsersMailer).not_to receive(:new_militant_email)
        user.process_militant_data
      end
    end

    context 'when user was militant but is no longer' do
      let!(:existing_record) { create(:militant_record, user: user, is_militant: true) }

      it 'does not send email' do
        expect(UsersMailer).not_to receive(:new_militant_email)
        user.process_militant_data
      end

      it 'creates new militant record' do
        expect do
          user.process_militant_data
        end.to change(MilitantRecord, :count).by(1)
      end
    end
  end

  describe '#militant_records_management' do
    context 'when user is verified' do
      before do
        user.update_column(:flags, user.flags | 4)
        create(:user_verification, user: user, status: :accepted)
      end

      it 'creates record with verification dates' do
        user.militant_records_management(true)
        record = user.militant_records.last
        expect(record.begin_verified).to be_present
        expect(record.end_verified).to be_nil
      end
    end

    context 'when user is in vote circle' do
      before do
        user.update_columns(vote_circle_changed_at: 1.day.ago)
      end

      it 'creates record with vote circle dates' do
        user.militant_records_management(true)
        record = user.militant_records.last
        expect(record.begin_in_vote_circle).to be_present
        expect(record.vote_circle_name).to eq(user.vote_circle.name)
        expect(record.end_in_vote_circle).to be_nil
      end
    end

    context 'when user has collaboration' do
      before do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'creates record with payment details' do
        user.militant_records_management(true)
        record = user.militant_records.last
        expect(record.begin_payment).to be_present
        expect(record.payment_type).to eq(1)
        expect(record.amount).to eq(min_amount)
        expect(record.end_payment).to be_nil
      end
    end

    context 'when user is exempt from payment' do
      before do
        user.update_column(:flags, user.flags | 512) # exempt_from_payment
      end

      it 'creates record with payment type 0' do
        user.militant_records_management(true)
        record = user.militant_records.last
        expect(record.payment_type).to eq(0)
        expect(record.amount).to eq(0)
      end
    end

    context 'when user stops being verified' do
      let!(:existing_record) do
        create(:militant_record,
               user: user,
               begin_verified: 1.month.ago,
               end_verified: nil)
      end

      it 'sets end_verified date' do
        user.militant_records_management(false)
        record = user.militant_records.last
        expect(record.end_verified).to be_present
      end
    end

    context 'when user leaves vote circle' do
      let!(:existing_record) do
        create(:militant_record,
               user: user,
               begin_in_vote_circle: 1.month.ago,
               vote_circle_name: 'Old Circle',
               end_in_vote_circle: nil)
      end

      before do
        user.update_column(:vote_circle_id, nil)
      end

      it 'sets end_in_vote_circle date' do
        user.militant_records_management(false)
        record = user.militant_records.last
        expect(record.end_in_vote_circle).to be_present
      end
    end

    context 'when user stops having collaboration' do
      let!(:existing_record) do
        create(:militant_record,
               user: user,
               begin_payment: 1.month.ago,
               end_payment: nil,
               payment_type: 1)
      end

      before do
        user.update_column(:flags, user.flags & ~512) # not exempt
      end

      it 'sets end_payment date' do
        user.militant_records_management(false)
        record = user.militant_records.last
        expect(record.end_payment).to be_present
      end
    end

    context 'when user changes vote circle' do
      let!(:existing_record) do
        create(:militant_record,
               user: user,
               begin_in_vote_circle: 1.month.ago,
               vote_circle_name: 'Old Circle',
               end_in_vote_circle: nil)
      end

      let(:new_circle) { create(:vote_circle, name: 'New Circle') }

      before do
        user.update_columns(
          vote_circle_id: new_circle.id,
          vote_circle_changed_at: Time.current
        )
      end

      it 'creates new record with new circle name' do
        user.militant_records_management(true)
        record = user.militant_records.last
        expect(record.vote_circle_name).to eq('New Circle')
        expect(record.begin_in_vote_circle).to be_present
      end

      it 'closes previous record' do
        user.militant_records_management(true)
        existing_record.reload
        expect(existing_record.end_in_vote_circle).to be_present
      end
    end

    context 'when record has no changes' do
      let!(:existing_record) do
        create(:militant_record,
               user: user,
               is_militant: true,
               begin_verified: 1.month.ago,
               end_verified: nil)
      end

      before do
        user.update_column(:flags, user.flags | 4)
        create(:user_verification, user: user, status: :accepted).tap do |v|
          v.update_column(:updated_at, 1.month.ago)
        end
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_columns(status: 3, created_at: 1.month.ago)
        end
        user.update_columns(vote_circle_changed_at: 1.month.ago)
      end

      it 'does not create new record' do
        expect do
          user.militant_records_management(true)
        end.not_to change(MilitantRecord, :count)
      end
    end

    context 'when is_militant changes' do
      it 'sets is_militant flag correctly' do
        user.militant_records_management(true)
        record = user.militant_records.last
        expect(record.is_militant).to be true

        user.militant_records_management(false)
        record = user.militant_records.last
        expect(record.is_militant).to be false
      end
    end
  end
end
