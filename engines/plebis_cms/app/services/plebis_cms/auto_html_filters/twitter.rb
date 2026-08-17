# frozen_string_literal: true

module PlebisCms
  module AutoHtmlFilters
    # Convierte la URL de un tuit en el blockquote que widgets.js de Twitter
    # transforma en el tuit embebido.
    #
    # El filtro de auto_html 1.6.4 hacia una peticion HTTP sincrona a
    # api.twitter.com/1/statuses/oembed.json *durante el renderizado*: la v1 de
    # esa API lleva anos retirada, asi que hoy devolveria un error de parseo, y
    # aunque respondiera, salir a la red al pintar una pagina significa que cada
    # visita al blog espera a un tercero. Se genera el marcado directamente, que
    # es lo que la propia Twitter recomienda y no depende de nadie en tiempo de
    # render; si widgets.js no esta cargado, degrada a un enlace normal.
    class Twitter
      PATTERN = %r{(?<!href=")https://twitter\.com(/\#!)?/[A-Za-z0-9_]{1,15}/status(es)?/\d+/?}

      def call(text)
        text.gsub(PATTERN) do |url|
          %(<blockquote class="twitter-tweet"><a href="#{url}">#{url}</a></blockquote>)
        end
      end
    end
  end
end
