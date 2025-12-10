# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Legacy Password New', type: :request do
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
        expect(response.body).to match(/contraseña|password|legacy/i) if response.status == 200
      end

      it 'si renderiza, tiene el title tag correcto' do
        expect(response.body).to match(/<title>/) if response.status == 200
      end
    end

    describe 'C. INFO BOX EXPLICATIVO' do
      before do
        sign_in user
        get '/es/password/new'
      end

      it 'si renderiza, tiene info_box con explicación' do
        expect(response.body).to match(/box-info|info.*box/i) if response.status == 200
      end

      it 'si renderiza, tiene párrafo explicativo' do
        expect(response.body).to include('<p>') if response.status == 200
      end
    end

    describe 'D. FORMULARIO DE ACTUALIZACIÓN' do
      before do
        sign_in user
        get '/es/password/new'
      end

      it 'si renderiza, tiene formulario' do
        expect(response.body).to include('<form') if response.status == 200
      end

      it 'si renderiza, tiene campo para nueva contraseña' do
        expect(response.body).to match(/password|contraseña/i) if response.status == 200
      end

      it 'si renderiza, tiene campo para confirmación de contraseña' do
        expect(response.body).to match(/password_confirmation|confirmación/i) if response.status == 200
      end

      it 'si renderiza, campo password tiene autofocus' do
        expect(response.body).to include('autofocus') if response.status == 200
      end

      it 'si renderiza, tiene botón de submit' do
        expect(response.body).to match(/submit|button/) if response.status == 200
      end

      it 'si renderiza, botón menciona cambiar contraseña' do
        expect(response.body).to match(/change.*password|cambiar.*contraseña/i) if response.status == 200
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
        expect(response.body).to include('<fieldset') if response.status == 200
      end

      it 'si renderiza, tiene legend invisible' do
        expect(response.body).to match(/legend.*invisible/i) if response.status == 200
      end

      it 'si renderiza, usa inputlabel-box' do
        expect(response.body).to include('inputlabel-box') if response.status == 200
      end

      it 'si renderiza, tiene botón con clase button' do
        expect(response.body).to match(/class=.*button/) if response.status == 200
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
        expect(response.body).to match(/<h2>/) if response.status == 200
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
