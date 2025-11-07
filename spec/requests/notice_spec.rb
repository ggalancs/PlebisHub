# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Notice Index', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }

  describe 'GET /notice' do
    describe 'A. AUTENTICACIÓN Y RENDERING BÁSICO' do
      context 'cuando el usuario no está autenticado' do
        it 'redirige a la página de login' do
          get '/notice'
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'no renderiza la vista' do
          get '/notice'
          expect(response).not_to have_http_status(:success)
        end
      end

      context 'cuando el usuario está autenticado' do
        before { sign_in user }

        context 'con notificaciones' do
          let!(:notice) { create(:notice, :sent_active, title: 'Test Notice', body: 'Test Body') }

          before { get '/notice' }

          it 'retorna http success' do
            expect(response).to have_http_status(:success)
          end

          it 'usa la estructura HTML correcta con content-content' do
            expect(response.body).to have_css('div.content-content.cols')
          end

          it 'contiene un div.row' do
            expect(response.body).to have_css('div.row')
          end

          it 'contiene un div con clase col-b-4a12' do
            expect(response.body).to have_css('div.col-b-4a12')
          end

          it 'contiene un div.box para la notificación' do
            expect(response.body).to have_css('div.box')
          end

          it 'contiene un div.box-notif dentro de cada box' do
            expect(response.body).to have_css('div.box div.box-notif')
          end
        end

        context 'sin notificaciones' do
          before { get '/notice' }

          it 'renderiza exitosamente sin errores' do
            expect(response).to have_http_status(:success)
          end

          it 'mantiene la estructura HTML base' do
            expect(response.body).to have_css('div.content-content.cols')
            expect(response.body).to have_css('div.row')
            expect(response.body).to have_css('div.col-b-4a12')
          end

          it 'no muestra ningún div.box' do
            expect(response.body).not_to have_css('div.box')
          end

          it 'no muestra ningún div.box-notif' do
            expect(response.body).not_to have_css('div.box-notif')
          end
        end
      end
    end

    describe 'B. TESTS DE CONTENIDO' do
      before { sign_in user }

      context 'con una sola notificación' do
        let!(:notice) do
          create(:notice, :sent_active,
                 title: 'Importante: Mantenimiento del Sistema',
                 body: 'El sistema estará en mantenimiento el próximo domingo.')
        end

        before { get '/notice' }

        it 'muestra el título de la notificación' do
          expect(response.body).to have_content('Importante: Mantenimiento del Sistema')
        end

        it 'muestra el título en negrita (strong)' do
          expect(response.body).to have_css('strong', text: 'Importante: Mantenimiento del Sistema')
        end

        it 'muestra el cuerpo de la notificación' do
          expect(response.body).to have_content('El sistema estará en mantenimiento el próximo domingo.')
        end

        it 'muestra la fecha de creación formateada' do
          expect(response.body).to have_css('p.date')
        end

        it 'el título está en un párrafo dentro de box-notif' do
          expect(response.body).to have_css('div.box-notif p strong', text: 'Importante: Mantenimiento del Sistema')
        end

        it 'el cuerpo está en un párrafo dentro de box-notif' do
          expect(response.body).to have_css('div.box-notif p', text: 'El sistema estará en mantenimiento el próximo domingo.')
        end

        it 'la fecha está en un párrafo con clase date' do
          expect(response.body).to have_css('div.box-notif p.date')
        end
      end

      context 'con múltiples notificaciones' do
        let!(:notice1) do
          create(:notice, :sent_active,
                 title: 'Primera Notificación',
                 body: 'Contenido de la primera notificación',
                 created_at: 2.hours.ago)
        end
        let!(:notice2) do
          create(:notice, :sent_active,
                 title: 'Segunda Notificación',
                 body: 'Contenido de la segunda notificación',
                 created_at: 1.hour.ago)
        end
        let!(:notice3) do
          create(:notice, :sent_active,
                 title: 'Tercera Notificación',
                 body: 'Contenido de la tercera notificación',
                 created_at: 30.minutes.ago)
        end

        before { get '/notice' }

        it 'muestra todas las notificaciones' do
          expect(response.body).to have_content('Primera Notificación')
          expect(response.body).to have_content('Segunda Notificación')
          expect(response.body).to have_content('Tercera Notificación')
        end

        it 'muestra tres div.box (uno por notificación)' do
          expect(response.body).to have_css('div.box', count: 3)
        end

        it 'muestra tres div.box-notif (uno por notificación)' do
          expect(response.body).to have_css('div.box-notif', count: 3)
        end

        it 'muestra todos los títulos' do
          expect(response.body).to have_css('strong', text: 'Primera Notificación')
          expect(response.body).to have_css('strong', text: 'Segunda Notificación')
          expect(response.body).to have_css('strong', text: 'Tercera Notificación')
        end

        it 'muestra todos los cuerpos' do
          expect(response.body).to have_content('Contenido de la primera notificación')
          expect(response.body).to have_content('Contenido de la segunda notificación')
          expect(response.body).to have_content('Contenido de la tercera notificación')
        end

        it 'muestra tres fechas' do
          expect(response.body).to have_css('p.date', count: 3)
        end

        it 'mantiene el orden de las notificaciones (más reciente primero)' do
          boxes = Nokogiri::HTML(response.body).css('div.box-notif strong')
          expect(boxes[0].text).to eq('Tercera Notificación')
          expect(boxes[1].text).to eq('Segunda Notificación')
          expect(boxes[2].text).to eq('Primera Notificación')
        end
      end
    end

    describe 'C. TESTS DE PAGINACIÓN' do
      before { sign_in user }

      context 'cuando hay más de 5 notificaciones' do
        before do
          12.times { create(:notice, :sent_active) }
          get '/notice'
        end

        it 'muestra controles de paginación' do
          expect(response.body).to match(/pagination|paginator|page/)
        end

        it 'muestra solo 5 notificaciones en la página 1' do
          expect(response.body).to have_css('div.box', count: 5)
        end
      end

      context 'cuando hay exactamente 5 notificaciones' do
        before do
          5.times { create(:notice, :sent_active) }
          get '/notice'
        end

        it 'muestra todas las 5 notificaciones' do
          expect(response.body).to have_css('div.box', count: 5)
        end

        it 'no muestra controles de paginación activos' do
          parsed = Nokogiri::HTML(response.body)
          page_links = parsed.css('a[rel="next"], a[rel="prev"]')
          expect(page_links).to be_empty
        end
      end

      context 'cuando hay menos de 5 notificaciones' do
        before do
          3.times { create(:notice, :sent_active) }
          get '/notice'
        end

        it 'muestra todas las notificaciones disponibles' do
          expect(response.body).to have_css('div.box', count: 3)
        end

        it 'no muestra controles de paginación' do
          parsed = Nokogiri::HTML(response.body)
          page_links = parsed.css('a[rel="next"], a[rel="prev"]')
          expect(page_links).to be_empty
        end
      end

      context 'en la página 2 de resultados' do
        before do
          12.times { create(:notice, :sent_active) }
          get '/notice', params: { page: 2 }
        end

        it 'muestra las notificaciones de la página 2' do
          expect(response.body).to have_css('div.box', count: 5)
        end

        it 'muestra controles de paginación' do
          expect(response.body).to match(/pagination|paginator|page/)
        end
      end

      context 'en la última página con resultados parciales' do
        before do
          12.times { create(:notice, :sent_active) }
          get '/notice', params: { page: 3 }
        end

        it 'muestra solo las notificaciones restantes' do
          expect(response.body).to have_css('div.box', count: 2)
        end
      end
    end

    describe 'D. TESTS DE FORMATEO Y I18N' do
      before { sign_in user }

      context 'formateo de fechas' do
        let!(:specific_date) { Time.zone.parse('2025-01-15 14:30:00') }
        let!(:notice) do
          create(:notice, :sent_active,
                 title: 'Test Date',
                 body: 'Testing date formatting',
                 created_at: specific_date)
        end

        before do
          I18n.locale = :es
          get '/notice'
        end

        it 'formatea la fecha usando el helper I18n.l' do
          expect(response.body).to have_css('p.date')
        end

        it 'muestra la fecha dentro del párrafo con clase date' do
          expect(response.body).to have_css('div.box-notif p.date')
        end

        it 'la fecha no está vacía' do
          date_element = Nokogiri::HTML(response.body).css('p.date').first
          expect(date_element.text.strip).not_to be_empty
        end
      end

      context 'con fechas antiguas' do
        let!(:old_notice) do
          create(:notice, :sent_active,
                 created_at: 2.years.ago,
                 title: 'Old Notice',
                 body: 'This is an old notice')
        end

        before do
          I18n.locale = :es
          get '/notice'
        end

        it 'formatea correctamente fechas antiguas' do
          expect(response.body).to have_css('p.date')
          date_element = Nokogiri::HTML(response.body).css('p.date').first
          expect(date_element.text.strip).not_to be_empty
        end
      end

      context 'con fechas muy recientes' do
        let!(:recent_notice) do
          create(:notice, :sent_active,
                 created_at: 5.minutes.ago,
                 title: 'Recent Notice',
                 body: 'This is a recent notice')
        end

        before do
          I18n.locale = :es
          get '/notice'
        end

        it 'formatea correctamente fechas recientes' do
          expect(response.body).to have_css('p.date')
          date_element = Nokogiri::HTML(response.body).css('p.date').first
          expect(date_element.text.strip).not_to be_empty
        end
      end
    end

    describe 'E. TESTS DE SEGURIDAD (XSS)' do
      before { sign_in user }

      context 'prevención de XSS en títulos' do
        let!(:notice_with_html) do
          create(:notice, :sent_active,
                 title: '<script>alert("XSS")</script>',
                 body: 'Safe body')
        end

        before { get '/notice' }

        it 'escapa HTML en el título' do
          expect(response.body).to include('&lt;script&gt;')
          expect(response.body).not_to include('<script>alert("XSS")</script>')
        end

        it 'no ejecuta JavaScript inyectado en el título' do
          parsed = Nokogiri::HTML(response.body)
          script_tags = parsed.css('script')
          script_content = script_tags.map(&:text).join
          expect(script_content).not_to include('alert("XSS")')
        end

        it 'muestra el contenido malicioso como texto escapado' do
          expect(response.body).to have_content('<script>alert("XSS")</script>')
        end
      end

      context 'prevención de XSS en cuerpos' do
        let!(:notice_with_html_body) do
          create(:notice, :sent_active,
                 title: 'Safe Title',
                 body: '<img src=x onerror="alert(\'XSS\')">Click here')
        end

        before { get '/notice' }

        it 'escapa HTML en el cuerpo' do
          expect(response.body).to include('&lt;img')
          expect(response.body).not_to include('<img src=x onerror')
        end

        it 'muestra el contenido como texto escapado' do
          expect(response.body).to have_content('<img src=x onerror')
        end

        it 'no permite atributos onerror' do
          parsed = Nokogiri::HTML(response.body)
          elements_with_onerror = parsed.css('[onerror]')
          expect(elements_with_onerror).to be_empty
        end
      end

      context 'prevención de inyección de HTML malicioso' do
        let!(:notice_with_iframe) do
          create(:notice, :sent_active,
                 title: 'Title with <iframe src="evil.com"></iframe>',
                 body: 'Body with <a href="javascript:void(0)">click</a>')
        end

        before { get '/notice' }

        it 'escapa iframes en el título' do
          expect(response.body).to include('&lt;iframe')
          expect(response.body).not_to include('<iframe src="evil.com">')
        end

        it 'escapa javascript: URLs en el cuerpo' do
          expect(response.body).to include('&lt;a')
          expect(response.body).not_to include('href="javascript:')
        end
      end
    end

    describe 'F. TESTS DE EDGE CASES' do
      before { sign_in user }

      context 'títulos muy largos' do
        let!(:notice_long_title) do
          create(:notice, :sent_active,
                 title: 'A' * 500,
                 body: 'Normal body')
        end

        before { get '/notice' }

        it 'muestra títulos muy largos sin errores' do
          expect(response.body).to have_css('strong')
          expect(response.body).to include('A' * 500)
        end

        it 'mantiene la estructura HTML correcta' do
          expect(response.body).to have_css('div.box-notif')
        end
      end

      context 'cuerpos muy largos' do
        let!(:notice_long_body) do
          create(:notice, :sent_active,
                 title: 'Normal Title',
                 body: 'B' * 1000)
        end

        before { get '/notice' }

        it 'muestra cuerpos muy largos sin errores' do
          expect(response.body).to include('B' * 1000)
        end

        it 'mantiene la estructura HTML correcta' do
          expect(response.body).to have_css('div.box-notif')
        end
      end

      context 'caracteres especiales UTF-8' do
        let!(:notice_utf8) do
          create(:notice, :sent_active,
                 title: 'Título con ñ, á, é, í, ó, ú, ü',
                 body: 'Cuerpo con €, £, ¥, ©, ®, ™, emojis: 😀 🎉 ✅')
        end

        before { get '/notice' }

        it 'maneja correctamente caracteres acentuados' do
          expect(response.body).to have_content('ñ, á, é, í, ó, ú, ü')
        end

        it 'maneja correctamente símbolos especiales' do
          expect(response.body).to have_content('€, £, ¥, ©, ®, ™')
        end

        it 'maneja correctamente emojis' do
          expect(response.body).to have_content('😀 🎉 ✅')
        end
      end

      context 'notificaciones con saltos de línea' do
        let!(:notice_multiline) do
          create(:notice, :sent_active,
                 title: "Title\nwith\nnewlines",
                 body: "Body\nwith\nmultiple\nlines\nof\ntext")
        end

        before { get '/notice' }

        it 'muestra notificaciones con saltos de línea' do
          expect(response.body).to have_content('Title')
          expect(response.body).to have_content('with')
          expect(response.body).to have_content('newlines')
        end

        it 'mantiene el formato del cuerpo con múltiples líneas' do
          expect(response.body).to have_content('Body')
          expect(response.body).to have_content('multiple')
          expect(response.body).to have_content('lines')
        end
      end

      context 'notificaciones con espacios en blanco' do
        let!(:notice_spaces) do
          create(:notice, :sent_active,
                 title: '   Title with spaces   ',
                 body: '   Body with   extra   spaces   ')
        end

        before { get '/notice' }

        it 'muestra títulos con espacios' do
          expect(response.body).to have_content('Title with spaces')
        end

        it 'muestra cuerpos con espacios extra' do
          expect(response.body).to have_content('Body with   extra   spaces')
        end
      end

      context 'títulos y cuerpos con comillas' do
        let!(:notice_quotes) do
          create(:notice, :sent_active,
                 title: 'Title with "double quotes" and \'single quotes\'',
                 body: 'Body with "quotes" and \'apostrophes\'')
        end

        before { get '/notice' }

        it 'maneja comillas dobles correctamente' do
          expect(response.body).to have_content('double quotes')
        end

        it 'maneja comillas simples correctamente' do
          expect(response.body).to have_content('single quotes')
        end

        it 'escapa correctamente las comillas en HTML' do
          parsed = Nokogiri::HTML(response.body)
          expect(parsed.css('strong').first.text).to include('"')
          expect(parsed.css('strong').first.text).to include("'")
        end
      end
    end

    describe 'G. TESTS DE ACCESIBILIDAD Y SEMÁNTICA HTML' do
      before { sign_in user }

      let!(:notice) do
        create(:notice, :sent_active,
               title: 'Accessible Notice',
               body: 'Testing accessibility')
      end

      before { get '/notice' }

      it 'usa elementos strong para énfasis semántico' do
        expect(response.body).to have_css('strong')
      end

      it 'usa elementos p para párrafos de texto' do
        expect(response.body).to have_css('p', minimum: 3)
      end

      it 'estructura correctamente el contenido en divs semánticos' do
        expect(response.body).to have_css('div.box > div.box-notif')
      end

      it 'la fecha tiene una clase CSS específica para styling' do
        expect(response.body).to have_css('p.date')
      end

      it 'cada notificación está contenida en su propio div.box' do
        parsed = Nokogiri::HTML(response.body)
        boxes = parsed.css('div.box')
        expect(boxes.count).to eq(1)

        boxes.each do |box|
          expect(box.css('div.box-notif').count).to eq(1)
        end
      end
    end

    describe 'H. TESTS DE CONSISTENCIA Y VALIDACIÓN' do
      before { sign_in user }

      context 'validación de estructura completa' do
        let!(:notice1) { create(:notice, :sent_active, title: 'Notice 1', body: 'Body 1') }
        let!(:notice2) { create(:notice, :sent_active, title: 'Notice 2', body: 'Body 2') }

        before { get '/notice' }

        it 'cada notificación tiene exactamente un título' do
          parsed = Nokogiri::HTML(response.body)
          boxes = parsed.css('div.box-notif')

          expect(boxes.count).to eq(2)
          boxes.each do |box|
            titles = box.css('strong')
            expect(titles.count).to eq(1)
          end
        end

        it 'cada notificación tiene exactamente una fecha' do
          parsed = Nokogiri::HTML(response.body)
          boxes = parsed.css('div.box-notif')

          boxes.each do |box|
            dates = box.css('p.date')
            expect(dates.count).to eq(1)
          end
        end

        it 'cada notificación tiene su contenido correctamente anidado' do
          parsed = Nokogiri::HTML(response.body)
          boxes = parsed.css('div.box')

          boxes.each do |box|
            box_notif = box.css('div.box-notif').first
            expect(box_notif).not_to be_nil

            paragraphs = box_notif.css('> p')
            expect(paragraphs.count).to be >= 3
          end
        end
      end

      context 'validación de datos mostrados' do
        let!(:notice) do
          create(:notice, :sent_active,
                 title: 'Specific Title 123',
                 body: 'Specific Body 456',
                 created_at: Time.zone.parse('2025-02-14 15:45:00'))
        end

        before { get '/notice' }

        it 'muestra exactamente el título de la notificación' do
          expect(response.body).to have_css('strong', text: 'Specific Title 123', exact_text: true)
        end

        it 'muestra exactamente el cuerpo de la notificación' do
          parsed = Nokogiri::HTML(response.body)
          body_paragraphs = parsed.css('div.box-notif > p').select do |p|
            !p.css('strong').any? && !p['class']&.include?('date')
          end

          expect(body_paragraphs.first.text.strip).to eq('Specific Body 456')
        end

        it 'no muestra datos de otras notificaciones inexistentes' do
          expect(response.body).not_to have_content('Random Title')
          expect(response.body).not_to have_content('Random Body')
        end
      end
    end

    describe 'I. TESTS DE CASOS LÍMITE DE PAGINACIÓN' do
      before { sign_in user }

      context 'página vacía (más allá del rango)' do
        before do
          5.times { create(:notice, :sent_active) }
          get '/notice', params: { page: 10 }
        end

        it 'renderiza sin errores en página fuera de rango' do
          expect(response).to have_http_status(:success)
        end

        it 'no muestra notificaciones' do
          expect(response.body).not_to have_css('div.box')
        end

        it 'mantiene la estructura HTML base' do
          expect(response.body).to have_css('div.content-content')
        end
      end

      context 'primera página con exactamente 1 notificación' do
        before do
          create(:notice, :sent_active)
          get '/notice'
        end

        it 'muestra la única notificación' do
          expect(response.body).to have_css('div.box', count: 1)
        end

        it 'no muestra controles de paginación' do
          parsed = Nokogiri::HTML(response.body)
          page_links = parsed.css('a[rel="next"], a[rel="prev"]')
          expect(page_links).to be_empty
        end
      end
    end

    describe 'J. TESTS DE FILTRADO DEL CONTROLADOR' do
      before { sign_in user }

      context 'solo muestra notificaciones enviadas y activas' do
        let!(:sent_active) { create(:notice, :sent_active) }
        let!(:pending) { create(:notice, :pending) }
        let!(:expired) { create(:notice, :sent_expired) }

        before { get '/notice' }

        it 'muestra notificaciones enviadas y activas' do
          expect(response.body).to have_content(sent_active.title)
        end

        it 'no muestra notificaciones pendientes' do
          expect(response.body).not_to have_content(pending.title)
        end

        it 'no muestra notificaciones expiradas' do
          expect(response.body).not_to have_content(expired.title)
        end
      end
    end
  end
end
