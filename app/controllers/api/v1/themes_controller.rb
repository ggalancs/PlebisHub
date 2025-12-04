# frozen_string_literal: true

module Api
  module V1
    class ThemesController < ApplicationController
      # Permitir acceso sin autenticación para GET requests
      skip_before_action :verify_authenticity_token, only: %i[index show]
      before_action :set_theme, only: %i[show activate]
      before_action :require_admin, only: [:activate]

      # GET /api/v1/themes
      # Retorna todos los temas disponibles con paginación
      def index
        page = params[:page] || 1
        per_page = [params[:per_page].to_i, 100].min
        per_page = 20 if per_page <= 0

        @themes = ThemeSetting
                  .order(created_at: :desc)
                  .offset((page.to_i - 1) * per_page)
                  .limit(per_page)

        total_count = ThemeSetting.count

        render json: {
          themes: @themes.map(&:to_theme_json),
          meta: {
            current_page: page.to_i,
            per_page: per_page,
            total_count: total_count,
            total_pages: (total_count.to_f / per_page).ceil
          }
        }
      end

      # GET /api/v1/themes/:id
      # Retorna un tema específico
      def show
        render json: @theme.to_theme_json
      end

      # POST /api/v1/themes/:id/activate
      # Activa un tema específico (solo admins)
      def activate
        ActiveRecord::Base.transaction do
          ThemeSetting.lock.update_all(is_active: false)
          @theme.lock!
          @theme.update!(is_active: true)
        end

        # Invalidar cache
        Rails.cache.delete('active_theme')

        render json: {
          success: true,
          message: "Tema '#{@theme.name}' activado exitosamente",
          theme: @theme.to_theme_json
        }
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
        render json: {
          success: false,
          error: e.message,
          details: e.record&.errors&.full_messages
        }, status: :unprocessable_content
      rescue StandardError => e
        Rails.logger.error "Theme activation failed: #{e.class} - #{e.message}"
        render json: {
          success: false,
          error: 'Error al activar el tema'
        }, status: :internal_server_error
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
        return if current_user&.is_admin?

        render json: {
          success: false,
          error: 'No tienes permisos para realizar esta acción'
        }, status: :forbidden
      end
    end
  end
end
