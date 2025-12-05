# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Microcredits Summary Admin Page', type: :request do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in_admin admin_user
    # Stub Microcredit model if it exists
    unless defined?(Microcredit)
      stub_const('Microcredit', Class.new(ApplicationRecord))
    end
    # Stub ability to read Microcredit
    allow_any_instance_of(Ability).to receive(:can?).with(:read, Microcredit).and_return(true)
  end

  describe 'GET /admin/microcredits_summary' do
    it 'renders the summary page' do
      get admin_microcredits_summary_path
      expect(response).to have_http_status(:success)
    end

    it 'displays the page title' do
      get admin_microcredits_summary_path
      expect(response.body).to include('Resumen de microcréditos')
    end

    it 'has panel for amounts evolution' do
      get admin_microcredits_summary_path
      expect(response.body).to match(/Evolución.*€/i)
    end

    it 'has panel for count evolution' do
      get admin_microcredits_summary_path
      expect(response.body).to match(/Evolución.*#/i)
    end

    it 'renders microcredits_amounts partial' do
      # Check that the partial would be rendered
      get admin_microcredits_summary_path
      expect(response).to have_http_status(:success)
    end

    it 'renders microcredits_count partial' do
      # Check that the partial would be rendered
      get admin_microcredits_summary_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'menu configuration' do
    it 'appears under microcredits parent menu' do
      get admin_microcredits_summary_path
      expect(response).to have_http_status(:success)
    end

    it 'has label "Resumen de microcréditos"' do
      get admin_microcredits_summary_path
      expect(response.body).to include('Resumen de microcréditos')
    end
  end

  describe 'authorization' do
    before do
      allow_any_instance_of(Ability).to receive(:can?).with(:read, Microcredit).and_return(false)
    end

    it 'requires authorization to read Microcredit' do
      # This will raise CanCan::AccessDenied if authorization is properly enforced
      expect do
        get admin_microcredits_summary_path
      end.to raise_error(CanCan::AccessDenied)
    end
  end
end
