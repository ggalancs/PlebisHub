# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collaborations Summary Admin Page', type: :request do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in_admin admin_user
  end

  describe 'GET /admin/collaborations_summary' do
    it 'renders the summary page' do
      get admin_collaborations_summary_path
      expect(response).to have_http_status(:success)
    end

    it 'displays the page title' do
      get admin_collaborations_summary_path
      expect(response.body).to include('Resumen de colaboraciones')
    end

    it 'has panel for collaborations by type' do
      get admin_collaborations_summary_path
      expect(response.body).to include('Colaboraciones por tipo')
    end

    it 'has panel for collaborations by frequency' do
      get admin_collaborations_summary_path
      expect(response.body).to include('Colaboraciones por frecuencia')
    end

    it 'has panel for collaborations by amount' do
      get admin_collaborations_summary_path
      expect(response.body).to include('Colaboraciones por cantidad')
    end

    it 'has panel for collaborations evolution' do
      get admin_collaborations_summary_path
      expect(response.body).to include('Evolución de colaboraciones')
    end

    it 'has summary panel' do
      get admin_collaborations_summary_path
      expect(response.body).to include('Resumen')
    end

    it 'uses columns layout' do
      get admin_collaborations_summary_path
      expect(response.body).to match(/column/i)
    end
  end

  describe 'menu configuration' do
    it 'appears under Colaboraciones parent menu' do
      get admin_collaborations_summary_path
      expect(response).to have_http_status(:success)
    end

    it 'has label "Resumen de colaboraciones"' do
      get admin_collaborations_summary_path
      expect(response.body).to include('Resumen de colaboraciones')
    end
  end

  describe 'panels' do
    it 'renders graph_collaboration_type partial' do
      get admin_collaborations_summary_path
      expect(response).to have_http_status(:success)
    end

    it 'renders graph_collaboration_frequency partial' do
      get admin_collaborations_summary_path
      expect(response).to have_http_status(:success)
    end

    it 'renders graph_collaboration_amount partial' do
      get admin_collaborations_summary_path
      expect(response).to have_http_status(:success)
    end

    it 'renders graph_collaboration_evolution partial' do
      get admin_collaborations_summary_path
      expect(response).to have_http_status(:success)
    end

    it 'renders resumen partial' do
      get admin_collaborations_summary_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'layout structure' do
    it 'organizes panels in columns' do
      get admin_collaborations_summary_path
      # Should have multiple column blocks
      expect(response.body.scan(/column/).count).to be >= 3
    end

    it 'has multiple rows of panels' do
      get admin_collaborations_summary_path
      # Should have at least 5 panels
      expect(response.body.scan(/panel/).count).to be >= 5
    end
  end
end
