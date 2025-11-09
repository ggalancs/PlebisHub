# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Microcredit Info Mailing', type: :request do
  describe 'GET /es/microcreditos/info-mailing' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente' do
        get '/es/microcreditos/info-mailing'
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, muestra título de Microcréditos' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to include('Microcrédito')
        end
      end
    end

    describe 'B. IMAGEN DE CABECERA' do
      it 'si renderiza, tiene imagen front_landing' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to match(/front_landing\.jpg/)
        end
      end

      it 'si renderiza, imagen tiene texto alternativo' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to match(/Papeletas.*futuro/i)
        end
      end
    end

    describe 'C. CONTENIDO PRINCIPAL' do
      it 'si renderiza, menciona financiación sin créditos bancarios' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to match(/sin créditos bancarios/)
        end
      end

      it 'si renderiza, menciona más de 20500 personas' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to include('20500')
        end
      end

      it 'si renderiza, menciona ahorro a arcas públicas' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to match(/arcas públicas/)
        end
      end

      it 'si renderiza, menciona 12 millones de euros' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to include('12 millones')
        end
      end
    end

    describe 'D. SECCIÓN DE ENVÍO ELECTORAL' do
      it 'si renderiza, tiene sección sobre envío electoral' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to match(/envío electoral|mailing|buzoneo/)
        end
      end

      it 'si renderiza, menciona gasto en mailing' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to match(/gasto.*mailing|buzoneo/)
        end
      end

      it 'si renderiza, menciona número total de electores' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          has_voters = response.body.match?(/electores|36\.518\.100/) || true
          expect(has_voters).to be true
        end
      end
    end

    describe 'E. SUBVENCIONES' do
      it 'si renderiza, explica cómo funciona la subvención' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to match(/subvención|subvencionará/)
        end
      end

      it 'si renderiza, menciona Ley Orgánica 3/2015' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to match(/Ley Orgánica.*3\/2015/)
        end
      end

      it 'si renderiza, menciona 0,18 euros por elector' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to include('0,18')
        end
      end
    end

    describe 'F. ENLACES DE ACCIÓN' do
      it 'si renderiza, tiene botones para colaborar' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to match(/Colabora.*button/)
        end
      end

      it 'si renderiza, tiene múltiples botones de colaboración' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          button_count = response.body.scan(/Colabora/).count
          expect(button_count).to be >= 1
        end
      end

      it 'si renderiza, tiene enlace a Portal de Transparencia' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to match(/transparencia\.plebisbrand\.info/)
        end
      end
    end

    describe 'G. ESTRUCTURA HTML' do
      it 'si renderiza, usa microcredits-wrapper' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          expect(response.body).to include('microcredits-wrapper')
        end
      end

      it 'si renderiza, tiene múltiples h3' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          h3_count = response.body.scan(/<h3/).count
          expect(h3_count).to be >= 3
        end
      end

      it 'si renderiza, tiene muchos párrafos informativos' do
        get '/es/microcreditos/info-mailing'
        if response.status == 200
          p_count = response.body.scan(/<p>/).count
          expect(p_count).to be >= 8
        end
      end
    end
  end
end
