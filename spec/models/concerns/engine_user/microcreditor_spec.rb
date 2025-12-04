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
  end

  describe '#any_microcredit_renewable?' do
    it 'responds to the method' do
      expect(user).to respond_to(:any_microcredit_renewable?)
    end

    it 'returns boolean' do
      result = user.any_microcredit_renewable?
      expect([true, false]).to include(result)
    end
  end
end

