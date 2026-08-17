# frozen_string_literal: true

module PlebisCms
  module AutoHtmlFilters
    # Convierte una URL de Vimeo en su iframe embebido.
    # Portado de auto_html 1.6.4, que la 2.x ya no incluye. Ver Youtube.
    class Vimeo
      # Ver la guarda equivalente en Youtube.
      PATTERN = %r{(?<!href=")https?://(www\.)?vimeo\.com/([A-Za-z0-9._%-]*)((\?|\#)\S+)?}

      def initialize(width: 440, height: 248, frameborder: 0)
        @width = width
        @height = height
        @frameborder = frameborder
      end

      def call(text)
        text.gsub(PATTERN) do
          id = Regexp.last_match(2)
          %(<iframe src="//player.vimeo.com/video/#{id}?title=0&byline=0&portrait=0" ) +
            %(width="#{@width}" height="#{@height}" frameborder="#{@frameborder}"></iframe>)
        end
      end
    end
  end
end
