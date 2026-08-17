# frozen_string_literal: true

require 'rails_helper'

# El proyecto llamaba a `auto_html(texto) { youtube; redcarpet; ... }`, la DSL de
# auto_html 1.x, con la 2.x instalada. Ese metodo no existe en la 2.x, asi que el
# blog y la pantalla de admin de entradas contestaban 500 desde que se subio la
# gema. Nadie lo veia porque un stub de tests reemplazaba el helper entero.
module PlebisCms
  RSpec.describe ContentPipeline do
    describe '.content' do
      it 'convierte Markdown en HTML' do
        expect(described_class.content('Un **parrafo**')).to include('<strong>parrafo</strong>')
      end

      it 'envuelve en un unico parrafo, sin anidar' do
        resultado = described_class.content('Texto suelto')

        expect(resultado).to include('<p>Texto suelto</p>')
        expect(resultado).not_to include('<p><p>')
      end

      it 'respeta los saltos de linea sueltos' do
        expect(described_class.content("primera\nsegunda")).to include('<br>')
      end

      it 'separa los parrafos en saltos dobles' do
        expect(described_class.content("uno\n\ndos").scan('<p>').size).to eq(2)
      end

      it 'enlaza las URLs sueltas abriendolas en otra pestana' do
        resultado = described_class.content('Visita http://ejemplo.com hoy')

        expect(resultado).to include('href="http://ejemplo.com"')
        expect(resultado).to include('target="_blank"')
      end

      it 'convierte las imagenes en etiquetas img' do
        expect(described_class.content('https://ejemplo.com/foto.png')).to include('<img src="https://ejemplo.com/foto.png"')
      end

      it 'devuelve cadena vacia con texto nulo' do
        expect(described_class.content(nil)).to eq('')
      end

      context 'HTML crudo escrito por el autor' do
        it 'neutraliza un iframe' do
          resultado = described_class.content('<iframe src="http://evil.com"></iframe>')
          expect(resultado).not_to include('<iframe src="http://evil.com"')
        end

        it 'neutraliza un manejador onerror' do
          resultado = described_class.content('<img src=x onerror="alert(1)">')
          expect(resultado).not_to include('onerror="alert(1)"')
        end

        it 'neutraliza una etiqueta script' do
          expect(described_class.content('<script>alert("XSS")</script>')).not_to include('<script>')
        end

        it 'sigue embebiendo los videos legitimos pese al escapado' do
          # Los filtros de embebido corren despues de Markdown justamente para
          # que su HTML no caiga en el escape_html.
          expect(described_class.content('https://youtu.be/abc123')).to include('<iframe')
        end
      end
    end

    describe '.media' do
      it 'embebe un video de YouTube' do
        resultado = described_class.media('https://youtu.be/abc123')

        expect(resultado).to include('youtube.com/embed/abc123')
        expect(resultado).to include('<iframe')
      end

      it 'embebe un video de Vimeo' do
        expect(described_class.media('https://vimeo.com/12345')).to include('player.vimeo.com/video/12345')
      end

      it 'embebe una imagen' do
        expect(described_class.media('https://ejemplo.com/foto.jpg')).to include('<img src="https://ejemplo.com/foto.jpg"')
      end

      it 'no pasa el contenido por Markdown' do
        expect(described_class.media('**no es markdown**')).not_to include('<strong>')
      end
    end

    describe '.markdown' do
      it 'aplica solo Markdown, sin enlazar URLs sueltas' do
        resultado = described_class.markdown('Texto con http://ejemplo.com dentro')

        expect(resultado).to include('<p>')
        expect(resultado).not_to include('target="_blank"')
      end
    end
  end
end
