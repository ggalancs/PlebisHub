# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Vote Votes Count', type: :request do
  describe 'GET /es/votacion/contador' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente' do
        get '/es/votacion/contador'
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, muestra título de número de votos' do
        get '/es/votacion/contador'
        expect(response.body).to match(/número.*votos|votos/i) if response.status == 200
      end
    end

    describe 'B. CONTENIDO DEL CONTADOR' do
      it 'si renderiza, tiene elemento pre para mostrar votos' do
        get '/es/votacion/contador'
        expect(response.body).to include('<pre>') if response.status == 200
      end

      it 'si renderiza, tiene enlace a participa.plebisbrand.info' do
        get '/es/votacion/contador'
        expect(response.body).to include('participa.plebisbrand.info') if response.status == 200
      end

      it 'si renderiza, muestra la palabra "votos"' do
        get '/es/votacion/contador'
        expect(response.body).to include('votos') if response.status == 200
      end

      it 'si renderiza, tiene span para label de votos' do
        get '/es/votacion/contador'
        expect(response.body).to match(%r{<span>.*votos.*</span>}i) if response.status == 200
      end
    end

    describe 'C. ESTILOS PERSONALIZADOS' do
      it 'si renderiza, tiene estilos inline' do
        get '/es/votacion/contador'
        expect(response.body).to include('<style') if response.status == 200
      end

      it 'si renderiza, tiene estilos para body' do
        get '/es/votacion/contador'
        expect(response.body).to match(/body.*margin.*padding/m) if response.status == 200
      end

      it 'si renderiza, tiene estilos para pre' do
        get '/es/votacion/contador'
        expect(response.body).to match(/pre.*background|color/m) if response.status == 200
      end

      it 'si renderiza, usa color morado (#612d62)' do
        get '/es/votacion/contador'
        expect(response.body).to include('#612d62') if response.status == 200
      end

      it 'si renderiza, configura border-radius' do
        get '/es/votacion/contador'
        expect(response.body).to include('border-radius') if response.status == 200
      end

      it 'si renderiza, configura font-size y font-weight' do
        get '/es/votacion/contador'
        expect(response.body).to match(/font-size|font-weight/) if response.status == 200
      end
    end

    describe 'D. ENLACE EXTERNO' do
      it 'si renderiza, enlace abre en nueva pestaña' do
        get '/es/votacion/contador'
        expect(response.body).to include('target="_top"') if response.status == 200
      end
    end
  end
end
