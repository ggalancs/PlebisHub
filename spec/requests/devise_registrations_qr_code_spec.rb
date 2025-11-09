# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devise Registrations QR Code', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/qr_code' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado' do
        get '/es/qr_code'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es/qr_code'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'muestra carnet digital de militante' do
        expect(response.body).to include('Carnet digital de militante')
      end
    end

    describe 'C. INFORMACIÓN DEL USUARIO' do
      before do
        sign_in user
        get '/es/qr_code'
      end

      it 'muestra nombre completo del usuario' do
        expect(response.body).to include('Nombre')
      end

      it 'muestra documento del usuario' do
        expect(response.body).to include('DNI/NIE/Pasaporte')
      end

      it 'muestra código QR' do
        expect(response.body).to include('box_qr_code')
      end

      it 'muestra información de caducidad' do
        expect(response.body).to match(/caduca|countdown/)
      end
    end

    describe 'D. ELEMENTOS VISUALES' do
      before do
        sign_in user
        get '/es/qr_code'
      end

      it 'tiene imagen de fondo' do
        expect(response.body).to match(/qr_bg|background/)
      end

      it 'tiene logo de PlebisBrand' do
        expect(response.body).to include('logo')
      end

      it 'tiene líneas decorativas' do
        expect(response.body).to include('qr_line')
      end

      it 'tiene botón para volver' do
        expect(response.body).to match(/Volver|back/)
      end
    end

    describe 'E. ESTILOS PERSONALIZADOS' do
      before do
        sign_in user
        get '/es/qr_code'
      end

      it 'tiene estilos inline con @font-face' do
        expect(response.body).to include('@font-face')
      end

      it 'usa fuente Centra-Medium' do
        expect(response.body).to include('Centra-Medium')
      end

      it 'usa fuente Centra-Bold' do
        expect(response.body).to include('Centra-Bold')
      end

      it 'tiene estilos para contenedor QR' do
        expect(response.body).to include('qr_container')
      end

      it 'tiene estilos para labels' do
        expect(response.body).to include('qr_label')
      end
    end

    describe 'F. FUNCIONALIDAD JAVASCRIPT' do
      before do
        sign_in user
        get '/es/qr_code'
      end

      it 'tiene script de countdown' do
        expect(response.body).to include('countdown')
      end

      it 'tiene setInterval para actualizar contador' do
        expect(response.body).to include('setInterval')
      end

      it 'calcula días, horas, minutos, segundos' do
        expect(response.body).to match(/days.*hours.*minutes.*seconds/m)
      end

      it 'muestra mensaje cuando expira' do
        expect(response.body).to match(/EXPIRADO|expirado/)
      end
    end

    describe 'G. VIEWPORT Y RESPONSIVIDAD' do
      before do
        sign_in user
        get '/es/qr_code'
      end

      it 'tiene meta viewport configurado' do
        expect(response.body).to include('viewport')
      end

      it 'viewport deshabilita user-scalable' do
        expect(response.body).to include('user-scalable=no')
      end
    end
  end
end
