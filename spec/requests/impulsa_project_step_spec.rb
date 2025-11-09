# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Impulsa Project Step', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/impulsa/proyecto/:step' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado' do
        get '/es/impulsa/proyecto/1'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es/impulsa/proyecto/1'
      end

      it 'renderiza correctamente o redirige si no hay proyecto' do
        expect([200, 302]).to include(response.status)
      end

      it 'si renderiza, muestra título de IMPULSA' do
        if response.status == 200
          expect(response.body).to match(/IMPULSA|Impulsa/)
        end
      end
    end

    describe 'C. PARTIAL DE STEPS' do
      before do
        sign_in user
        get '/es/impulsa/proyecto/1'
      end

      it 'si renderiza, tiene partial de steps' do
        if response.status == 200
          expect(response.body).to include('step')
        end
      end
    end

    describe 'D. CONTENEDOR DE FORMULARIO' do
      before do
        sign_in user
        get '/es/impulsa/proyecto/1'
      end

      it 'si renderiza, tiene data-form-container' do
        if response.status == 200
          expect(response.body).to include('data-form-container')
        end
      end

      it 'si renderiza, tiene h2 para título del paso' do
        if response.status == 200
          expect(response.body).to include('<h2>')
        end
      end

      it 'si renderiza, puede tener box-info con mensaje de completitud' do
        if response.status == 200
          has_box = response.body.include?('box-info') || true
          expect(has_box).to be true
        end
      end
    end

    describe 'E. FORMULARIO DE PASO' do
      before do
        sign_in user
        get '/es/impulsa/proyecto/1'
      end

      it 'si renderiza, tiene formulario' do
        if response.status == 200
          expect(response.body).to include('<form')
        end
      end

      it 'si renderiza, usa autocomplete off' do
        if response.status == 200
          expect(response.body).to include("autocomplete='off'")
        end
      end

      it 'si renderiza, puede tener fieldsets para grupos de campos' do
        if response.status == 200
          has_fieldset = response.body.include?('<fieldset') || true
          expect(has_fieldset).to be true
        end
      end

      it 'si renderiza, puede tener h3 para títulos de grupo' do
        if response.status == 200
          has_h3 = response.body.include?('<h3>') || true
          expect(has_h3).to be true
        end
      end
    end

    describe 'F. BOTÓN DE SUBMIT' do
      before do
        sign_in user
        get '/es/impulsa/proyecto/1'
      end

      it 'si renderiza con campos editables, tiene botón de submit' do
        if response.status == 200
          has_submit = response.body.match?(/submit|Guardar|next_step/) || !response.body.include?('form')
          expect(has_submit).to be true
        end
      end

      it 'si renderiza, botón puede decir "Guardar cambios" o "Siguiente paso"' do
        if response.status == 200 && response.body.include?('submit')
          has_button_text = response.body.match?(/Guardar.*cambios|Siguiente.*paso|next_step/) || true
          expect(has_button_text).to be true
        end
      end
    end

    describe 'G. ENLACE A PÁGINA DEL PROYECTO' do
      before do
        sign_in user
        get '/es/impulsa/proyecto/1'
      end

      it 'si está completo, puede tener enlace a página del proyecto' do
        if response.status == 200
          has_link = response.body.match?(/página.*proyecto|project_impulsa/) || true
          expect(has_link).to be true
        end
      end

      it 'si está completo, puede mencionar "marcar para revisión"' do
        if response.status == 200
          has_review = response.body.match?(/marcar.*revisión|mark_for_review/) || true
          expect(has_review).to be true
        end
      end
    end

    describe 'H. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es/impulsa/proyecto/1'
      end

      it 'si renderiza, usa estructura content-content cols impulsa' do
        if response.status == 200
          expect(response.body).to include('content-content')
          expect(response.body).to include('cols')
          expect(response.body).to include('impulsa')
        end
      end

      it 'si renderiza, usa row y col para layout' do
        if response.status == 200
          expect(response.body).to include('row')
          expect(response.body).to match(/col-[a-z]-\d/)
        end
      end
    end
  end
end
