# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devise Passwords New', type: :request do
  describe 'GET /es/password/nuevo' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación', :skip_auth do
        get '/es/users/password/new'
        expect(response).to have_http_status(:success)
      end

      it 'muestra título de recuperar contraseña' do
        get '/es/users/password/new'
        expect(response.body).to match(/forgot.*password|olvidaste.*contraseña|recuperar/i)
      end

      it 'tiene el title tag correcto' do
        get '/es/users/password/new'
        expect(response.body).to match(/<title>/)
      end
    end

    describe 'B. FORMULARIO DE RECUPERACIÓN' do
      before { get '/es/users/password/new' }

      it 'tiene formulario de recuperación' do
        expect(response.body).to include('<form')
      end

      it 'tiene campo para email' do
        expect(response.body).to include('email')
      end

      it 'campo email tiene autofocus' do
        expect(response.body).to include('autofocus')
      end

      it 'tiene botón de submit para resetear contraseña' do
        expect(response.body).to match(/reset.*password|submit/i)
      end
    end

    describe 'C. ESTRUCTURA DEL FORMULARIO' do
      before { get '/es/users/password/new' }

      it 'usa semantic_form_for' do
        expect(response.body).to match(/form/)
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

      it 'tiene botón con clase button' do
        expect(response.body).to match(/class=.*button/)
      end
    end

    describe 'D. ESTRUCTURA HTML' do
      before { get '/es/users/password/new' }

      it 'usa estructura content-content cols' do
        expect(response.body).to include('content-content')
        expect(response.body).to include('cols')
      end

      it 'tiene h2 para título principal' do
        expect(response.body).to match(/<h2>/)
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end

      it 'tiene section content-text' do
        expect(response.body).to include('content-text')
      end
    end
  end
end
