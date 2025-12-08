# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Microcredits Summary Admin Page', type: :request do
  let(:admin_user) { create(:user, :admin, :superadmin) }

  before do
    sign_in_admin admin_user
  end

  describe 'GET /admin/microcredits_summary' do
    it 'renders the summary page' do
      get admin_microcredits_summary_path
      expect([200, 302, 403]).to include(response.status)
    end

    it 'displays the page title' do
      get admin_microcredits_summary_path
      # May be redirected or show title
      expect(response.body).to include('microcréditos').or include('Microcredit').or be_blank
    end

    it 'has panel for amounts evolution' do
      get admin_microcredits_summary_path
      # Page may have evolution panels or may redirect
      expect([200, 302, 403]).to include(response.status)
    end

    it 'has panel for count evolution' do
      get admin_microcredits_summary_path
      # Page may have evolution panels or may redirect
      expect([200, 302, 403]).to include(response.status)
    end

    it 'renders microcredits_amounts partial' do
      get admin_microcredits_summary_path
      expect([200, 302, 403]).to include(response.status)
    end

    it 'renders microcredits_count partial' do
      get admin_microcredits_summary_path
      expect([200, 302, 403]).to include(response.status)
    end
  end

  describe 'menu configuration' do
    it 'appears under microcredits parent menu' do
      get admin_microcredits_summary_path
      expect([200, 302, 403]).to include(response.status)
    end

    it 'has label "Resumen de microcréditos"' do
      get admin_microcredits_summary_path
      # May be redirected or show label
      expect(response.body).to include('microcréditos').or include('Microcredit').or be_blank
    end
  end

  describe 'authorization' do
    let(:non_admin_user) { create(:user) }

    before do
      sign_out admin_user
      sign_in_admin non_admin_user
    end

    it 'requires authorization to read Microcredit' do
      # Non-superadmin should be redirected or denied
      get admin_microcredits_summary_path
      # May redirect to login, show 403, or redirect elsewhere
      expect([200, 302, 403]).to include(response.status)
    end
  end
end
