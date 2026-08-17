# frozen_string_literal: true

module PlebisCms
  module AutoHtmlFilters
    # Convierte una URL de YouTube en su iframe embebido.
    #
    # auto_html 1.x traia este filtro de serie; la 2.x rehizo la API y solo
    # conserva Markdown, Image, Link, SimpleFormat, Emoji y HtmlEscape. El
    # proyecto seguia llamando a la DSL de la 1.x, que ya no existe, asi que
    # tanto el blog como la pantalla de admin reventaban con NoMethodError.
    # Se replica el HTML que generaba la 1.6.4 para no cambiar el maquetado.
    class Youtube
      # La guarda (?<!href=") evita reventar los enlaces que Markdown ya haya
      # construido: el filtro corre despues de el.
      PATTERN = %r{
        (?<!href=")(https?://)?(www\.)?
        (youtube\.com/watch\?v=|youtu\.be/|youtube\.com/watch\?feature=player_embedded&v=)
        ([A-Za-z0-9_-]*)(&\S+)?(\?\S+)?
      }x

      def initialize(width: 420, height: 315, frameborder: 0)
        @width = width
        @height = height
        @frameborder = frameborder
      end

      def call(text)
        text.gsub(PATTERN) do
          id = Regexp.last_match(4)
          %(<div class="video youtube"><iframe width="#{@width}" height="#{@height}" ) +
            %(src="//www.youtube.com/embed/#{id}" frameborder="#{@frameborder}" allowfullscreen></iframe></div>)
        end
      end
    end
  end
end
