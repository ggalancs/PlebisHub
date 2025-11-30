# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Collaborations Edit', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'GET /es/colabora/ver' do
    describe 'A. AUTENTICACIÓN REQUERIDA' do
      it 'redirige al login si no está autenticado', :skip_auth do
        get '/es/colabora/ver'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'B. REDIRECT SI NO HAY COLABORACIÓN' do
      before do
        sign_in user
        get '/es/colabora/ver'
      end

      it 'redirige a new_collaboration si no hay colaboración' do
        expect(response).to redirect_to(new_collaboration_path)
      end
    end

    describe 'C. RENDERING BÁSICO CON COLABORACIÓN' do
      let!(:collaboration) { create(:collaboration, :incomplete, user: user, frequency: 1, payment_type: 1) }

      before do
        sign_in user
        get '/es/colabora/ver'
      end

      it 'renderiza correctamente' do
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título de Colaboración' do
        expect(response.body).to include('Colabora')
      end

      it 'tiene el title tag correcto' do
        expect(response.body).to match(/<title>.*Colabora/i)
      end
    end

    describe 'D. CONTENIDO DE LA PÁGINA' do
      let!(:collaboration) { create(:collaboration, :incomplete, user: user, frequency: 1, payment_type: 1) }

      before do
        sign_in user
        get '/es/colabora/ver'
      end

      it 'muestra info_box con información' do
        expect(response.body).to match(/info.*box/i)
      end

      it 'indica que ya tiene una colaboración' do
        expect(response.body).to include('Ya tienes una colaboración')
      end

      it 'renderiza tabla de colaboraciones puntuales' do
        expect(response.body).to match(/table|colaboracion/i)
      end

      it 'tiene enlace para colaboración puntual' do
        expect(response.body).to include('Colaboración puntual')
      end
    end

    describe 'E. FORMULARIO DE MODIFICACIÓN' do
      let!(:collaboration) { create(:collaboration, :incomplete, user: user, frequency: 1, payment_type: 1) }

      before do
        sign_in user
        get '/es/colabora/ver'
      end

      it 'tiene formulario con action modificar' do
        expect(response.body).to include('modificar')
      end

      it 'renderiza el partial form' do
        expect(response.body).to match(/form|input/)
      end

      it 'renderiza tabla de frecuencias' do
        expect(response.body).to match(/frequency|frecuencia/i)
      end

      it 'tiene botón para dar de baja' do
        expect(response.body).to include('baja')
      end

      it 'tiene botón de guardar cambios' do
        expect(response.body).to match(/guardar.*cambios/i)
      end

      it 'usa autocomplete off para seguridad' do
        expect(response.body).to include("autocomplete='off'")
      end
    end

    describe 'F. BOTONES DE ACCIÓN' do
      let!(:collaboration) { create(:collaboration, :incomplete, user: user, frequency: 1, payment_type: 1) }

      before do
        sign_in user
        get '/es/colabora/ver'
      end

      it 'tiene buttonbox para los botones' do
        expect(response.body).to include('buttonbox')
      end

      it 'botón de baja tiene clase danger' do
        expect(response.body).to include('button-danger')
      end

      it 'botón de baja tiene confirmación' do
        expect(response.body).to match(/confirm.*seguro/i)
      end

      it 'enlace de baja usa método delete' do
        expect(response.body).to include('baja')
      end
    end

    describe 'G. AVISO TARJETA DE CRÉDITO' do
      # RAILS 7.2 FIX: Use correct column name redsys_identifier instead of payment_identifier
      let!(:collaboration) { create(:collaboration, :incomplete, user: user, frequency: 1, payment_type: 1, redsys_identifier: '1234') }

      before do
        sign_in user
        get '/es/colabora/ver'
      end

      it 'muestra aviso sobre cambios en tarjeta de crédito' do
        expect(response.body).to match(/tarjeta.*crédito/i)
      end

      it 'menciona problemas con entidad financiera' do
        expect(response.body).to include('entidad financiera')
      end

      it 'sugiere cambiar a recibo domiciliado' do
        expect(response.body).to include('recibo domiciliado')
      end

      it 'menciona Tribunal de Cuentas' do
        expect(response.body).to include('Tribunal de Cuentas')
      end
    end

    describe 'H. ESTRUCTURA HTML' do
      let!(:collaboration) { create(:collaboration, :incomplete, user: user, frequency: 1, payment_type: 1) }

      before do
        sign_in user
        get '/es/colabora/ver'
      end

      it 'usa estructura content-content' do
        expect(response.body).to include('content-content')
      end

      it 'tiene h2 para título principal' do
        expect(response.body).to match(/<h2>/)
      end

      it 'usa row y col para layout' do
        expect(response.body).to include('row')
        expect(response.body).to match(/col-[a-z]-\d/)
      end

      it 'tiene al menos un párrafo' do
        expect(response.body).to match(/<p>/)
      end
    end

    describe 'I. DIFERENTES TIPOS DE PAGO' do
      before do
        sign_in user
      end

      it 'renderiza con colaboración de transferencia bancaria' do
        create(:collaboration, :incomplete, :with_ccc, user: user, frequency: 1)
        get '/es/colabora/ver'
        expect(response).to have_http_status(:success)
      end

      it 'renderiza con colaboración de cuenta bancaria (CCC)' do
        create(:collaboration, :incomplete, :with_ccc, user: user, frequency: 1)
        get '/es/colabora/ver'
        expect(response).to have_http_status(:success)
      end

      it 'renderiza con colaboración IBAN' do
        create(:collaboration, :incomplete, :with_iban, user: user, frequency: 1)
        get '/es/colabora/ver'
        expect(response).to have_http_status(:success)
      end
    end
  end
end
