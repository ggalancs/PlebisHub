# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collaborations KO', type: :request do

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/colabora/KO' do
    describe 'A. AUTENTICACIÓN Y REDIRECTS' do
      it 'redirige al login si no está autenticado', :skip_auth do
        get '/es/colabora/KO'
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'redirige a new_collaboration si no hay collaboration o renderiza la página KO' do
        sign_in user
        get '/es/colabora/KO'
        expect([200, 302]).to include(response.status)
      end
    end

    describe 'B. RENDERING BÁSICO CON COLLABORATION' do
      let!(:collaboration) { create(:collaboration, :incomplete, user: user, payment_type: 1) }

      before do
        sign_in user
        get '/es/colabora/KO'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título de colaboración' do
        expect(response.body).to include('Colabora')
      end
    end

    describe 'C. CONTENIDO DEL MENSAJE DE ERROR' do
      let!(:collaboration) { create(:collaboration, :incomplete, user: user, payment_type: 1) }

      before do
        sign_in user
        get '/es/colabora/KO'
      end

      it 'muestra el error_box o mensaje de error' do
        has_error = response.body.match?(/error.*box|box-error|box-ko|alert|danger|warning/i) || response.body.include?('KO')
        expect(has_error).to be true
      end

      it 'muestra mensaje de contacto' do
        expect(response.body).to match(/contact/i)
      end

      it 'muestra botón para intentar de nuevo' do
        expect(response.body).to include('Intentar pagar nuevamente')
      end

      it 'tiene enlace a confirm_collaboration_path' do
        expect(response.body).to include('confirmar')
      end
    end

    describe 'D. PARTIAL DE STEPS' do
      let!(:collaboration) { create(:collaboration, :incomplete, user: user, payment_type: 1) }

      before do
        sign_in user
        get '/es/colabora/KO'
      end

      it 'renderiza el partial de steps' do
        expect(response.body).to include('step')
      end
    end

    describe 'E. ESTRUCTURA HTML' do
      let!(:collaboration) { create(:collaboration, :incomplete, user: user, payment_type: 1) }

      before do
        sign_in user
        get '/es/colabora/KO'
      end

      it 'usa estructura semántica con divs' do
        expect(response.body).to include('content-content')
      end

      it 'tiene un h2 con el título' do
        expect(response.body).to match(/<h2>/)
      end

      it 'tiene un botón en buttonbox' do
        expect(response.body).to include('buttonbox')
        expect(response.body).to include('button')
      end
    end
  end
end
