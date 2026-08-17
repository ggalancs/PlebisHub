# frozen_string_literal: true

require 'rails_helper'

# Pantalla registrada durante el upgrade a Rails 8 y sin specs hasta ahora: se
# quedaba al 15,91% de cobertura, la mas baja del proyecto.
RSpec.describe 'Page Admin', type: :request do
  let(:admin_user) { create(:user, :admin, :superadmin) }
  let!(:page) { create(:page, :promoted, :with_external_link, title: 'Pagina de prueba') }

  before { sign_in_admin admin_user }

  describe 'GET /admin/pages' do
    it 'responde correctamente' do
      get admin_pages_path
      expect(response).to have_http_status(:success)
    end

    it 'muestra las columnas de la tabla' do
      get admin_pages_path
      expect(response.body).to include('Pagina de prueba')
      expect(response.body).to include(page.id_form.to_s)
    end

    it 'enlaza el slug a la pagina publica' do
      get admin_pages_path
      # El bloque `column :slug` construye el enlace a "/#{page.slug}"
      expect(response.body).to include("href=\"/#{page.slug}\"")
    end

    it 'incluye la columna seleccionable y el id' do
      get admin_pages_path
      expect(response.body).to match(/batch_action/i)
      expect(response.body).to include(page.id.to_s)
    end
  end

  describe 'GET /admin/pages/:id' do
    it 'muestra la tabla de atributos completa' do
      get admin_page_path(page)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(page.title)
      expect(response.body).to include(page.slug)
      expect(response.body).to include(page.link)
    end

    it 'ofrece la accion de recargar rutas' do
      get admin_page_path(page)
      # action_item(:reload_routes, only: :show)
      expect(response.body).to include('Recargar rutas')
      expect(response.body).to include(reload_admin_pages_path)
    end
  end

  describe 'GET /admin/pages/new y /edit' do
    it 'renderiza el formulario de alta con sus etiquetas' do
      get new_admin_page_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Formulario de gravity')
      expect(response.body).to include('Título de la página')
      expect(response.body).to include('Slug (dirección de la página)')
      expect(response.body).to include('page[require_login]')
      expect(response.body).to include('page[promoted]')
    end

    it 'renderiza el formulario de edicion' do
      get edit_admin_page_path(page)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(page.title)
    end
  end

  describe 'POST /admin/pages' do
    it 'crea la pagina con los parametros permitidos' do
      expect do
        post admin_pages_path, params: {
          page: { title: 'Pagina nueva', slug: 'pagina-nueva', id_form: 42, priority: 7 }
        }
      end.to change(PlebisCms::Page, :count).by(1)

      creada = PlebisCms::Page.find_by(slug: 'pagina-nueva')
      expect(creada.id_form).to eq(42)
      expect(creada.priority).to eq(7)
    end
  end

  describe 'PATCH /admin/pages/:id' do
    it 'actualiza la pagina' do
      patch admin_page_path(page), params: { page: { title: 'Titulo corregido' } }
      expect(page.reload.title).to eq('Titulo corregido')
    end
  end

  describe 'GET /admin/pages/reload' do
    # El collection_action manda SIGHUP al proceso padre para que recargue las
    # rutas. Sin interceptarlo, el spec se lo mandaria al proceso que ejecuta la
    # suite. Se comprueba que se pide la senal correcta, no que se envie.
    it 'senala al proceso padre para recargar las rutas' do
      expect(Process).to receive(:kill).with('HUP', Process.ppid)
      get reload_admin_pages_path
    end

    it 'redirige al listado avisando de la recarga' do
      allow(Process).to receive(:kill)
      get reload_admin_pages_path

      expect(response).to redirect_to(admin_pages_path)
      expect(flash[:alert]).to eq('Las rutas han sido recargadas.')
    end
  end
end
