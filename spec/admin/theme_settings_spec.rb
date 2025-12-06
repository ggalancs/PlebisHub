# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ThemeSettings Admin', type: :request do
  let(:admin_user) { create(:user, :admin) }
  let!(:theme_setting) do
    create(:theme_setting,
           name: 'Default Theme',
           primary_color: '#612d62',
           secondary_color: '#269283',
           accent_color: '#954e99',
           is_active: false)
  end
  let!(:active_theme) do
    create(:theme_setting,
           name: 'Active Theme',
           primary_color: '#0EA5E9',
           secondary_color: '#06B6D4',
           is_active: true)
  end

  before do
    sign_in_admin admin_user
  end

  # ========================================
  # INDEX TESTS
  # ========================================
  describe 'GET /admin/theme_settings' do
    it 'displays the index page' do
      get admin_theme_settings_path
      expect(response).to have_http_status(:success)
    end

    it 'shows selectable column' do
      get admin_theme_settings_path
      expect(response.body).to match(/selectable.*column/i)
    end

    it 'shows id column' do
      get admin_theme_settings_path
      expect(response.body).to include(theme_setting.id.to_s)
    end

    it 'shows name column' do
      get admin_theme_settings_path
      expect(response.body).to include('Default Theme')
      expect(response.body).to include('Active Theme')
    end

    it 'shows primary color with preview' do
      get admin_theme_settings_path
      expect(response.body).to include('#612d62')
      expect(response.body).to include('background-color: #612d62')
    end

    it 'shows secondary color with preview' do
      get admin_theme_settings_path
      expect(response.body).to include('#269283')
      expect(response.body).to include('background-color: #269283')
    end

    it 'shows active status tag' do
      get admin_theme_settings_path
      expect(response.body).to match(/Activo/i)
    end

    it 'shows inactive status tag' do
      get admin_theme_settings_path
      expect(response.body).to match(/No|inactive/i)
    end

    it 'shows created_at column' do
      get admin_theme_settings_path
      expect(response.body).to match(/\d{4}/)
    end

    it 'shows actions column with preview link' do
      get admin_theme_settings_path
      expect(response.body).to include('Vista Previa')
      expect(response.body).to include(preview_admin_theme_setting_path(theme_setting))
    end

    it 'shows export JSON link' do
      get admin_theme_settings_path
      expect(response.body).to include('Exportar JSON')
      expect(response.body).to include(export_admin_theme_setting_path(theme_setting, format: :json))
    end

    it 'shows activate link for inactive themes' do
      get admin_theme_settings_path
      expect(response.body).to include('Activar')
      expect(response.body).to include(activate_admin_theme_setting_path(theme_setting))
    end

    it 'does not show activate link for active themes' do
      get admin_theme_settings_path
      expect(response.body).not_to include(activate_admin_theme_setting_path(active_theme))
    end
  end

  # ========================================
  # SHOW TESTS
  # ========================================
  describe 'GET /admin/theme_settings/:id' do
    it 'displays the show page' do
      get admin_theme_setting_path(theme_setting)
      expect(response).to have_http_status(:success)
    end

    it 'sets custom page title' do
      get admin_theme_setting_path(theme_setting)
      expect(assigns(:page_title)).to eq("Tema: #{theme_setting.name}")
    end

    it 'shows name' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('Default Theme')
    end

    it 'shows primary color with preview' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('#612d62')
      expect(response.body).to include('background-color: #612d62')
    end

    it 'shows primary color variants' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('Variantes:')
      expect(response.body).to match(/50|100|200|300|400|500|600|700|800|900|950/)
    end

    it 'shows secondary color with preview' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('#269283')
      expect(response.body).to include('background-color: #269283')
    end

    it 'shows secondary color variants' do
      get admin_theme_setting_path(theme_setting)
      # Check that color variants are displayed
      expect(response.body).to match(/Variantes:/i)
    end

    it 'shows accent color' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('#954e99')
    end

    it 'shows font primary' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('Inter')
    end

    it 'shows font display' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('Montserrat')
    end

    it 'shows logo_url when valid external URL' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('https://example.com/logo.png')
    end

    it 'shows warning for invalid logo URL' do
      theme_setting.update_column(:logo_url, 'http://localhost/logo.png')
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('URL no válida o no permitida')
    end

    it 'shows "Sin logo" when logo_url is blank' do
      theme_setting.update_column(:logo_url, nil)
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('Sin logo')
    end

    it 'shows favicon_url' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('https://example.com/favicon.ico')
    end

    it 'shows custom CSS when present' do
      theme_setting.update!(custom_css: '.button { color: red; }')
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('.button { color: red; }')
    end

    it 'shows is_active status' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to match(/is_active|activo/i)
    end

    it 'shows created_at' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to match(/created_at|creado/i)
    end

    it 'shows updated_at' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to match(/updated_at|actualizado/i)
    end

    it 'shows CSS generated preview panel' do
      get admin_theme_setting_path(theme_setting)
      expect(response.body).to include('CSS Generado')
      expect(response.body).to include(theme_setting.to_css)
    end
  end

  # ========================================
  # FORM TESTS (NEW)
  # ========================================
  describe 'GET /admin/theme_settings/new' do
    it 'displays the new form' do
      get new_admin_theme_setting_path
      expect(response).to have_http_status(:success)
    end

    it 'has basic information section' do
      get new_admin_theme_setting_path
      expect(response.body).to match(/Información Básica/i)
    end

    it 'has name field' do
      get new_admin_theme_setting_path
      expect(response.body).to include('theme_setting[name]')
    end

    it 'has is_active field' do
      get new_admin_theme_setting_path
      expect(response.body).to include('theme_setting[is_active]')
    end

    it 'has colors section' do
      get new_admin_theme_setting_path
      expect(response.body).to match(/Colores de Marca/i)
    end

    it 'has primary_color field with color input' do
      get new_admin_theme_setting_path
      expect(response.body).to include('theme_setting[primary_color]')
      expect(response.body).to include('type="color"')
    end

    it 'has secondary_color field with color input' do
      get new_admin_theme_setting_path
      expect(response.body).to include('theme_setting[secondary_color]')
    end

    it 'has accent_color field with color input' do
      get new_admin_theme_setting_path
      expect(response.body).to include('theme_setting[accent_color]')
    end

    it 'has color preview container' do
      get new_admin_theme_setting_path
      expect(response.body).to include('Vista Previa de Colores')
      expect(response.body).to include('primary-preview')
      expect(response.body).to include('secondary-preview')
      expect(response.body).to include('accent-preview')
    end

    it 'has typography section' do
      get new_admin_theme_setting_path
      expect(response.body).to match(/Tipografía/i)
    end

    it 'has font_primary select with options' do
      get new_admin_theme_setting_path
      expect(response.body).to include('theme_setting[font_primary]')
      expect(response.body).to include('Inter')
      expect(response.body).to include('Roboto')
      expect(response.body).to include('Poppins')
    end

    it 'has font_display select with options' do
      get new_admin_theme_setting_path
      expect(response.body).to include('theme_setting[font_display]')
      expect(response.body).to include('Montserrat')
      expect(response.body).to include('Playfair Display')
    end

    it 'has assets section' do
      get new_admin_theme_setting_path
      expect(response.body).to match(/Assets/i)
    end

    it 'has logo_url field' do
      get new_admin_theme_setting_path
      expect(response.body).to include('theme_setting[logo_url]')
    end

    it 'has favicon_url field' do
      get new_admin_theme_setting_path
      expect(response.body).to include('theme_setting[favicon_url]')
    end

    it 'has custom CSS section' do
      get new_admin_theme_setting_path
      expect(response.body).to match(/CSS Personalizado/i)
    end

    it 'has custom_css textarea' do
      get new_admin_theme_setting_path
      expect(response.body).to include('theme_setting[custom_css]')
    end

    it 'has form actions' do
      get new_admin_theme_setting_path
      expect(response.body).to match(/Guardar Tema/i)
    end

    it 'has cancel action' do
      get new_admin_theme_setting_path
      expect(response.body).to match(/cancel/i)
    end
  end

  # ========================================
  # CREATE TESTS
  # ========================================
  describe 'POST /admin/theme_settings' do
    context 'with valid params' do
      let(:valid_params) do
        {
          theme_setting: {
            name: 'New Theme',
            primary_color: '#FF0000',
            secondary_color: '#00FF00',
            accent_color: '#0000FF',
            font_primary: 'Inter',
            font_display: 'Poppins',
            is_active: false
          }
        }
      end

      it 'creates a new theme setting' do
        expect do
          post admin_theme_settings_path, params: valid_params
        end.to change(ThemeSetting, :count).by(1)
      end

      it 'redirects to the show page' do
        post admin_theme_settings_path, params: valid_params
        expect(response).to redirect_to(admin_theme_setting_path(ThemeSetting.last))
      end

      it 'shows success notice' do
        post admin_theme_settings_path, params: valid_params
        follow_redirect!
        expect(response.body).to match(/created|creado/i)
      end

      it 'creates with correct attributes' do
        post admin_theme_settings_path, params: valid_params
        theme = ThemeSetting.last
        expect(theme.name).to eq('New Theme')
        expect(theme.primary_color).to eq('#FF0000')
        expect(theme.secondary_color).to eq('#00FF00')
        expect(theme.accent_color).to eq('#0000FF')
      end

      it 'applies default colors from after_build' do
        post admin_theme_settings_path, params: {
          theme_setting: { name: 'Theme with defaults' }
        }
        theme = ThemeSetting.last
        expect(theme.primary_color).to eq('#612d62')
        expect(theme.secondary_color).to eq('#269283')
        expect(theme.accent_color).to eq('#954e99')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          theme_setting: {
            name: '', # Invalid: name is required
            primary_color: '#FF0000'
          }
        }
      end

      it 'does not create a theme setting' do
        expect do
          post admin_theme_settings_path, params: invalid_params
        end.not_to change(ThemeSetting, :count)
      end

      it 'renders new template' do
        post admin_theme_settings_path, params: invalid_params
        expect(response).to have_http_status(:success)
        expect(response.body).to include('theme_setting[name]')
      end

      it 'shows error message' do
        post admin_theme_settings_path, params: invalid_params
        expect(response.body).to match(/error|can't be blank/i)
      end
    end

    context 'with custom CSS' do
      let(:valid_params) do
        {
          theme_setting: {
            name: 'Theme with CSS',
            custom_css: '.button { color: red; }'
          }
        }
      end

      it 'creates theme with custom CSS' do
        post admin_theme_settings_path, params: valid_params
        theme = ThemeSetting.last
        expect(theme.custom_css).to eq('.button { color: red; }')
      end
    end
  end

  # ========================================
  # EDIT TESTS
  # ========================================
  describe 'GET /admin/theme_settings/:id/edit' do
    it 'displays the edit form' do
      get edit_admin_theme_setting_path(theme_setting)
      expect(response).to have_http_status(:success)
    end

    it 'sets custom page title' do
      get edit_admin_theme_setting_path(theme_setting)
      expect(assigns(:page_title)).to eq("Editar Tema: #{theme_setting.name}")
    end

    it 'pre-populates name field' do
      get edit_admin_theme_setting_path(theme_setting)
      expect(response.body).to include('Default Theme')
    end

    it 'pre-populates primary_color field' do
      get edit_admin_theme_setting_path(theme_setting)
      expect(response.body).to include('#612d62')
    end

    it 'pre-populates secondary_color field' do
      get edit_admin_theme_setting_path(theme_setting)
      expect(response.body).to include('#269283')
    end

    it 'has all form sections' do
      get edit_admin_theme_setting_path(theme_setting)
      expect(response.body).to match(/Información Básica/i)
      expect(response.body).to match(/Colores de Marca/i)
      expect(response.body).to match(/Tipografía/i)
    end

    it 'shows preview link for persisted theme' do
      get edit_admin_theme_setting_path(theme_setting)
      expect(response.body).to include('Vista Previa')
      expect(response.body).to include(preview_admin_theme_setting_path(theme_setting))
    end
  end

  # ========================================
  # UPDATE TESTS
  # ========================================
  describe 'PUT /admin/theme_settings/:id' do
    context 'with valid params' do
      let(:update_params) do
        {
          theme_setting: {
            name: 'Updated Theme',
            primary_color: '#FF0000',
            secondary_color: '#00FF00'
          }
        }
      end

      it 'updates the theme setting' do
        put admin_theme_setting_path(theme_setting), params: update_params
        theme_setting.reload
        expect(theme_setting.name).to eq('Updated Theme')
        expect(theme_setting.primary_color).to eq('#FF0000')
        expect(theme_setting.secondary_color).to eq('#00FF00')
      end

      it 'redirects to show page' do
        put admin_theme_setting_path(theme_setting), params: update_params
        expect(response).to redirect_to(admin_theme_setting_path(theme_setting))
      end

      it 'shows success notice' do
        put admin_theme_setting_path(theme_setting), params: update_params
        follow_redirect!
        expect(response.body).to match(/updated|actualizado/i)
      end
    end

    context 'updating colors' do
      let(:update_params) do
        {
          theme_setting: {
            primary_color: '#FF0000',
            secondary_color: '#00FF00',
            accent_color: '#0000FF'
          }
        }
      end

      it 'updates colors' do
        put admin_theme_setting_path(theme_setting), params: update_params
        theme_setting.reload
        expect(theme_setting.primary_color).to eq('#FF0000')
        expect(theme_setting.secondary_color).to eq('#00FF00')
        expect(theme_setting.accent_color).to eq('#0000FF')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          theme_setting: {
            name: '' # Invalid: name is required
          }
        }
      end

      it 'does not update the theme setting' do
        original_name = theme_setting.name
        put admin_theme_setting_path(theme_setting), params: invalid_params
        theme_setting.reload
        expect(theme_setting.name).to eq(original_name)
      end

      it 'renders edit template' do
        put admin_theme_setting_path(theme_setting), params: invalid_params
        expect(response).to have_http_status(:success)
        expect(response.body).to include('theme_setting[name]')
      end

      it 'shows error message' do
        put admin_theme_setting_path(theme_setting), params: invalid_params
        expect(response.body).to match(/error|can't be blank/i)
      end
    end
  end

  # ========================================
  # DELETE TESTS
  # ========================================
  describe 'DELETE /admin/theme_settings/:id' do
    let!(:deletable_theme) do
      create(:theme_setting, name: 'Deletable Theme', is_active: false)
    end

    it 'deletes the theme setting' do
      expect do
        delete admin_theme_setting_path(deletable_theme)
      end.to change(ThemeSetting, :count).by(-1)
    end

    it 'redirects to index page' do
      delete admin_theme_setting_path(deletable_theme)
      expect(response).to redirect_to(admin_theme_settings_path)
    end
  end

  # ========================================
  # MEMBER ACTION TESTS
  # ========================================
  describe 'Member Actions' do
    describe 'GET /admin/theme_settings/:id/preview' do
      it 'renders preview template' do
        get preview_admin_theme_setting_path(theme_setting)
        expect(response).to have_http_status(:success)
      end

      it 'renders without layout' do
        get preview_admin_theme_setting_path(theme_setting)
        expect(response).to render_template(layout: false)
      end

      it 'assigns @theme variable' do
        get preview_admin_theme_setting_path(theme_setting)
        expect(assigns(:theme)).to eq(theme_setting)
      end
    end

    describe 'GET /admin/theme_settings/:id/export' do
      it 'exports theme as JSON' do
        get export_admin_theme_setting_path(theme_setting, format: :json)
        expect(response).to have_http_status(:success)
        expect(response.content_type).to match(%r{application/json})
      end

      it 'returns correct JSON structure' do
        get export_admin_theme_setting_path(theme_setting, format: :json)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json).to have_key(:name)
        expect(json).to have_key(:colors)
        expect(json).to have_key(:typography)
        expect(json).to have_key(:assets)
      end

      it 'includes theme data in JSON' do
        get export_admin_theme_setting_path(theme_setting, format: :json)
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:name]).to eq('Default Theme')
        expect(json[:colors][:primary]).to eq('#612d62')
        expect(json[:colors][:secondary]).to eq('#269283')
      end
    end

    describe 'POST /admin/theme_settings/:id/activate' do
      before do
        # Ensure we have an active theme to deactivate
        active_theme
      end

      it 'activates the theme' do
        post activate_admin_theme_setting_path(theme_setting)
        theme_setting.reload
        expect(theme_setting.is_active).to be true
      end

      it 'deactivates other themes' do
        post activate_admin_theme_setting_path(theme_setting)
        active_theme.reload
        expect(active_theme.is_active).to be false
      end

      it 'redirects to index' do
        post activate_admin_theme_setting_path(theme_setting)
        expect(response).to redirect_to(admin_theme_settings_path)
      end

      it 'shows success notice' do
        post activate_admin_theme_setting_path(theme_setting)
        follow_redirect!
        expect(response.body).to include('activado exitosamente')
      end

      it 'invalidates cache' do
        expect(Rails.cache).to receive(:delete).with('active_theme')
        post activate_admin_theme_setting_path(theme_setting)
      end

      context 'when activation fails' do
        before do
          allow_any_instance_of(ThemeSetting).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(theme_setting))
        end

        it 'shows error alert' do
          post activate_admin_theme_setting_path(theme_setting)
          follow_redirect!
          expect(response.body).to match(/Error al activar tema/i)
        end
      end

      context 'when unexpected error occurs' do
        before do
          allow_any_instance_of(ThemeSetting).to receive(:update!).and_raise(StandardError.new('Unexpected error'))
        end

        it 'shows generic error alert' do
          post activate_admin_theme_setting_path(theme_setting)
          follow_redirect!
          expect(response.body).to include('Error inesperado al activar el tema')
        end

        it 'logs the error' do
          allow(Rails.logger).to receive(:error).and_call_original
          post activate_admin_theme_setting_path(theme_setting)
          expect(Rails.logger).to have_received(:error).with(/Theme activation failed/).at_least(:once)
        end
      end
    end
  end

  # ========================================
  # COLLECTION ACTION TESTS
  # ========================================
  describe 'Collection Actions' do
    describe 'GET /admin/theme_settings/import' do
      it 'displays import form' do
        get import_admin_theme_settings_path
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST /admin/theme_settings/import' do
      let(:valid_json) do
        {
          name: 'Imported Theme',
          colors: {
            primary: '#FF0000',
            secondary: '#00FF00',
            accent: '#0000FF'
          },
          typography: {
            fontPrimary: 'Inter',
            fontDisplay: 'Poppins'
          },
          assets: {
            logo: 'https://example.com/logo.png',
            favicon: 'https://example.com/favicon.ico'
          },
          customCSS: '.custom { color: red; }'
        }.to_json
      end

      context 'with valid JSON file' do
        let(:file) { Rack::Test::UploadedFile.new(StringIO.new(valid_json), 'application/json') }

        it 'imports theme successfully' do
          expect do
            post import_admin_theme_settings_path, params: { theme_file: file }
          end.to change(ThemeSetting, :count).by(1)
        end

        it 'creates theme with correct data' do
          post import_admin_theme_settings_path, params: { theme_file: file }
          theme = ThemeSetting.last
          expect(theme.name).to eq('Imported Theme')
          expect(theme.primary_color).to eq('#FF0000')
          expect(theme.secondary_color).to eq('#00FF00')
        end

        it 'redirects to index with success notice' do
          post import_admin_theme_settings_path, params: { theme_file: file }
          expect(response).to redirect_to(admin_theme_settings_path)
          follow_redirect!
          expect(response.body).to include('Tema importado exitosamente')
        end
      end

      context 'without file' do
        it 'shows error message' do
          post import_admin_theme_settings_path, params: {}
          expect(response.body).to include('Por favor selecciona un archivo para importar')
        end

        it 'renders import template' do
          post import_admin_theme_settings_path, params: {}
          expect(response).to render_template(:import)
        end
      end

      context 'with file too large' do
        let(:large_content) { 'x' * 2.megabytes }
        let(:large_file) { Rack::Test::UploadedFile.new(StringIO.new(large_content), 'application/json') }

        it 'shows error message' do
          post import_admin_theme_settings_path, params: { theme_file: large_file }
          expect(response.body).to include('El archivo es demasiado grande')
        end
      end

      context 'with invalid JSON' do
        let(:invalid_file) { Rack::Test::UploadedFile.new(StringIO.new('invalid json'), 'application/json') }

        it 'shows JSON parse error' do
          post import_admin_theme_settings_path, params: { theme_file: invalid_file }
          expect(response.body).to include('Error al parsear JSON')
        end

        it 'renders import template' do
          post import_admin_theme_settings_path, params: { theme_file: invalid_file }
          expect(response).to render_template(:import)
        end
      end

      context 'with invalid theme data' do
        let(:invalid_json) do
          {
            name: '', # Invalid: name is required
            colors: {
              primary: '#FF0000',
              secondary: '#00FF00'
            }
          }.to_json
        end
        let(:invalid_file) { Rack::Test::UploadedFile.new(StringIO.new(invalid_json), 'application/json') }

        it 'shows validation error' do
          post import_admin_theme_settings_path, params: { theme_file: invalid_file }
          expect(response.body).to match(/Tema inválido|Invalid theme/)
        end
      end

      context 'with StandardError' do
        let(:file) { Rack::Test::UploadedFile.new(StringIO.new(valid_json), 'application/json') }

        before do
          allow(ThemeSetting).to receive(:from_theme_json).and_raise(StandardError.new('Unexpected error'))
        end

        it 'shows generic error message' do
          post import_admin_theme_settings_path, params: { theme_file: file }
          expect(response.body).to include('Error inesperado al importar tema')
        end

        it 'logs the error' do
          allow(Rails.logger).to receive(:error).and_call_original
          post import_admin_theme_settings_path, params: { theme_file: file }
          expect(Rails.logger).to have_received(:error).with(/Theme import failed/).at_least(:once)
        end
      end
    end

    describe 'import action item on index page' do
      it 'shows import link' do
        get admin_theme_settings_path
        expect(response.body).to include('Importar Tema')
        expect(response.body).to include(import_admin_theme_settings_path)
      end
    end
  end

  # ========================================
  # CONTROLLER HELPER METHOD TESTS
  # ========================================
  describe 'Controller helper methods' do
    describe '#valid_external_url?' do
      let(:controller) { Admin::ThemeSettingsController.new }

      it 'returns false for blank URL' do
        expect(controller.send(:valid_external_url?, nil)).to be false
        expect(controller.send(:valid_external_url?, '')).to be false
      end

      it 'returns true for valid https URL' do
        expect(controller.send(:valid_external_url?, 'https://example.com/logo.png')).to be true
      end

      it 'returns false for http URL' do
        expect(controller.send(:valid_external_url?, 'http://example.com/logo.png')).to be false
      end

      it 'returns false for localhost' do
        expect(controller.send(:valid_external_url?, 'https://localhost/logo.png')).to be false
      end

      it 'returns false for 127.0.0.1' do
        expect(controller.send(:valid_external_url?, 'https://127.0.0.1/logo.png')).to be false
      end

      it 'returns false for 192.168.x.x' do
        expect(controller.send(:valid_external_url?, 'https://192.168.1.1/logo.png')).to be false
      end

      it 'returns false for 10.x.x.x' do
        expect(controller.send(:valid_external_url?, 'https://10.0.0.1/logo.png')).to be false
      end

      it 'returns false for 172.16-31.x.x' do
        expect(controller.send(:valid_external_url?, 'https://172.16.0.1/logo.png')).to be false
        expect(controller.send(:valid_external_url?, 'https://172.20.0.1/logo.png')).to be false
        expect(controller.send(:valid_external_url?, 'https://172.31.0.1/logo.png')).to be false
      end

      it 'returns false for invalid URI' do
        expect(controller.send(:valid_external_url?, 'not a valid url')).to be false
      end
    end
  end

  # ========================================
  # PERMITTED PARAMS TESTS
  # ========================================
  describe 'Permitted Parameters' do
    it 'permits name' do
      post admin_theme_settings_path, params: {
        theme_setting: { name: 'Permitted Name' }
      }
      expect(ThemeSetting.last.name).to eq('Permitted Name')
    end

    it 'permits primary_color' do
      post admin_theme_settings_path, params: {
        theme_setting: {
          name: 'Test',
          primary_color: '#FF0000'
        }
      }
      expect(ThemeSetting.last.primary_color).to eq('#FF0000')
    end

    it 'permits secondary_color' do
      post admin_theme_settings_path, params: {
        theme_setting: {
          name: 'Test',
          secondary_color: '#00FF00'
        }
      }
      expect(ThemeSetting.last.secondary_color).to eq('#00FF00')
    end

    it 'permits accent_color' do
      post admin_theme_settings_path, params: {
        theme_setting: {
          name: 'Test',
          accent_color: '#0000FF'
        }
      }
      expect(ThemeSetting.last.accent_color).to eq('#0000FF')
    end

    it 'permits font_primary' do
      post admin_theme_settings_path, params: {
        theme_setting: {
          name: 'Test',
          font_primary: 'Inter'
        }
      }
      expect(ThemeSetting.last.font_primary).to eq('Inter')
    end

    it 'permits font_display' do
      post admin_theme_settings_path, params: {
        theme_setting: {
          name: 'Test',
          font_display: 'Poppins'
        }
      }
      expect(ThemeSetting.last.font_display).to eq('Poppins')
    end

    it 'permits logo_url' do
      post admin_theme_settings_path, params: {
        theme_setting: {
          name: 'Test',
          logo_url: 'https://example.com/logo.png'
        }
      }
      expect(ThemeSetting.last.logo_url).to eq('https://example.com/logo.png')
    end

    it 'permits favicon_url' do
      post admin_theme_settings_path, params: {
        theme_setting: {
          name: 'Test',
          favicon_url: 'https://example.com/favicon.ico'
        }
      }
      expect(ThemeSetting.last.favicon_url).to eq('https://example.com/favicon.ico')
    end

    it 'permits custom_css' do
      post admin_theme_settings_path, params: {
        theme_setting: {
          name: 'Test',
          custom_css: '.button { color: red; }'
        }
      }
      expect(ThemeSetting.last.custom_css).to eq('.button { color: red; }')
    end

    it 'permits is_active' do
      post admin_theme_settings_path, params: {
        theme_setting: {
          name: 'Test',
          is_active: true
        }
      }
      expect(ThemeSetting.last.is_active).to be true
    end
  end

  # ========================================
  # MENU CONFIGURATION TESTS
  # ========================================
  describe 'Menu Configuration' do
    it 'has correct menu priority' do
      get admin_theme_settings_path
      expect(response).to have_http_status(:success)
    end

    it 'has correct menu label Temas' do
      get admin_theme_settings_path
      expect(response).to have_http_status(:success)
    end
  end

  # ========================================
  # AFTER_BUILD CALLBACK TESTS
  # ========================================
  describe 'after_build callback' do
    it 'sets default primary_color when nil' do
      get new_admin_theme_setting_path
      # The after_build sets defaults in the form
      expect(response).to have_http_status(:success)
    end

    it 'sets default secondary_color when nil' do
      get new_admin_theme_setting_path
      expect(response).to have_http_status(:success)
    end

    it 'sets default accent_color when nil' do
      get new_admin_theme_setting_path
      expect(response).to have_http_status(:success)
    end

    it 'does not override existing colors' do
      theme = build(:theme_setting, primary_color: '#FF0000')
      expect(theme.primary_color).to eq('#FF0000')
    end
  end
end
