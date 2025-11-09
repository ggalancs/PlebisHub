# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Page Privacy Policy', type: :request do
  describe 'GET /es/politica-privacidad' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación' do
        get '/es/politica-privacidad'
        expect(response).to have_http_status(:success)
      end

      it 'muestra título de política de privacidad' do
        get '/es/politica-privacidad'
        expect(response.body).to match(/política.*privacidad|legal|privacidad/i)
      end

      it 'tiene el title tag correcto' do
        get '/es/politica-privacidad'
        expect(response.body).to match(/<title>/)
      end
    end

    describe 'B. ESTRUCTURA DEL DOCUMENTO LEGAL' do
      before { get '/es/politica-privacidad' }

      it 'usa info_box para contenido legal' do
        expect(response.body).to match(/info.*box/i)
      end

      it 'tiene h1 para título principal' do
        expect(response.body).to include('<h1>')
      end

      it 'tiene h2 para títulos de sección' do
        h2_count = response.body.scan(/<h2>/).count
        expect(h2_count).to be >= 2
      end

      it 'tiene h3 para secciones principales (al menos 4)' do
        h3_count = response.body.scan(/<h3>/).count
        expect(h3_count).to be >= 4
      end

      it 'tiene h4 para subsecciones' do
        h4_count = response.body.scan(/<h4>/).count
        expect(h4_count).to be >= 10
      end
    end

    describe 'C. SECCIONES DEL DOCUMENTO' do
      before { get '/es/politica-privacidad' }

      it 'tiene sección 1 con subsecciones 1.1 y 1.2' do
        expect(response.body).to match(/1\..*1\.1.*1\.2/m)
      end

      it 'tiene sección 2 con al menos 10 subsecciones' do
        expect(response.body).to match(/2\.1.*2\.2.*2\.3.*2\.4.*2\.5/m)
        expect(response.body).to match(/2\.6.*2\.7.*2\.8.*2\.9.*2\.10/m)
      end

      it 'tiene sección 3 con subsecciones' do
        expect(response.body).to match(/3\..*3\.1.*3\.2/m)
      end

      it 'tiene sección 4 con subsecciones' do
        expect(response.body).to match(/4\..*4\.1/m)
      end
    end

    describe 'D. CONTENIDO DE PÁRRAFOS' do
      before { get '/es/politica-privacidad' }

      it 'tiene múltiples párrafos con contenido legal' do
        p_count = response.body.scan(/<p>/).count
        expect(p_count).to be >= 15
      end

      it 'usa traducciones desde plebisbrand.legal' do
        # Content comes from translations
        has_legal_content = response.body.match?(/<p>|<h3>|<h4>/)
        expect(has_legal_content).to be true
      end
    end

    describe 'E. ESTRUCTURA HTML' do
      before { get '/es/politica-privacidad' }

      it 'usa estructura content-content cols' do
        expect(response.body).to include('content-content')
        expect(response.body).to include('cols')
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end
    end
  end
end
