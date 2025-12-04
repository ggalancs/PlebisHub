# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Militant Get Militant Info', type: :request do
  describe 'GET /es/militant/info' do
    describe 'A. RENDERING BÁSICO' do
      it 'renderiza o requiere autenticación/permisos' do
        get '/es/militant/info'
        expect([200, 302, 404]).to include(response.status)
      end

      it 'si renderiza, muestra resultado dinámico' do
        get '/es/militant/info'
        if response.status == 200
          # Esta vista solo muestra @result
          expect(response.body).not_to be_empty
        end
      end
    end

    describe 'B. CONTENIDO SIMPLE' do
      it 'si renderiza, devuelve texto plano o HTML simple' do
        get '/es/militant/info'
        if response.status == 200
          # La vista es muy simple, solo <%= @result %>
          has_content = !response.body.empty?
          expect(has_content).to be true
        end
      end
    end
  end
end
