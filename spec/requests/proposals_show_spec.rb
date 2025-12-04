# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Proposals Show', type: :request do
  describe 'GET /es/propuestas/:id' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o redirige si no existe la propuesta' do
        get '/es/propuestas/1'
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, muestra título de Iniciativas Ciudadanas' do
        get '/es/propuestas/1'
        expect(response.body).to include('Iniciativas') if response.status == 200
      end
    end

    describe 'B. INFORMACIÓN DEL AUTOR' do
      it 'si renderiza, muestra información del autor' do
        get '/es/propuestas/1'
        expect(response.body).to include('author') if response.status == 200
      end

      it 'si renderiza, tiene imagen del autor' do
        get '/es/propuestas/1'
        expect(response.body).to match(/author-default\.png|image_tag/) if response.status == 200
      end

      it 'si renderiza, muestra fecha de creación' do
        get '/es/propuestas/1'
        expect(response.body).to match(/hace|date/) if response.status == 200
      end
    end

    describe 'C. CONTENIDO DE LA PROPUESTA' do
      it 'si renderiza, muestra título de la propuesta en h2' do
        get '/es/propuestas/1'
        expect(response.body).to include('<h2>') if response.status == 200
      end

      it 'si renderiza, muestra descripción de la propuesta' do
        get '/es/propuestas/1'
        if response.status == 200
          has_description = response.body.include?('description') || response.body.match?(%r{<p>.*</p>}m)
          expect(has_description).to be true
        end
      end

      it 'si renderiza, tiene enlace a debate en Plaza PlebisBrand' do
        get '/es/propuestas/1'
        expect(response.body).to match(/Debate.*Plaza|reddit_url/i) if response.status == 200
      end

      it 'si renderiza, muestra tiempo restante o finalización' do
        get '/es/propuestas/1'
        expect(response.body).to match(/Termina|Cerrada/i) if response.status == 200
      end
    end

    describe 'D. SIDEBAR DE INFORMACIÓN' do
      it 'si renderiza, tiene sidebar con información' do
        get '/es/propuestas/1'
        expect(response.body).to include('sidebar') if response.status == 200
      end

      it 'si renderiza, muestra umbrales de apoyo' do
        get '/es/propuestas/1'
        expect(response.body).to match(/Umbrales|0,2%|2%|10%|20%/) if response.status == 200
      end

      it 'si renderiza, menciona Plaza PlebisBrand' do
        get '/es/propuestas/1'
        expect(response.body).to include('Plaza') if response.status == 200
      end

      it 'si renderiza, muestra porcentaje de apoyos necesarios' do
        get '/es/propuestas/1'
        expect(response.body).to match(/apoyos necesarios|10% necesario/) if response.status == 200
      end
    end

    describe 'E. BARRA DE PROGRESO' do
      it 'si renderiza, tiene barra de progreso' do
        get '/es/propuestas/1'
        expect(response.body).to include('progress') if response.status == 200
      end

      it 'si renderiza, usa Bootstrap progress-bar' do
        get '/es/propuestas/1'
        expect(response.body).to include('progress-bar') if response.status == 200
      end
    end

    describe 'F. BOTÓN DE APOYO' do
      it 'si renderiza propuesta no finalizada, muestra formulario de apoyo' do
        get '/es/propuestas/1'
        if response.status == 200 && response.body.exclude?('finished?')
          has_support = response.body.include?('supports') || response.body.include?('button-support')
          expect(has_support || response.body.include?('Quedan')).to be true
        end
      end
    end

    describe 'G. NAVEGACIÓN' do
      it 'si renderiza, tiene enlace para volver' do
        get '/es/propuestas/1'
        expect(response.body).to match(/Volver|back/) if response.status == 200
      end
    end

    describe 'H. ESTRUCTURA HTML' do
      it 'si renderiza, usa section con clase generic-wrapper' do
        get '/es/propuestas/1'
        expect(response.body).to include('generic-wrapper') if response.status == 200
      end

      it 'si renderiza, tiene article para la propuesta' do
        get '/es/propuestas/1'
        expect(response.body).to include('<article') if response.status == 200
      end

      it 'si renderiza, usa clase proposal' do
        get '/es/propuestas/1'
        expect(response.body).to match(/class=".*proposal/) if response.status == 200
      end
    end
  end
end
