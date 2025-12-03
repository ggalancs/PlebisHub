# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Impulsa Project', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }
  let!(:edition) { create(:impulsa_edition, start_at: 1.week.ago, new_projects_until: 1.week.from_now, ends_at: 1.month.from_now) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/impulsa/proyecto' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado', :skip_auth do
        get '/es/impulsa/proyecto'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es/impulsa/proyecto'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'muestra título de IMPULSA' do
        expect(response.body).to match(/IMPULSA|Impulsa/)
      end

      it 'tiene el title tag correcto' do
        expect(response.body).to match(/<title>.*IMPULSA/i)
      end
    end

    describe 'C. ESTRUCTURA DEL PROYECTO' do
      before do
        sign_in user
        get '/es/impulsa/proyecto'
      end

      it 'renderiza el partial de steps' do
        expect(response.body).to include('step')
      end

      it 'usa clase impulsa para estilos' do
        expect(response.body).to include('impulsa')
      end

      it 'tiene contenedor de formulario de datos' do
        expect(response.body).to include('data-form-container')
      end
    end

    describe 'D. FORMULARIO DE PROYECTO' do
      before do
        sign_in user
        get '/es/impulsa/proyecto'
      end

      it 'tiene h2 para título del proyecto' do
        expect(response.body).to match(/<h2>/)
      end

      it 'muestra "Nuevo proyecto" si no tiene nombre' do
        expect(response.body).to include('Nuevo proyecto')
      end

      it 'tiene formulario de proyecto' do
        expect(response.body).to match(/form|semantic_form/)
      end

      it 'tiene selector de categoría' do
        expect(response.body).to match(/categor/i)
      end

      it 'tiene campo para nombre del proyecto' do
        expect(response.body).to match(/name|nombre/i)
      end
    end

    describe 'E. TÉRMINOS Y CONDICIONES (PROYECTO NUEVO)' do
      before do
        sign_in user
        get '/es/impulsa/proyecto'
      end

      it 'muestra checkbox de términos de servicio para proyectos nuevos' do
        expect(response.body).to include('terms_of_service')
      end

      it 'muestra checkbox de veracidad de datos para proyectos nuevos' do
        expect(response.body).to include('data_truthfulness')
      end

      it 'muestra checkbox de derechos de contenido para proyectos nuevos' do
        expect(response.body).to include('content_rights')
      end
    end

    describe 'F. ENLACES E INFORMACIÓN' do
      before do
        sign_in user
        get '/es/impulsa/proyecto'
      end

      it 'menciona las bases del programa' do
        expect(response.body).to match(/bases/i)
      end

      it 'tiene enlace a impulsa.plebisbrand.info' do
        expect(response.body).to include('impulsa.plebisbrand.info')
      end

      it 'menciona correo electrónico de contacto' do
        expect(response.body).to match(/@|email/)
      end
    end

    describe 'G. ESTADOS DEL PROYECTO' do
      before do
        sign_in user
        get '/es/impulsa/proyecto'
      end

      it 'muestra algún mensaje de estado del proyecto' do
        # Should show one of many possible states
        has_state_message = response.body.match?(/fecha.*límite|revisión|evaluación|validado|superado/i)
        expect(has_state_message || response.body.include?('Nuevo proyecto')).to be true
      end
    end

    describe 'H. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es/impulsa/proyecto'
      end

      it 'usa estructura content-content' do
        expect(response.body).to include('content-content')
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end

      it 'tiene al menos un fieldset' do
        expect(response.body).to include('<fieldset')
      end

      it 'usa autocomplete off para seguridad' do
        expect(response.body).to include('autocomplete="off"')
      end
    end
  end
end
