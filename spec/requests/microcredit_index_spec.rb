# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Microcredit Index', type: :request do
  describe 'GET /es/microcreditos' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación' do
        get '/es/microcreditos'
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título de Microcréditos' do
        get '/es/microcreditos'
        expect(response.body).to match(/Microcrédito/i)
      end

      it 'tiene el title tag correcto' do
        get '/es/microcreditos'
        expect(response.body).to include('<title>')
      end
    end

    describe 'B. CONTENIDO PRINCIPAL' do
      before { get '/es/microcreditos' }

      it 'tiene h2 con título' do
        expect(response.body).to match(/<h2>/)
      end

      it 'tiene enlace a más información' do
        expect(response.body).to match(/más.*info|more.*info/i)
      end
    end

    describe 'C. ESTRUCTURA HTML' do
      before { get '/es/microcreditos' }

      it 'usa estructura content-content' do
        expect(response.body).to include('content-content')
      end

      it 'tiene al menos un h2' do
        expect(response.body).to match(/<h2>/)
      end

      it 'tiene al menos un párrafo' do
        expect(response.body).to match(/<p>/)
      end
    end

    describe 'D. ESTADOS POSIBLES' do
      before { get '/es/microcreditos' }

      it 'muestra algún contenido (campañas activas, próximas, finalizadas o sin campañas)' do
        # Should have one of these states
        has_content = response.body.match?(/microcredit_boxes|próxim|finaliza|no.*campaña/i)
        expect(has_content).to be true
      end
    end
  end
end
