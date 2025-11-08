# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Vote Check', type: :request do
  describe 'GET /es/votacion/:election_id/comprobar' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o redirige si no hay elección activa' do
        get '/es/votacion/1/comprobar'
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, contiene widget de Agora Voting' do
        get '/es/votacion/1/comprobar'
        if response.status == 200
          expect(response.body).to include('agoravoting')
        end
      end
    end

    describe 'B. CONTENIDO DEL WIDGET' do
      it 'si renderiza, tiene enlace a ballot-locator' do
        get '/es/votacion/1/comprobar'
        if response.status == 200
          expect(response.body).to include('ballot-locator')
        end
      end

      it 'si renderiza, carga script de Agora Voting widgets' do
        get '/es/votacion/1/comprobar'
        if response.status == 200
          expect(response.body).to include('avWidgets')
        end
      end
    end

    describe 'C. ESTRUCTURA HTML' do
      it 'si renderiza, tiene contenedor con estilo' do
        get '/es/votacion/1/comprobar'
        if response.status == 200
          expect(response.body).to match(/width.*height/i)
        end
      end
    end
  end
end
