# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineUser::Microcreditor, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it 'responds to microcredit_loans' do
      expect(user).to respond_to(:microcredit_loans)
    end

    it 'returns an ActiveRecord relation' do
      expect(user.microcredit_loans).to be_an(ActiveRecord::Relation)
    end

    it 'defines has_many with dependent destroy' do
      reflection = user.class.reflect_on_association(:microcredit_loans)
      expect(reflection).not_to be_nil
      expect(reflection.macro).to eq(:has_many)
      expect(reflection.options[:dependent]).to eq(:destroy)
    end
  end

  describe '#any_microcredit_renewable?' do
    it 'responds to the method' do
      expect(user).to respond_to(:any_microcredit_renewable?)
    end

    it 'returns boolean' do
      result = user.any_microcredit_renewable?
      expect([true, false]).to include(result)
    end

    it 'checks MicrocreditLoan.renewables' do
      user.update_column(:document_vatid, '12345678A')
      expect(MicrocreditLoan).to receive_message_chain(:renewables, :exists?).with(document_vatid: '12345678A').and_return(false)
      expect(user.any_microcredit_renewable?).to be false
    end

    it 'uses document_vatid to find loans' do
      user.update_column(:document_vatid, '87654321B')
      allow(MicrocreditLoan).to receive_message_chain(:renewables, :exists?).with(document_vatid: '87654321B').and_return(true)
      expect(user.any_microcredit_renewable?).to be true
    end
  end
end

