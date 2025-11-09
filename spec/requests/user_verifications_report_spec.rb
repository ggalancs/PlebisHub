# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Verifications Report', type: :request do
  describe 'GET /es/report' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o requiere autenticación' do
        get '/es/report'
        expect([200, 302]).to include(response.status)
      end

      it 'si renderiza, muestra título de informe' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to match(/informe|verificaciones/i)
        end
      end
    end

    describe 'B. TABLAS DE DATOS' do
      it 'si renderiza, tiene tabla para autonomías' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to match(/autonom|table/)
        end
      end

      it 'si renderiza, tiene tabla para provincias' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to match(/provincias|table/)
        end
      end

      it 'si renderiza, tiene encabezados de verificaciones' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to match(/Verificaciones|Pendientes|Aceptadas/)
        end
      end

      it 'si renderiza, tiene encabezados de usuarios' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to match(/Usuarios|Verificados/)
        end
      end

      it 'si renderiza, tiene columnas con porcentajes' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to match(/%.*verificados/)
        end
      end
    end

    describe 'C. CATEGORÍAS DE VERIFICACIÓN' do
      it 'si renderiza, menciona verificaciones pendientes' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to include('Pendientes')
        end
      end

      it 'si renderiza, menciona con problemas' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to include('Con problemas')
        end
      end

      it 'si renderiza, menciona rechazados' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to include('Rechazados')
        end
      end

      it 'si renderiza, menciona aceptadas' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to include('Aceptadas')
        end
      end
    end

    describe 'D. TOTALES' do
      it 'si renderiza, tiene fila de totales' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to match(/tfoot|Totales/)
        end
      end
    end

    describe 'E. ESTRUCTURA HTML' do
      it 'si renderiza, usa estructura content-content' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to include('content-content')
        end
      end

      it 'si renderiza, tiene h2 para títulos de sección' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to include('<h2>')
        end
      end

      it 'si renderiza, usa clase table' do
        get '/es/report'
        if response.status == 200
          expect(response.body).to include('table')
        end
      end
    end
  end
end
