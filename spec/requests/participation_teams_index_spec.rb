# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Participation Teams Index', type: :request do
  describe 'GET /es/equipos-participacion' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación' do
        get '/es/equipos-participacion'
        expect(response).to have_http_status(:success)
      end

      it 'muestra título de Equipos de Acción PlebisHubtiva' do
        get '/es/equipos-participacion'
        expect(response.body).to match(/Equipos.*Acción.*PlebisHubtiva/i)
      end

      it 'tiene el title tag correcto' do
        get '/es/equipos-participacion'
        expect(response.body).to match(/<title>.*Equipos/i)
      end
    end

    describe 'B. BOTONES DE PARTICIPACIÓN' do
      before { get '/es/equipos-participacion' }

      it 'renderiza partial wants_participation_buttons' do
        expect(response.body).to include('buttonbox')
      end

      it 'tiene múltiples buttonbox (inicio y final)' do
        buttonbox_count = response.body.scan(/buttonbox/).count
        expect(buttonbox_count).to be >= 2
      end
    end

    describe 'C. INFORMACIÓN SOBRE EQUIPOS DE CAMPAÑA' do
      before { get '/es/equipos-participacion' }

      it 'tiene sección participation_teams_info' do
        expect(response.body).to include('participation_teams_info')
      end

      it 'menciona Equipos de campaña' do
        expect(response.body).to match(/Equipos.*campaña/i)
      end

      it 'menciona elecciones generales' do
        expect(response.body).to match(/elecciones.*generales/i)
      end

      it 'menciona inteligencia colectiva' do
        expect(response.body).to include('inteligencia colectiva')
      end

      it 'invita a incorporarse a equipos' do
        expect(response.body).to match(/Incorpórate|formar parte/i)
      end
    end

    describe 'D. ENLACE A GUÍA' do
      before { get '/es/equipos-participacion' }

      it 'tiene enlace a Guía del Área de PlebisHubción' do
        expect(response.body).to match(/Guía.*Área.*PlebisHubción/i)
      end

      it 'enlace apunta a plebisbrand.info' do
        expect(response.body).to include('plebisbrand.info')
      end
    end

    describe 'E. CONTENIDO EXPLICATIVO' do
      before { get '/es/equipos-participacion' }

      it 'menciona capital económico vs apoyo de personas' do
        expect(response.body).to match(/capital económico|apoyo.*personas/i)
      end

      it 'menciona especificidades locales' do
        expect(response.body).to match(/especificidades locales|municipios.*comunidades/i)
      end

      it 'menciona gente corriente haciendo cosas extraordinarias' do
        expect(response.body).to include('gente corriente haciendo cosas extraordinarias')
      end
    end

    describe 'F. ESTRUCTURA HTML' do
      before { get '/es/equipos-participacion' }

      it 'usa estructura content-content cols' do
        expect(response.body).to include('content-content')
        expect(response.body).to include('cols')
      end

      it 'tiene h2 para título principal' do
        expect(response.body).to match(/<h2>.*Equipos/i)
      end

      it 'tiene h3 para subtítulos' do
        expect(response.body).to include('<h3>')
      end

      it 'usa row con clase justify-texts' do
        expect(response.body).to include('justify-texts')
      end

      it 'tiene múltiples párrafos explicativos' do
        p_count = response.body.scan(/<p>/).count
        expect(p_count).to be >= 3
      end
    end
  end
end
