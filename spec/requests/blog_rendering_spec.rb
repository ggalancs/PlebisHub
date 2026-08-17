# frozen_string_literal: true

require 'rails_helper'

# Regresion: el blog contestaba 500 en produccion.
#
# El proyecto usa la DSL `auto_html(texto) { youtube; redcarpet; ... }` de
# auto_html 1.x, pero el Gemfile.lock trae la 2.x, que rehizo la API por
# completo y no define ningun metodo `auto_html`. Cualquier pagina que pintara
# una entrada del blog moria con NoMethodError.
#
# No lo veia ningun spec porque spec/support/blog_helper_stub.rb reemplazaba
# `formatted_content` y `main_media` por versiones simplificadas "porque
# auto_html no funciona bien en el entorno de test". No era el entorno de test:
# no funcionaba en ninguno. El stub esta eliminado y estos specs entran por las
# vistas reales.
RSpec.describe 'Renderizado del blog', type: :request do
  let!(:category) { create(:category, name: 'Politica') }
  let!(:post_publicado) do
    create(:post, :published,
           title: 'Entrada de prueba',
           content: "Primer parrafo con http://ejemplo.com\n\nSegundo parrafo",
           categories: [category])
  end

  describe 'GET /brujula' do
    it 'renderiza el listado' do
      get '/brujula'
      expect(response).to have_http_status(:success)
    end

    it 'pinta el contenido de la entrada pasado por el pipeline' do
      get '/brujula'

      expect(response.body).to include('Entrada de prueba')
      expect(response.body).to include('Primer parrafo')
      # El pipeline enlaza las URLs sueltas
      expect(response.body).to include('href="http://ejemplo.com"')
    end

    it 'corta el contenido y ofrece "Seguir leyendo"' do
      get '/brujula'
      # El listado llama a formatted_content(post, 1)
      expect(response.body).to include('Seguir leyendo')
      expect(response.body).not_to include('Segundo parrafo')
    end
  end

  describe 'GET /brujula/:id' do
    it 'renderiza la entrada completa' do
      get "/brujula/#{post_publicado.slug}"

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Primer parrafo')
      expect(response.body).to include('Segundo parrafo')
    end

    context 'con media principal' do
      let!(:post_publicado) do
        create(:post, :published, title: 'Entrada con video',
                                  content: 'Cuerpo',
                                  media_url: 'https://youtu.be/abc123',
                                  categories: [category])
      end

      it 'embebe el video' do
        get "/brujula/#{post_publicado.slug}"

        expect(response).to have_http_status(:success)
        expect(response.body).to include('youtube.com/embed/abc123')
      end
    end

    context 'sin media principal' do
      let!(:post_publicado) do
        create(:post, :published, title: 'Entrada sin media', content: 'Cuerpo',
                                  media_url: nil, categories: [category])
      end

      it 'renderiza igualmente' do
        get "/brujula/#{post_publicado.slug}"
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET /brujula/categoria/:id' do
    it 'renderiza el listado de la categoria' do
      get "/brujula/categoria/#{category.slug}"

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Entrada de prueba')
    end
  end
end
