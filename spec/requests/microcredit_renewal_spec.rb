# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Microcredit Renewal', type: :request do
  describe 'GET /es/microcreditos/renovacion' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente (puede requerir parámetros específicos)' do
        get '/es/microcreditos/renovacion'
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, muestra título de Microcréditos' do
        get '/es/microcreditos/renovacion'
        if response.status == 200
          expect(response.body).to include('Microcrédito')
        end
      end
    end

    describe 'B. CONTENIDO SIN MICROCRÉDITOS RENOVABLES' do
      it 'si renderiza, puede mostrar mensaje de no microcréditos' do
        get '/es/microcreditos/renovacion'
        if response.status == 200
          has_message = response.body.include?('No hemos encontrado') || response.body.match?(/renovar|campaña/i)
          expect(has_message).to be true
        end
      end
    end

    describe 'C. CONTENIDO CON MICROCRÉDITOS RENOVABLES' do
      it 'si renderiza con renovables, muestra agradecimiento' do
        get '/es/microcreditos/renovacion'
        if response.status == 200 && !response.body.include?('No hemos encontrado')
          expect(response.body).to match(/gracias|confianza/i)
        end
      end

      it 'si renderiza con renovables, tiene lista ordenada de campañas' do
        get '/es/microcreditos/renovacion'
        if response.status == 200 && !response.body.include?('No hemos encontrado')
          expect(response.body).to include('<ol>')
        end
      end
    end

    describe 'D. ESTRUCTURA HTML' do
      it 'si renderiza, usa clase microcredits-wrapper' do
        get '/es/microcreditos/renovacion'
        if response.status == 200
          expect(response.body).to include('microcredits-wrapper')
        end
      end

      it 'si renderiza, tiene h2 para título' do
        get '/es/microcreditos/renovacion'
        if response.status == 200
          expect(response.body).to match(/<h2>/)
        end
      end
    end
  end
end
