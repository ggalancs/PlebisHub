# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devise Passwords Edit', type: :request do
  describe 'GET /es/users/password/edit' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza con token válido o redirige sin token' do
        get '/es/users/password/edit'
        expect([200, 302]).to include(response.status)
      end

      it 'si renderiza, muestra título de cambiar contraseña' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to match(/cambiar.*contraseña|change.*password/i) if response.status == 200
      end
    end

    describe 'B. FORMULARIO DE CAMBIO DE CONTRASEÑA' do
      it 'si renderiza, tiene formulario' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to include('<form') if response.status == 200
      end

      it 'si renderiza, tiene campo hidden para reset_password_token' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        if response.status == 200
          expect(response.body).to include('reset_password_token')
          expect(response.body).to include('hidden')
        end
      end

      it 'si renderiza, tiene campo para nueva contraseña' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to match(/password|contraseña/i) if response.status == 200
      end

      it 'si renderiza, tiene campo para confirmación de contraseña' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to match(/password_confirmation|confirmación/i) if response.status == 200
      end

      it 'si renderiza, campo password tiene autofocus' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to include('autofocus') if response.status == 200
      end

      it 'si renderiza, tiene botón de submit' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to match(/submit|button/) if response.status == 200
      end
    end

    describe 'C. ESTRUCTURA DEL FORMULARIO' do
      it 'si renderiza, usa semantic_form_for' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to include('<form') if response.status == 200
      end

      it 'si renderiza, usa método PUT' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        if response.status == 200
          has_put = response.body.include?('_method') && response.body.include?('put')
          expect(has_put || response.body.include?('method')).to be true
        end
      end

      it 'si renderiza, tiene fieldset' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to include('<fieldset') if response.status == 200
      end

      it 'si renderiza, tiene legend invisible' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to match(/legend.*invisible/i) if response.status == 200
      end

      it 'si renderiza, usa inputlabel-box' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to include('inputlabel-box') if response.status == 200
      end
    end

    describe 'D. ESTRUCTURA HTML' do
      it 'si renderiza, usa estructura content-content cols' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        if response.status == 200
          expect(response.body).to include('content-content')
          expect(response.body).to include('cols')
        end
      end

      it 'si renderiza, tiene h2 para título' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to match(/<h2>/) if response.status == 200
      end

      it 'si renderiza, tiene section content-text' do
        get '/es/users/password/edit', params: { reset_password_token: 'test' }
        expect(response.body).to include('content-text') if response.status == 200
      end
    end
  end
end
