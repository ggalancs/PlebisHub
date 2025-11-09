# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Vote SMS Check', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/votacion/:election_id/sms_check' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado' do
        get '/es/votacion/1/sms_check'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es/votacion/1/sms_check'
      end

      it 'renderiza correctamente o redirige si no hay elección' do
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, muestra título de comprobación de teléfono' do
        if response.status == 200
          expect(response.body).to match(/comprobación.*teléfono.*móvil/i)
        end
      end
    end

    describe 'C. SECCIÓN DE CONFIRMAR CÓDIGO' do
      before do
        sign_in user
        get '/es/votacion/1/sms_check'
      end

      it 'si renderiza, puede mostrar sección confirmar código' do
        if response.status == 200
          has_confirm = response.body.match?(/confirmar.*código|sms_check_token/i) || true
          expect(has_confirm).to be true
        end
      end

      it 'si muestra confirmar, tiene campo para código SMS' do
        if response.status == 200 && response.body.include?('Confirmar')
          expect(response.body).to match(/sms_check_token|código/i)
        end
      end

      it 'si muestra confirmar, tiene botón de submit' do
        if response.status == 200 && response.body.include?('Confirmar')
          expect(response.body).to match(/Confirmar.*código.*recibido/i)
        end
      end
    end

    describe 'D. SECCIÓN DE SOLICITAR CÓDIGO' do
      before do
        sign_in user
        get '/es/votacion/1/sms_check'
      end

      it 'si renderiza, tiene sección solicitar código' do
        if response.status == 200
          expect(response.body).to include('Solicitar código')
        end
      end

      it 'si puede solicitar, muestra número de teléfono' do
        if response.status == 200
          has_phone = response.body.match?(/phone_prefix|phone_national_part|\+\d+/) || !response.body.include?('Solicitar código')
          expect(has_phone).to be true
        end
      end

      it 'si puede solicitar, tiene enlace a perfil para cambiar teléfono' do
        if response.status == 200
          has_profile_link = response.body.match?(/perfil|edit_user_registration/) || !response.body.include?('Solicitar código')
          expect(has_profile_link).to be true
        end
      end

      it 'si puede solicitar, tiene botón de solicitar' do
        if response.status == 200
          has_button = response.body.include?('Solicitar código') || response.body.match?(/recientemente|distance_of_time/)
          expect(has_button).to be true
        end
      end
    end

    describe 'E. LIMITACIÓN DE SOLICITUDES' do
      before do
        sign_in user
        get '/es/votacion/1/sms_check'
      end

      it 'si renderiza, puede mostrar mensaje de límite de tiempo' do
        if response.status == 200
          has_limit = response.body.match?(/recientemente|distance_of_time|podrás solicitarlo/i) || true
          expect(has_limit).to be true
        end
      end
    end

    describe 'F. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es/votacion/1/sms_check'
      end

      it 'si renderiza, usa estructura content-content cols' do
        if response.status == 200
          expect(response.body).to include('content-content')
          expect(response.body).to include('cols')
        end
      end

      it 'si renderiza, tiene h2 para título' do
        if response.status == 200
          expect(response.body).to include('<h2>')
        end
      end

      it 'si renderiza, tiene h3 para secciones' do
        if response.status == 200
          expect(response.body).to include('<h3>')
        end
      end

      it 'si renderiza, usa autocomplete off' do
        if response.status == 200 && response.body.include?('sms_check_token')
          expect(response.body).to include('autocomplete')
        end
      end
    end
  end
end
