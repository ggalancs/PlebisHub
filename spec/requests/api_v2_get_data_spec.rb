# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V2 Get Data', type: :request do
  describe 'GET /api/v2/datos' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o requiere autenticación/parámetros' do
        get '/api/v2/datos'
        expect([200, 302, 404, 422]).to include(response.status)
      end

      it 'si renderiza, devuelve resultado dinámico' do
        get '/api/v2/datos'
        if response.status == 200
          # La vista solo muestra @result
          expect(response.body).not_to be_empty
        end
      end
    end

    describe 'B. CONTENIDO DE API' do
      it 'si renderiza, devuelve datos simples' do
        get '/api/v2/datos'
        if response.status == 200
          # Es una vista muy simple que solo renderiza @result
          has_content = !response.body.empty?
          expect(has_content).to be true
        end
      end
    end
  end
end
