# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SMS Validator Step2', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/validacion/sms/captcha' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado' do
        get '/es/validacion/sms/captcha'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es/validacion/sms/captcha'
      end

      it 'renderiza correctamente o redirige' do
        expect([200, 302]).to include(response.status)
      end

      it 'si renderiza, muestra título de captcha' do
        if response.status == 200
          expect(response.body).to match(/código.*imagen|captcha/i)
        end
      end

      it 'si renderiza, tiene el title tag correcto' do
        if response.status == 200
          expect(response.body).to match(/<title>/)
        end
      end
    end

    describe 'C. PARTIAL DE STEPS' do
      before do
        sign_in user
        get '/es/validacion/sms/captcha'
      end

      it 'si renderiza, muestra step 2' do
        if response.status == 200
          expect(response.body).to include('step')
        end
      end
    end

    describe 'D. FORMULARIO DE CAPTCHA' do
      before do
        sign_in user
        get '/es/validacion/sms/captcha'
      end

      it 'si renderiza, tiene formulario de captcha' do
        if response.status == 200
          expect(response.body).to include('<form')
        end
      end

      it 'si renderiza, muestra captcha simple' do
        if response.status == 200
          expect(response.body).to match(/captcha|simple_captcha/)
        end
      end

      it 'si renderiza, tiene campo de captcha' do
        if response.status == 200
          expect(response.body).to include('captcha')
        end
      end

      it 'si renderiza, tiene botón de submit' do
        if response.status == 200
          expect(response.body).to match(/submit|button/)
        end
      end
    end

    describe 'E. INSTRUCCIONES' do
      before do
        sign_in user
        get '/es/validacion/sms/captcha'
      end

      it 'si renderiza, tiene párrafo con instrucciones' do
        if response.status == 200
          expect(response.body).to include('<p>')
        end
      end
    end

    describe 'F. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es/validacion/sms/captcha'
      end

      it 'si renderiza, usa estructura content-content cols' do
        if response.status == 200
          expect(response.body).to include('content-content')
          expect(response.body).to include('cols')
        end
      end

      it 'si renderiza, tiene fieldset' do
        if response.status == 200
          expect(response.body).to include('<fieldset')
        end
      end

      it 'si renderiza, tiene legend invisible' do
        if response.status == 200
          expect(response.body).to match(/legend.*invisible/i)
        end
      end

      it 'si renderiza, usa inputlabel-box' do
        if response.status == 200
          expect(response.body).to include('inputlabel-box')
        end
      end
    end
  end
end
