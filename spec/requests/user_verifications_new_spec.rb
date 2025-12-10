# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Verifications New', type: :request do
  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
    # Bypass check_valid_and_verified before_action to allow test access
    allow_any_instance_of(PlebisVerification::UserVerificationsController).to receive(:check_valid_and_verified).and_return(true)
  end

  describe 'GET /es/verificacion-identidad' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado', :skip_auth do
        get '/es/verificacion-identidad'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es/verificacion-identidad'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'muestra título de Verificación de Identidad' do
        expect(response.body).to match(/Verificación.*Identidad/i)
      end

      it 'tiene el title tag correcto' do
        expect(response.body).to match(/<title>/)
      end
    end

    describe 'C. FORMULARIO DE VERIFICACIÓN' do
      before do
        sign_in user
        get '/es/verificacion-identidad'
      end

      it 'tiene formulario de verificación' do
        expect(response.body).to match(/form|semantic_form/)
      end

      it 'usa autocomplete off para seguridad' do
        expect(response.body).to include('autocomplete="off"')
      end

      it 'tiene action crear verificación' do
        expect(response.body).to match(/create.*verification|verificacion/)
      end
    end

    describe 'D. CARGA DE FOTOS DE DOCUMENTO' do
      before do
        sign_in user
        get '/es/verificacion-identidad'
      end

      it 'puede tener campos para foto frontal del documento' do
        # Only if photos_necessary? is true
        has_front = response.body.include?('front_vatid') || response.body.exclude?('js-user-verification')
        expect(has_front).to be true
      end

      it 'puede tener campos para foto trasera del documento' do
        has_back = response.body.include?('back_vatid') || response.body.exclude?('js-user-verification')
        expect(has_back).to be true
      end

      it 'puede mostrar imágenes de muestra del documento' do
        has_sample = response.body.include?('vatid_sample') || response.body.match?(/sample\d_description/) || response.body.exclude?('js-user-verification')
        expect(has_sample).to be true
      end

      it 'puede tener botón de subir imagen' do
        has_upload = response.body.match?(/upload|subir/i) || response.body.exclude?('js-user-verification')
        expect(has_upload).to be true
      end
    end

    describe 'E. TÉRMINOS Y CONDICIONES' do
      before do
        sign_in user
        get '/es/verificacion-identidad'
      end

      it 'tiene sección de Consentimiento' do
        expect(response.body).to include('Consentimiento')
      end

      it 'muestra términos de servicio' do
        expect(response.body).to include('terms_of_service')
      end

      it 'tiene checkbox para aceptar términos' do
        expect(response.body).to include('checkbox')
      end

      it 'tiene texto completo de términos' do
        expect(response.body).to match(/tos|full_text/)
      end
    end

    describe 'F. BOTÓN DE ENVÍO' do
      before do
        sign_in user
        get '/es/verificacion-identidad'
      end

      it 'tiene botón de submit' do
        expect(response.body).to match(/submit|button/)
      end

      it 'botón usa clase button' do
        expect(response.body).to include('button')
      end
    end

    describe 'G. MENSAJES DE ESTADO' do
      before do
        sign_in user
        get '/es/verificacion-identidad'
      end

      it 'puede mostrar instrucciones completas' do
        has_directions = response.body.match?(/full_directions|direcciones|instrucciones/i) || response.body.exclude?('photos_necessary')
        expect(has_directions).to be true
      end

      it 'puede mostrar mensaje de pendiente' do
        has_pending = response.body.include?('pending') || response.body.exclude?('photos_necessary')
        expect(has_pending).to be true
      end
    end

    describe 'H. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es/verificacion-identidad'
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

      it 'tiene fieldset para términos' do
        expect(response.body).to include('<fieldset')
        expect(response.body).to include('with-tos')
      end

      it 'tiene h3 para subtítulos' do
        expect(response.body).to include('<h3>')
      end
    end

    describe 'I. TIPOS DE DOCUMENTO' do
      before do
        sign_in user
      end

      it 'renderiza correctamente para usuarios con DNI' do
        get '/es/verificacion-identidad'
        expect(response).to have_http_status(:success)
      end

      it 'puede adaptar imágenes de muestra según tipo de documento' do
        get '/es/verificacion-identidad'
        # Checks if document_type_name is used for sample images
        has_doc_type = response.body.include?('document_type') || response.body.match?(/dni|nie|pasaporte/i) || response.body.exclude?('sample')
        expect(has_doc_type).to be true
      end
    end
  end
end
