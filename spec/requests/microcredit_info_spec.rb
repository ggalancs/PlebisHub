# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Microcredit Info', type: :request do
  describe 'GET /es/microcreditos/informacion' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación' do
        get '/es/microcreditos/informacion'
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título Microcréditos' do
        get '/es/microcreditos/informacion'
        expect(response.body).to include('Microcréditos')
      end
    end

    describe 'B. CONTENIDO EXPLICATIVO' do
      before { get '/es/microcreditos/informacion' }

      it 'explica qué son los microcréditos' do
        expect(response.body).to include('préstamo civil')
      end

      it 'menciona campaña electoral' do
        expect(response.body).to include('campaña')
      end

      it 'menciona la devolución' do
        expect(response.body).to include('devolveremos')
        expect(response.body).to include('subvención electoral')
      end

      it 'menciona rango de aportación (50 a 10000 euros)' do
        expect(response.body).to match(/50.*10.*mil/i)
      end
    end

    describe 'C. PRINCIPIOS DIFERENCIALES' do
      before { get '/es/microcreditos/informacion' }

      it 'menciona Independencia' do
        expect(response.body).to include('Independencia')
        expect(response.body).to include('no queremos depender de bancos')
      end

      it 'menciona Innovación' do
        expect(response.body).to include('Innovación')
      end

      it 'menciona Transparencia' do
        expect(response.body).to include('Transparencia')
        expect(response.body).to include('publicar nuestras cuentas')
      end

      it 'menciona crowdfunding' do
        expect(response.body).to include('crowdfunding')
      end
    end

    describe 'D. CONTEXTO Y COMPARACIÓN' do
      before { get '/es/microcreditos/informacion' }

      it 'menciona deuda cero con bancos' do
        expect(response.body).to match(/deuda.*0.*euros/i)
      end

      it 'menciona deuda de otros partidos' do
        expect(response.body).to match(/millones.*euros/i)
      end

      it 'menciona Tribunal de Cuentas' do
        expect(response.body).to include('Tribunal de Cuentas')
      end

      it 'menciona Código Ético' do
        expect(response.body).to include('Código Ético')
      end

      it 'menciona Asamblea Ciudadana' do
        expect(response.body).to include('Asamblea Ciudadana')
      end
    end

    describe 'E. IMÁGENES' do
      before { get '/es/microcreditos/informacion' }

      it 'tiene imágenes relacionadas con microcréditos' do
        expect(response.body).to match(/microcredits\d+\.jpg/)
      end

      it 'tiene textos alt en las imágenes' do
        expect(response.body).to match(/alt=/)
      end
    end

    describe 'F. ESTRUCTURA HTML' do
      before { get '/es/microcreditos/informacion' }

      it 'usa estructura content-content' do
        expect(response.body).to include('content-content')
      end

      it 'tiene h2 para título principal' do
        expect(response.body).to match(/<h2>Microcréditos/)
      end

      it 'tiene listas ul/li' do
        expect(response.body).to include('<ul>')
        expect(response.body).to include('<li>')
      end

      it 'tiene múltiples párrafos' do
        paragraphs = response.body.scan(/<p>/).count
        expect(paragraphs).to be >= 8
      end

      it 'usa negritas para énfasis' do
        expect(response.body).to include('<strong>')
      end
    end
  end
end
