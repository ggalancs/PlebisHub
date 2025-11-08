# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SMS Validator Step1', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/validacion/sms' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado' do
        get '/es/validacion/sms'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es/validacion/sms'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'muestra título sobre teléfono móvil' do
        expect(response.body).to match(/teléfono.*móvil|móvil/i)
      end

      it 'tiene el title tag correcto' do
        expect(response.body).to match(/<title>/)
      end
    end

    describe 'C. PARTIAL DE STEPS' do
      before do
        sign_in user
        get '/es/validacion/sms'
      end

      it 'renderiza partial de steps (paso 1)' do
        expect(response.body).to include('step')
      end
    end

    describe 'D. FORMULARIO DE TELÉFONO' do
      before do
        sign_in user
        get '/es/validacion/sms'
      end

      it 'tiene formulario para current_user' do
        expect(response.body).to include('<form')
      end

      it 'tiene campo unconfirmed_phone' do
        expect(response.body).to include('unconfirmed_phone')
      end

      it 'campo es de tipo number' do
        expect(response.body).to match(/type=.*number/)
      end

      it 'tiene autofocus en el campo' do
        expect(response.body).to include('autofocus')
      end

      it 'muestra prefijo internacional del país' do
        expect(response.body).to match(/\+\d+|country_phone_prefix/)
      end

      it 'tiene botón de submit para guardar móvil' do
        expect(response.body).to match(/Guardar.*móvil/)
      end
    end

    describe 'E. INSTRUCCIONES' do
      before do
        sign_in user
        get '/es/validacion/sms'
      end

      it 'tiene párrafos con instrucciones' do
        p_count = response.body.scan(/<p>/).count
        expect(p_count).to be >= 3
      end

      it 'menciona teléfono válido sin prefijo internacional' do
        expect(response.body).to match(/teléfono.*válido|sin prefijo internacional/i)
      end

      it 'menciona solo números sin espacios ni guiones' do
        expect(response.body).to match(/números.*sin espacios|sin guiones/i)
      end

      it 'muestra país del usuario' do
        expect(response.body).to match(/te encuentras en|country_name/)
      end

      it 'tiene enlace a página de perfil para cambiar ubicación' do
        expect(response.body).to match(/perfil|edit_user_registration/)
      end
    end

    describe 'F. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es/validacion/sms'
      end

      it 'usa estructura content-content cols' do
        expect(response.body).to include('content-content')
        expect(response.body).to include('cols')
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end

      it 'tiene fieldset' do
        expect(response.body).to include('<fieldset')
      end

      it 'tiene legend invisible' do
        expect(response.body).to match(/legend.*invisible/)
      end

      it 'usa inputlabel-box para campos' do
        expect(response.body).to include('inputlabel-box')
      end
    end
  end
end
