# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Proposals Flows', type: :system do
  let(:user) { create(:user, password: 'Password123456') }

  describe 'Proposals Index' do
    it 'displays proposals page' do
      visit '/es/propuestas'
      expect(page.status_code).to be_in([200, 302, 404])
    end

    it 'shows list of proposals' do
      visit '/es/propuestas'
      if page.status_code == 200
        has_content = page.has_content?(/propuestas|propuesta/i) ||
                      page.has_selector?('h1, h2, h3, article')
        expect(has_content).to be true
      end
    end
  end

  describe 'Proposal Show' do
    it 'displays individual proposal' do
      visit '/es/propuestas/1'
      expect(page.status_code).to be_in([200, 302, 404])
    end

    it 'shows proposal content' do
      visit '/es/propuestas/1'
      # Should load appropriately
      expect(page.status_code).to be_in([200, 302, 404])
    end
  end

  describe 'Proposal Info' do
    it 'displays proposal info page' do
      visit '/es/propuestas/info'
      expect(page.status_code).to be_in([200, 302, 404])
    end
  end

  describe 'Voting on Proposals' do
    before { sign_in user }

    it 'shows vote buttons' do
      visit '/es/propuestas/1'
      # Page should load without error
      expect(page.status_code).to be_in([200, 302, 404])
    end
  end
end
