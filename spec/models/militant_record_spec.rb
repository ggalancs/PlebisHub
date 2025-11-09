# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MilitantRecord, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid militant_record' do
      record = build(:militant_record)
      expect(record).to be_valid, "Factory should create a valid militant_record"
    end

    it 'creates record with associations' do
      record = create(:militant_record)
      expect(record.user).not_to be_nil
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates militant_record with valid attributes' do
      expect { create(:militant_record) }.to change(MilitantRecord, :count).by(1)
    end

    it 'reads militant_record attributes correctly' do
      user = create(:user)
      record = create(:militant_record,
        user: user,
        amount: 5000,
        payment_type: 2,
        is_militant: true
      )

      found_record = MilitantRecord.find(record.id)
      expect(found_record.user_id).to eq(user.id)
      expect(found_record.amount).to eq(5000)
      expect(found_record.payment_type).to eq(2)
      expect(found_record.is_militant).to eq(true)
    end

    it 'updates militant_record attributes' do
      record = create(:militant_record, is_militant: true)

      record.update(is_militant: false, end_verified: Time.current)

      expect(record.reload.is_militant).to eq(false)
      expect(record.end_verified).not_to be_nil
    end

    it 'deletes militant_record' do
      record = create(:militant_record)

      expect { record.destroy }.to change(MilitantRecord, :count).by(-1)
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to user' do
      record = create(:militant_record)
      expect(record).to respond_to(:user)
      expect(record.user).to be_an_instance_of(User)
    end
  end

  # ====================
  # DATE RANGE TESTS
  # ====================

  describe 'date ranges' do
    it 'tracks verification period' do
      record = create(:militant_record,
        begin_verified: 1.year.ago,
        end_verified: nil
      )

      expect(record.begin_verified).not_to be_nil
      expect(record.end_verified).to be_nil
    end

    it 'tracks payment period' do
      record = create(:militant_record,
        begin_payment: 1.year.ago,
        end_payment: nil
      )

      expect(record.begin_payment).not_to be_nil
      expect(record.end_payment).to be_nil
    end

    it 'handles ended militant status' do
      record = create(:militant_record, :ended)

      expect(record.end_verified).not_to be_nil
      expect(record.end_payment).not_to be_nil
      expect(record.is_militant).to eq(false)
    end
  end

  # ====================
  # PAYMENT TESTS
  # ====================

  describe 'payment' do
    it 'stores payment_type' do
      record = create(:militant_record, payment_type: 3)
      expect(record.payment_type).to eq(3)
    end

    it 'stores amount in cents' do
      record = create(:militant_record, amount: 2500)
      expect(record.amount).to eq(2500)
    end

    it 'handles zero amount' do
      record = create(:militant_record, amount: 0)
      expect(record.amount).to eq(0)
    end
  end

  # ====================
  # QUERY TESTS
  # ====================

  describe 'queries' do
    it 'finds active militants by nil end_verified' do
      active = create(:militant_record, end_verified: nil)
      ended = create(:militant_record, end_verified: 1.day.ago)

      results = MilitantRecord.where(end_verified: nil)

      expect(results).to include(active)
      expect(results).not_to include(ended)
    end

    it 'finds by is_militant flag' do
      militant = create(:militant_record, is_militant: true)
      non_militant = create(:militant_record, is_militant: false)

      results = MilitantRecord.where(is_militant: true)

      expect(results).to include(militant)
      expect(results).not_to include(non_militant)
    end

    it 'finds records by user' do
      user = create(:user)
      record1 = create(:militant_record, user: user)
      record2 = create(:militant_record, user: user)
      other_record = create(:militant_record)

      user_records = MilitantRecord.where(user: user)

      expect(user_records.count).to eq(2)
      expect(user_records).to include(record1)
      expect(user_records).to include(record2)
      expect(user_records).not_to include(other_record)
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles nil dates' do
      record = create(:militant_record,
        begin_verified: nil,
        end_verified: nil,
        begin_payment: nil,
        end_payment: nil
      )

      expect(record.begin_verified).to be_nil
      expect(record.end_verified).to be_nil
      expect(record.begin_payment).to be_nil
      expect(record.end_payment).to be_nil
    end

    it 'handles negative amounts' do
      record = create(:militant_record, amount: -1000)
      expect(record.amount).to eq(-1000)
    end

    it 'handles large amounts' do
      record = create(:militant_record, amount: 1_000_000_00)
      expect(record.amount).to eq(1_000_000_00)
    end
  end

  # ====================
  # DIFF FUNCTIONALITY TESTS
  # ====================

  describe 'diff functionality' do
    it 'supports diff functionality' do
      record = create(:militant_record, amount: 1000, is_militant: true)

      expect(record).to respond_to(:diff)
    end

    it 'calculates diff between records' do
      record1 = create(:militant_record, amount: 1000, is_militant: true)
      record2 = build(:militant_record, amount: 2000, is_militant: false)

      # The diff method should work
      diff = record1.diff(record2)

      expect(diff).to be_a(Hash)
    end

    it 'excludes created_at and updated_at from diff' do
      record1 = create(:militant_record, amount: 1000)
      sleep 0.01
      record2 = create(:militant_record, amount: 1000)

      diff = record1.diff(record2)

      # created_at and updated_at should be excluded
      expect(diff.keys).not_to include(:created_at)
      expect(diff.keys).not_to include(:updated_at)
    end
  end
end
