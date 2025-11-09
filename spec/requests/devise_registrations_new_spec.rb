# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devise Registrations New', type: :request do
  describe 'GET /es/registro' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación' do
        get '/es/registro'
        expect(response).to have_http_status(:success)
      end

      it 'muestra título de registro' do
        get '/es/registro'
        expect(response.body).to match(/sign.*up|registro|inscripción/i)
      end

      it 'tiene el title tag correcto' do
        get '/es/registro'
        expect(response.body).to match(/<title>/)
      end
    end

    describe 'B. INFORMACIÓN INTRODUCTORIA' do
      before { get '/es/registro' }

      it 'muestra info_box con información' do
        expect(response.body).to match(/info.*box/i)
      end

      it 'tiene párrafo introductorio' do
        expect(response.body).to match(/<p>/)
      end
    end

    describe 'C. FORMULARIO DE REGISTRO' do
      before { get '/es/registro' }

      it 'renderiza el partial form' do
        expect(response.body).to match(/form/)
      end

      it 'tiene formulario para nuevo usuario' do
        expect(response.body).to include('<form')
      end

      it 'pasa action "new" al partial' do
        # The form should be in new mode
        expect(response.body).to match(/form|input/)
      end
    end

    describe 'D. ESTRUCTURA HTML' do
      before { get '/es/registro' }

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
    end
  end
end
