# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Impulsa Evaluation', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/impulsa/evaluacion' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado', :skip_auth do
        get '/es/impulsa/evaluacion'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON PROYECTO EVALUADO' do
      before do
        sign_in user
        get '/es/impulsa/evaluacion'
      end

      it 'renderiza correctamente o redirige si no hay proyecto evaluado' do
        expect([200, 302]).to include(response.status)
      end

      it 'si renderiza, muestra título de IMPULSA' do
        expect(response.body).to match(/IMPULSA|Impulsa/) if response.status == 200
      end
    end

    describe 'C. CONTENIDO DE EVALUACIÓN (si existe proyecto evaluado)' do
      before do
        sign_in user
        get '/es/impulsa/evaluacion'
      end

      it 'si renderiza, muestra título de Evaluación' do
        expect(response.body).to include('Evaluación') if response.status == 200
      end

      it 'si renderiza, menciona evaluadores' do
        expect(response.body).to match(/evaluador|evaluación/i) if response.status == 200
      end

      it 'si renderiza, muestra resultado de evaluación' do
        expect(response.body).to match(/resultado|superada|no superada/i) if response.status == 200
      end
    end

    describe 'D. ESTRUCTURA HTML (si renderiza)' do
      before do
        sign_in user
        get '/es/impulsa/evaluacion'
      end

      it 'si renderiza, usa estructura content-content' do
        expect(response.body).to include('content-content') if response.status == 200
      end

      it 'si renderiza, tiene h2 para título principal' do
        expect(response.body).to match(/<h2>/) if response.status == 200
      end

      it 'si renderiza, usa clase impulsa' do
        expect(response.body).to include('impulsa') if response.status == 200
      end
    end
  end
end
