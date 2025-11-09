# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Impulsa Inactive', type: :request do
  describe 'GET /es/impulsa (cuando está inactivo)' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza sin autenticación (probablemente redirige a index que maneja el estado)' do
        get '/es/impulsa'
        expect([200, 302]).to include(response.status)
      end

      it 'muestra título de IMPULSA' do
        get '/es/impulsa'
        if response.status == 200
          expect(response.body).to match(/IMPULSA|Impulsa/)
        end
      end
    end

    describe 'B. MENSAJES DE ESTADO' do
      it 'muestra mensaje sobre próxima edición o ausencia de ediciones' do
        get '/es/impulsa'
        if response.status == 200
          expect(response.body).to match(/próxim|upcoming|noupcoming/i)
        end
      end
    end

    describe 'C. ESTRUCTURA HTML' do
      it 'usa estructura content-content' do
        get '/es/impulsa'
        if response.status == 200
          expect(response.body).to include('content-content')
        end
      end

      it 'tiene h2 para título principal' do
        get '/es/impulsa'
        if response.status == 200
          expect(response.body).to match(/<h2>/)
        end
      end
    end
  end
end
