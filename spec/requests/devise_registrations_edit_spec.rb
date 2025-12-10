# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devise Registrations Edit', type: :request do
  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/perfil' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado', :skip_auth do
        get '/es/users/edit'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. RENDERING BÁSICO CON AUTENTICACIÓN' do
      before do
        sign_in user
        get '/es/users/edit'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'muestra título de datos personales' do
        expect(response.body).to match(/datos.*personales/i)
      end

      it 'tiene el title tag correcto' do
        expect(response.body).to match(/<title>/)
      end
    end

    describe 'C. MENÚ DE NAVEGACIÓN' do
      before do
        sign_in user
        get '/es/users/edit'
      end

      it 'tiene submenu de navegación' do
        expect(response.body).to include('personal-data-submenu')
        expect(response.body).to include('submenu')
      end

      it 'tiene enlace a datos personales' do
        expect(response.body).to match(/datos.*personales/i)
      end

      it 'tiene enlace a cambiar contraseña' do
        expect(response.body).to match(/cambiar.*contraseña|change.*password/i)
      end

      it 'tiene enlace a recuperar contraseña' do
        expect(response.body).to match(/recuperar.*contraseña|recover.*password/i)
      end

      it 'tiene enlace a cambiar email' do
        expect(response.body).to match(/cambiar.*email|change.*email/i)
      end

      it 'tiene enlace a cambiar teléfono' do
        expect(response.body).to match(/cambiar.*teléfono|change.*phone/i)
      end

      it 'tiene enlace a suscripción newsletters' do
        expect(response.body).to match(/newsletters|suscripción/i)
      end

      it 'tiene enlace a información por SMS' do
        expect(response.body).to match(/sms/i)
      end

      it 'tiene enlace a círculo de votación' do
        expect(response.body).to match(/círculo|circle/i)
      end

      it 'tiene enlace a cancelar cuenta' do
        expect(response.body).to match(/cancel.*account|cancelar.*cuenta|baja/i)
      end
    end

    describe 'D. CONTENIDO DE SECCIONES' do
      before do
        sign_in user
        get '/es/users/edit'
      end

      it 'renderiza partial de datos personales' do
        expect(response.body).to include('personal-data')
      end

      it 'renderiza partial de cambiar contraseña' do
        expect(response.body).to include('change-password')
      end

      it 'renderiza partial de recuperar contraseña' do
        expect(response.body).to include('recover-password')
      end

      it 'renderiza partial de cambiar email' do
        expect(response.body).to include('change-email')
      end

      it 'renderiza partial de cancelar cuenta' do
        expect(response.body).to include('cancel-account')
      end

      it 'renderiza partial de newsletters' do
        expect(response.body).to include('newsletters-suscription')
      end

      it 'renderiza partial de SMS' do
        expect(response.body).to include('wants-info-by-sms')
      end
    end

    describe 'E. FUNCIONALIDAD JAVASCRIPT' do
      before do
        sign_in user
        get '/es/users/edit'
      end

      it 'usa clase js-change-tab para navegación' do
        expect(response.body).to include('js-change-tab')
      end

      it 'usa clase js-personal-content para contenido' do
        expect(response.body).to include('js-personal-content')
      end

      it 'marca secciones como invisibles inicialmente' do
        expect(response.body).to include('invisible')
      end

      it 'marca tab activo' do
        expect(response.body).to match(/class=.*active/)
      end
    end

    describe 'F. ESTRUCTURA HTML' do
      before do
        sign_in user
        get '/es/users/edit'
      end

      it 'usa estructura content-content cols' do
        expect(response.body).to include('content-content')
        expect(response.body).to include('cols')
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end

      it 'tiene nav para submenu' do
        expect(response.body).to include('<nav')
      end

      it 'tiene lista ul para navegación' do
        expect(response.body).to include('<ul>')
      end

      it 'tiene divs para cada sección de contenido' do
        div_count = response.body.scan('personal-data-content').count
        expect(div_count).to be >= 1
      end
    end
  end
end
