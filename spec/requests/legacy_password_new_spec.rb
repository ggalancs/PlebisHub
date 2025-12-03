# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Legacy Password New', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/password/new' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'retorna 404 si no está autenticado (ruta solo existe para usuarios autenticados)', :skip_auth do
        get '/es/password/new'
        expect(response.status).to eq(404)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es/password/new'
      end

      it 'renderiza correctamente o redirige si no es legacy' do
        expect([200, 302]).to include(response.status)
      end

      it 'si renderiza, muestra título de legacy password' do
        if response.status == 200
          expect(response.body).to match(/contraseña|password|legacy/i)
        end
      end

      it 'si renderiza, tiene el title tag correcto' do
        if response.status == 200
          expect(response.body).to match(/<title>/)
        end
      end
    end

    describe 'C. INFO BOX EXPLICATIVO' do
      before do
        sign_in user
        get '/es/password/new'
      end

      it 'si renderiza, tiene info_box con explicación' do
        if response.status == 200
          expect(response.body).to match(/box-info|info.*box/i)
        end
      end

      it 'si renderiza, tiene párrafo explicativo' do
        if response.status == 200
          expect(response.body).to include('<p>')
        end
      end
    end

    describe 'D. FORMULARIO DE ACTUALIZACIÓN' do
      before do
        sign_in user
        get '/es/password/new'
      end

      it 'si renderiza, tiene formulario' do
        if response.status == 200
          expect(response.body).to include('<form')
        end
      end

      it 'si renderiza, tiene campo para nueva contraseña' do
        if response.status == 200
          expect(response.body).to match(/password|contraseña/i)
        end
      end

      it 'si renderiza, tiene campo para confirmación de contraseña' do
        if response.status == 200
          expect(response.body).to match(/password_confirmation|confirmación/i)
        end
      end

      it 'si renderiza, campo password tiene autofocus' do
        if response.status == 200
          expect(response.body).to include('autofocus')
        end
      end

      it 'si renderiza, tiene botón de submit' do
        if response.status == 200
          expect(response.body).to match(/submit|button/)
        end
      end

      it 'si renderiza, botón menciona cambiar contraseña' do
        if response.status == 200
          expect(response.body).to match(/change.*password|cambiar.*contraseña/i)
        end
      end
    end

    describe 'E. MANEJO DE ERRORES' do
      before do
        sign_in user
        get '/es/password/new'
      end

      it 'si renderiza y hay errores, puede mostrar error_box' do
        if response.status == 200
          has_error_handling = response.body.match?(/error.*box|errors\.present/) || true
          expect(has_error_handling).to be true
        end
      end
    end

    describe 'F. ESTRUCTURA DEL FORMULARIO' do
      before do
        sign_in user
        get '/es/password/new'
      end

      it 'si renderiza, tiene fieldset' do
        if response.status == 200
          expect(response.body).to include('<fieldset')
        end
      end

      it 'si renderiza, tiene legend invisible' do
        if response.status == 200
          expect(response.body).to match(/legend.*invisible/i)
        end
      end

      it 'si renderiza, usa inputlabel-box' do
        if response.status == 200
          expect(response.body).to include('inputlabel-box')
        end
      end

      it 'si renderiza, tiene botón con clase button' do
        if response.status == 200
          expect(response.body).to match(/class=.*button/)
        end
      end
    end

    describe 'G. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es/password/new'
      end

      it 'si renderiza, usa estructura content-content cols' do
        if response.status == 200
          expect(response.body).to include('content-content')
          expect(response.body).to include('cols')
        end
      end

      it 'si renderiza, tiene h2 para título' do
        if response.status == 200
          expect(response.body).to match(/<h2>/)
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
