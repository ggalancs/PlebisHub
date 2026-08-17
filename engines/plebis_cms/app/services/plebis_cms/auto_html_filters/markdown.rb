# frozen_string_literal: true

require 'redcarpet'

module PlebisCms
  module AutoHtmlFilters
    # Markdown con `hard_wrap`, que convierte los saltos de linea sueltos en
    # <br>.
    #
    # AutoHtml::Markdown no acepta opciones: usa Redcarpet pelado, que colapsa
    # los saltos simples en espacios. La llamada original compensaba eso
    # encadenando el filtro simple_format detras, pero como Markdown ya envuelve
    # en <p>, el resultado era <p><p>texto</p></p>: HTML invalido. Con hard_wrap
    # se respeta el salto de linea sin necesidad del segundo filtro.
    class Markdown
      def initialize
        # hard_wrap es opcion del renderer, no extension del parser: pasada a
        # Redcarpet::Markdown se ignora en silencio.
        #
        # escape_html neutraliza el HTML crudo que venga en el texto: sin el, un
        # <iframe src="http://evil.com"> o un <img onerror=...> escritos en el
        # cuerpo de una entrada llegaban intactos al navegador. Los embebidos
        # legitimos (YouTube, Vimeo, Twitter) se inyectan despues de este filtro,
        # asi que no les afecta.
        @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(hard_wrap: true, escape_html: true))
      end

      def call(text)
        @markdown.render(text)
      end
    end
  end
end
