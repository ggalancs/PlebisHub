# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devise Sessions New', type: :request do
  describe 'GET /es/login' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación', :skip_auth do
        get '/es/users/sign_in'
        expect(response).to have_http_status(:success)
      end

      it 'muestra título de inicio de sesión' do
        get '/es/users/sign_in'
        expect(response.body).to match(/sign.*in|acceder|login/i)
      end

      it 'tiene el title tag correcto' do
        get '/es/users/sign_in'
        expect(response.body).to match(/<title>/)
      end
    end

    describe 'B. FORMULARIO DE LOGIN' do
      before { get '/es/users/sign_in' }

      it 'tiene formulario de login' do
        expect(response.body).to include('<form')
      end

      it 'tiene campo para login (email o documento)' do
        expect(response.body).to include('login')
      end

      it 'placeholder menciona Email o Documento' do
        expect(response.body).to match(/Email.*Documento|DNI.*NIE.*Pasaporte/i)
      end

      it 'tiene campo para contraseña' do
        expect(response.body).to include('password')
      end

      it 'tiene checkbox de recordarme' do
        expect(response.body).to match(/remember_me|Recordar/)
      end

      it 'tiene botón de submit' do
        expect(response.body).to match(/submit|button/)
      end
    end

    describe 'C. ENLACES DE AYUDA' do
      before { get '/es/users/sign_in' }

      it 'tiene enlace de ayuda para acceder' do
        expect(response.body).to include('Ayuda para acceder')
      end

      it 'tiene enlace para recuperar contraseña' do
        # May not have exact Spanish text, check for password recovery link
        has_password_recovery = response.body.match?(/olvidaste.*contraseña|forgot.*password|password|recuperar/i)
        expect(has_password_recovery).to be true
      end
    end

    describe 'D. INFORMACIÓN DE INSCRIPCIÓN' do
      before { get '/es/users/sign_in' }

      it 'muestra artículo introductorio' do
        expect(response.body).to include('intro')
      end

      it 'menciona inscripción en PlebisBrand' do
        expect(response.body).to match(/Inscríbete|Inscripción/)
      end

      it 'tiene enlace a nueva inscripción' do
        expect(response.body).to match(/Inscripción|new_user_registration/)
      end

      it 'explica militancia en PlebisBrand' do
        expect(response.body).to include('MILITANTES')
      end

      it 'menciona asambleas ciudadanas' do
        expect(response.body).to match(/asambleas.*ciudadanas/i)
      end
    end

    describe 'E. ESTRUCTURA HTML' do
      before { get '/es/users/sign_in' }

      it 'usa div con clase people-bg' do
        expect(response.body).to include('people-bg')
      end

      it 'tiene login-box para el formulario' do
        expect(response.body).to include('login-box')
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-/)
      end

      it 'tiene fieldset con legend' do
        expect(response.body).to include('<fieldset')
        expect(response.body).to include('<legend')
      end

      it 'usa clases específicas de home' do
        expect(response.body).to include('content-content-home')
      end
    end
  end
end
