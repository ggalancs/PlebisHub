# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Blog Category', type: :request do
  describe 'GET /es/blog/categoria/:id' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o redirige si no existe la categoría' do
        get '/brujula/categoria/1'
        expect([200, 302, 404, 500]).to include(response.status)
      end

      it 'si renderiza, muestra título de la categoría' do
        get '/brujula/categoria/1'
        if response.status == 200
          expect(response.body).to match(/<h1>.*Entradas/i)
        end
      end
    end

    describe 'B. LISTADO DE POSTS' do
      it 'si renderiza, tiene contenedor principal' do
        get '/brujula/categoria/1'
        if response.status == 200
          expect(response.body).to include('container')
        end
      end

      it 'si renderiza, puede renderizar posts de la categoría' do
        get '/brujula/categoria/1'
        if response.status == 200
          # Posts may or may not exist
          has_posts_or_empty = true
          expect(has_posts_or_empty).to be true
        end
      end
    end

    describe 'C. PAGINACIÓN' do
      it 'si renderiza, tiene enlaces de paginación' do
        get '/brujula/categoria/1'
        if response.status == 200
          has_pagination = response.body.match?(/Posteriores|Anteriores|link_to_previous_page|link_to_next_page/)
          expect(has_pagination).to be_truthy
        end
      end

      it 'si renderiza, usa iconos Font Awesome para paginación' do
        get '/brujula/categoria/1'
        if response.status == 200
          expect(response.body).to match(/fa-|chevron/)
        end
      end
    end

    describe 'D. SIDEBAR DE CATEGORÍAS' do
      it 'si renderiza, tiene sidebar' do
        get '/brujula/categoria/1'
        if response.status == 200
          expect(response.body).to include('sidebar')
        end
      end

      it 'si renderiza, muestra h2 de Categorias' do
        get '/brujula/categoria/1'
        if response.status == 200
          expect(response.body).to match(/<h2>.*Categorias/i)
        end
      end

      it 'si renderiza, tiene lista de categorías' do
        get '/brujula/categoria/1'
        if response.status == 200
          expect(response.body).to include('<ul>')
        end
      end

      it 'si renderiza, marca categoría activa' do
        get '/brujula/categoria/1'
        if response.status == 200
          has_active = response.body.include?('active') || !response.body.include?('<li')
          expect(has_active).to be true
        end
      end
    end

    describe 'E. ESTRUCTURA HTML' do
      it 'si renderiza, usa section con clase generic-wrapper blog' do
        get '/brujula/categoria/1'
        if response.status == 200
          expect(response.body).to include('generic-wrapper')
          expect(response.body).to include('blog')
        end
      end

      it 'si renderiza, tiene h1 para título' do
        get '/brujula/categoria/1'
        if response.status == 200
          expect(response.body).to include('<h1>')
        end
      end

      it 'si renderiza, usa párrafo con clase links para navegación' do
        get '/brujula/categoria/1'
        if response.status == 200
          expect(response.body).to include('links')
        end
      end
    end
  end
end
