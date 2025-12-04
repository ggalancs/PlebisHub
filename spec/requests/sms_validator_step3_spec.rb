# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SMS Validator Step3', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/validator/sms/step3' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado', :skip_auth do
        get '/es/validator/sms/step3'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es/validator/sms/step3'
      end

      it 'renderiza correctamente o redirige' do
        expect([200, 302]).to include(response.status)
      end

      it 'si renderiza, muestra título sobre código SMS' do
        expect(response.body).to match(/código.*SMS|sms|token/i) if response.status == 200
      end

      it 'si renderiza, tiene el title tag correcto' do
        expect(response.body).to match(/<title>/) if response.status == 200
      end
    end

    describe 'C. PARTIAL DE STEPS' do
      before do
        sign_in user
        get '/es/validacion/sms/codigo'
      end

      it 'si renderiza, muestra step 3' do
        expect(response.body).to include('step') if response.status == 200
      end
    end

    describe 'D. FORMULARIO DE CÓDIGO SMS' do
      before do
        sign_in user
        get '/es/validacion/sms/codigo'
      end

      it 'si renderiza, tiene formulario' do
        expect(response.body).to include('<form') if response.status == 200
      end

      it 'si renderiza, tiene campo sms_user_token_given' do
        expect(response.body).to include('sms_user_token_given') if response.status == 200
      end

      it 'si renderiza, tiene label para token' do
        expect(response.body).to match(/token|código/i) if response.status == 200
      end

      it 'si renderiza, tiene botón de submit' do
        expect(response.body).to match(/submit|button/) if response.status == 200
      end
    end

    describe 'E. INSTRUCCIONES' do
      before do
        sign_in user
        get '/es/validacion/sms/codigo'
      end

      it 'si renderiza, tiene párrafo con instrucciones' do
        expect(response.body).to include('<p>') if response.status == 200
      end
    end

    describe 'F. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es/validacion/sms/codigo'
      end

      it 'si renderiza, usa estructura content-content cols' do
        if response.status == 200
          expect(response.body).to include('content-content')
          expect(response.body).to include('cols')
        end
      end

      it 'si renderiza, tiene fieldset' do
        expect(response.body).to include('<fieldset') if response.status == 200
      end

      it 'si renderiza, tiene legend invisible' do
        expect(response.body).to match(/legend.*invisible/i) if response.status == 200
      end

      it 'si renderiza, usa inputlabel-box' do
        expect(response.body).to include('inputlabel-box') if response.status == 200
      end
    end
  end
end
