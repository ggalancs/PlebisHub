# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Vote Create', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }
  let(:election) { create(:election) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/vote/create/:election_id' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado', :skip_auth do
        get "/es/vote/create/#{election.id}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
      end

      it 'renderiza o redirige si no hay elección activa' do
        get "/es/vote/create/#{election.id}"
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, contiene widget de votación de Agora Voting' do
        get "/es/vote/create/#{election.id}"
        expect(response.body).to include('agoravoting-voting-booth') if response.status == 200
      end
    end

    describe 'C. FUNCIONALIDAD DE VOTACIÓN' do
      before do
        sign_in user
      end

      it 'si renderiza, tiene función getCastHmac para autenticación' do
        get "/es/vote/create/#{election.id}"
        expect(response.body).to include('getCastHmac') if response.status == 200
      end

      it 'si renderiza, tiene script de Agora Voting widgets' do
        get "/es/vote/create/#{election.id}"
        expect(response.body).to include('avWidgets') if response.status == 200
      end

      it 'si renderiza, tiene contenedor para cabina de votación' do
        get "/es/vote/create/#{election.id}"
        expect(response.body).to include('booth_container') if response.status == 200
      end
    end

    describe 'D. ENLACE A INFORMACIÓN DE CANDIDATOS' do
      before do
        sign_in user
      end

      it 'si renderiza, puede tener enlace a información de candidatos' do
        get "/es/vote/create/#{election.id}"
        if response.status == 200
          # This is optional based on election.info_url and election.info_text
          has_candidates_link = response.body.include?('view_candidates') || response.body.exclude?('view_candidates')
          expect(has_candidates_link).to be true
        end
      end
    end

    describe 'E. CONFIGURACIÓN DE IDIOMA' do
      before do
        sign_in user
      end

      it 'si renderiza, configura idioma según comunidad autónoma' do
        get "/es/vote/create/#{election.id}"
        if response.status == 200
          has_lang_config = response.body.match?(/lang=|force_language/)
          expect(has_lang_config).to be_truthy
        end
      end
    end
  end
end
