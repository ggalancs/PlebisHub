# frozen_string_literal: true

# Controller Test Helpers
#
# Provides helper methods to bypass ApplicationController filters
# that can interfere with testing

module RequestSpecHelpers
  # Stub asset_path to prevent AssetNotFound errors in tests
  # Returns a placeholder path for any requested asset
  def asset_path(asset_name, options = {})
    "/assets/test-placeholder-#{asset_name}"
  end

  # Stub funding_path route helper from CMS engine
  def funding_path
    "/financiacion"
  end
end

RSpec.configure do |config|
  # Include asset helpers for request specs
  config.include RequestSpecHelpers, type: :request

  # For request specs, stub out problematic ApplicationController before_actions
  # This prevents redirects caused by user validation issues
  config.before(:each, type: :request) do
    # Add CMS engine route helpers to view context
    # These are defined in engines/plebis_cms/config/routes.rb
    ApplicationController.helper do
      def funding_path
        "/financiacion"
      end

      def faq_path
        "/preguntas-frecuentes"
      end

      def guarantees_path
        "/comision-de-garantias-democraticas"
      end

      def blog_path
        "/brujula"
      end

      def notices_path
        "/notices"
      end
    end

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
    allow_any_instance_of(ActionView::Base).to receive(:asset_path) do |_, asset_name, options = {}|
      "/assets/test-placeholder-#{asset_name}"
    end

    allow_any_instance_of(ActionView::Base).to receive(:image_path) do |_, source, options = {}|
      "/assets/test-placeholder-#{source}"
    end

    allow_any_instance_of(ActionView::Base).to receive(:image_tag) do |_, source, options = {}|
      options_str = options.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
      "<img src=\"/assets/test-placeholder-#{source}\" #{options_str} />".html_safe
    end
  end
end
