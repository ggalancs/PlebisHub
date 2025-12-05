# frozen_string_literal: true

require 'rails_helper'

module PlebisMicrocredit
  RSpec.describe MicrocreditLoan, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:microcredit).class_name('PlebisMicrocredit::Microcredit') }
      it { is_expected.to belong_to(:user).optional }
      it { is_expected.to belong_to(:microcredit_option).class_name('PlebisMicrocredit::MicrocreditOption') }
      it { is_expected.to belong_to(:transferred_to).class_name('PlebisMicrocredit::MicrocreditLoan').optional }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:amount) }
    end

    describe 'scopes' do
      describe '.confirmed' do
        it 'returns loans with confirmed_at timestamp' do
          confirmed = create(:microcredit_loan, confirmed_at: 1.hour.ago)
          unconfirmed = create(:microcredit_loan, confirmed_at: nil)

          expect(MicrocreditLoan.confirmed).to include(confirmed)
          expect(MicrocreditLoan.confirmed).not_to include(unconfirmed)
        end
      end

      describe '.counted' do
        it 'returns loans with counted_at timestamp' do
          counted = create(:microcredit_loan, counted_at: 1.hour.ago)
          not_counted = create(:microcredit_loan, counted_at: nil)

          expect(MicrocreditLoan.counted).to include(counted)
          expect(MicrocreditLoan.counted).not_to include(not_counted)
        end
      end
    end

    describe 'table name' do
      it 'uses microcredit_loans table' do
        expect(MicrocreditLoan.table_name).to eq('microcredit_loans')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        loan = build(:microcredit_loan)
        expect(loan).to be_valid
      end

      it 'creates a loan with required attributes' do
        loan = create(:microcredit_loan)
        expect(loan).to be_persisted
        expect(loan.amount).to be_present
      end
    end
  end
end
