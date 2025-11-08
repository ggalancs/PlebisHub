# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Proposals Info', type: :request do
  describe 'GET /es/propuestas/informacion' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación' do
        get '/es/propuestas/informacion'
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título Iniciativas Ciudadanas PlebisBrand' do
        get '/es/propuestas/informacion'
        expect(response.body).to include('Iniciativas Ciudadanas')
      end

      it 'tiene el title tag correcto' do
        get '/es/propuestas/informacion'
        expect(response.body).to match(/<title>.*Iniciativas/i)
      end
    end

    describe 'B. FASES DEL MECANISMO' do
      before { get '/es/propuestas/informacion' }

      it 'muestra título de mecanismo con varias fases' do
        expect(response.body).to match(/mecanismo.*fases/i)
      end

      it 'explica Fase 1: Recogida de propuestas' do
        expect(response.body).to match(/1\..*RECOGIDA.*PROPUESTAS/i)
      end

      it 'explica Fase 2: Apoyo de propuestas' do
        expect(response.body).to match(/2\..*APOYO.*PROPUESTAS/i)
      end

      it 'explica Fase 3: Desarrollo de propuestas' do
        expect(response.body).to match(/3\..*DESARROLLO.*PROPUESTAS/i)
      end

      it 'explica Fase 4: Referéndum vinculante' do
        expect(response.body).to match(/4\..*REFERENDUM.*VINCULANTE/i)
      end
    end

    describe 'C. FASE 1: RECOGIDA DE PROPUESTAS' do
      before { get '/es/propuestas/informacion' }

      it 'menciona Plaza PlebisBrand' do
        expect(response.body).to include('Plaza PlebisBrand')
      end

      it 'menciona umbral de 0,2% de votos positivos' do
        expect(response.body).to include('0,2%')
      end

      it 'tiene enlace a plaza.plebisbrand.info' do
        expect(response.body).to include('plaza.plebisbrand.info')
      end

      it 'menciona portal de participación' do
        expect(response.body).to include('participa.plebisbrand.info')
      end
    end

    describe 'D. FASE 2: APOYO DE PROPUESTAS' do
      before { get '/es/propuestas/informacion' }

      it 'menciona umbral del 2% para correo electrónico' do
        expect(response.body).to include('2%')
      end

      it 'menciona umbral del 10% de inscritos' do
        expect(response.body).to include('10%')
      end

      it 'menciona umbral del 20% de círculos' do
        expect(response.body).to include('20%')
      end

      it 'menciona plazo de 3 meses' do
        expect(response.body).to include('3 meses')
      end
    end

    describe 'E. FASE 3: DESARROLLO DE PROPUESTAS' do
      before { get '/es/propuestas/informacion' }

      it 'menciona grupo de trabajo' do
        expect(response.body).to include('grupo de trabajo')
      end

      it 'menciona plazo de un mes' do
        expect(response.body).to match(/plazo.*un mes/)
      end

      it 'menciona redacción final' do
        expect(response.body).to include('redacción final')
      end
    end

    describe 'F. FASE 4: REFERÉNDUM' do
      before { get '/es/propuestas/informacion' }

      it 'menciona Agora Voting' do
        expect(response.body).to include('Agora Voting')
      end

      it 'menciona votación segura' do
        expect(response.body).to match(/votar.*segura|plataforma/)
      end

      it 'menciona mayoría simple' do
        expect(response.body).to include('mayoría simple')
      end

      it 'menciona que es vinculante' do
        expect(response.body).to match(/vinculante/)
      end
    end

    describe 'G. DOCUMENTO ORGANIZATIVO' do
      before { get '/es/propuestas/informacion' }

      it 'menciona Asamblea Ciudadana' do
        expect(response.body).to include('Asamblea Ciudadana')
      end

      it 'tiene enlace al documento organizativo en PDF' do
        expect(response.body).to include('.pdf')
        expect(response.body).to match(/documento.*organizativo/i)
      end

      it 'indica páginas específicas (42 y 43)' do
        expect(response.body).to match(/página.*42.*43/)
      end
    end

    describe 'H. ESTRUCTURA HTML' do
      before { get '/es/propuestas/informacion' }

      it 'usa div con id info' do
        expect(response.body).to include('id="info"')
      end

      it 'tiene h1 para título principal' do
        expect(response.body).to match(/<h1>.*Iniciativas/i)
      end

      it 'tiene h2 para subtítulo de fases' do
        expect(response.body).to include('<h2>')
      end

      it 'tiene h3 para cada fase' do
        h3_count = response.body.scan(/<h3>/).count
        expect(h3_count).to be >= 4
      end

      it 'tiene múltiples párrafos explicativos' do
        p_count = response.body.scan(/<p>/).count
        expect(p_count).to be >= 5
      end
    end
  end
end
