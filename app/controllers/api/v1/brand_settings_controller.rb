# frozen_string_literal: true

module Api
  module V1
    class BrandSettingsController < ApplicationController
      # Allow public access to GET requests (brand settings are public)
      skip_before_action :verify_authenticity_token, only: [:current, :show]
      before_action :set_brand_setting, only: [:show]

      # GET /api/v1/brand_settings/current
      # Returns the active brand setting for the current user's organization
      # Falls back to global brand setting if no organization-specific setting exists
      def current
        organization_id = current_user&.organization_id || params[:organization_id]

        @brand_setting = BrandSetting.current_for_organization(organization_id)

        render json: @brand_setting.to_brand_json
      rescue StandardError => e
        Rails.logger.error "Brand settings fetch failed: #{e.class} - #{e.message}"
        render json: {
          success: false,
          error: 'Error al obtener la configuración de marca',
          fallback: default_brand_json
        }, status: :internal_server_error
      end

      # GET /api/v1/brand_settings/:id
      # Returns a specific brand setting (useful for preview in admin)
      def show
        render json: @brand_setting.to_brand_json
      end

      private

      def set_brand_setting
        @brand_setting = BrandSetting.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          error: 'Configuración de marca no encontrada'
        }, status: :not_found
      end

      # Default brand JSON for fallback scenarios
      def default_brand_json
        {
          theme: {
            id: 'default',
            name: 'PlebisHub Default',
            description: 'Original PlebisHub brand colors',
            colors: {
              primary: '#612d62',
              primaryLight: '#8a4f98',
              primaryDark: '#4c244a',
              secondary: '#269283',
              secondaryLight: '#14b8a6',
              secondaryDark: '#0f766e'
            }
          },
          scope: 'global',
          active: true,
          version: 1,
          customColors: nil
        }
      end
    end
  end
end
