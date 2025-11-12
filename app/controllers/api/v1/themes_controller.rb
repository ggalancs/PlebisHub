# frozen_string_literal: true

module Api
  module V1
    class ThemesController < ApplicationController
      # Permitir acceso sin autenticación para GET requests
      skip_before_action :verify_authenticity_token, only: [:index, :show]
      before_action :set_theme, only: [:show, :activate]
      before_action :require_admin, only: [:activate]

      # GET /api/v1/themes
      # Retorna todos los temas disponibles
      def index
        @themes = ThemeSetting.all.order(created_at: :desc)

        render json: @themes.map(&:to_theme_json)
      end

      # GET /api/v1/themes/:id
      # Retorna un tema específico
      def show
        render json: @theme.to_theme_json
      end

      # POST /api/v1/themes/:id/activate
      # Activa un tema específico (solo admins)
      def activate
        ThemeSetting.update_all(is_active: false)
        @theme.update!(is_active: true)

        render json: {
          success: true,
          message: "Tema '#{@theme.name}' activado exitosamente",
          theme: @theme.to_theme_json
        }
      rescue StandardError => e
        render json: {
          success: false,
          error: e.message
        }, status: :unprocessable_entity
      end

      # GET /api/v1/themes/active
      # Retorna el tema activo actual
      def active
        @theme = ThemeSetting.active

        if @theme
          render json: @theme.to_theme_json
        else
          render json: {
            name: 'Default',
            colors: {
              primary: '#612d62',
              secondary: '#269283',
              accent: '#954e99'
            },
            typography: {
              fontPrimary: 'Inter',
              fontDisplay: 'Montserrat'
            }
          }
        end
      end

      private

      def set_theme
        @theme = ThemeSetting.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {
          success: false,
          error: 'Tema no encontrado'
        }, status: :not_found
      end

      def require_admin
        # Verificar si el usuario actual es administrador
        # Ajustar según tu sistema de autenticación
        unless current_user&.is_admin?
          render json: {
            success: false,
            error: 'No tienes permisos para realizar esta acción'
          }, status: :forbidden
        end
      end
    end
  end
end
