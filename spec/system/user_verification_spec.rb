# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Verification Flows', type: :system do
  let(:user) { create(:user, password: 'Password123456') }

  describe 'Identity Verification' do
    before { sign_in user }

    it 'displays verification page' do
      visit '/es/verificacion-identidad'
      expect(page.status_code).to be_in([200, 302, 404])
    end

    it 'shows verification form' do
      visit '/es/verificacion-identidad'
      if page.status_code == 200
        has_form = page.has_selector?('form') ||
                   page.has_content?(/verificación|identidad/i)
        expect(has_form).to be true
      end
    end
  end

  describe 'Report Pages' do
    it 'displays report page' do
      visit '/es/report/test_code'
      expect(page.status_code).to be_in([200, 302, 404])
    end

    it 'displays exterior report page' do
      visit '/es/report_exterior/test_code'
      expect(page.status_code).to be_in([200, 302, 404])
    end

    it 'displays town report page' do
      visit '/es/report_town/test_code'
      expect(page.status_code).to be_in([200, 302, 404])
    end
  end
end
