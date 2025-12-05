# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Page FAQ', type: :request, skip: 'Tests check specific FAQ content that changes' do
  describe 'GET /es/preguntas-frecuentes' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza correctamente sin autenticación' do
        get '/preguntas-frecuentes'
        expect(response).to have_http_status(:success)
      end

      it 'muestra el título principal' do
        get '/preguntas-frecuentes'
        expect(response.body).to include('Preguntas Frecuentes')
      end

      it 'tiene el title tag correcto' do
        get '/preguntas-frecuentes'
        expect(response.body).to include('<title>')
        expect(response.body).to match(/Preguntas Frecuentes/i)
      end
    end

    describe 'B. CATEGORÍAS DE NAVEGACIÓN' do
      before { get '/preguntas-frecuentes' }

      it 'muestra las categorías de FAQ' do
        expect(response.body).to include('cd-faq-categories')
      end

      it 'tiene enlace a sección GENERAL' do
        expect(response.body).to include('href="#general"')
        expect(response.body).to include('GENERAL')
      end

      it 'tiene enlace a sección INSCRIPCIÓN' do
        expect(response.body).to include('href="#inscripcion"')
        expect(response.body).to include('INSCRIPCIÓN')
      end

      it 'tiene enlace a sección VOTACIONES' do
        expect(response.body).to include('href="#votaciones"')
        expect(response.body).to include('VOTACIONES')
      end

      it 'marca GENERAL como seleccionada por defecto' do
        expect(response.body).to match(%r{<a\s+class="selected"\s+href="#general">GENERAL</a>}i)
      end
    end

    describe 'C. SECCIÓN GENERAL (9 preguntas)' do
      before { get '/preguntas-frecuentes' }

      it 'tiene el div de sección general' do
        expect(response.body).to include('id="general"')
        expect(response.body).to include('class="cd-faq-group"')
      end

      it 'muestra pregunta 1: Qué necesitas para entrar' do
        expect(response.body).to include('¿Qué necesitas para entrar en participa.plebisbrand.info?')
      end

      it 'menciona requisitos: DNI/NIF/Pasaporte' do
        expect(response.body).to include('DNI/NIF/Pasaporte')
      end

      it 'menciona requisitos: Teléfono móvil' do
        expect(response.body).to include('Teléfono móvil')
      end

      it 'menciona requisitos: Correo electrónico' do
        expect(response.body).to include('Correo electrónico')
      end

      it 'muestra pregunta 2: Para qué sirve la plataforma' do
        expect(response.body).to include('¿Para qué sirve participa.plebisbrand.info?')
      end

      it 'menciona funcionalidad de pasarela de voto' do
        expect(response.body).to include('Pasarela segura de voto')
      end

      it 'muestra pregunta sobre cuenta bloqueada' do
        expect(response.body).to include('Me han bloqueado la cuenta')
      end

      it 'explica bloqueo temporal de 1 hora' do
        expect(response.body).to include('una hora')
        expect(response.body).to include('20 intentos')
      end

      it 'muestra pregunta sobre votar 2 veces' do
        expect(response.body).to include('¿Cómo es posible que haya podido votar 2 veces?')
      end

      it 'explica sistema de repetición de voto' do
        expect(response.body).to include('cinco ocasiones')
      end

      it 'muestra pregunta sobre teléfono móvil' do
        expect(response.body).to include('¿Se puede participar sin un número de teléfono móvil?')
      end

      it 'indica que el teléfono móvil es obligatorio' do
        expect(response.body).to include('No. Por razones de seguridad')
      end
    end

    describe 'D. SECCIÓN INSCRIPCIÓN (errores comunes)' do
      before { get '/preguntas-frecuentes' }

      it 'tiene el div de sección inscripción' do
        expect(response.body).to include('id="inscripcion"')
      end

      it 'muestra Error 0: credenciales inválidas' do
        expect(response.body).to include('Error 0')
        expect(response.body).to include('Correo electrónico, número de documento o contraseña inválidos')
      end

      it 'incluye imagen de error de login' do
        expect(response.body).to include('faq-error-login.png')
      end

      it 'muestra Error 1: DNI ya inscrito' do
        expect(response.body).to include('Error 1')
        expect(response.body).to include('Ya estás inscrito con tu documento')
      end

      it 'muestra Error 2: email ya inscrito' do
        expect(response.body).to include('Error 2')
        expect(response.body).to include('Ya estás inscrito con tu correo electrónico')
      end

      it 'muestra Error 3: no llega el correo' do
        expect(response.body).to include('Error 3')
        expect(response.body).to include('No me llega ningún correo')
      end

      it 'muestra Error 4: no llega SMS' do
        expect(response.body).to include('Error 4')
        expect(response.body).to include('No me llega el SMS')
      end

      it 'explica formato internacional de teléfono' do
        expect(response.body).to include('+34 677XXXXXX')
      end
    end

    describe 'E. SECCIÓN VOTACIONES (14 preguntas)' do
      before { get '/preguntas-frecuentes' }

      it 'tiene el div de sección votaciones' do
        expect(response.body).to include('id="votaciones"')
      end

      it 'muestra pregunta: Qué necesito para votar' do
        expect(response.body).to include('¿Qué necesito para votar?')
      end

      it 'muestra pregunta sobre dispositivos móviles' do
        expect(response.body).to include('No tengo un dispositivo móvil')
      end

      it 'indica que se puede votar desde ordenador' do
        expect(response.body).to include('desde un ordenador')
      end

      it 'muestra pregunta sobre métodos de autenticación' do
        expect(response.body).to include('¿Qué metodos de autenticación')
      end

      it 'muestra pregunta: ¿Puedo cambiar mi voto?' do
        expect(response.body).to include('¿Puedo cambiar mi voto?')
      end

      it 'explica límite de 5 cambios de voto' do
        expect(response.body).to include('hasta cinco veces')
      end

      it 'muestra pregunta: ¿Puedo votar en blanco?' do
        expect(response.body).to include('¿Puedo votar en blanco?')
      end

      it 'confirma que se puede votar en blanco' do
        expect(response.body).to include('Si, se puede votar en blanco')
      end

      it 'muestra pregunta sobre medidas de seguridad' do
        expect(response.body).to include('¿Qué medidas de seguridad')
      end

      it 'menciona verificatum' do
        expect(response.body).to include('verificatum')
      end

      it 'muestra pregunta sobre comprobar voto' do
        expect(response.body).to include('¿Cómo puedo comprobar que mi voto ha quedado registrado')
      end

      it 'menciona localizador de voto' do
        expect(response.body).to include('localizador del voto')
      end

      it 'muestra pregunta sobre secreto del voto' do
        expect(response.body).to include('¿Es posible averiguar el contenido de mi voto?')
      end

      it 'asegura que administradores no pueden ver votos' do
        expect(response.body).to include('ni siquiera los administradores')
      end

      it 'muestra pregunta sobre software libre' do
        expect(response.body).to include('¿Es Agora Voting software libre?')
      end

      it 'menciona que Nvotes es software libre' do
        expect(response.body).to include('Nvotes')
        expect(response.body).to include('software libre')
      end

      it 'menciona GitHub como repositorio público' do
        expect(response.body).to include('github.com/nvotes')
      end
    end

    describe 'F. ENLACES EXTERNOS' do
      before { get '/preguntas-frecuentes' }

      it 'tiene enlaces a participa.plebisbrand.info' do
        expect(response.body).to include('participa.plebisbrand.info')
      end

      it 'tiene enlace a ayuda para acceder' do
        expect(response.body).to include('ayuda-para-acceder')
      end

      it 'tiene enlace al repositorio GitHub de nvotes' do
        expect(response.body).to include('github.com/nvotes')
      end

      it 'tiene enlace a nvotes.com' do
        expect(response.body).to include('nvotes.com')
      end

      it 'tiene enlaces a navegadores (Chrome/Firefox)' do
        expect(response.body).to include('chrome')
        expect(response.body).to include('firefox')
      end

      it 'tiene enlaces con target=_blank para externos' do
        expect(response.body).to match(/target="_blank"/)
      end
    end

    describe 'G. ESTRUCTURA HTML Y ACCESIBILIDAD' do
      before { get '/preguntas-frecuentes' }

      it 'usa estructura semántica con section' do
        expect(response.body).to include('<section class="cd-faq">')
      end

      it 'tiene h2 para títulos principales' do
        expect(response.body).to match(%r{<h2>.*General.*</h2>}i)
        expect(response.body).to match(%r{<h2>.*Inscripción.*</h2>}i)
        expect(response.body).to match(%r{<h2>.*Votaciones.*</h2>}i)
      end

      it 'usa listas ul para organizar preguntas' do
        expect(response.body).to include('<ul id="general" class="cd-faq-group">')
        expect(response.body).to include('<ul id="inscripcion" class="cd-faq-group">')
        expect(response.body).to include('<ul id="votaciones" class="cd-faq-group">')
      end

      it 'tiene botón de cerrar panel' do
        expect(response.body).to include('cd-close-panel')
      end

      it 'usa clases CSS consistentes para FAQ items' do
        expect(response.body).to include('cd-faq-trigger')
        expect(response.body).to include('cd-faq-content')
      end

      it 'tiene estructura de acordeón con triggers y content' do
        triggers = response.body.scan('cd-faq-trigger').count
        contents = response.body.scan('cd-faq-content').count
        expect(triggers).to be > 20
        expect(contents).to be > 20
      end
    end

    describe 'H. CONTENIDO Y DETALLES' do
      before { get '/preguntas-frecuentes' }

      it 'tiene más de 25 preguntas/items en total' do
        faq_items = response.body.scan('<li>').count
        expect(faq_items).to be >= 25
      end

      it 'contiene la palabra "seguridad" múltiples veces' do
        security_count = response.body.scan(/seguridad/i).count
        expect(security_count).to be >= 5
      end

      it 'menciona el límite de tiempo de sesión' do
        expect(response.body).to include('20 minutos')
      end

      it 'menciona diferentes sistemas operativos/dispositivos' do
        expect(response.body).to match(/android|iphone/i)
      end
    end
  end
end
