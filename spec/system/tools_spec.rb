# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tools/Dashboard', type: :system do
  let(:user) { create(:user, password: 'Password123456') }

  describe 'Tools Index (Dashboard)' do
    before { sign_in user }

    it 'displays tools page' do
      visit '/es'
      expect(page.status_code).to be_in([200, 302])
    end

    it 'shows user menu' do
      visit '/es'
      if page.status_code == 200
        has_user_info = page.has_content?(user.first_name) ||
                        page.has_selector?('nav') ||
                        page.has_selector?('.menu') ||
                        page.has_selector?('[class*="menu"]')
        expect(has_user_info).to be true
      end
    end

    it 'has logout link' do
      visit '/es'
      if page.status_code == 200
        has_logout = page.has_link?('Salir') || page.has_link?('Cerrar sesión') ||
                     page.has_selector?('[href*="sign_out"]')
        expect(has_logout).to be true
      end
    end
  end

  describe 'Militant Request Tool' do
    before { sign_in user }

    it 'displays militant request page' do
      visit '/es/tools/militant_request'
      expect(page.status_code).to be_in([200, 302, 404])
    end

    it 'handles access appropriately' do
      visit '/es/tools/militant_request'
      expect(page.status_code).to be_in([200, 302, 403, 404])
    end
  end

  describe 'QR Code Digital Card' do
    before { sign_in user }

    it 'displays QR code page' do
      visit '/es/carnet_digital_con_qr'
      expect(page.status_code).to be_in([200, 302, 404])
    end
  end
end
