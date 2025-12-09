# frozen_string_literal: true

module ApplicationHelper
  # Rails 7.2 FIX: semantic_form_with doesn't exist in formtastic gem
  # This method provides compatibility by delegating to semantic_form_for
  # which is the correct formtastic helper method
  def semantic_form_with(model: nil, scope: nil, url: nil, **options, &)
    # Convert Rails 7+ form_with params to formtastic semantic_form_for params
    record = model
    as = scope

    # Pass through url and other options
    form_options = options.dup
    form_options[:url] = url if url
    form_options[:as] = as if as

    semantic_form_for(record, **form_options, &)
  end

  # Like link_to but third parameter is an array of options for current_page?.
  def nav_menu_link_to(name, icon, url, current_urls, html_options = {})
    html_options[:class] ||= ''
    html_options[:class] += ' active' if current_urls.any? { |u| current_page?(u) }
    link_to(fa_icon(icon) + content_tag(:span, name), url, html_options)
  end

  def new_notifications_class
    # TODO: Implement check if there are any new notifications
    # If so, return "claim"
    ''
  end

  def current_lang?(lang)
    I18n.locale.to_s.downcase == lang.to_s.downcase
  end

  def current_lang_class(lang)
    if current_lang? lang
      'active'
    else
      ''
    end
  end

  def info_box(&)
    content = with_output_buffer(&)
    render partial: 'application/info', locals: { content: content }
  end

  # Renders an alert with given title,
  # text for close-button and content given in
  # a block.
  def alert_box(title, close_text = '', &)
    render_flash('application/alert', title, close_text, &)
  end

  # Renders an error with given title,
  # text for close-button and content given in
  # a block.
  def error_box(title, close_text = '', &)
    render_flash('application/error', title, close_text, &)
  end

  # Generalization from render_alert and render_error
  def render_flash(partial_name, title, close_text = '', &)
    content = with_output_buffer(&)
    render partial: partial_name, locals: { title: title, content: content, close_text: close_text }
  end

  def field_notice_box
    render partial: 'application/form_field_notice'
  end

  def errors_in_form(resource)
    render partial: 'application/errors_in_form', locals: { resource: resource }
  end

  def steps_nav current_step, *steps_text
    render partial: 'application/steps_nav',
           locals: { first_step: steps_text[0],
                     second_step: steps_text[1],
                     third_step: steps_text[2],
                     steps_text: steps_text,
                     current_step: current_step }
  end

  def body_class(signed_in, controller, action)
    classes = []
    classes << (signed_in ? 'signed-in' : 'logged-out')
    classes << "controller-#{controller}" if controller.present?
    classes << "action-#{action}" if action.present?
    classes.join(' ')
  end

  # ==========================================
  # Modern Frontend Helpers
  # ==========================================

  # Check if Vite assets are available (for hybrid legacy/modern setup)
  def vite_asset_available?
    defined?(ViteRails) && ViteRails.instance.config.present?
  rescue StandardError
    false
  end

  # Check if a page should use legacy assets (Bootstrap/jQuery)
  # Override in specific controllers/views as needed
  def use_legacy_assets?
    # Default to true during migration, flip to false when migration complete
    true
  end

  # Check if a page should use modern assets (Vue/Tailwind)
  def use_modern_assets?
    vite_asset_available?
  end

  # Mount point helper for Vue components in ERB templates
  # Usage: <%= vue_component('ComponentName', { prop1: 'value1' }) %>
  def vue_component(name, props = {}, **html_options)
    html_options[:data] ||= {}
    html_options[:data][:vue_component] = name
    html_options[:data][:props] = props.to_json if props.present?

    content_tag(:div, '', **html_options)
  end

  # Helper to include component-specific styles
  def component_styles(*components)
    components.map do |component|
      stylesheet_link_tag("components/#{component}", media: 'all')
    end.join.html_safe
  end

  # SVG icon helper (for Lucide icons or custom SVGs)
  def svg_icon(name, **options)
    options[:class] = "icon icon-#{name} #{options[:class]}".strip
    options[:width] ||= 24
    options[:height] ||= 24

    content_tag(:svg, **options) do
      content_tag(:use, '', href: "#icon-#{name}")
    end
  end

  # Flash message type mapping (Bootstrap -> Tailwind)
  def flash_type_class(type)
    case type.to_s
    when 'notice', 'success'
      'alert-success'
    when 'alert', 'error', 'danger'
      'alert-error'
    when 'warning'
      'alert-warning'
    else
      'alert-info'
    end
  end

  # Button helper with consistent styling
  def styled_button(text, url = nil, **options)
    variant = options.delete(:variant) || :primary
    size = options.delete(:size) || :md
    icon = options.delete(:icon)

    options[:class] = [
      'btn',
      "btn-#{variant}",
      size != :md ? "btn-#{size}" : nil,
      options[:class]
    ].compact.join(' ')

    content = icon ? "#{svg_icon(icon)} #{text}".html_safe : text

    if url
      link_to(content, url, **options)
    else
      content_tag(:button, content, **options)
    end
  end
end
