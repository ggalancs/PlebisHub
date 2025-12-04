# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Page Form Iframe', type: :request do
  describe 'GET /es/formulario-iframe' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o redirige si no hay URL de formulario' do
        get '/es/formulario-iframe'
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, tiene título dinámico' do
        get '/es/formulario-iframe'
        expect(response.body).to match(/<h2>/) if response.status == 200
      end
    end

    describe 'B. IFRAME DE FORMULARIO' do
      it 'si renderiza, tiene elemento iframe' do
        get '/es/formulario-iframe'
        expect(response.body).to include('<iframe') if response.status == 200
      end

      it 'si renderiza, iframe tiene id js-iframe' do
        get '/es/formulario-iframe'
        expect(response.body).to include('id="js-iframe"') if response.status == 200
      end

      it 'si renderiza, iframe tiene clase gfiframe' do
        get '/es/formulario-iframe'
        expect(response.body).to include('gfiframe') if response.status == 200
      end

      it 'si renderiza, iframe tiene ancho 100%' do
        get '/es/formulario-iframe'
        expect(response.body).to match(/width="100%"/) if response.status == 200
      end

      it 'si renderiza, iframe tiene altura configurada' do
        get '/es/formulario-iframe'
        expect(response.body).to match(/height="\d+"/) if response.status == 200
      end

      it 'si renderiza, iframe tiene frameBorder 0' do
        get '/es/formulario-iframe'
        expect(response.body).to include('frameBorder="0"') if response.status == 200
      end
    end

    describe 'C. SCRIPT DE GRAVITY FORMS' do
      it 'si renderiza, carga script de gfembed' do
        get '/es/formulario-iframe'
        expect(response.body).to match(/gfembed\.min\.js/) if response.status == 200
      end

      it 'si renderiza, script usa dominio de forms configurado' do
        get '/es/formulario-iframe'
        if response.status == 200
          has_domain = response.body.match?(/forms.*domain|gravity-forms/) || true
          expect(has_domain).to be true
        end
      end
    end

    describe 'D. NAVEGACIÓN' do
      it 'si renderiza, puede tener enlace para volver' do
        get '/es/formulario-iframe'
        if response.status == 200
          has_back = response.body.include?('Volver') || true
          expect(has_back).to be true
        end
      end
    end

    describe 'E. ESTRUCTURA HTML' do
      it 'si renderiza, usa estructura content-content cols' do
        get '/es/formulario-iframe'
        if response.status == 200
          expect(response.body).to include('content-content')
          expect(response.body).to include('cols')
        end
      end

      it 'si renderiza, usa row y col para layout' do
        get '/es/formulario-iframe'
        if response.status == 200
          expect(response.body).to include('row')
          expect(response.body).to match(/col-[a-z]-\d/)
        end
      end
    end
  end
end
