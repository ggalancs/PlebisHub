# frozen_string_literal: true

ActiveAdmin.register EngineActivation do
  menu priority: 1, label: "Engines"

  permit_params :engine_name, :enabled, :description, :configuration, :load_priority

  # Index page - list of all engines
  index do
    selectable_column
    id_column
    column :engine_name do |ea|
      strong ea.engine_name
    end
    column :enabled do |ea|
      status_tag(ea.enabled ? "Active" : "Inactive", ea.enabled ? :ok : :warning)
    end
    column :description do |ea|
      truncate(ea.description, length: 100)
    end
    column :load_priority
    column :updated_at
    actions defaults: true do |ea|
      if ea.enabled
        link_to 'Disable', disable_admin_engine_activation_path(ea),
                method: :post, class: 'button', data: { confirm: 'Are you sure?' }
      else
        if ea.can_enable?
          link_to 'Enable', enable_admin_engine_activation_path(ea),
                  method: :post, class: 'button', data: { confirm: 'Are you sure?' }
        else
          content_tag(:span, 'Missing dependencies', class: 'status_tag warning')
        end
      end
    end
  end

  # Filter sidebar
  filter :engine_name
  filter :enabled
  filter :load_priority
  filter :updated_at

  # Show page - detailed view of an engine
  show do
    attributes_table do
      row :id
      row :engine_name do |ea|
        strong ea.engine_name
      end
      row :enabled do |ea|
        status_tag(ea.enabled ? "Active" : "Inactive", ea.enabled ? :ok : :warning)
      end
      row :description
      row :load_priority
      row :configuration do |ea|
        pre JSON.pretty_generate(ea.configuration)
      end
      row :created_at
      row :updated_at
    end

    panel "Engine Details" do
      if defined?(PlebisCore::EngineRegistry)
        engine_info = PlebisCore::EngineRegistry.info(resource.engine_name)

        attributes_table_for OpenStruct.new(engine_info) do
          row("Name") { engine_info[:name] }
          row("Version") { engine_info[:version] }
          row("Models") { engine_info[:models].join(', ') }
          row("Controllers") { engine_info[:controllers].join(', ') }
          row("Dependencies") do
            deps = engine_info[:dependencies] || []
            if deps.empty?
              "None"
            else
              deps.map do |dep|
                if dep == 'User' || EngineActivation.enabled?(dep)
                  status_tag(dep, :ok)
                else
                  status_tag(dep, :error)
                end
              end.join(' ').html_safe
            end
          end
        end
      else
        para "Engine registry not available"
      end
    end

    active_admin_comments
  end

  # Form for creating/editing engine activations
  form do |f|
    f.semantic_errors

    f.inputs "Engine Details" do
      if f.object.new_record?
        if defined?(PlebisCore::EngineRegistry)
          f.input :engine_name, as: :select,
                  collection: PlebisCore::EngineRegistry.available_engines,
                  include_blank: false,
                  hint: "Select the engine to activate"
        else
          f.input :engine_name, hint: "Enter the engine name"
        end
      else
        f.input :engine_name, input_html: { disabled: true },
                hint: "Engine name cannot be changed after creation"
      end

      f.input :enabled, as: :boolean,
              hint: "Enable this engine to load it on next application reload"

      f.input :description, as: :text,
              hint: "Describe what this engine does",
              input_html: { rows: 3 }

      f.input :load_priority, as: :number,
              hint: "Lower numbers load first (default: 100)"
    end

    f.inputs "Configuration (JSON)", class: 'json-config' do
      f.input :configuration, as: :text,
              hint: "Engine-specific configuration in JSON format. Leave empty for defaults.",
              input_html: { rows: 10, placeholder: '{"key": "value"}' }
    end

    f.actions do
      f.action :submit
      f.cancel_link
    end
  end

  # Custom member actions for enabling/disabling engines
  member_action :enable, method: :post do
    if resource.can_enable?
      EngineActivation.enable!(resource.engine_name)
      redirect_to admin_engine_activations_path,
                  notice: "Engine '#{resource.engine_name}' enabled. Application reload may be required."
    else
      deps = PlebisCore::EngineRegistry.dependencies_for(resource.engine_name)
      missing = deps.reject { |d| d == 'User' || EngineActivation.enabled?(d) }
      redirect_to admin_engine_activations_path,
                  alert: "Cannot enable '#{resource.engine_name}'. Missing dependencies: #{missing.join(', ')}"
    end
  end

  member_action :disable, method: :post do
    # Check if any enabled engine depends on this one
    if defined?(PlebisCore::EngineRegistry)
      dependents = PlebisCore::EngineRegistry.dependents_of(resource.engine_name)
      enabled_dependents = dependents.select { |d| EngineActivation.enabled?(d) }

      if enabled_dependents.any?
        redirect_to admin_engine_activations_path,
                    alert: "Cannot disable '#{resource.engine_name}'. " \
                           "These engines depend on it: #{enabled_dependents.join(', ')}"
        return
      end
    end

    EngineActivation.disable!(resource.engine_name)
    redirect_to admin_engine_activations_path,
                notice: "Engine '#{resource.engine_name}' disabled. Application reload may be required."
  end

  # Before save callback to parse JSON configuration
  before_save do |engine_activation|
    if engine_activation.configuration.is_a?(String)
      begin
        engine_activation.configuration = JSON.parse(engine_activation.configuration)
      rescue JSON::ParserError => e
        engine_activation.errors.add(:configuration, "Invalid JSON: #{e.message}")
        throw :abort
      end
    end
  end
end
