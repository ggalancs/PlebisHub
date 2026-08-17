# frozen_string_literal: true

require 'rails_helper'

# Regresion: las paginas servidas por un engine renderizan el layout de la
# aplicacion, y ese layout incluye `application/_header` y `application/_sidr_menu`.
# Ambos partials solo dibujan el bloque de usuario cuando hay sesion, y llamaban a
# rutas de la app (`root_path`, `edit_user_registration_path`, `qr_code_path`,
# `destroy_user_session_path`) sin prefijo `main_app.`. En contexto de engine
# `_routes` apunta al route set del engine, que no las tiene, asi que reventaban
# con NameError: 500 para cualquier usuario con sesion.
#
# No lo veia ningun spec porque todos entraban a esas paginas como invitados, y
# de invitado el bloque de usuario no se dibuja.
RSpec.describe 'Paginas de engine con sesion iniciada', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  # ruta publica servida por cada engine que usa el layout de la aplicacion
  {
    'plebis_cms (blog)' => '/brujula',
    'plebis_cms (avisos)' => '/notices',
    'plebis_participation' => '/equipos-de-accion-participativa'
  }.each do |engine, path|
    it "renderiza #{path} de #{engine} sin reventar" do
      get path
      expect(response).not_to have_http_status(:internal_server_error)
    end
  end

  describe 'los partials compartidos usan main_app para las rutas de la app' do
    # Guarda directa sobre el fuente: si alguien vuelve a anadir un helper de la
    # app sin cualificar, el fallo solo aparece con sesion y en una vista de
    # engine, que es justo el hueco que dejo pasar el bug.
    let(:app_route_helpers) do
      %w[root_path edit_user_registration_path qr_code_path destroy_user_session_path]
    end

    %w[
      app/views/application/_header.html.erb
      app/views/application/_sidr_menu.html.erb
    ].each do |partial|
      it "#{partial} no llama a rutas de la app sin prefijo" do
        source = Rails.root.join(partial).read
        sin_prefijo = app_route_helpers.select do |helper|
          source.match?(/(?<![.\w])#{Regexp.escape(helper)}\b/)
        end
        expect(sin_prefijo).to be_empty,
                               "#{partial} usa #{sin_prefijo.join(', ')} sin main_app.: " \
                               'reventara con NameError al renderizarse desde un engine'
      end
    end
  end
end
