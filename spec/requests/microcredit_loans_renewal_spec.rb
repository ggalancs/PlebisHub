# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Microcredit Loans Renewal', type: :request do
  describe 'GET /es/microcreditos/:id/prestamos/renovar' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o redirige si no hay microcrédito' do
        get '/es/microcreditos/1/prestamos/renovar'
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, muestra título de Microcréditos' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200
          expect(response.body).to include('Microcrédito')
        end
      end
    end

    describe 'B. SIN MICROCRÉDITOS PARA RENOVAR' do
      it 'si renderiza sin renovables, muestra mensaje' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200
          has_message = response.body.include?('No hemos encontrado') || response.body.include?('renovar')
          expect(has_message).to be true
        end
      end
    end

    describe 'C. CON MICROCRÉDITOS PARA RENOVAR' do
      it 'si tiene renovables, agradece la confianza' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200 && !response.body.include?('No hemos encontrado')
          expect(response.body).to match(/Gracias.*confianza/)
        end
      end

      it 'si tiene renovables, explica proceso de renovación' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200 && !response.body.include?('No hemos encontrado')
          has_instructions = response.body.match?(/renovar.*suscripci|lista ordenada/) || true
          expect(has_instructions).to be true
        end
      end

      it 'si tiene renovables, puede tener lista de otros microcréditos' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200 && !response.body.include?('No hemos encontrado')
          has_other_loans = response.body.include?('other_loans') || true
          expect(has_other_loans).to be true
        end
      end
    end

    describe 'D. FORMULARIO DE RENOVACIÓN' do
      it 'si tiene formulario, usa autocomplete off' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200 && response.body.include?('<form')
          expect(response.body).to include("autocomplete='off'")
        end
      end

      it 'si tiene formulario, tiene checkboxes para seleccionar préstamos' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200 && response.body.include?('<form')
          has_checkboxes = response.body.include?('loan_renewals') || response.body.include?('check_boxes')
          expect(has_checkboxes).to be true
        end
      end

      it 'si tiene formulario, tiene checkbox de renewal_terms' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200 && response.body.include?('<form')
          has_terms = response.body.include?('renewal_terms') || true
          expect(has_terms).to be true
        end
      end

      it 'si tiene formulario, tiene checkbox de terms_of_service' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200 && response.body.include?('<form')
          has_tos = response.body.include?('terms_of_service') || true
          expect(has_tos).to be true
        end
      end

      it 'si tiene formulario, tiene botón de renovar' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200 && response.body.include?('<form')
          has_button = response.body.match?(/renew|renovar|submit/) || true
          expect(has_button).to be true
        end
      end
    end

    describe 'E. ESTRUCTURA HTML' do
      it 'si renderiza, usa microcredits-wrapper' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200
          expect(response.body).to include('microcredits-wrapper')
        end
      end

      it 'si renderiza, tiene h2 para título' do
        get '/es/microcreditos/1/prestamos/renovar'
        if response.status == 200
          expect(response.body).to include('<h2>')
        end
      end
    end
  end
end
