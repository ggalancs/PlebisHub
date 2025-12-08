# frozen_string_literal: true

# Controller Test Helpers
#
# Provides helper methods to bypass ApplicationController filters
# that can interfere with testing

module RequestSpecHelpers
  # Stub asset_path to prevent AssetNotFound errors in tests
  # Returns a placeholder path for any requested asset
  def asset_path(asset_name, _options = {})
    "/assets/test-placeholder-#{asset_name}"
  end

  # Stub funding_path route helper from CMS engine
  def funding_path
    '/financiacion'
  end
end

# Define custom route helpers in a module to avoid redefinition warnings
# This module is included as a helper once during test setup
module TestRouteHelpers
  # Devise route helpers
  def edit_user_registration_path
    "/#{I18n.locale}/users/edit"
  end

  def new_user_session_path
    "/#{I18n.locale}/users/sign_in"
  end

  def destroy_user_session_path
    "/#{I18n.locale}/users/sign_out"
  end

  # Main app route helpers
  def root_path
    "/#{I18n.locale}"
  end

  def qr_code_path
    "/#{I18n.locale}/qr"
  end

  def new_collaboration_path(*_args)
    "/#{I18n.locale}/colabora"
  end

  def microcredit_path
    "/#{I18n.locale}/microcreditos"
  end

  # CMS engine route helpers
  def funding_path
    "/#{I18n.locale}/financiacion"
  end

  def faq_path
    "/#{I18n.locale}/preguntas-frecuentes"
  end

  def guarantees_path
    "/#{I18n.locale}/comision-de-garantias-democraticas"
  end

  def blog_path
    "/#{I18n.locale}/brujula"
  end

  def notices_path
    "/#{I18n.locale}/notices"
  end
end

RSpec.configure do |config|
  # Include asset helpers for request specs
  config.include RequestSpecHelpers, type: :request

  # Configure routes for controller specs
  # Controller specs in Rails 7 need explicit routes configuration
  config.before(:each, type: :controller) do
    # Make all application routes available in controller specs
    @routes = Rails.application.routes
  end

  # Include the TestRouteHelpers once before all request specs
  config.before(:suite) do
    # Add the route helpers module as a helper to ApplicationController
    # This prevents method redefinition warnings by only including once
    # Use _helpers which returns the actual module, not the instance
    unless ApplicationController._helpers.included_modules.include?(TestRouteHelpers)
      ApplicationController.helper TestRouteHelpers
    end
  end

  # For request specs, stub out problematic ApplicationController before_actions
  # This prevents redirects caused by user validation issues
  config.before(:each, type: :request) do
    # Set default URL options to include locale
    # This ensures all route helpers generate URLs with the correct locale
    Rails.application.routes.default_url_options[:locale] = I18n.locale

    # Stub the problematic before_actions to prevent redirects
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
    allow_any_instance_of(ApplicationController).to receive(:banned_user).and_return(nil)
    allow_any_instance_of(ApplicationController).to receive(:admin_logger).and_return(nil)

    # Stub MicrocreditController's init_env to prevent configuration-related redirects
    if defined?(PlebisMicrocredit::MicrocreditController)
      allow_any_instance_of(PlebisMicrocredit::MicrocreditController).to receive(:init_env) do |controller|
        controller.instance_variable_set(:@brand, 'test_brand')
        controller.instance_variable_set(:@brand_config, {
                                           'name' => 'Test Organization',
                                           'mail_from' => 'test@example.com',
                                           'main_url' => 'http://test.example.com',
                                           'twitter_account' => '@testorg',
                                           'external' => false
                                         })
        controller.instance_variable_set(:@external, false)
        controller.instance_variable_set(:@url_params, {})
      end
    end

    # Stub asset helpers in view context to prevent AssetNotFound errors
    allow_any_instance_of(ActionView::Base).to receive(:asset_path) do |_, asset_name, _options = {}|
      "/assets/test-placeholder-#{asset_name}"
    end

    allow_any_instance_of(ActionView::Base).to receive(:image_path) do |_, source, _options = {}|
      "/assets/test-placeholder-#{source}"
    end

    allow_any_instance_of(ActionView::Base).to receive(:image_tag) do |_, source, options = {}|
      options_str = options.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
      "<img src=\"/assets/test-placeholder-#{source}\" #{options_str} />".html_safe
    end
  end
end
