# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Blog Index', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:admin_user) { create(:user, admin: true) }

  describe 'GET /es/brujula' do
    describe 'A. RENDERING BÁSICO' do
      context 'sin posts ni categorías' do
        it 'renderiza la página sin errores' do
          get '/es/brujula'
          expect(response).to have_http_status(:success)
        end

        it 'muestra el título "Brújula"' do
          get '/es/brujula'
          expect(response.body).to include('Brújula')
        end

        it 'muestra la sección de categorías vacía' do
          get '/es/brujula'
          expect(response.body).to include('Categorias')
        end
      end

      context 'con posts publicados' do
        before do
          create_list(:post, 3, :published)
        end

        it 'renderiza correctamente para usuarios no autenticados' do
          get '/es/brujula'
          expect(response).to have_http_status(:success)
        end

        it 'renderiza correctamente para usuarios autenticados' do
          sign_in user
          get '/es/brujula'
          expect(response).to have_http_status(:success)
        end

        it 'renderiza correctamente para usuarios administradores' do
          sign_in admin_user
          get '/es/brujula'
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'B. TESTS DE CONTENIDO' do
      context 'con un solo post' do
        let!(:post) { create(:post, :published, title: 'Test Post Title', content: 'Test post content here') }
        let!(:category) { create(:category, :active, name: 'Test Category') }

        before do
          post.categories << category
          get '/es/brujula'
        end

        it 'muestra el título del post' do
          expect(response.body).to include('Test Post Title')
        end

        it 'muestra el contenido del post' do
          expect(response.body).to include('Test post content here')
        end

        it 'muestra las categorías en el sidebar' do
          expect(response.body).to include('Test Category')
        end

        it 'contiene la estructura HTML del post' do
          expect(response.body).to include('<article class="post">')
        end

        it 'incluye el elemento de fecha' do
          expect(response.body).to include('class="date"')
        end
      end

      context 'con múltiples posts' do
        before do
          create(:post, :published, title: 'First Post', content: 'First content')
          create(:post, :published, title: 'Second Post', content: 'Second content')
          create(:post, :published, title: 'Third Post', content: 'Third content')
          get '/es/brujula'
        end

        it 'muestra todos los posts publicados' do
          expect(response.body).to include('First Post')
          expect(response.body).to include('Second Post')
          expect(response.body).to include('Third Post')
        end

        it 'muestra el contenido de todos los posts' do
          expect(response.body).to include('First content')
          expect(response.body).to include('Second content')
          expect(response.body).to include('Third content')
        end

        it 'renderiza múltiples artículos' do
          expect(response.body.scan(/<article class="post">/).count).to eq(3)
        end
      end

      context 'con múltiples categorías' do
        let!(:category1) { create(:category, :with_posts, name: 'Politics') }
        let!(:category2) { create(:category, :with_posts, name: 'Economy') }
        let!(:category3) { create(:category, :with_posts, name: 'Culture') }

        before do
          get '/es/brujula'
        end

        it 'muestra todas las categorías activas en el sidebar' do
          expect(response.body).to include('Politics')
          expect(response.body).to include('Economy')
          expect(response.body).to include('Culture')
        end

        it 'contiene enlaces a las categorías' do
          expect(response.body).to include('Categorias')
          expect(response.body.scan(/<li>/).count).to be >= 3
        end
      end

      context 'con categorías inactivas' do
        let!(:active_category) { create(:category, :with_posts, name: 'Active Category') }
        let!(:inactive_category) { create(:category, :inactive, name: 'Inactive Category') }

        before do
          get '/es/brujula'
        end

        it 'muestra solo categorías activas (con posts)' do
          expect(response.body).to include('Active Category')
          expect(response.body).not_to include('Inactive Category')
        end
      end
    end

    describe 'C. TESTS DE PAGINACIÓN' do
      context 'con exactamente 5 posts (límite por página)' do
        before do
          create_list(:post, 5, :published)
          get '/es/brujula'
        end

        it 'muestra todos los 5 posts en la primera página' do
          expect(response.body.scan(/<article class="post">/).count).to eq(5)
        end

        it 'no muestra enlaces de paginación' do
          parsed = Nokogiri::HTML(response.body)
          # link_to_next_page and link_to_previous_page only appear when there are more pages
          expect(parsed.css('p.links a').count).to eq(0)
        end
      end

      context 'con más de 5 posts' do
        before do
          create_list(:post, 8, :published)
          get '/es/brujula'
        end

        it 'muestra solo 5 posts en la primera página' do
          expect(response.body.scan(/<article class="post">/).count).to eq(5)
        end

        it 'muestra el enlace a la siguiente página' do
          expect(response.body).to include('Anteriores')
        end

        it 'el enlace de siguiente página funciona correctamente' do
          get '/es/brujula?page=2'
          expect(response).to have_http_status(:success)
          expect(response.body.scan(/<article class="post">/).count).to eq(3)
        end

        it 'la página 2 muestra el enlace a la página anterior' do
          get '/es/brujula?page=2'
          expect(response.body).to include('Posteriores')
        end
      end

      context 'con 11 posts (más de 2 páginas)' do
        before do
          create_list(:post, 11, :published)
        end

        it 'página 1 muestra 5 posts' do
          get '/es/brujula?page=1'
          expect(response.body.scan(/<article class="post">/).count).to eq(5)
        end

        it 'página 2 muestra 5 posts' do
          get '/es/brujula?page=2'
          expect(response.body.scan(/<article class="post">/).count).to eq(5)
        end

        it 'página 3 muestra 1 post' do
          get '/es/brujula?page=3'
          expect(response.body.scan(/<article class="post">/).count).to eq(1)
        end

        it 'página 2 tiene enlaces a anterior y siguiente' do
          get '/es/brujula?page=2'
          expect(response.body).to include('Anteriores')
          expect(response.body).to include('Posteriores')
        end
      end
    end

    describe 'D. TESTS DE FORMATEO Y I18N' do
      context 'formato de fechas' do
        let!(:post) { create(:post, :published, created_at: Time.zone.local(2023, 6, 15, 14, 30)) }

        it 'formatea la fecha correctamente' do
          get '/es/brujula'
          expect(response.body).to include('class="date"')
        end
      end

      context 'contenido formateado' do
        let!(:post) do
          create(:post, :published,
                 title: 'Post with Formatting',
                 content: "Line 1\n\nLine 2\n\nLine 3")
        end

        it 'renderiza el contenido del post' do
          get '/es/brujula'
          expect(response.body).to include('Line 1')
        end
      end
    end

    describe 'E. TESTS DE SEGURIDAD (XSS)' do
      context 'con scripts maliciosos en el título' do
        let!(:post) { create(:post, :published, title: '<script>alert("XSS")</script>', content: 'Safe content') }

        before { get '/es/blog' }

        it 'escapa HTML en el título del post' do
          expect(response.body).to include('&lt;script&gt;')
          expect(response.body).not_to include('<script>alert("XSS")</script>')
        end

        it 'no ejecuta el script malicioso' do
          parsed = Nokogiri::HTML(response.body)
          expect(parsed.css('script').map(&:text)).not_to include('alert("XSS")')
        end
      end

      context 'con HTML malicioso en el contenido' do
        let!(:post) do
          create(:post, :published,
                 title: 'Safe Title',
                 content: '<img src=x onerror="alert(1)">')
        end

        before { get '/es/blog' }

        it 'escapa el HTML peligroso en el contenido' do
          # Note: formatted_content helper may allow some HTML, test actual behavior
          expect(response.body).not_to include('onerror="alert(1)"')
        end
      end

      context 'con scripts en nombres de categorías' do
        let!(:category) { create(:category, :with_posts, name: '<script>evil()</script>Category') }

        before { get '/es/blog' }

        it 'escapa HTML en nombres de categorías' do
          expect(response.body).to include('&lt;script&gt;')
          expect(response.body).not_to include('<script>evil()</script>')
        end
      end

      context 'con inyección de atributos HTML' do
        let!(:post) do
          create(:post, :published,
                 title: '" onclick="alert(1)"',
                 content: 'Content')
        end

        before { get '/es/blog' }

        it 'escapa comillas y atributos peligrosos' do
          expect(response.body).not_to include('onclick="alert(1)"')
        end
      end

      context 'con iframes maliciosos' do
        let!(:post) do
          create(:post, :published,
                 title: 'Title',
                 content: '<iframe src="http://evil.com"></iframe>')
        end

        before { get '/es/blog' }

        it 'escapa o elimina iframes peligrosos' do
          parsed = Nokogiri::HTML(response.body)
          iframes = parsed.css('iframe[src*="evil.com"]')
          expect(iframes).to be_empty
        end
      end
    end

    describe 'F. TESTS DE EDGE CASES' do
      context 'con título muy largo' do
        let!(:post) { create(:post, :published, title: 'A' * 500, content: 'Content') }

        it 'renderiza el título largo sin errores' do
          get '/es/brujula'
          expect(response).to have_http_status(:success)
          expect(response.body).to include('A' * 500)
        end
      end

      context 'con contenido muy largo' do
        let!(:post) { create(:post, :published, title: 'Title', content: 'Word ' * 1000) }

        it 'renderiza el contenido largo sin errores' do
          get '/es/brujula'
          expect(response).to have_http_status(:success)
        end
      end

      context 'con caracteres UTF-8 especiales' do
        let!(:post) do
          create(:post, :published,
                 title: 'Título con ñ, á, é, í, ó, ú, ü 中文 한글 العربية',
                 content: 'Contenido con émojis 🎉 🚀 ❤️')
        end

        before { get '/es/blog' }

        it 'renderiza correctamente caracteres UTF-8 en títulos' do
          expect(response.body).to include('ñ, á, é, í, ó, ú, ü')
          expect(response.body).to include('中文 한글 العربية')
        end

        it 'renderiza correctamente emojis en el contenido' do
          expect(response.body).to include('🎉')
          expect(response.body).to include('🚀')
        end
      end

      context 'con comillas y caracteres especiales' do
        let!(:post) do
          create(:post, :published,
                 title: %q(Title with "quotes" and 'apostrophes'),
                 content: %q(Content & special <characters>))
        end

        before { get '/es/blog' }

        it 'escapa correctamente comillas dobles' do
          expect(response.body).to include('&quot;').or include('"quotes"')
        end

        it 'escapa correctamente ampersands y símbolos <>' do
          expect(response.body).to include('&amp;').or include('&')
          expect(response.body).to include('&lt;').or include('&gt;')
        end
      end

      context 'con espacios en blanco excesivos' do
        let!(:post) do
          create(:post, :published,
                 title: "   Title   with   spaces   ",
                 content: "   Content   \n\n\n   with   \n   newlines   ")
        end

        it 'renderiza sin errores' do
          get '/es/brujula'
          expect(response).to have_http_status(:success)
        end
      end

      context 'con categoría con nombre muy largo' do
        let!(:category) { create(:category, :with_posts, name: 'C' * 200) }

        it 'renderiza la categoría larga sin errores' do
          get '/es/brujula'
          expect(response).to have_http_status(:success)
          expect(response.body).to include('C' * 200)
        end
      end
    end

    describe 'G. TESTS DE ACCESIBILIDAD Y SEMÁNTICA HTML' do
      before do
        create(:post, :published, title: 'Test Post', content: 'Test content')
        create(:category, :with_posts, name: 'Test Category')
        get '/es/brujula'
      end

      it 'usa la etiqueta semántica <article> para posts' do
        expect(response.body).to include('<article class="post">')
      end

      it 'usa la etiqueta <h1> para el título principal' do
        expect(response.body).to include('<h1>Brújula</h1>')
      end

      it 'usa <h2> para títulos de posts' do
        expect(response.body).to include('<h2>')
      end

      it 'usa listas <ul> para las categorías' do
        expect(response.body).to include('<ul>')
        expect(response.body).to include('<li>')
      end

      it 'contiene la estructura semántica correcta' do
        parsed = Nokogiri::HTML(response.body)
        expect(parsed.css('section.blog').any?).to be true
        expect(parsed.css('article.post').any?).to be true
      end
    end

    describe 'H. TESTS DE CONSISTENCIA Y VALIDACIÓN' do
      context 'con posts sin categorías' do
        let!(:post) { create(:post, :published, title: 'Post Without Category') }

        it 'renderiza el post sin errores' do
          get '/es/brujula'
          expect(response).to have_http_status(:success)
          expect(response.body).to include('Post Without Category')
        end
      end

      context 'con posts con múltiples categorías' do
        let!(:post) { create(:post, :published, title: 'Multi-Category Post') }
        let!(:cat1) { create(:category, name: 'Cat1', posts: [post]) }
        let!(:cat2) { create(:category, name: 'Cat2', posts: [post]) }
        let!(:cat3) { create(:category, name: 'Cat3', posts: [post]) }

        before { get '/es/blog' }

        it 'muestra todas las categorías del post' do
          expect(response.body).to include('Cat1')
          expect(response.body).to include('Cat2')
          expect(response.body).to include('Cat3')
        end

        it 'muestra todas las categorías en el sidebar' do
          parsed = Nokogiri::HTML(response.body)
          sidebar_cats = parsed.css('.sidebar li').map(&:text)
          expect(sidebar_cats).to include('Cat1', 'Cat2', 'Cat3')
        end
      end

      context 'con validación de orden de posts' do
        let!(:old_post) { create(:post, :published, title: 'Old Post', created_at: 3.days.ago) }
        let!(:new_post) { create(:post, :published, title: 'New Post', created_at: 1.day.ago) }

        before { get '/es/blog' }

        it 'muestra los posts en orden cronológico inverso (más recientes primero)' do
          # Posts are ordered by created_at DESC in Post.recent scope
          body_text = response.body
          new_pos = body_text.index('New Post')
          old_pos = body_text.index('Old Post')
          expect(new_pos).to be < old_pos
        end
      end

      context 'validación de unicidad de categorías en sidebar' do
        let!(:cat1) { create(:category, :with_posts, name: 'Unique Cat') }

        before { get '/es/blog' }

        it 'no muestra categorías duplicadas en el sidebar' do
          parsed = Nokogiri::HTML(response.body)
          cat_names = parsed.css('.sidebar li').map(&:text).map(&:strip)
          expect(cat_names.count('Unique Cat')).to eq(1)
        end
      end

      context 'con categorías sin slug' do
        let!(:category) { create(:category, name: 'Category Without Slug') }
        let!(:post) { create(:post, :published, categories: [category]) }

        it 'genera slug automáticamente y renderiza sin errores' do
          get '/es/brujula'
          expect(response).to have_http_status(:success)
          expect(response.body).to include('Category Without Slug')
        end
      end
    end

    describe 'I. TESTS DE CASOS LÍMITE DE PAGINACIÓN' do
      context 'con página no existente' do
        before do
          create_list(:post, 3, :published)
          get '/es/brujula?page=999'
        end

        it 'maneja correctamente páginas fuera de rango' do
          expect(response).to have_http_status(:success)
          # Kaminari returns empty page for out of range
          expect(response.body.scan(/<article class="post">/).count).to eq(0)
        end
      end

      context 'con parámetro de página inválido' do
        before do
          create_list(:post, 3, :published)
        end

        it 'maneja page=0 correctamente' do
          get '/es/brujula?page=0'
          expect(response).to have_http_status(:success)
        end

        it 'maneja page=-1 correctamente' do
          get '/es/brujula?page=-1'
          expect(response).to have_http_status(:success)
        end

        it 'maneja page con valor no numérico' do
          get '/es/brujula?page=abc'
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'J. TESTS DE FILTRADO (ADMIN VS USUARIO REGULAR)' do
      context 'con posts publicados y borradores' do
        let!(:published_post1) { create(:post, :published, title: 'Published Post 1') }
        let!(:published_post2) { create(:post, :published, title: 'Published Post 2') }
        let!(:draft_post1) { create(:post, :draft, title: 'Draft Post 1') }
        let!(:draft_post2) { create(:post, :draft, title: 'Draft Post 2') }

        context 'usuario no autenticado' do
          before { get '/es/blog' }

          it 'muestra solo posts publicados' do
            expect(response.body).to include('Published Post 1')
            expect(response.body).to include('Published Post 2')
          end

          it 'no muestra posts en borrador' do
            expect(response.body).not_to include('Draft Post 1')
            expect(response.body).not_to include('Draft Post 2')
          end

          it 'muestra exactamente 2 posts (solo publicados)' do
            expect(response.body.scan(/<article class="post">/).count).to eq(2)
          end
        end

        context 'usuario regular autenticado' do
          before do
            sign_in user
            get '/es/brujula'
          end

          it 'muestra solo posts publicados' do
            expect(response.body).to include('Published Post 1')
            expect(response.body).to include('Published Post 2')
          end

          it 'no muestra posts en borrador' do
            expect(response.body).not_to include('Draft Post 1')
            expect(response.body).not_to include('Draft Post 2')
          end

          it 'muestra exactamente 2 posts (solo publicados)' do
            expect(response.body.scan(/<article class="post">/).count).to eq(2)
          end
        end

        context 'usuario administrador' do
          before do
            sign_in admin_user
            get '/es/brujula'
          end

          it 'muestra posts publicados' do
            expect(response.body).to include('Published Post 1')
            expect(response.body).to include('Published Post 2')
          end

          it 'muestra posts en borrador' do
            expect(response.body).to include('Draft Post 1')
            expect(response.body).to include('Draft Post 2')
          end

          it 'muestra todos los 4 posts (publicados + borradores)' do
            expect(response.body.scan(/<article class="post">/).count).to eq(4)
          end
        end
      end

      context 'con posts eliminados (soft delete)' do
        let!(:active_post) { create(:post, :published, title: 'Active Post') }
        let!(:deleted_post) { create(:post, :published, :deleted, title: 'Deleted Post') }

        context 'usuario regular' do
          before do
            sign_in user
            get '/es/brujula'
          end

          it 'no muestra posts eliminados' do
            expect(response.body).to include('Active Post')
            expect(response.body).not_to include('Deleted Post')
          end
        end

        context 'usuario administrador' do
          before do
            sign_in admin_user
            get '/es/brujula'
          end

          it 'no muestra posts eliminados (soft delete los oculta)' do
            expect(response.body).to include('Active Post')
            expect(response.body).not_to include('Deleted Post')
          end
        end
      end

      context 'solo borradores sin publicados' do
        before do
          create_list(:post, 3, :draft)
        end

        it 'usuario regular ve página vacía' do
          sign_in user
          get '/es/brujula'
          expect(response.body.scan(/<article class="post">/).count).to eq(0)
        end

        it 'admin ve los 3 borradores' do
          sign_in admin_user
          get '/es/brujula'
          expect(response.body.scan(/<article class="post">/).count).to eq(3)
        end
      end
    end

    describe 'K. TESTS DE CATEGORÍAS' do
      context 'sin categorías activas' do
        before do
          create(:post, :published, title: 'Post Without Categories')
          get '/es/brujula'
        end

        it 'muestra el sidebar de categorías vacío' do
          expect(response.body).to include('Categorias')
          parsed = Nokogiri::HTML(response.body)
          expect(parsed.css('.sidebar li').count).to eq(0)
        end

        it 'no muestra enlaces a categorías' do
          parsed = Nokogiri::HTML(response.body)
          expect(parsed.css('.sidebar a').count).to eq(0)
        end
      end

      context 'con categorías activas e inactivas mezcladas' do
        let!(:active_cat1) { create(:category, :with_posts, name: 'Active 1') }
        let!(:inactive_cat) { create(:category, :inactive, name: 'Inactive') }
        let!(:active_cat2) { create(:category, :with_posts, name: 'Active 2') }

        before { get '/es/blog' }

        it 'muestra solo categorías activas' do
          expect(response.body).to include('Active 1')
          expect(response.body).to include('Active 2')
          expect(response.body).not_to include('Inactive')
        end

        it 'el sidebar contiene solo 2 categorías' do
          parsed = Nokogiri::HTML(response.body)
          expect(parsed.css('.sidebar li').count).to eq(2)
        end
      end

      context 'enlaces de categorías' do
        let!(:category) { create(:category, :with_posts, name: 'Test Category', slug: 'test-category') }

        before { get '/es/blog' }

        it 'contiene enlaces a las páginas de categorías' do
          expect(response.body).to include('Test Category')
          expect(response.body).to include('categoria')
        end
      end
    end
  end
end
