# frozen_string_literal: true

require 'rails_helper'

# auto_html 2.x solo conserva Markdown, Image, Link, SimpleFormat, Emoji y
# HtmlEscape. Estos filtros reponen los que el proyecto usaba de la 1.x y que
# desaparecieron al subir la gema, dejando el blog y el admin en 500.
module PlebisCms
  RSpec.describe AutoHtmlFilters do
    describe AutoHtmlFilters::Youtube do
      it 'reconoce el formato largo de youtube.com' do
        resultado = described_class.new.call('https://www.youtube.com/watch?v=xyz789')
        expect(resultado).to include('//www.youtube.com/embed/xyz789')
      end

      it 'reconoce el formato corto youtu.be' do
        expect(described_class.new.call('https://youtu.be/xyz789')).to include('//www.youtube.com/embed/xyz789')
      end

      it 'permite cambiar las dimensiones' do
        resultado = described_class.new(width: 800, height: 600).call('https://youtu.be/xyz789')

        expect(resultado).to include('width="800"')
        expect(resultado).to include('height="600"')
      end

      it 'deja intacto el texto sin videos' do
        expect(described_class.new.call('sin videos aqui')).to eq('sin videos aqui')
      end
    end

    describe AutoHtmlFilters::Vimeo do
      it 'construye el iframe del reproductor' do
        resultado = described_class.new.call('https://vimeo.com/98765')

        expect(resultado).to include('player.vimeo.com/video/98765')
        expect(resultado).to include('title=0&byline=0&portrait=0')
      end

      it 'deja intacto el texto sin videos' do
        expect(described_class.new.call('sin videos aqui')).to eq('sin videos aqui')
      end
    end

    describe AutoHtmlFilters::Twitter do
      it 'genera el blockquote que widgets.js convierte en tuit' do
        resultado = described_class.new.call('https://twitter.com/usuario/status/123456')

        expect(resultado).to include('class="twitter-tweet"')
        expect(resultado).to include('href="https://twitter.com/usuario/status/123456"')
      end

      it 'no toca una URL que ya esta dentro de un href' do
        original = '<a href="https://twitter.com/usuario/status/123456">tuit</a>'
        expect(described_class.new.call(original)).to eq(original)
      end

      it 'no sale a la red al renderizar' do
        # El filtro de auto_html 1.x pedia el oembed a la API v1 de Twitter en
        # cada render; esa API ya no existe y ademas bloqueaba la peticion.
        expect(Net::HTTP).not_to receive(:new)
        described_class.new.call('https://twitter.com/usuario/status/123456')
      end
    end

    describe AutoHtmlFilters::Markdown do
      it 'convierte los saltos simples en <br>' do
        expect(described_class.new.call("uno\ndos")).to include('<br>')
      end
    end
  end
end
