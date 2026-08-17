# frozen_string_literal: true

require 'rails_helper'

# La pantalla de Avisos se registro durante el upgrade a Rails 8 y hasta ahora
# no la ejercitaba ningun spec: los bloques de index/show/form solo se ejecutan
# al renderizar, asi que el fichero quedaba al 27% de cobertura y cualquier
# error dentro de esos bloques habria llegado a produccion sin avisar.
RSpec.describe 'Notice Admin', type: :request do
  let(:admin_user) { create(:user, :admin, :superadmin) }
  let!(:notice) { create(:notice, :pending, :with_link, title: 'Aviso de prueba') }

  before { sign_in_admin admin_user }

  describe 'GET /admin/notices' do
    it 'responde correctamente' do
      get admin_notices_path
      expect(response).to have_http_status(:success)
    end

    it 'muestra las columnas title, link y created_at' do
      get admin_notices_path
      expect(response.body).to include('Aviso de prueba')
      expect(response.body).to include(notice.link)
    end

    it 'incluye la columna seleccionable y el id' do
      get admin_notices_path
      expect(response.body).to match(/batch_action/i)
      expect(response.body).to include(notice.id.to_s)
    end

    it 'filtra por titulo' do
      create(:notice, title: 'Otro aviso distinto')
      get admin_notices_path, params: { q: { title_cont: 'Aviso de prueba' } }
      expect(response.body).to include('Aviso de prueba')
      expect(response.body).not_to include('Otro aviso distinto')
    end
  end

  describe 'GET /admin/notices/:id' do
    context 'cuando el aviso todavia no se ha enviado' do
      it 'ofrece el enlace de envio con el recuento de destinatarios' do
        create_list(:notice_registrar, 2)
        get admin_notice_path(notice)

        expect(response).to have_http_status(:success)
        # La rama else del bloque `row :send`
        expect(response.body).to include('Enviar a')
        expect(response.body).to include(broadcast_admin_notice_path(notice))
      end
    end

    context 'cuando el aviso ya se ha enviado' do
      let!(:notice) { create(:notice, :sent, title: 'Aviso ya enviado') }

      it 'muestra el boton deshabilitado' do
        get admin_notice_path(notice)

        # La rama if del bloque `row :send`
        expect(response.body).to include('Ya se ha enviado')
        expect(response.body).not_to include(broadcast_admin_notice_path(notice))
      end
    end

    it 'muestra el resto de filas de la tabla de atributos' do
      get admin_notice_path(notice)
      expect(response.body).to include(notice.title)
      expect(response.body).to include(notice.body)
    end
  end

  describe 'GET /admin/notices/new y /edit' do
    it 'renderiza el formulario de alta' do
      get new_admin_notice_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Aviso')
      expect(response.body).to include('notice[title]')
      expect(response.body).to include('notice[link]')
      expect(response.body).to include('notice[body]')
    end

    it 'renderiza el formulario de edicion' do
      get edit_admin_notice_path(notice)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(notice.title)
    end
  end

  describe 'POST /admin/notices' do
    it 'crea el aviso con los parametros permitidos' do
      expect do
        post admin_notices_path, params: {
          notice: { title: 'Aviso nuevo', body: 'Cuerpo del aviso', link: 'https://example.com/x' }
        }
      end.to change(PlebisCms::Notice, :count).by(1)

      expect(PlebisCms::Notice.find_by(title: 'Aviso nuevo').link).to eq('https://example.com/x')
    end
  end

  describe 'PATCH /admin/notices/:id' do
    it 'actualiza el aviso' do
      patch admin_notice_path(notice), params: { notice: { title: 'Titulo corregido' } }
      expect(notice.reload.title).to eq('Titulo corregido')
    end
  end

  describe 'POST /admin/notices/:id/broadcast' do
    before do
      # broadcast_gcm sale a la red contra GCM: se corta ahi, no en broadcast!,
      # para que el member_action y el update_column del modelo si se ejecuten.
      allow_any_instance_of(PlebisCms::Notice).to receive(:broadcast_gcm)
    end

    it 'envia el aviso y marca sent_at' do
      expect { post broadcast_admin_notice_path(notice) }
        .to change { notice.reload.sent_at }.from(nil)
    end

    it 'redirige a la pantalla de detalle con el mensaje de confirmacion' do
      post broadcast_admin_notice_path(notice)
      expect(response).to redirect_to(admin_notice_path(notice))
      expect(flash[:notice]).to eq('Se ha enviado el Aviso')
    end
  end
end
