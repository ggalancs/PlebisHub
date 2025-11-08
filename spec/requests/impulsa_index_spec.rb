# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Impulsa Index', type: :request do
  describe 'GET /es/impulsa' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación' do
        get '/es/impulsa'
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título IMPULSA' do
        get '/es/impulsa'
        expect(response.body).to include('IMPULSA')
      end

      it 'tiene el title tag correcto' do
        get '/es/impulsa'
        expect(response.body).to include('<title>')
      end
    end

    describe 'B. CONTENIDO INFORMATIVO' do
      before { get '/es/impulsa' }

      it 'tiene h2 con el título' do
        expect(response.body).to match(/<h2>.*IMPULSA/i)
      end

      it 'tiene enlace a más información' do
        expect(response.body).to include('Ver más información')
        expect(response.body).to include('plebisbrand.info/impulsa')
      end
    end

    describe 'C. DESCRIPCIÓN CUANDO NO HAY EDICIÓN ACTIVA' do
      before { get '/es/impulsa' }

      it 'muestra qué es IMPULSA o descripción de edición' do
        # Should have either the default description or an edition description
        has_description = response.body.match?(/Qué es IMPULSA|proyectos emprendedores|dotación económica/i)
        expect(has_description).to be true
      end
    end

    describe 'D. ESTRUCTURA HTML' do
      before { get '/es/impulsa' }

      it 'usa estructura content-content' do
        expect(response.body).to include('content-content')
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end

      it 'tiene al menos un párrafo' do
        expect(response.body).to match(/<p>/)
      end
    end

    describe 'E. ESTADOS POSIBLES' do
      before { get '/es/impulsa' }

      it 'muestra algún estado (activa, concluida, próxima o información general)' do
        # Should have one of these states
        has_state = response.body.match?(/presentación.*proyecto|subsanación|evaluación|concluído|Qué es IMPULSA/i)
        expect(has_state).to be true
      end
    end
  end
end
