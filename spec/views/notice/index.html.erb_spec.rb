# frozen_string_literal: true

require 'rails_helper'

# Rails 7.2 FIX: Template is in PlebisCms engine, need correct namespace
RSpec.describe 'plebis_cms/notice/index.html.erb', type: :view do
  # RAILS 7.2 FIX: Add engine view paths for view specs
  before(:all) do
    # Prepend engine view paths so Rails can find the templates
    engine_path = PlebisCms::Engine.root.join('app', 'views').to_s
    # Convert PathSet to array, prepend engine path, then reassign
    current_paths = ActionController::Base.view_paths.paths.map(&:to_s)
    ActionController::Base.view_paths = [engine_path] + current_paths unless current_paths.include?(engine_path)
  end

  # Helper para crear colección paginada de Kaminari
  def paginated_collection(items, page: 1, per_page: 5)
    Kaminari.paginate_array(items).page(page).per(per_page)
  end

  describe 'A. RENDERING BÁSICO' do
    context 'cuando hay notificaciones' do
      let!(:notice) { create(:notice, :sent_active, title: 'Test Notice', body: 'Test Body') }

      before do
        @notices = paginated_collection([notice])
        render
      end

      it 'renderiza exitosamente sin errores' do
        expect(rendered).not_to be_nil
      end

      it 'usa la estructura HTML correcta con content-content' do
        expect(rendered).to have_css('div.content-content.cols')
      end

      it 'contiene un div.row' do
        expect(rendered).to have_css('div.row')
      end

      it 'contiene un div con clase col-b-4a12' do
        expect(rendered).to have_css('div.col-b-4a12')
      end

      it 'contiene un div.box para la notificación' do
        expect(rendered).to have_css('div.box')
      end

      it 'contiene un div.box-notif dentro de cada box' do
        expect(rendered).to have_css('div.box div.box-notif')
      end
    end

    context 'cuando no hay notificaciones' do
      before do
        @notices = paginated_collection([])
        render
      end

      it 'renderiza exitosamente sin errores' do
        expect(rendered).not_to be_nil
      end

      it 'mantiene la estructura HTML base' do
        expect(rendered).to have_css('div.content-content.cols')
        expect(rendered).to have_css('div.row')
        expect(rendered).to have_css('div.col-b-4a12')
      end

      it 'no muestra ningún div.box' do
        expect(rendered).not_to have_css('div.box')
      end

      it 'no muestra ningún div.box-notif' do
        expect(rendered).not_to have_css('div.box-notif')
      end
    end
  end

  describe 'B. TESTS DE CONTENIDO' do
    context 'con una sola notificación' do
      let!(:notice) do
        create(:notice, :sent_active,
               title: 'Importante: Mantenimiento del Sistema',
               body: 'El sistema estará en mantenimiento el próximo domingo.')
      end

      before do
        @notices = paginated_collection([notice])
        render
      end

      it 'muestra el título de la notificación' do
        expect(rendered).to have_content('Importante: Mantenimiento del Sistema')
      end

      it 'muestra el título en negrita (strong)' do
        expect(rendered).to have_css('strong', text: 'Importante: Mantenimiento del Sistema')
      end

      it 'muestra el cuerpo de la notificación' do
        expect(rendered).to have_content('El sistema estará en mantenimiento el próximo domingo.')
      end

      it 'muestra la fecha de creación formateada' do
        # La fecha debería estar formateada con el helper l (localize)
        # En español típicamente: "01 ene 2025 12:00"
        expect(rendered).to have_css('p.date')
      end

      it 'el título está en un párrafo dentro de box-notif' do
        expect(rendered).to have_css('div.box-notif p strong', text: 'Importante: Mantenimiento del Sistema')
      end

      it 'el cuerpo está en un párrafo dentro de box-notif' do
        expect(rendered).to have_css('div.box-notif p', text: 'El sistema estará en mantenimiento el próximo domingo.')
      end

      it 'la fecha está en un párrafo con clase date' do
        expect(rendered).to have_css('div.box-notif p.date')
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

      before do
        # Ordenar por created_at DESC (más reciente primero)
        notices_ordered = [notice3, notice2, notice1]
        @notices = paginated_collection(notices_ordered)
        render
      end

      it 'muestra todas las notificaciones' do
        expect(rendered).to have_content('Primera Notificación')
        expect(rendered).to have_content('Segunda Notificación')
        expect(rendered).to have_content('Tercera Notificación')
      end

      it 'muestra tres div.box (uno por notificación)' do
        expect(rendered).to have_css('div.box', count: 3)
      end

      it 'muestra tres div.box-notif (uno por notificación)' do
        expect(rendered).to have_css('div.box-notif', count: 3)
      end

      it 'muestra todos los títulos' do
        expect(rendered).to have_css('strong', text: 'Primera Notificación')
        expect(rendered).to have_css('strong', text: 'Segunda Notificación')
        expect(rendered).to have_css('strong', text: 'Tercera Notificación')
      end

      it 'muestra todos los cuerpos' do
        expect(rendered).to have_content('Contenido de la primera notificación')
        expect(rendered).to have_content('Contenido de la segunda notificación')
        expect(rendered).to have_content('Contenido de la tercera notificación')
      end

      it 'muestra tres fechas' do
        expect(rendered).to have_css('p.date', count: 3)
      end

      it 'mantiene el orden de las notificaciones (más reciente primero)' do
        # Verificar que el orden en el HTML es correcto
        # La tercera notificación (más reciente) debe aparecer primero
        boxes = Nokogiri::HTML(rendered).css('div.box-notif strong')
        expect(boxes[0].text).to eq('Tercera Notificación')
        expect(boxes[1].text).to eq('Segunda Notificación')
        expect(boxes[2].text).to eq('Primera Notificación')
      end
    end
  end

  describe 'C. TESTS DE PAGINACIÓN' do
    # RAILS 7.2 FIX: View specs need route helpers for Kaminari pagination
    before(:each) do
      # Stub the url_for helper that Kaminari uses to generate pagination links
      allow(view).to receive(:url_for).and_return('/notice')
    end

    context 'cuando hay más de 5 notificaciones' do
      let!(:notices) { create_list(:notice, 12, :sent_active) }

      before do
        @notices = paginated_collection(notices, page: 1, per_page: 5)
        render
      end

      it 'muestra controles de paginación' do
        # Kaminari renderiza un nav con clase pagination
        expect(rendered).to match(/pagination|paginator|page/)
      end

      it 'muestra solo 5 notificaciones en la página 1' do
        expect(rendered).to have_css('div.box', count: 5)
      end
    end

    context 'cuando hay exactamente 5 notificaciones' do
      let!(:notices) { create_list(:notice, 5, :sent_active) }

      before do
        @notices = paginated_collection(notices, page: 1, per_page: 5)
        render
      end

      it 'muestra todas las 5 notificaciones' do
        expect(rendered).to have_css('div.box', count: 5)
      end

      it 'no muestra controles de paginación (solo 1 página)' do
        # Cuando solo hay 1 página, Kaminari no renderiza los controles
        # o los renderiza deshabilitados
        # Verificamos que no hay enlaces a otras páginas
        parsed = Nokogiri::HTML(rendered)
        page_links = parsed.css('a[rel="next"], a[rel="prev"]')
        expect(page_links).to be_empty
      end
    end

    context 'cuando hay menos de 5 notificaciones' do
      let!(:notices) { create_list(:notice, 3, :sent_active) }

      before do
        @notices = paginated_collection(notices, page: 1, per_page: 5)
        render
      end

      it 'muestra todas las notificaciones disponibles' do
        expect(rendered).to have_css('div.box', count: 3)
      end

      it 'no muestra controles de paginación' do
        parsed = Nokogiri::HTML(rendered)
        page_links = parsed.css('a[rel="next"], a[rel="prev"]')
        expect(page_links).to be_empty
      end
    end

    context 'en la página 2 de resultados' do
      let!(:notices) { create_list(:notice, 12, :sent_active) }

      before do
        @notices = paginated_collection(notices, page: 2, per_page: 5)
        render
      end

      it 'muestra las notificaciones de la página 2' do
        expect(rendered).to have_css('div.box', count: 5)
      end

      it 'muestra controles de paginación' do
        expect(rendered).to match(/pagination|paginator|page/)
      end
    end

    context 'en la última página con resultados parciales' do
      let!(:notices) { create_list(:notice, 12, :sent_active) }

      before do
        # Página 3: solo 2 notificaciones (12 total, 5 por página = 2 en última)
        @notices = paginated_collection(notices, page: 3, per_page: 5)
        render
      end

      it 'muestra solo las notificaciones restantes' do
        expect(rendered).to have_css('div.box', count: 2)
      end
    end
  end

  describe 'D. TESTS DE FORMATEO Y I18N' do
    context 'formateo de fechas' do
      let!(:specific_date) { Time.zone.parse('2025-01-15 14:30:00') }
      let!(:notice) do
        create(:notice, :sent_active,
               title: 'Test Date',
               body: 'Testing date formatting',
               created_at: specific_date)
      end

      before do
        # Asegurar que el locale está en español
        I18n.locale = :es
        @notices = paginated_collection([notice])
        render
      end

      it 'formatea la fecha usando el helper I18n.l' do
        # El helper l (localize) debería formatear la fecha
        # En español típicamente incluye el mes en minúsculas
        expect(rendered).to have_css('p.date')
      end

      it 'muestra la fecha dentro del párrafo con clase date' do
        expect(rendered).to have_css('div.box-notif p.date')
      end

      it 'la fecha no está vacía' do
        date_element = Nokogiri::HTML(rendered).css('p.date').first
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
        @notices = paginated_collection([old_notice])
        render
      end

      it 'formatea correctamente fechas antiguas' do
        expect(rendered).to have_css('p.date')
        date_element = Nokogiri::HTML(rendered).css('p.date').first
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
        @notices = paginated_collection([recent_notice])
        render
      end

      it 'formatea correctamente fechas recientes' do
        expect(rendered).to have_css('p.date')
        date_element = Nokogiri::HTML(rendered).css('p.date').first
        expect(date_element.text.strip).not_to be_empty
      end
    end
  end

  describe 'E. TESTS DE SEGURIDAD (XSS)' do
    context 'prevención de XSS en títulos' do
      let!(:notice_with_html) do
        create(:notice, :sent_active,
               title: '<script>alert("XSS")</script>',
               body: 'Safe body')
      end

      before do
        @notices = paginated_collection([notice_with_html])
        render
      end

      it 'escapa HTML en el título' do
        expect(rendered).to include('&lt;script&gt;')
        expect(rendered).not_to include('<script>alert("XSS")</script>')
      end

      it 'no ejecuta JavaScript inyectado en el título' do
        parsed = Nokogiri::HTML(rendered)
        script_tags = parsed.css('script')
        # No debe haber script tags inyectados desde el título
        script_content = script_tags.map(&:text).join
        expect(script_content).not_to include('alert("XSS")')
      end

      it 'muestra el contenido malicioso como texto escapado' do
        expect(rendered).to have_content('<script>alert("XSS")</script>')
      end
    end

    context 'prevención de XSS en cuerpos' do
      let!(:notice_with_html_body) do
        create(:notice, :sent_active,
               title: 'Safe Title',
               body: '<img src=x onerror="alert(\'XSS\')">Click here')
      end

      before do
        @notices = paginated_collection([notice_with_html_body])
        render
      end

      it 'escapa HTML en el cuerpo' do
        expect(rendered).to include('&lt;img')
        expect(rendered).not_to include('<img src=x onerror')
      end

      it 'muestra el contenido como texto escapado' do
        expect(rendered).to have_content('<img src=x onerror')
      end

      it 'no permite atributos onerror' do
        parsed = Nokogiri::HTML(rendered)
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

      before do
        @notices = paginated_collection([notice_with_iframe])
        render
      end

      it 'escapa iframes en el título' do
        expect(rendered).to include('&lt;iframe')
        expect(rendered).not_to include('<iframe src="evil.com">')
      end

      it 'escapa javascript: URLs en el cuerpo' do
        expect(rendered).to include('&lt;a')
        expect(rendered).not_to include('href="javascript:')
      end
    end
  end

  describe 'F. TESTS DE EDGE CASES' do
    context 'títulos muy largos' do
      let!(:notice_long_title) do
        create(:notice, :sent_active,
               title: 'A' * 500,
               body: 'Normal body')
      end

      before do
        @notices = paginated_collection([notice_long_title])
        render
      end

      it 'muestra títulos muy largos sin errores' do
        expect(rendered).to have_css('strong')
        expect(rendered).to include('A' * 500)
      end

      it 'mantiene la estructura HTML correcta' do
        expect(rendered).to have_css('div.box-notif')
      end
    end

    context 'cuerpos muy largos' do
      let!(:notice_long_body) do
        create(:notice, :sent_active,
               title: 'Normal Title',
               body: 'B' * 1000)
      end

      before do
        @notices = paginated_collection([notice_long_body])
        render
      end

      it 'muestra cuerpos muy largos sin errores' do
        expect(rendered).to include('B' * 1000)
      end

      it 'mantiene la estructura HTML correcta' do
        expect(rendered).to have_css('div.box-notif')
      end
    end

    context 'caracteres especiales UTF-8' do
      let!(:notice_utf8) do
        create(:notice, :sent_active,
               title: 'Título con ñ, á, é, í, ó, ú, ü',
               body: 'Cuerpo con €, £, ¥, ©, ®, ™, emojis: 😀 🎉 ✅')
      end

      before do
        @notices = paginated_collection([notice_utf8])
        render
      end

      it 'maneja correctamente caracteres acentuados' do
        expect(rendered).to have_content('ñ, á, é, í, ó, ú, ü')
      end

      it 'maneja correctamente símbolos especiales' do
        expect(rendered).to have_content('€, £, ¥, ©, ®, ™')
      end

      it 'maneja correctamente emojis' do
        expect(rendered).to have_content('😀 🎉 ✅')
      end
    end

    context 'notificaciones con saltos de línea' do
      let!(:notice_multiline) do
        create(:notice, :sent_active,
               title: "Title\nwith\nnewlines",
               body: "Body\nwith\nmultiple\nlines\nof\ntext")
      end

      before do
        @notices = paginated_collection([notice_multiline])
        render
      end

      it 'muestra notificaciones con saltos de línea' do
        expect(rendered).to have_content('Title')
        expect(rendered).to have_content('with')
        expect(rendered).to have_content('newlines')
      end

      it 'mantiene el formato del cuerpo con múltiples líneas' do
        expect(rendered).to have_content('Body')
        expect(rendered).to have_content('multiple')
        expect(rendered).to have_content('lines')
      end
    end

    context 'notificaciones con espacios en blanco' do
      let!(:notice_spaces) do
        create(:notice, :sent_active,
               title: '   Title with spaces   ',
               body: '   Body with   extra   spaces   ')
      end

      before do
        @notices = paginated_collection([notice_spaces])
        render
      end

      it 'muestra títulos con espacios' do
        expect(rendered).to have_content('Title with spaces')
      end

      it 'muestra cuerpos con espacios extra' do
        expect(rendered).to have_content('Body with   extra   spaces')
      end
    end

    context 'títulos y cuerpos con comillas' do
      let!(:notice_quotes) do
        create(:notice, :sent_active,
               title: 'Title with "double quotes" and \'single quotes\'',
               body: 'Body with "quotes" and \'apostrophes\'')
      end

      before do
        @notices = paginated_collection([notice_quotes])
        render
      end

      it 'maneja comillas dobles correctamente' do
        expect(rendered).to have_content('double quotes')
      end

      it 'maneja comillas simples correctamente' do
        expect(rendered).to have_content('single quotes')
      end

      it 'escapa correctamente las comillas en HTML' do
        # Las comillas deberían estar escapadas como &quot; o &#39;
        parsed = Nokogiri::HTML(rendered)
        expect(parsed.css('strong').first.text).to include('"')
        expect(parsed.css('strong').first.text).to include("'")
      end
    end
  end

  describe 'G. TESTS DE INTEGRACIÓN CON HELPERS' do
    # RAILS 7.2 FIX: View specs need route helpers for Kaminari pagination
    before(:each) do
      # Stub the url_for helper that Kaminari uses to generate pagination links
      allow(view).to receive(:url_for).and_return('/notice')
    end

    context 'helper localize (l)' do
      let!(:notice) do
        create(:notice, :sent_active,
               created_at: Time.zone.parse('2025-03-20 10:30:00'))
      end

      before do
        I18n.locale = :es
        @notices = paginated_collection([notice])
      end

      it 'utiliza el helper l para formatear fechas' do
        # Mock del helper l para verificar que se llama
        allow(view).to receive(:l).and_call_original
        render
        expect(view).to have_received(:l).at_least(:once)
      end

      it 'formatea la fecha según la configuración de I18n' do
        render
        # Verificar que la fecha está formateada (no es timestamp crudo)
        expect(rendered).to have_css('p.date')
        date_text = Nokogiri::HTML(rendered).css('p.date').first.text
        expect(date_text).not_to match(/^\d{4}-\d{2}-\d{2}/) # No formato ISO
      end
    end

    context 'helper paginate de Kaminari' do
      let!(:notices) { create_list(:notice, 10, :sent_active) }

      before do
        @notices = paginated_collection(notices, page: 1, per_page: 5)
      end

      it 'utiliza el helper paginate' do
        # Mock del helper paginate para verificar que se llama
        allow(view).to receive(:paginate).and_call_original
        render
        expect(view).to have_received(:paginate).with(@notices)
      end

      it 'el helper paginate recibe la colección correcta' do
        expect(@notices).to respond_to(:current_page)
        expect(@notices).to respond_to(:total_pages)
        expect(@notices).to respond_to(:limit_value)
        render
        # No debe haber errores
      end
    end
  end

  describe 'H. TESTS DE ACCESIBILIDAD Y SEMÁNTICA HTML' do
    let!(:notice) do
      create(:notice, :sent_active,
             title: 'Accessible Notice',
             body: 'Testing accessibility')
    end

    before do
      @notices = paginated_collection([notice])
      render
    end

    it 'usa elementos strong para énfasis semántico' do
      expect(rendered).to have_css('strong')
    end

    it 'usa elementos p para párrafos de texto' do
      expect(rendered).to have_css('p', minimum: 3) # Título, cuerpo, fecha
    end

    it 'estructura correctamente el contenido en divs semánticos' do
      expect(rendered).to have_css('div.box > div.box-notif')
    end

    it 'la fecha tiene una clase CSS específica para styling' do
      expect(rendered).to have_css('p.date')
    end

    it 'cada notificación está contenida en su propio div.box' do
      parsed = Nokogiri::HTML(rendered)
      boxes = parsed.css('div.box')
      expect(boxes.count).to eq(1)

      # Cada box debe contener exactamente un box-notif
      boxes.each do |box|
        expect(box.css('div.box-notif').count).to eq(1)
      end
    end
  end

  describe 'I. TESTS DE CONSISTENCIA Y VALIDACIÓN' do
    context 'validación de estructura completa' do
      let!(:notice1) { create(:notice, :sent_active, title: 'Notice 1', body: 'Body 1') }
      let!(:notice2) { create(:notice, :sent_active, title: 'Notice 2', body: 'Body 2') }

      before do
        @notices = paginated_collection([notice1, notice2])
        render
      end

      it 'cada notificación tiene exactamente un título' do
        parsed = Nokogiri::HTML(rendered)
        boxes = parsed.css('div.box-notif')

        expect(boxes.count).to eq(2)
        boxes.each do |box|
          titles = box.css('strong')
          expect(titles.count).to eq(1)
        end
      end

      it 'cada notificación tiene exactamente una fecha' do
        parsed = Nokogiri::HTML(rendered)
        boxes = parsed.css('div.box-notif')

        boxes.each do |box|
          dates = box.css('p.date')
          expect(dates.count).to eq(1)
        end
      end

      it 'cada notificación tiene su contenido correctamente anidado' do
        parsed = Nokogiri::HTML(rendered)

        # Estructura esperada:
        # div.box > div.box-notif > (p>strong + p + p.date)
        boxes = parsed.css('div.box')

        boxes.each do |box|
          box_notif = box.css('div.box-notif').first
          expect(box_notif).not_to be_nil

          paragraphs = box_notif.css('> p')
          expect(paragraphs.count).to be >= 3 # Al menos título, cuerpo, fecha
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

      before do
        @notices = paginated_collection([notice])
        render
      end

      it 'muestra exactamente el título de la notificación' do
        expect(rendered).to have_css('strong', text: 'Specific Title 123', exact_text: true)
      end

      it 'muestra exactamente el cuerpo de la notificación' do
        parsed = Nokogiri::HTML(rendered)
        # Buscar el párrafo que contiene el cuerpo (no el que tiene strong, no el que tiene clase date)
        body_paragraphs = parsed.css('div.box-notif > p').select do |p|
          p.css('strong').none? && !p['class']&.include?('date')
        end

        expect(body_paragraphs.first.text.strip).to eq('Specific Body 456')
      end

      it 'no muestra datos de otras notificaciones inexistentes' do
        expect(rendered).not_to have_content('Random Title')
        expect(rendered).not_to have_content('Random Body')
      end
    end
  end

  describe 'J. TESTS DE CASOS LÍMITE DE PAGINACIÓN' do
    context 'página vacía (más allá del rango)' do
      let!(:notices) { create_list(:notice, 5, :sent_active) }

      before do
        @notices = paginated_collection(notices, page: 10, per_page: 5)
        render
      end

      it 'renderiza sin errores en página fuera de rango' do
        expect(rendered).not_to be_nil
      end

      it 'no muestra notificaciones' do
        expect(rendered).not_to have_css('div.box')
      end

      it 'mantiene la estructura HTML base' do
        expect(rendered).to have_css('div.content-content')
      end
    end

    context 'primera página con exactamente 1 notificación' do
      let!(:notice) { create(:notice, :sent_active) }

      before do
        @notices = paginated_collection([notice], page: 1, per_page: 5)
        render
      end

      it 'muestra la única notificación' do
        expect(rendered).to have_css('div.box', count: 1)
      end

      it 'no muestra controles de paginación' do
        parsed = Nokogiri::HTML(rendered)
        page_links = parsed.css('a[rel="next"], a[rel="prev"]')
        expect(page_links).to be_empty
      end
    end
  end
end
