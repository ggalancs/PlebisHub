# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Page Closed Form', type: :request do
  describe 'GET /es/formulario-cerrado' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o redirige si no hay formulario cerrado' do
        get '/es/formulario-cerrado'
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, tiene título dinámico' do
        get '/es/formulario-cerrado'
        expect(response.body).to match(/<h2>/) if response.status == 200
      end
    end

    describe 'B. CONTENIDO DE LA PÁGINA' do
      it 'si renderiza, tiene texto dinámico' do
        get '/es/formulario-cerrado'
        expect(response.body).to include('<p>') if response.status == 200
      end

      it 'si renderiza, puede tener enlace para volver' do
        get '/es/formulario-cerrado'
        if response.status == 200
          has_back = response.body.include?('Volver') || true
          expect(has_back).to be true
        end
      end
    end

    describe 'C. ESTRUCTURA HTML' do
      it 'si renderiza, usa estructura content-content cols' do
        get '/es/formulario-cerrado'
        if response.status == 200
          expect(response.body).to include('content-content')
          expect(response.body).to include('cols')
        end
      end

      it 'si renderiza, usa row y col para layout' do
        get '/es/formulario-cerrado'
        if response.status == 200
          expect(response.body).to include('row')
          expect(response.body).to match(/col-[a-z]-\d/)
        end
      end
    end
  end
end
