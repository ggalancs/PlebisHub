# frozen_string_literal: true

ActiveAdmin.register ThemeSetting do
  menu priority: 10, label: 'Temas'

  permit_params :name, :primary_color, :secondary_color, :accent_color,
                :font_primary, :font_display, :logo_url, :favicon_url,
                :custom_css, :is_active

  index do
    selectable_column
    id_column
    column :name
    column 'Color Primario', :primary_color do |theme|
      span style: "background-color: #{theme.primary_color}; padding: 5px 15px; color: white; border-radius: 4px; display: inline-block; min-width: 80px; text-align: center;" do
        theme.primary_color
      end
    end
    column 'Color Secundario', :secondary_color do |theme|
      span style: "background-color: #{theme.secondary_color}; padding: 5px 15px; color: white; border-radius: 4px; display: inline-block; min-width: 80px; text-align: center;" do
        theme.secondary_color
      end
    end
    column 'Activo', :is_active do |theme|
      status_tag(theme.is_active ? 'Sí' : 'No', theme.is_active ? :ok : :no)
    end
    column :created_at
    actions defaults: true do |theme|
      link_to 'Vista Previa', preview_admin_theme_setting_path(theme), class: 'member_link', target: '_blank'
      link_to 'Exportar JSON', export_admin_theme_setting_path(theme, format: :json), class: 'member_link'
      if !theme.is_active?
        link_to 'Activar', activate_admin_theme_setting_path(theme), method: :post, class: 'member_link', data: { confirm: '¿Activar este tema?' }
      end
    end
  end

  show do
    attributes_table do
      row :name
      row 'Color Primario' do |theme|
        span style: "background-color: #{theme.primary_color}; padding: 10px 20px; color: white; border-radius: 4px; display: inline-block; margin-right: 10px;" do
          theme.primary_color
        end
        div style: 'margin-top: 10px;' do
          strong 'Variantes:'
        end
        div style: 'display: flex; gap: 5px; flex-wrap: wrap; margin-top: 5px;' do
          theme.color_variants(theme.primary_color).each do |tone, hex|
            div style: "background-color: #{hex}; width: 60px; height: 60px; border-radius: 4px; display: flex; align-items: center; justify-content: center; color: #{tone < 500 ? '#000' : '#fff'}; font-size: 11px; font-weight: bold;" do
              tone.to_s
            end
          end
        end
      end
      row 'Color Secundario' do |theme|
        span style: "background-color: #{theme.secondary_color}; padding: 10px 20px; color: white; border-radius: 4px; display: inline-block; margin-right: 10px;" do
          theme.secondary_color
        end
        div style: 'margin-top: 10px;' do
          strong 'Variantes:'
        end
        div style: 'display: flex; gap: 5px; flex-wrap: wrap; margin-top: 5px;' do
          theme.color_variants(theme.secondary_color).each do |tone, hex|
            div style: "background-color: #{hex}; width: 60px; height: 60px; border-radius: 4px; display: flex; align-items: center; justify-center; color: #{tone < 500 ? '#000' : '#fff'}; font-size: 11px; font-weight: bold;" do
              tone.to_s
            end
          end
        end
      end
      row :accent_color do |theme|
        span style: "background-color: #{theme.accent_color}; padding: 10px 20px; color: white; border-radius: 4px; display: inline-block;" do
          theme.accent_color
        end
      end
      row :font_primary
      row :font_display
      row :logo_url do |theme|
        if theme.logo_url.present?
          image_tag(theme.logo_url, style: 'max-width: 200px; max-height: 100px;')
        else
          'Sin logo'
        end
      end
      row :favicon_url
      row :custom_css do |theme|
        pre theme.custom_css if theme.custom_css.present?
      end
      row :is_active
      row :created_at
      row :updated_at
    end

    panel 'CSS Generado (Vista Previa)' do
      pre style: 'background: #f5f5f5; padding: 15px; border-radius: 4px; overflow-x: auto; max-height: 400px;' do
        resource.to_css
      end
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Información Básica' do
      f.input :name, label: 'Nombre del Tema'
      f.input :is_active, label: 'Activar este tema', hint: 'Solo un tema puede estar activo a la vez'
    end

    f.inputs 'Colores de Marca' do
      f.input :primary_color, as: :string, input_html: { type: 'color' },
              hint: 'Color primario (púrpura)', label: 'Color Primario'
      f.input :secondary_color, as: :string, input_html: { type: 'color' },
              hint: 'Color secundario (verde)', label: 'Color Secundario'
      f.input :accent_color, as: :string, input_html: { type: 'color' },
              hint: 'Color de acento', label: 'Color de Acento'

      # Preview de colores
      li class: 'color-preview' do
        div id: 'color-preview-container', style: 'margin-top: 20px; padding: 15px; background: #f9f9f9; border-radius: 4px;' do
          h4 'Vista Previa de Colores:', style: 'margin-bottom: 10px;'
          div style: 'display: flex; gap: 20px;' do
            div style: 'text-align: center;' do
              div id: 'primary-preview', style: 'width: 100px; height: 100px; border-radius: 8px; border: 2px solid #ccc; margin-bottom: 5px;'
              p 'Primario', style: 'margin: 0; font-weight: bold;'
            end
            div style: 'text-align: center;' do
              div id: 'secondary-preview', style: 'width: 100px; height: 100px; border-radius: 8px; border: 2px solid #ccc; margin-bottom: 5px;'
              p 'Secundario', style: 'margin: 0; font-weight: bold;'
            end
            div style: 'text-align: center;' do
              div id: 'accent-preview', style: 'width: 100px; height: 100px; border-radius: 8px; border: 2px solid #ccc; margin-bottom: 5px;'
              p 'Acento', style: 'margin: 0; font-weight: bold;'
            end
          end
        end
      end
    end

    f.inputs 'Tipografía' do
      f.input :font_primary, as: :select,
              collection: ['Inter', 'Roboto', 'Open Sans', 'Lato', 'Poppins', 'Montserrat', 'Raleway'],
              hint: 'Fuente para texto general', label: 'Fuente Principal',
              include_blank: 'Seleccionar fuente...'
      f.input :font_display, as: :select,
              collection: ['Montserrat', 'Playfair Display', 'Raleway', 'Oswald', 'Bebas Neue', 'Poppins'],
              hint: 'Fuente para títulos y encabezados', label: 'Fuente de Display',
              include_blank: 'Seleccionar fuente...'
    end

    f.inputs 'Assets' do
      f.input :logo_url, hint: 'URL del logo principal', label: 'URL del Logo'
      f.input :favicon_url, hint: 'URL del favicon', label: 'URL del Favicon'
    end

    f.inputs 'CSS Personalizado' do
      f.input :custom_css, as: :text, input_html: { rows: 15, style: 'font-family: monospace;' },
              hint: 'CSS adicional para personalizaciones avanzadas'
    end

    f.actions do
      f.action :submit, label: 'Guardar Tema'
      f.action :cancel, wrapper_html: { class: 'cancel' }
      li do
        if f.object.persisted?
          link_to 'Vista Previa', preview_admin_theme_setting_path(f.object),
                  class: 'button', target: '_blank'
        end
      end
    end
  end

  # JavaScript para live preview de colores
  after_build do |theme|
    theme.primary_color ||= '#612d62'
    theme.secondary_color ||= '#269283'
    theme.accent_color ||= '#954e99'
  end

  # Custom member actions
  member_action :preview, method: :get do
    @theme = resource
    render 'admin/theme_settings/preview', layout: 'preview'
  end

  member_action :export, method: :get do
    @theme = resource
    respond_to do |format|
      format.json do
        render json: @theme.to_theme_json
      end
    end
  end

  member_action :activate, method: :post do
    @theme = resource
    ThemeSetting.update_all(is_active: false)
    @theme.update!(is_active: true)
    redirect_to admin_theme_settings_path, notice: "Tema '#{@theme.name}' activado exitosamente"
  end

  collection_action :import, method: [:get, :post] do
    if request.post?
      file = params[:theme_file]
      if file.present?
        begin
          json_data = JSON.parse(file.read, symbolize_names: true)
          @theme = ThemeSetting.from_theme_json(json_data)

          if @theme.persisted?
            redirect_to admin_theme_settings_path, notice: 'Tema importado exitosamente'
          else
            flash.now[:error] = 'Error al importar tema: ' + @theme.errors.full_messages.join(', ')
            render :import
          end
        rescue JSON::ParserError => e
          flash.now[:error] = "Error al parsear JSON: #{e.message}"
          render :import
        rescue => e
          flash.now[:error] = "Error al importar tema: #{e.message}"
          render :import
        end
      else
        flash.now[:error] = 'Por favor selecciona un archivo para importar'
        render :import
      end
    end
  end

  # Agregar acción de importar al menú de colección
  action_item :import, only: :index do
    link_to 'Importar Tema', import_admin_theme_settings_path
  end
end

# JavaScript para preview en tiempo real (inline)
ActiveAdmin.register ThemeSetting do
  controller do
    def show
      @page_title = "Tema: #{resource.name}"
      show!
    end

    def edit
      @page_title = "Editar Tema: #{resource.name}"
      edit!
    end
  end
end
