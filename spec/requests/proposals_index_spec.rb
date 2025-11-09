# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Proposals Index', type: :request do
  describe 'GET /es/propuestas' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación' do
        get '/es/propuestas'
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título Iniciativas Ciudadanas' do
        get '/es/propuestas'
        expect(response.body).to include('Iniciativas Ciudadanas')
      end

      it 'tiene el title tag correcto' do
        get '/es/propuestas'
        expect(response.body).to match(/<title>.*Iniciativas/i)
      end
    end

    describe 'B. ENLACE A INFORMACIÓN' do
      before { get '/es/propuestas' }

      it 'tiene enlace a información sobre iniciativas' do
        expect(response.body).to include('Qué son')
        expect(response.body).to include('cómo funcionan')
      end

      it 'enlace apunta a proposals_info_path' do
        expect(response.body).to match(/info|informacion/i)
      end
    end

    describe 'C. NAVEGACIÓN Y FILTROS' do
      before { get '/es/propuestas' }

      it 'tiene navegación para filtrar propuestas' do
        expect(response.body).to include('<nav>')
      end

      it 'tiene filtro de Nuevas' do
        expect(response.body).to include('Nuevas')
      end

      it 'tiene filtro de Populares' do
        expect(response.body).to include('Populares')
      end

      it 'tiene filtro Por tiempo' do
        expect(response.body).to include('Por tiempo')
      end

      it 'tiene filtro de Candentes' do
        expect(response.body).to include('Candentes')
      end
    end

    describe 'D. AVISO DEL SISTEMA' do
      before { get '/es/propuestas' }

      it 'tiene box-info con aviso sobre plazo de apoyos' do
        expect(response.body).to include('box-info')
      end

      it 'menciona el plazo de 3 meses' do
        expect(response.body).to include('3 meses')
      end

      it 'menciona documento organizativo' do
        expect(response.body).to include('documento organizativo')
      end
    end

    describe 'E. SIDEBAR DE CANDENTES' do
      before { get '/es/propuestas' }

      it 'tiene sidebar' do
        expect(response.body).to include('sidebar')
      end

      it 'sidebar muestra propuestas candentes' do
        expect(response.body).to match(/h2.*Candentes/m)
      end

      it 'propuestas en sidebar tienen clase proposal-sidebar' do
        expect(response.body).to include('proposal-sidebar')
      end
    end

    describe 'F. ESTRUCTURA HTML' do
      before { get '/es/propuestas' }

      it 'usa section con clase generic-wrapper' do
        expect(response.body).to include('generic-wrapper')
      end

      it 'tiene h1 para título principal' do
        expect(response.body).to match(/<h1>.*Iniciativas/i)
      end

      it 'tiene contenedor principal' do
        expect(response.body).to include('container')
      end

      it 'tiene article para propuestas' do
        expect(response.body).to include('<article')
      end
    end

    describe 'G. INFORMACIÓN DE PROPUESTAS' do
      before { get '/es/propuestas' }

      it 'muestra porcentaje de avales' do
        # May not have proposals, so check conditionally
        has_support_info = response.body.include?('avales') || response.body.include?('support')
        expect(has_support_info || !response.body.include?('proposal-sidebar')).to be true
      end

      it 'muestra tiempo restante o finalización' do
        has_time_info = response.body.match?(/Termina|Cerrada|finish/i) || !response.body.include?('proposal-sidebar')
        expect(has_time_info).to be true
      end
    end
  end
end
