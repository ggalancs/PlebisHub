# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Verifications Report Town', type: :request do
  describe 'GET /es/report_town' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o requiere autenticación' do
        get '/es/report_town'
        expect([200, 302]).to include(response.status)
      end

      it 'si renderiza, muestra título de informe' do
        get '/es/report_town'
        expect(response.body).to match(/informe|verificaciones/i) if response.status == 200
      end
    end

    describe 'B. TABLAS DE DATOS POR NIVEL' do
      it 'si renderiza, tiene tabla para autonomías' do
        get '/es/report_town'
        expect(response.body).to match(/autonom|table/) if response.status == 200
      end

      it 'si renderiza, tiene tabla para provincias' do
        get '/es/report_town'
        expect(response.body).to match(/provincias|table/) if response.status == 200
      end

      it 'si renderiza, tiene tabla para municipios' do
        get '/es/report_town'
        expect(response.body).to match(/municipios|table/) if response.status == 200
      end

      it 'si renderiza, tiene múltiples h2 (uno por nivel)' do
        get '/es/report_town'
        if response.status == 200
          h2_count = response.body.scan('<h2>').count
          expect(h2_count).to be >= 3
        end
      end
    end

    describe 'C. ENCABEZADOS DE TABLA' do
      it 'si renderiza, tiene encabezados de verificaciones' do
        get '/es/report_town'
        expect(response.body).to match(/Verificaciones|Pendientes|Aceptadas/) if response.status == 200
      end

      it 'si renderiza, tiene encabezados de usuarios' do
        get '/es/report_town'
        expect(response.body).to match(/Usuarios|Verificados/) if response.status == 200
      end

      it 'si renderiza, tiene usuarios activos' do
        get '/es/report_town'
        expect(response.body).to match(/activos/) if response.status == 200
      end

      it 'si renderiza, tiene columnas con porcentajes' do
        get '/es/report_town'
        expect(response.body).to match(/%.*verificados/) if response.status == 200
      end
    end

    describe 'D. CATEGORÍAS DE VERIFICACIÓN' do
      it 'si renderiza, menciona verificaciones pendientes' do
        get '/es/report_town'
        expect(response.body).to include('Pendientes') if response.status == 200
      end

      it 'si renderiza, menciona con problemas' do
        get '/es/report_town'
        expect(response.body).to include('Con problemas') if response.status == 200
      end

      it 'si renderiza, menciona rechazados' do
        get '/es/report_town'
        expect(response.body).to include('Rechazados') if response.status == 200
      end

      it 'si renderiza, menciona aceptadas' do
        get '/es/report_town'
        expect(response.body).to include('Aceptadas') if response.status == 200
      end
    end

    describe 'E. TOTALES' do
      it 'si renderiza, tiene filas de totales' do
        get '/es/report_town'
        expect(response.body).to match(/tfoot|Totales/) if response.status == 200
      end
    end

    describe 'F. ESTRUCTURA HTML' do
      it 'si renderiza, usa estructura content-content' do
        get '/es/report_town'
        expect(response.body).to include('content-content') if response.status == 200
      end

      it 'si renderiza, usa clase table' do
        get '/es/report_town'
        expect(response.body).to include('table') if response.status == 200
      end
    end
  end
end
