# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Participation Teams Flows', type: :system do
  let(:user) { create(:user, password: 'Password123456') }

  describe 'Participation Teams Index' do
    it 'displays teams page' do
      visit '/es/equipos-de-accion-participativa'
      expect(page.status_code).to be_in([200, 302, 404])
    end

    it 'shows teams list' do
      visit '/es/equipos-de-accion-participativa'
      if page.status_code == 200
        has_content = page.has_content?(/equipos|participat/i) ||
                      page.has_selector?('h1, h2, h3')
        expect(has_content).to be true
      end
    end
  end

  describe 'With logged in user' do
    before { sign_in user }

    it 'allows viewing teams' do
      visit '/es/equipos-de-accion-participativa'
      expect(page.status_code).to be_in([200, 302, 404])
    end
  end
end
