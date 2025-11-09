# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Microcredit, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid microcredit' do
      microcredit = build(:microcredit)
      expect(microcredit).to be_valid, "Factory should create a valid microcredit"
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'validates limits format' do
      microcredit = build(:microcredit, limits: "invalid")
      expect(microcredit).not_to be_valid
      expect(microcredit.errors[:limits]).to include("Introduce pares (monto, cantidad)")
    end

    it 'accepts valid limits format' do
      microcredit = build(:microcredit, limits: "100€: 10\n500€: 5")
      expect(microcredit).to be_valid
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates microcredit with valid attributes' do
      expect {
        create(:microcredit)
      }.to change(described_class, :count).by(1)
    end

    it 'updates microcredit attributes' do
      microcredit = create(:microcredit, title: "Original")

      microcredit.update(title: "Updated")

      expect(microcredit.reload.title).to eq("Updated")
    end

    it 'soft deletes microcredit' do
      microcredit = create(:microcredit)

      expect {
        microcredit.destroy
      }.to change(described_class, :count).by(-1)

      expect(microcredit.reload.deleted_at).not_to be_nil
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.active' do
      it 'returns currently active microcredits' do
        active = create(:microcredit, :active)
        upcoming = create(:microcredit, :upcoming)
        finished = create(:microcredit, :finished)

        results = described_class.active

        expect(results).to include(active)
        expect(results).not_to include(upcoming)
        expect(results).not_to include(finished)
      end
    end

    describe '.non_finished' do
      it 'returns future microcredits' do
        active = create(:microcredit, :active)
        finished = create(:microcredit, :finished)

        results = described_class.non_finished

        expect(results).to include(active)
        expect(results).not_to include(finished)
      end
    end

    describe '.standard' do
      it 'returns non-mailing microcredits' do
        standard = create(:microcredit, mailing: false)
        mailing = create(:microcredit, :with_mailing)

        results = described_class.standard

        expect(results).to include(standard)
        expect(results).not_to include(mailing)
      end
    end

    describe '.mailing' do
      it 'returns mailing microcredits' do
        standard = create(:microcredit, mailing: false)
        mailing = create(:microcredit, :with_mailing)

        results = described_class.mailing

        expect(results).to include(mailing)
        expect(results).not_to include(standard)
      end
    end
  end

  # ====================
  # FLAG TESTS
  # ====================

  describe 'flags' do
    it 'has mailing flag' do
      microcredit = create(:microcredit, :with_mailing)
      expect(microcredit.mailing?).to be true
    end

    it 'does not have mailing flag by default' do
      microcredit = create(:microcredit)
      expect(microcredit.mailing?).to be false
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'has many loans' do
      microcredit = create(:microcredit)
      expect(microcredit).to respond_to(:loans)
    end

    it 'has many microcredit_options' do
      microcredit = create(:microcredit)
      expect(microcredit).to respond_to(:microcredit_options)
    end

    it 'destroys dependent microcredit_options' do
      microcredit = create(:microcredit)
      option = create(:microcredit_option, microcredit: microcredit)

      expect {
        microcredit.destroy
      }.to change(MicrocreditOption, :count).by(-1)
    end
  end
end
