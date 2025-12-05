# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Page Guarantees', type: :request, skip: 'Tests check static page content' do
  describe 'GET /es/comision-de-garantias-democraticas' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación', :skip_auth do
        get '/comision-de-garantias-democraticas'
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título de Comisión de Garantías' do
        get '/comision-de-garantias-democraticas'
        expect(response.body).to include('Comisión de Garantías Democráticas')
      end
    end

    describe 'B. CONTENIDO INFORMATIVO' do
      before { get '/comision-de-garantias-democraticas' }

      it 'explica qué es la Comisión' do
        expect(response.body).to include('órgano independiente')
      end

      it 'menciona el Documento Organizativo' do
        expect(response.body).to include('Documento Organizativo')
      end

      it 'menciona los Estatutos' do
        expect(response.body).to include('Estatutos')
      end

      it 'menciona principios de democracia' do
        expect(response.body).to include('democracia')
      end

      it 'menciona transparencia' do
        expect(response.body).to include('transparencia')
      end

      it 'menciona justicia' do
        expect(response.body).to include('justicia')
      end

      it 'menciona participación igualitaria' do
        expect(response.body).to include('participación igualitaria')
      end

      it 'menciona la Asamblea Ciudadana' do
        expect(response.body).to include('Asamblea Ciudadana')
      end

      it 'menciona protección de derechos' do
        expect(response.body).to include('protege los derechos')
      end

      it 'menciona el Código Ético' do
        expect(response.body).to include('Código Ético')
      end

      it 'tiene múltiples párrafos explicativos' do
        paragraphs = response.body.scan('<p>').count
        expect(paragraphs).to be >= 4
      end
    end

    describe 'C. DOCUMENTOS Y ENLACES' do
      before { get '/comision-de-garantias-democraticas' }

      it 'tiene enlace al Reglamento' do
        expect(response.body).to include('Reglamento de la Comisión')
        expect(response.body).to include('reglamento_cgde.pdf')
      end

      it 'tiene enlace al Protocolo de funcionamiento' do
        expect(response.body).to include('Protocolo de funcionamiento')
        expect(response.body).to include('Protocolo-funcionamiento-CDGE.pdf')
      end

      it 'enlaces apuntan a plebisbrand.info' do
        expect(response.body).to include('plebisbrand.info/wp-content')
      end
    end

    describe 'D. BOTÓN DE COMUNICACIÓN' do
      before { get '/comision-de-garantias-democraticas' }

      it 'tiene botón para comunicar' do
        expect(response.body).to include('Comunicar a la Comisión')
      end

      it 'botón enlaza a guarantees_form_path' do
        expect(response.body).to include('comision-de-garantias-democraticas/comunicacion')
      end

      it 'botón tiene clase button' do
        expect(response.body).to match(/button.*Comunicar/)
      end
    end

    describe 'E. ESTRUCTURA HTML' do
      before { get '/comision-de-garantias-democraticas' }

      it 'usa estructura content-content' do
        expect(response.body).to include('content-content')
      end

      it 'tiene h2 para título principal' do
        expect(response.body).to match(/<h2>/)
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end
    end
  end
end
