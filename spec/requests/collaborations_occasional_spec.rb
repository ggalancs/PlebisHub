# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collaborations Occasional', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/colabora/puntual' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado', :skip_auth do
        get '/es/colabora/puntual'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO' do
      before do
        sign_in user
        get '/es/colabora/puntual'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título de Colaboración' do
        expect(response.body).to include('Colabora')
      end

      it 'tiene el title tag correcto' do
        expect(response.body).to match(/<title>.*Colabora/i)
      end
    end

    describe 'C. CONTENIDO DE AGRADECIMIENTO' do
      before do
        sign_in user
        get '/es/colabora/puntual'
      end

      it 'muestra mensaje de agradecimiento (Gracias)' do
        expect(response.body).to include('Gracias')
      end

      it 'renderiza el partial de steps (paso 3)' do
        expect(response.body).to include('step')
      end

      it 'muestra alert_box' do
        expect(response.body).to match(/alert.*box/i)
      end

      it 'tiene al menos 2 párrafos de información' do
        paragraphs = response.body.scan(/<p>/).count
        expect(paragraphs).to be >= 2
      end
    end

    describe 'D. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es/colabora/puntual'
      end

      it 'usa estructura content-content' do
        expect(response.body).to include('content-content')
      end

      it 'tiene h2 para título principal' do
        expect(response.body).to match(/<h2>/)
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end
    end
  end
end
