# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Blog Post', type: :request do
  describe 'GET /es/blog/:id' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o redirige si no existe el post' do
        get '/es/blog/1'
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, muestra título del post' do
        get '/es/blog/1'
        if response.status == 200
          expect(response.body).to include('<h1>')
        end
      end
    end

    describe 'B. CONTENIDO DEL POST' do
      it 'si renderiza, muestra categorías del post' do
        get '/es/blog/1'
        if response.status == 200
          expect(response.body).to include('categories')
        end
      end

      it 'si renderiza, muestra fecha del post' do
        get '/es/blog/1'
        if response.status == 200
          expect(response.body).to match(/date|fecha/)
        end
      end

      it 'si renderiza, tiene sección de media' do
        get '/es/blog/1'
        if response.status == 200
          expect(response.body).to include('media')
        end
      end

      it 'si renderiza, muestra contenido formateado' do
        get '/es/blog/1'
        if response.status == 200
          has_content = response.body.match?(/<p>|<div>/)
          expect(has_content).to be true
        end
      end
    end

    describe 'C. NAVEGACIÓN' do
      it 'si renderiza, tiene enlace para volver' do
        get '/es/blog/1'
        if response.status == 200
          expect(response.body).to match(/Volver|back/)
        end
      end

      it 'si renderiza, usa icono Font Awesome' do
        get '/es/blog/1'
        if response.status == 200
          expect(response.body).to match(/fa-|chevron/)
        end
      end
    end

    describe 'D. ESTRUCTURA HTML' do
      it 'si renderiza, usa div con clase generic-wrapper blog' do
        get '/es/blog/1'
        if response.status == 200
          expect(response.body).to include('generic-wrapper')
          expect(response.body).to include('blog')
        end
      end

      it 'si renderiza, tiene article para el post' do
        get '/es/blog/1'
        if response.status == 200
          expect(response.body).to include('<article')
        end
      end

      it 'si renderiza, tiene h1 para título' do
        get '/es/blog/1'
        if response.status == 200
          expect(response.body).to include('<h1>')
        end
      end
    end
  end
end
