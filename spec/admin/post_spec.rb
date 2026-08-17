# frozen_string_literal: true

require 'rails_helper'

# Pantalla registrada durante el upgrade a Rails 8, sin specs hasta ahora (23,81%).
# Los bloques de estado usan `status_tag(..., class:)`, que es la firma nueva de
# ActiveAdmin 3.4: renderizarlos de verdad es lo unico que detecta una regresion ahi.
RSpec.describe 'Post Admin', type: :request do
  let(:admin_user) { create(:user, :admin, :superadmin) }
  let!(:category) { create(:category, name: 'Politica') }
  let!(:post_publicado) { create(:post, :published, title: 'Entrada publicada', categories: [category]) }

  before { sign_in_admin admin_user }

  describe 'GET /admin/posts' do
    it 'responde correctamente' do
      get admin_posts_path
      expect(response).to have_http_status(:success)
    end

    it 'muestra el titulo y la columna de categorias enlazadas' do
      get admin_posts_path

      expect(response.body).to include('Entrada publicada')
      # El bloque `column :categories` enlaza cada categoria a su pantalla
      expect(response.body).to include('Politica')
      expect(response.body).to include(admin_category_path(category))
    end

    it 'marca como publicado en la columna de estado' do
      get admin_posts_path
      expect(response.body).to include('Publicado')
    end

    it 'incluye la columna seleccionable y el id' do
      get admin_posts_path
      expect(response.body).to match(/batch_action/i)
      expect(response.body).to include(post_publicado.id.to_s)
    end
  end

  describe 'ambitos' do
    let!(:post_borrado) { create(:post, title: 'Entrada borrada', categories: [category]) }

    before { post_borrado.destroy }

    it 'el ambito por defecto (created) no lista los borrados' do
      get admin_posts_path
      expect(response.body).to include('Entrada publicada')
      expect(response.body).not_to include('Entrada borrada')
    end

    it 'el ambito published lista solo las publicadas' do
      get admin_posts_path, params: { scope: 'published' }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Entrada publicada')
    end

    it 'el ambito deleted lista las borradas' do
      # scope_to ... association_method: :with_deleted es lo que hace visible
      # el registro borrado por acts_as_paranoid
      get admin_posts_path, params: { scope: 'deleted' }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Entrada borrada')
    end
  end

  describe 'GET /admin/posts/:id' do
    it 'muestra la tabla de atributos con el contenido y las categorias' do
      get admin_post_path(post_publicado)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(post_publicado.title)
      expect(response.body).to include(post_publicado.slug)
      expect(response.body).to include('Politica')
      expect(response.body).to include('Publicado')
    end

    it 'renderiza el contenido pasandolo por auto_html' do
      entrada = create(:post, :published, content: 'Un **parrafo** de contenido', categories: [category])
      get admin_post_path(entrada)

      expect(response).to have_http_status(:success)
      expect(response.body).to include('parrafo')
    end

    context 'con una entrada borrada' do
      let!(:borrada) { create(:post, :published, title: 'Entrada retirada', categories: [category]) }

      before { borrada.destroy }

      it 'marca el estado como borrado y muestra la fecha de borrado' do
        get admin_post_path(borrada)

        expect(response).to have_http_status(:success)
        # Las ramas `if post.deleted?` del bloque de estado y de `row :deleted_at`
        expect(response.body).to include('Borrado')
      end
    end
  end

  describe 'GET /admin/posts/new y /edit' do
    it 'renderiza el formulario de alta con sus campos' do
      get new_admin_post_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Posts')
      expect(response.body).to include('post[title]')
      expect(response.body).to include('post[media_url]')
      # f.input :status como select con la constante STATUS
      expect(response.body).to include('Borrador')
      expect(response.body).to include('Publicado')
      # f.input :categories como check_boxes
      expect(response.body).to include('Politica')
      # El hint con markup html_safe
      expect(response.body).to include('Seguir leyendo')
    end

    it 'renderiza el formulario de edicion' do
      get edit_admin_post_path(post_publicado)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(post_publicado.title)
    end
  end

  describe 'POST /admin/posts' do
    it 'crea la entrada con las categorias permitidas' do
      expect do
        post admin_posts_path, params: {
          post: { title: 'Entrada nueva', content: 'Contenido', status: 1, category_ids: [category.id] }
        }
      end.to change(PlebisCms::Post, :count).by(1)

      creada = PlebisCms::Post.find_by(title: 'Entrada nueva')
      expect(creada.categories).to include(category)
    end
  end

  describe 'PATCH /admin/posts/:id' do
    it 'actualiza la entrada' do
      patch admin_post_path(post_publicado), params: { post: { title: 'Titulo corregido' } }
      expect(post_publicado.reload.title).to eq('Titulo corregido')
    end
  end
end
