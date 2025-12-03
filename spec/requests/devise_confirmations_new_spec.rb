# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devise Confirmations New', type: :request do
  describe 'GET /es/confirmacion/nuevo' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación' do
        get '/es/users/confirmation/new'
        expect(response).to have_http_status(:success)
      end

      it 'muestra título de instrucciones de confirmación' do
        get '/es/users/confirmation/new'
        expect(response.body).to match(/confirmation|confirmación/i)
      end

      it 'tiene el title tag correcto' do
        get '/es/users/confirmation/new'
        expect(response.body).to match(/<title>/)
      end
    end

    describe 'B. FORMULARIO DE CONFIRMACIÓN' do
      before { get '/es/users/confirmation/new' }

      it 'tiene formulario' do
        expect(response.body).to include('<form')
      end

      it 'tiene campo para email' do
        expect(response.body).to include('email')
      end

      it 'campo email tiene autofocus' do
        expect(response.body).to include('autofocus')
      end

      it 'tiene botón de submit' do
        expect(response.body).to match(/submit|button/)
      end

      it 'botón menciona instrucciones de confirmación' do
        expect(response.body).to match(/confirmation.*instructions|confirmación/i)
      end
    end

    describe 'C. ESTRUCTURA DEL FORMULARIO' do
      before { get '/es/users/confirmation/new' }

      it 'usa semantic_form_for' do
        expect(response.body).to include('<form')
      end

      it 'tiene fieldset' do
        expect(response.body).to include('<fieldset')
      end

      it 'tiene legend invisible' do
        expect(response.body).to match(/legend.*invisible/i)
      end

      it 'usa inputlabel-box' do
        expect(response.body).to include('inputlabel-box')
      end

      it 'tiene botón con clase button' do
        expect(response.body).to match(/class=.*button/)
      end
    end

    describe 'D. ESTRUCTURA HTML' do
      before { get '/es/users/confirmation/new' }

      it 'usa estructura content-content cols' do
        expect(response.body).to include('content-content')
        expect(response.body).to include('cols')
      end

      it 'tiene h2 para título' do
        expect(response.body).to match(/<h2>/)
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end
    end
  end
end
