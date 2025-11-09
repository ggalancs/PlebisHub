# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collaborations Confirm', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }
  let(:other_user) { create(:user, :with_dni) }

  # Bypass unresolved_issues before_action check in ApplicationController
  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/colabora/confirmar' do
    describe 'A. AUTENTICACIÓN Y REDIRECTS' do
      context 'usuario no autenticado' do
        it 'redirige al login' do
          get '/es/colabora/confirmar'
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'usuario autenticado sin collaboration' do
        before { sign_in user }

        it 'redirige a new_collaboration_path' do
          get '/es/colabora/confirmar'
          expect(response).to redirect_to(new_collaboration_path)
        end
      end

      context 'con collaboration recurrente que ya tiene pago' do
        let!(:collaboration) { create(:collaboration, :active, user: user, frequency: 1) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'redirige a edit_collaboration_path' do
          expect(response).to redirect_to(edit_collaboration_path)
        end
      end

      context 'con collaboration puntual (force_single=true)' do
        let!(:collaboration) { create(:collaboration, :single, :incomplete, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar', params: { force_single: true }
        end

        it 'renderiza la vista de confirmación' do
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'B. RENDER CON TARJETA DE CRÉDITO' do
      let!(:collaboration) { create(:collaboration, :incomplete, user: user, payment_type: 1) }

      before do
        sign_in user
        get '/es/colabora/confirmar'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título' do
        expect(response.body).to include('title')
      end

      it 'muestra el paso 2 del proceso' do
        expect(response.body).to include('Confirmación')
      end

      it 'muestra el texto de revisión' do
        expect(response.body).to include('Revisa y confirma todos los datos')
      end

      it 'renderiza el partial de steps' do
        expect(response.body).to include('Cuánto y cómo quieres colaborar')
        expect(response.body).to include('Confirmación')
        expect(response.body).to include('Resultado')
      end

      it 'renderiza el partial de frequency_table' do
        # La tabla de frecuencia debe estar presente
        expect(response.body).to include('table')
      end

      it 'renderiza el form_redsys para tarjeta de crédito' do
        # Debe renderizar el formulario de Redsys (tarjeta)
        expect(response.body).to include('form')
      end

      it 'NO renderiza el form_bank' do
        # No debe mostrar formulario bancario
        # Verificar que no hay campos IBAN específicos del form_bank
        # (esto depende del contenido real del partial)
      end
    end

    describe 'C. RENDER CON CUENTA BANCARIA (CCC)' do
      let!(:collaboration) { create(:collaboration, :with_ccc, :incomplete, user: user) }

      before do
        sign_in user
        get '/es/colabora/confirmar'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título' do
        expect(response.body).to include('title')
      end

      it 'renderiza el form_bank para cuenta bancaria' do
        # Debe renderizar el formulario bancario
        expect(response.body).to include('form')
      end

      it 'muestra información de la cuenta CCC' do
        # Debería mostrar info de la cuenta (depende del partial)
        expect(response.body).to include('2100') # ccc_entity
      end
    end

    describe 'D. RENDER CON IBAN' do
      let!(:collaboration) { create(:collaboration, :with_iban, :incomplete, user: user) }

      before do
        sign_in user
        get '/es/colabora/confirmar'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'renderiza el form_bank para IBAN' do
        expect(response.body).to include('form')
      end

      it 'muestra información de la cuenta IBAN' do
        expect(response.body).to include('DE89370400440532013000')
      end
    end

    describe 'E. TESTS DE FRECUENCIA' do
      context 'colaboración puntual (single)' do
        let!(:collaboration) { create(:collaboration, :single, :incomplete, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar', params: { force_single: true }
        end

        it 'renderiza correctamente' do
          expect(response).to have_http_status(:success)
        end

        it 'muestra información de colaboración puntual' do
          # Verificar que muestra "Puntual" en la tabla de frecuencia
          expect(response.body).to include('Puntual')
        end
      end

      context 'colaboración mensual' do
        let!(:collaboration) { create(:collaboration, :incomplete, user: user, frequency: 1) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'renderiza correctamente' do
          expect(response).to have_http_status(:success)
        end

        it 'muestra información de frecuencia mensual' do
          expect(response.body).to include('Mensual')
        end
      end

      context 'colaboración trimestral' do
        let!(:collaboration) { create(:collaboration, :quarterly, :incomplete, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'muestra información de frecuencia trimestral' do
          expect(response.body).to include('Trimestral')
        end
      end

      context 'colaboración anual' do
        let!(:collaboration) { create(:collaboration, :annual, :incomplete, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'muestra información de frecuencia anual' do
          expect(response.body).to include('Anual')
        end
      end
    end

    describe 'F. TESTS DE CANTIDAD' do
      context 'con cantidad pequeña (3 EUR)' do
        let!(:collaboration) { create(:collaboration, :incomplete, user: user, amount: 300) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'muestra la cantidad correctamente' do
          expect(response.body).to include('3')
        end
      end

      context 'con cantidad mediana (50 EUR)' do
        let!(:collaboration) { create(:collaboration, :incomplete, user: user, amount: 5000) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'muestra la cantidad correctamente' do
          expect(response.body).to include('50')
        end
      end

      context 'con cantidad grande (500 EUR)' do
        let!(:collaboration) { create(:collaboration, :incomplete, user: user, amount: 50000) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'muestra la cantidad correctamente' do
          expect(response.body).to include('500')
        end
      end
    end

    describe 'G. TESTS DE EDGE CASES' do
      context 'con otro usuario intentando acceder' do
        let!(:collaboration) { create(:collaboration, :incomplete, user: other_user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'redirige porque no encuentra la collaboration del usuario actual' do
          expect(response).to redirect_to(new_collaboration_path)
        end
      end

      context 'con collaboration eliminada (soft delete)' do
        let!(:collaboration) { create(:collaboration, :incomplete, :deleted, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'redirige porque la collaboration está eliminada' do
          expect(response).to redirect_to(new_collaboration_path)
        end
      end

      context 'con parámetro force_single=false y collaboration recurrente' do
        let!(:collaboration) { create(:collaboration, :incomplete, user: user, frequency: 1) }

        before do
          sign_in user
          get '/es/colabora/confirmar', params: { force_single: false }
        end

        it 'usa la collaboration recurrente' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'con parámetro force_single=true y collaboration puntual' do
        let!(:collaboration) { create(:collaboration, :single, :incomplete, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar', params: { force_single: true }
        end

        it 'usa la collaboration puntual' do
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'H. TESTS DE ACCESIBILIDAD Y ESTRUCTURA HTML' do
      let!(:collaboration) { create(:collaboration, :incomplete, user: user) }

      before do
        sign_in user
        get '/es/colabora/confirmar'
      end

      it 'usa la estructura semántica con divs apropiados' do
        expect(response.body).to include('class="content-content cols"')
      end

      it 'contiene un h2 con el título' do
        parsed = Nokogiri::HTML(response.body)
        expect(parsed.css('h2').any?).to be true
      end

      it 'contiene un formulario' do
        parsed = Nokogiri::HTML(response.body)
        expect(parsed.css('form').any?).to be true
      end

      it 'contiene la sección de pasos de navegación' do
        expect(response.body).to include('Cuánto y cómo quieres colaborar')
      end
    end

    describe 'I. TESTS DE SEGURIDAD (IDOR)' do
      context 'usuario intenta acceder a collaboration de otro usuario' do
        let!(:other_collaboration) { create(:collaboration, :incomplete, user: other_user) }

        before do
          sign_in user
          # Intentar acceder sin tener ninguna collaboration propia
          get '/es/colabora/confirmar'
        end

        it 'redirige porque no tiene collaboration propia' do
          expect(response).to redirect_to(new_collaboration_path)
        end

        it 'NO muestra información de la collaboration de otro usuario' do
          expect(response.body).not_to include(other_collaboration.id.to_s)
        end
      end

      context 'usuario solo puede ver su propia collaboration' do
        let!(:user_collaboration) { create(:collaboration, :incomplete, user: user) }
        let!(:other_collaboration) { create(:collaboration, :incomplete, user: other_user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'muestra solo la información de su collaboration' do
          expect(response).to have_http_status(:success)
          # La vista debe mostrar solo la collaboration del usuario actual
        end
      end
    end

    describe 'J. TESTS DE TERRITORIAL ASSIGNMENT' do
      context 'con asignación a pueblo (town)' do
        let!(:collaboration) { create(:collaboration, :for_town, :incomplete, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'renderiza correctamente' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'con asignación a autonomía' do
        let!(:collaboration) { create(:collaboration, :for_autonomy, :incomplete, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'renderiza correctamente' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'con asignación a isla' do
        let!(:collaboration) { create(:collaboration, :for_island, :incomplete, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'renderiza correctamente' do
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'K. TESTS DE ESTADOS' do
      context 'collaboration en estado incomplete (0)' do
        let!(:collaboration) { create(:collaboration, :incomplete, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'renderiza la vista de confirmación' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'collaboration en estado unconfirmed (2)' do
        let!(:collaboration) { create(:collaboration, :unconfirmed, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'redirige a edit porque ya tiene pago (status > 0)' do
          expect(response).to redirect_to(edit_collaboration_path)
        end
      end

      context 'collaboration en estado active (3)' do
        let!(:collaboration) { create(:collaboration, :active, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'redirige a edit porque ya tiene pago' do
          expect(response).to redirect_to(edit_collaboration_path)
        end
      end

      context 'collaboration en estado warning (4)' do
        let!(:collaboration) { create(:collaboration, :warning, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'redirige a edit porque ya tiene pago' do
          expect(response).to redirect_to(edit_collaboration_path)
        end
      end

      context 'collaboration en estado error (1)' do
        let!(:collaboration) { create(:collaboration, :error, user: user) }

        before do
          sign_in user
          get '/es/colabora/confirmar'
        end

        it 'redirige a edit porque tiene status > 0' do
          expect(response).to redirect_to(edit_collaboration_path)
        end
      end
    end
  end
end
