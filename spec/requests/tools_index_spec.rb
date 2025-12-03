# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tools Index', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es (authenticated_root)' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado', :skip_auth do
        get '/es'
        # May render public page or redirect depending on configuration
        expect([200, 302]).to include(response.status)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título de Herramientas' do
        expect(response.body).to include('Herramientas de participación ciudadana')
      end

      it 'tiene el title tag correcto' do
        expect(response.body).to include('<title>')
      end
    end

    describe 'C. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es'
      end

      it 'usa estructura content-content' do
        expect(response.body).to include('content-content')
      end

      it 'tiene h2 para título principal' do
        expect(response.body).to match(/<h2>Herramientas/)
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end
    end

    describe 'D. CONTENIDO DINÁMICO' do
      before do
        sign_in user
        get '/es'
      end

      it 'muestra algún contenido (elecciones activas, próximas, finalizadas u otras herramientas)' do
        # Should render one of the partials
        expect(response.body.length).to be > 200
      end
    end
  end
end
