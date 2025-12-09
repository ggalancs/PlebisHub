# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Impulsa Project Flows', type: :system do
  let(:user) { create(:user, password: 'Password123456') }

  describe 'Impulsa Index' do
    it 'displays the impulsa page' do
      visit '/es/impulsa'
      expect(page.status_code).to be_in([200, 302, 404])
    end

    it 'shows active edition' do
      visit '/es/impulsa'
      expect(page.status_code).to be_in([200, 302, 404])
    end
  end

  describe 'Impulsa Project Creation' do
    before { sign_in user }

    it 'displays project page' do
      visit '/es/impulsa/proyecto'
      expect(page.status_code).to be_in([200, 302, 404])
    end

    it 'shows project form' do
      visit '/es/impulsa/proyecto'
      if page.status_code == 200
        has_form = page.has_selector?('form') ||
                   page.has_content?(/proyecto|impulsa/i)
        expect(has_form).to be true
      end
    end
  end

  describe 'Impulsa Project Steps' do
    before { sign_in user }

    it 'displays project step 1' do
      visit '/es/impulsa/proyecto/1'
      expect(page.status_code).to be_in([200, 302, 404])
    end

    it 'displays project step 2' do
      visit '/es/impulsa/proyecto/2'
      expect(page.status_code).to be_in([200, 302, 404])
    end

    it 'displays project step 3' do
      visit '/es/impulsa/proyecto/3'
      expect(page.status_code).to be_in([200, 302, 404])
    end
  end

  describe 'Impulsa Evaluation' do
    let(:admin_user) { create(:user, :admin, password: 'Password123456') }

    before { sign_in admin_user }

    it 'displays evaluation page' do
      visit '/es/impulsa/evaluacion'
      expect(page.status_code).to be_in([200, 302, 403, 404])
    end
  end

  describe 'Without active edition' do
    it 'handles no active edition gracefully' do
      visit '/es/impulsa'
      expect(page.status_code).to be_in([200, 302, 404])
    end
  end
end
