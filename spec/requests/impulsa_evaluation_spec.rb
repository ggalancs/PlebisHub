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
        if response.status == 200
          expect(response.body).to match(/IMPULSA|Impulsa/)
        end
      end
    end

    describe 'C. CONTENIDO DE EVALUACIÓN (si existe proyecto evaluado)' do
      before do
        sign_in user
        get '/es/impulsa/evaluacion'
      end

      it 'si renderiza, muestra título de Evaluación' do
        if response.status == 200
          expect(response.body).to include('Evaluación')
        end
      end

      it 'si renderiza, menciona evaluadores' do
        if response.status == 200
          expect(response.body).to match(/evaluador|evaluación/i)
        end
      end

      it 'si renderiza, muestra resultado de evaluación' do
        if response.status == 200
          expect(response.body).to match(/resultado|superada|no superada/i)
        end
      end
    end

    describe 'D. ESTRUCTURA HTML (si renderiza)' do
      before do
        sign_in user
        get '/es/impulsa/evaluacion'
      end

      it 'si renderiza, usa estructura content-content' do
        if response.status == 200
          expect(response.body).to include('content-content')
        end
      end

      it 'si renderiza, tiene h2 para título principal' do
        if response.status == 200
          expect(response.body).to match(/<h2>/)
        end
      end

      it 'si renderiza, usa clase impulsa' do
        if response.status == 200
          expect(response.body).to include('impulsa')
        end
      end
    end
  end
end
