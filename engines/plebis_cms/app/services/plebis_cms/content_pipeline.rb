# frozen_string_literal: true

module PlebisCms
  # Traduce el texto plano que escriben los editores a HTML.
  #
  # Reemplaza a la DSL `auto_html(texto) { youtube; redcarpet; ... }` de
  # auto_html 1.x, que desaparecio al pasar el proyecto a la 2.x sin adaptar las
  # llamadas: `auto_html` no existe en ninguna parte y tanto el blog como la
  # pantalla de admin de entradas contestaban 500.
  #
  # El orden importa. Markdown va el primero y escapa el HTML que traiga el
  # texto del autor; los embebidos se inyectan despues, para que ese escapado no
  # se los coma. La llamada original los ponia al reves, y por eso cualquier
  # etiqueta escrita en el cuerpo de una entrada llegaba viva al navegador.
  # Enlaces e imagenes sueltos van al final, sin volver a tocar los que Markdown
  # ya haya convertido.
  # Las tres salidas se marcan html_safe a proposito y en un unico sitio: el
  # objetivo del pipeline es justamente emitir HTML (iframes de YouTube y Vimeo,
  # blockquotes de Twitter, Markdown renderizado), asi que sanearlo lo vaciaria
  # de sentido. Lo que si se neutraliza es el HTML que venga en el texto del
  # autor: de eso se encarga escape_html en AutoHtmlFilters::Markdown.
  class ContentPipeline
    class << self
      # Cuerpo de una entrada del blog.
      def content(text)
        AutoHtml::Pipeline.new(
          AutoHtmlFilters::Markdown.new,
          AutoHtmlFilters::Twitter.new,
          AutoHtmlFilters::Youtube.new,
          AutoHtmlFilters::Vimeo.new,
          AutoHtml::Image.new,
          AutoHtml::Link.new(target: '_blank')
        ).call(text.to_s).html_safe # rubocop:disable Rails/OutputSafety
      end

      # Media principal de una entrada: un video o una imagen sueltos.
      def media(url)
        AutoHtml::Pipeline.new(
          AutoHtmlFilters::Youtube.new,
          AutoHtmlFilters::Vimeo.new,
          AutoHtml::Image.new
        ).call(url.to_s).html_safe # rubocop:disable Rails/OutputSafety
      end

      # Solo Markdown, que es lo unico que pedia la pantalla de admin.
      def markdown(text)
        AutoHtml::Pipeline.new(AutoHtmlFilters::Markdown.new).call(text.to_s).html_safe # rubocop:disable Rails/OutputSafety
      end
    end
  end
end
