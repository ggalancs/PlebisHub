# frozen_string_literal: true

module PlebisCms
  module BlogHelper
    def formatted_content(post, max_paraphs = nil)
      read_more = nil
      content = post.content.to_s
      if max_paraphs
        paraphs = content.split("\n", max_paraphs + 1)
        if paraphs.length > max_paraphs
          content = paraphs[0..(max_paraphs - 1)].join("\n")
          # La ruta se cualifica al engine: `link_to(..., post)` deja que
          # polymorphic_path resuelva contra el route set del contexto, que
          # fuera de una vista del engine no conoce post_path.
          read_more = content_tag(:p, link_to(fa_icon('plus-circle', text: 'Seguir leyendo'),
                                              plebis_cms.post_path(post)))
        end
      end

      # El original hacia `[...].compact.sum`, que sobre cadenas revienta con
      # TypeError porque Array#sum arranca en 0. Nunca salto porque la linea
      # anterior ya moria en `auto_html`.
      safe_join([ContentPipeline.content(content), read_more].compact)
    end

    def main_media(post)
      return if post.media_url.blank?

      ContentPipeline.media(post.media_url)
    end

    def long_date(post)
      I18n.l post.created_at.to_date, format: :long
    end
  end
end
