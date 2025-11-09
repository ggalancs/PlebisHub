# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Page Funding', type: :request do
  describe 'GET /es/financiacion' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación' do
        get '/es/financiacion'
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título Financiación' do
        get '/es/financiacion'
        expect(response.body).to include('Financiación')
      end

      it 'tiene el title tag correcto' do
        get '/es/financiacion'
        expect(response.body).to include('<title>')
      end
    end

    describe 'B. CONTENIDO PRINCIPAL' do
      before { get '/es/financiacion' }

      it 'menciona transparencia' do
        expect(response.body).to include('transparencia')
      end

      it 'menciona participación' do
        expect(response.body).to include('participación')
      end

      it 'menciona independencia' do
        expect(response.body).to include('independencia')
      end

      it 'tiene enlace al Portal de Transparencia' do
        expect(response.body).to include('Portal de Transparencia')
        expect(response.body).to include('transparencia.plebisbrand.info')
      end
    end

    describe 'C. SECCIÓN DE COLABORACIONES' do
      before { get '/es/financiacion' }

      it 'tiene título de Colaboraciones' do
        expect(response.body).to include('Colaboraciones')
      end

      it 'explica las colaboraciones' do
        expect(response.body).to match(/Colabora con PlebisBrand.*sencilla/i)
      end

      it 'tiene botón para Colaborar' do
        expect(response.body).to include('Colabora')
      end

      it 'enlaza a edit_collaboration_path' do
        expect(response.body).to match(/ver.*colabor/i)
      end
    end

    describe 'D. SECCIÓN DE MICROCRÉDITOS' do
      before { get '/es/financiacion' }

      it 'tiene título de Microcréditos' do
        expect(response.body).to include('Microcréditos')
      end

      it 'explica los microcréditos' do
        expect(response.body).to include('préstamos ciudadanos')
      end

      it 'menciona devolución íntegra sin intereses' do
        expect(response.body).to include('íntegra')
        expect(response.body).to include('sin intereses')
      end

      it 'tiene botón para Ver campañas' do
        expect(response.body).to include('Ver campañas')
      end
    end

    describe 'E. ESTRUCTURA HTML' do
      before { get '/es/financiacion' }

      it 'usa estructura con section.funding' do
        expect(response.body).to include('section class="funding"')
      end

      it 'tiene boxes de financiación' do
        boxes = response.body.scan(/box-funding/).count
        expect(boxes).to be >= 2
      end

      it 'usa listas ul/li para organizar contenido' do
        expect(response.body).to include('<ul>')
        expect(response.body).to include('<li')
      end

      it 'tiene h2 para título principal' do
        expect(response.body).to match(/<h2>Financiación<\/h2>/)
      end

      it 'tiene h3 para subtítulos de secciones' do
        h3_count = response.body.scan(/<h3>/).count
        expect(h3_count).to be >= 2
      end

      it 'tiene buttonbox para botones' do
        expect(response.body).to include('buttonbox')
      end
    end
  end
end
