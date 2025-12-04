# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisCms::NoticeRegistrar, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid notice_registrar' do
      registrar = build(:notice_registrar)
      expect(registrar).to be_valid, 'Factory should create a valid notice_registrar'
    end

    it 'creates registrar with attributes' do
      registrar = create(:notice_registrar)
      expect(registrar.registration_id).not_to be_nil
      expect(registrar.status).to eq(true)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'allows registrar without registration_id' do
      registrar = build(:notice_registrar, registration_id: nil)
      # No validations in model
      expect(registrar).to be_valid
    end

    it 'allows registrar without status' do
      registrar = build(:notice_registrar, status: nil)
      expect(registrar).to be_valid
    end

    it 'allows duplicate registration_ids' do
      create(:notice_registrar, registration_id: 'DUPLICATE')
      registrar2 = build(:notice_registrar, registration_id: 'DUPLICATE')

      # No uniqueness constraint
      expect(registrar2).to be_valid
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates notice_registrar with valid attributes' do
      expect { create(:notice_registrar) }.to change(NoticeRegistrar, :count).by(1)
    end

    it 'reads notice_registrar attributes correctly' do
      registrar = create(:notice_registrar,
                         registration_id: 'TEST123',
                         status: true)

      found_registrar = NoticeRegistrar.find(registrar.id)
      expect(found_registrar.registration_id).to eq('TEST123')
      expect(found_registrar.status).to eq(true)
    end

    it 'updates notice_registrar attributes' do
      registrar = create(:notice_registrar, status: true)

      registrar.update(status: false)

      expect(registrar.reload.status).to eq(false)
    end

    it 'deletes notice_registrar' do
      registrar = create(:notice_registrar)

      expect { registrar.destroy }.to change(NoticeRegistrar, :count).by(-1)
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles empty registration_id' do
      registrar = build(:notice_registrar, registration_id: '')
      expect(registrar).to be_valid
    end

    it 'handles very long registration_id' do
      registrar = build(:notice_registrar, registration_id: 'A' * 1000)
      expect(registrar).to be_valid
    end

    it 'handles special characters in registration_id' do
      registrar = build(:notice_registrar, registration_id: 'REG-2024/001@TEST')
      expect(registrar).to be_valid
    end

    it 'handles unicode in registration_id' do
      registrar = build(:notice_registrar, registration_id: '登録123')
      expect(registrar).to be_valid
    end

    it 'handles boolean status values' do
      registrar_true = create(:notice_registrar, status: true)
      registrar_false = create(:notice_registrar, status: false)
      registrar_nil = create(:notice_registrar, status: nil)

      expect(registrar_true.status).to eq(true)
      expect(registrar_false.status).to eq(false)
      expect(registrar_nil.status).to be_nil
    end

    it 'handles numeric values for status' do
      registrar = create(:notice_registrar, status: 1)
      # ActiveRecord coerces to boolean
      expect(registrar.status).to eq(true)
    end
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  describe 'combined scenarios' do
    it 'tracks full lifecycle of registrar' do
      initial_count = NoticeRegistrar.count

      # Create
      registrar = create(:notice_registrar, registration_id: 'LC001', status: true)
      expect(NoticeRegistrar.count).to eq(initial_count + 1)

      # Update
      registrar.update(status: false)
      expect(registrar.reload.status).to eq(false)

      # Update registration_id
      registrar.update(registration_id: 'LC002')
      expect(registrar.reload.registration_id).to eq('LC002')

      # Delete
      registrar.destroy
      expect(NoticeRegistrar.count).to eq(initial_count)
    end

    it 'handles multiple registrars with different statuses' do
      active = create(:notice_registrar, registration_id: 'ACTIVE', status: true)
      inactive = create(:notice_registrar, registration_id: 'INACTIVE', status: false)
      pending = create(:notice_registrar, registration_id: 'PENDING', status: nil)

      expect(NoticeRegistrar.count).to eq(3)

      # Verify each can be found
      expect(NoticeRegistrar.find(active.id).id).to eq(active.id)
      expect(NoticeRegistrar.find(inactive.id).id).to eq(inactive.id)
      expect(NoticeRegistrar.find(pending.id).id).to eq(pending.id)
    end

    it 'handles rapid creation of multiple registrars' do
      expect do
        10.times { |i| create(:notice_registrar, registration_id: "BULK#{i}") }
      end.to change(NoticeRegistrar, :count).by(10)
    end

    it 'handles updates without changing timestamps inappropriately' do
      registrar = create(:notice_registrar)
      original_created_at = registrar.created_at
      original_updated_at = registrar.updated_at

      sleep 0.01 # Ensure time passes

      registrar.update(status: false)

      expect(registrar.reload.created_at.to_i).to eq(original_created_at.to_i)
      expect(registrar.updated_at).to be > original_updated_at
    end

    it 'handles nil and empty values distinctly' do
      registrar_nil = create(:notice_registrar, registration_id: nil)
      registrar_empty = create(:notice_registrar, registration_id: '')

      expect(registrar_nil.registration_id).to be_nil
      expect(registrar_empty.registration_id).to eq('')
      expect(registrar_nil.registration_id).not_to eq(registrar_empty.registration_id)
    end
  end

  # ====================
  # QUERY TESTS
  # ====================

  describe 'queries' do
    it 'finds by registration_id' do
      registrar = create(:notice_registrar, registration_id: 'FIND_ME')

      found = NoticeRegistrar.find_by(registration_id: 'FIND_ME')

      expect(found).not_to be_nil
      expect(found.id).to eq(registrar.id)
    end

    it 'finds by status' do
      active1 = create(:notice_registrar, status: true)
      active2 = create(:notice_registrar, status: true)
      inactive = create(:notice_registrar, status: false)

      active_registrars = NoticeRegistrar.where(status: true)

      expect(active_registrars.count).to eq(2)
      expect(active_registrars.pluck(:id)).to include(active1.id)
      expect(active_registrars.pluck(:id)).to include(active2.id)
      expect(active_registrars.pluck(:id)).not_to include(inactive.id)
    end

    it 'handles ordering by created_at' do
      first = create(:notice_registrar, registration_id: 'FIRST')
      sleep 0.01
      second = create(:notice_registrar, registration_id: 'SECOND')
      sleep 0.01
      third = create(:notice_registrar, registration_id: 'THIRD')

      ordered = NoticeRegistrar.order(created_at: :asc).last(3)

      expect(ordered.map(&:id)).to eq([first.id, second.id, third.id])
    end

    it 'counts registrars by status' do
      3.times { create(:notice_registrar, status: true) }
      2.times { create(:notice_registrar, status: false) }
      create(:notice_registrar, status: nil)

      expect(NoticeRegistrar.where(status: true).count).to eq(3)
      expect(NoticeRegistrar.where(status: false).count).to eq(2)
      expect(NoticeRegistrar.where(status: nil).count).to eq(1)
    end
  end
end
