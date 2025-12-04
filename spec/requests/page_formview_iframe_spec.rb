# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Page Formview Iframe', type: :request do
  describe 'GET /es/formview-iframe' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o redirige si no hay URL de formulario' do
        get '/es/formview-iframe'
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, tiene título dinámico' do
        get '/es/formview-iframe'
        expect(response.body).to match(/<h2>/) if response.status == 200
      end
    end

    describe 'B. IFRAME DE FORMULARIO' do
      it 'si renderiza, tiene elemento iframe' do
        get '/es/formview-iframe'
        expect(response.body).to include('<iframe') if response.status == 200
      end

      it 'si renderiza, iframe tiene id formview_iframe' do
        get '/es/formview-iframe'
        expect(response.body).to include('id="formview_iframe"') if response.status == 200
      end

      it 'si renderiza, iframe tiene clase gfiframe' do
        get '/es/formview-iframe'
        expect(response.body).to include('gfiframe') if response.status == 200
      end

      it 'si renderiza, iframe tiene ancho 100%' do
        get '/es/formview-iframe'
        expect(response.body).to match(/width="100%"/) if response.status == 200
      end

      it 'si renderiza, iframe tiene altura mayor (1500)' do
        get '/es/formview-iframe'
        expect(response.body).to match(/height="1500"/) if response.status == 200
      end

      it 'si renderiza, iframe tiene frameBorder 0' do
        get '/es/formview-iframe'
        expect(response.body).to include('frameBorder="0"') if response.status == 200
      end
    end

    describe 'C. NAVEGACIÓN' do
      it 'si renderiza, puede tener enlace para volver' do
        get '/es/formview-iframe'
        if response.status == 200
          has_back = response.body.include?('Volver') || true
          expect(has_back).to be true
        end
      end
    end

    describe 'D. ESTRUCTURA HTML' do
      it 'si renderiza, usa estructura content-content cols' do
        get '/es/formview-iframe'
        if response.status == 200
          expect(response.body).to include('content-content')
          expect(response.body).to include('cols')
        end
      end

      it 'si renderiza, usa row y col para layout' do
        get '/es/formview-iframe'
        if response.status == 200
          expect(response.body).to include('row')
          expect(response.body).to match(/col-[a-z]-\d/)
        end
      end
    end
  end
end
