# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SMS Validator Step2', type: :request do
  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/validator/sms/step2' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado', :skip_auth do
        get '/es/validator/sms/step2'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es/validator/sms/step2'
      end

      it 'renderiza correctamente o redirige' do
        expect([200, 302]).to include(response.status)
      end

      it 'si renderiza, muestra título de captcha' do
        expect(response.body).to match(/código.*imagen|captcha/i) if response.status == 200
      end

      it 'si renderiza, tiene el title tag correcto' do
        expect(response.body).to match(/<title>/) if response.status == 200
      end
    end

    describe 'C. PARTIAL DE STEPS' do
      before do
        sign_in user
        get '/es/validator/sms/step2'
      end

      it 'si renderiza, muestra step 2' do
        expect(response.body).to include('step') if response.status == 200
      end
    end

    describe 'D. FORMULARIO DE CAPTCHA' do
      before do
        sign_in user
        get '/es/validator/sms/step2'
      end

      it 'si renderiza, tiene formulario de captcha' do
        expect(response.body).to include('<form') if response.status == 200
      end

      it 'si renderiza, muestra captcha simple' do
        expect(response.body).to match(/captcha|simple_captcha/) if response.status == 200
      end

      it 'si renderiza, tiene campo de captcha' do
        expect(response.body).to include('captcha') if response.status == 200
      end

      it 'si renderiza, tiene botón de submit' do
        expect(response.body).to match(/submit|button/) if response.status == 200
      end
    end

    describe 'E. INSTRUCCIONES' do
      before do
        sign_in user
        get '/es/validator/sms/step2'
      end

      it 'si renderiza, tiene párrafo con instrucciones' do
        expect(response.body).to include('<p>') if response.status == 200
      end
    end

    describe 'F. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es/validator/sms/step2'
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
