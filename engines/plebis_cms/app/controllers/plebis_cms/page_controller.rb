# frozen_string_literal: true

require 'securerandom'

module PlebisCms
  # IMPORTANT SECURITY NOTE:
  # The add_user_params method exposes PII in URL parameters for external form integration.
  # This is a known architectural issue that should be migrated to POST requests or
  # session-based data transfer to comply with GDPR/CCPA data minimization principles.
  # Current implementation required for backward compatibility with external forms system.
  class PageController < ApplicationController
    include ERB::Util

    # HIGH PRIORITY FIX: Replaced deprecated before_filter with before_action
    # Rails 7.2 FIX: Removed :count_votes from except list - action doesn't exist in controller
    # Rails 7.1+ validates callback action lists and raises errors for non-existent actions
    before_action :authenticate_user!, except: [
      :privacy_policy, :faq, :guarantees, :funding, :guarantees_form, :show_form,
      :old_circles_data_validation, :primarias_andalucia, :listas_primarias_andaluzas,
      :responsables_organizacion_municipales,
      :responsables_municipales_andalucia, :plaza_plebisbrand_municipal,
      :portal_transparencia_cc_estatal, :mujer_igualdad, :alta_consulta_ciudadana,
      :representantes_electorales_extranjeros, :responsables_areas_cc_autonomicos,
      :apoderados_campana_autonomica_andalucia, :comparte_cambio_valoracion_propietarios,
      :comparte_cambio_valoracion_usuarios, :avales_candidaturas_primarias, :iniciativa_ciudadana
    ]

    # HIGH PRIORITY FIX: Replaced deprecated before_filter with before_action
    before_action :set_metas

    def set_metas
      @current_elections = Election.active
      # MEDIUM PRIORITY FIX: Removed unused variable 'election'
      # Previous code selected election with meta_description but never used it

      @meta_description = Rails.application.secrets.metas["description"] if @meta_description.nil?
      # MEDIUM PRIORITY FIX: Fixed logic bug - was checking @meta_description instead of @meta_image
      @meta_image = Rails.application.secrets.metas["image"] if @meta_image.nil?
    end

    def show_form
      # HIGH PRIORITY FIX: Added input validation for params[:id]
      unless params[:id].present? && params[:id].to_i.positive?
        log_invalid_page_id(params[:id])
        render plain: "Invalid page ID", status: :bad_request
        return
      end

      # CRITICAL FIX: Added error handling for Page.find
      begin
        @page = PlebisCms::Page.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        log_page_not_found(params[:id])
        render plain: "Page not found", status: :not_found
        return
      end

      @meta_description = @page.meta_description if !@page.meta_description.blank?
      @meta_image = @page.meta_image if !@page.meta_image.blank?

      if @page.require_login && !user_signed_in?
        flash[:metas] = { description: @meta_description, image: @meta_image }
        authenticate_user!
        return
      end

      # HIGH PRIORITY FIX: Use Page model method instead of regex in controller
      if @page.external_plebisbrand_link?
        render :formview_iframe, locals: { title: @page.title, url: add_user_params(@page.link) }
      else
        render :form_iframe, locals: { title: @page.title, url: form_url(@page.id_form) }
      end
    end

    def privacy_policy
    end

    def faq
    end

    def guarantees
    end

    def funding
    end

    def guarantees_form
      render :form_iframe, locals: { title: "Comunicación a Comisiones de Garantías Democráticas", url: form_url(77), return_path: guarantees_path }
    end

    def old_circles_data_validation
      render :form_iframe, locals: { title: "Validación de Círculos", url: form_url(45) }
    end

    def list_register
      render :form_iframe, locals: { title: "Listas autonómicas", url: form_url(20) }
    end

    def offer_hospitality
      render :form_iframe, locals: { title: "Comparte tu casa", url: form_url(71), return_path: root_path }
    end

    def find_hospitality
      render :formview_iframe, locals: { title: "Encuentra alojamiento", url: "https://forms.plebisbrand.info/compartir-casa/" }
    end

    def share_car_sevilla
      render :form_iframe, locals: { title: "Comparte tu coche: Destino Sevilla", url: form_url(72), return_path: root_path }
    end

    def find_car_sevilla
      render :formview_iframe, locals: { title: "Encuentra coche a Sevilla", url: "https://forms.plebisbrand.info/compartir-viaje-sevilla/" }
    end

    def share_car_doshermanas
      render :form_iframe, locals: { title: "Comparte tu coche: Destino Dos Hermanas", url: form_url(73), return_path: root_path }
    end

    def find_car_doshermanas
      render :formview_iframe, locals: { title: "Encuentra coche a Dos Hermanas", url: "https://forms.plebisbrand.info/compartir-viaje-dos-hermanas/" }
    end

    def town_legal
      render :form_iframe, locals: { title: "Responsables de finanzas y legal", url: form_url(14) }
    end

    def avales_barcelona
      render :form_iframe, locals: { title: "Avales Barcelona", url: form_url(22) }
    end

    def primarias_andalucia
      render :form_iframe, locals: { title: "Primarias Andalucía", url: form_url(21) }
    end

    def listas_primarias_andaluzas
      render :form_iframe, locals: { title: "Listas Primarias Andalucía", url: form_url(23) }
    end

    def responsables_organizacion_municipales
      render :form_iframe, locals: { title: "Responsable del área de Organización / Extensión en los órganos municipales", url: form_url(26) }
    end

    def responsables_municipales_andalucia
      render :form_iframe, locals: { title: "Elecciones Andalucía 2015 - Personas de contacto", url: form_url(51) }
    end

    def plaza_plebisbrand_municipal
      render :form_iframe, locals: { title: "Plaza PlebisBrand municipales", url: form_url(52) }
    end

    def portal_transparencia_cc_estatal
      render :form_iframe, locals: { title: "Portal de Transparencia - CC Estatal", url: form_url(54) }
    end

    def mujer_igualdad
      render :form_iframe, locals: { title: "Área de mujer e igualdad - Encuentro", url: form_url(55) }
    end

    def alta_consulta_ciudadana
      render :form_iframe, locals: { title: "Formulario para activar la Consulta Ciudadana acerca de las candidaturas de unidad popular", url: form_url(57) }
    end

    # CRITICAL FIX: Removed duplicate method definition (was defined at lines 124 and 128)
    def representantes_electorales_extranjeros
      render :form_iframe, locals: { title: "Elecciones Andaluzas: Representantes electorales de PlebisBrand en Consulados extranjeros", url: form_url(60) }
    end

    def responsables_areas_cc_autonomicos
      render :form_iframe, locals: { title: "Responsables de Áreas de los Consejos Ciudadanos Autonómicos", url: form_url(61) }
    end

    def boletin_correo_electronico
      render :form_iframe, locals: { title: "Envío de boletín por correo electrónico", url: form_url(62) }
    end

    def candidaturas_primarias_autonomicas
      render :form_iframe, locals: { title: "Formulario de candidaturas", url: form_url(63) }
    end

    def listas_primarias_autonomicas
      render :form_iframe, locals: { title: "Formulario de listas de primarias Forales Euskadi", url: form_url(67) }
    end

    def apoderados_campana_autonomica_andalucia
      render :form_iframe, locals: { title: "Apoderados para la campaña autonómica en Andalucía", url: form_url(64) }
    end

    def comparte_cambio_valoracion_propietarios
      render :form_iframe, locals: { title: "Cuéntanos como fue la experiencia compartiendo tu casa o coche", url: form_url(65) }
    end

    def comparte_cambio_valoracion_usuarios
      render :form_iframe, locals: { title: "Cuéntanos que tal te acogieron en su casa o coche", url: form_url(66) }
    end

    def responsable_web_autonomico
      render :form_iframe, locals: { title: "Responsables webs autonómicos", url: form_url(68) }
    end

    def avales_candidaturas_primarias
      render :form_iframe, locals: { title: "Avales para candidaturas de primarias", url: form_url(83) }
    end

    def iniciativa_ciudadana
      render :form_iframe, locals: { title: "Iniciativa ciudadana", url: form_url(84) }
    end

    def cuentas_consejos_autonomicos
      render :form_iframe, locals: { title: "Solicitud de cuentas institucionales para consejos Autonómicos", url: form_url(79) }
    end

    def condiciones_uso_correo
      render :form_iframe, locals: { title: "Condiciones de uso del correo electrónico PLEBISBRAND", url: form_url(80) }
    end

    private

    def form_url(id_form)
      sign_url(add_user_params("https://#{domain}/gfembed/?f=#{id_form}"))
    end

    # WARNING: This method exposes PII in URL parameters for external form integration.
    # This is a known security/privacy issue that should be addressed architecturally.
    # See controller documentation at top of file for details.
    def add_user_params(url)
      return url unless user_signed_in?

      params = {
        id: current_user.id,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        street: current_user.address,
        town: current_user.town_name,
        province: current_user.province_name,
        postal_code: current_user.postal_code,
        country: current_user.country,
        address: current_user.full_address,
        phone: current_user.phone,
        email: current_user.email,
        document_vatid: current_user.document_vatid,
        # CRITICAL FIX: Added nil check to prevent NoMethodError crash
        born_at: current_user.born_at&.strftime('%d/%m/%Y') || '',
        autonomy: current_user.vote_autonomy_name,
        comunity: current_user.vote_autonomy_code,
        town_code: current_user.town,
        created_at: current_user.created_at,
        gender: current_user.gender,
        vote_town: current_user.vote_town,
        vote_autonomy_since: current_user.vote_autonomy_since.to_i,
        vote_province_since: current_user.vote_province_since.to_i,
        vote_island_since: current_user.vote_island_since.to_i,
        vote_town_since: current_user.vote_town_since.to_i,
        exempt_from_payment: current_user.exempt_from_payment? ? 1 : 0
      }

      url + params.map { |param, value| "&participa_user_#{param}=#{u(value)}" }.join
    end

    def sign_url(url)
      UrlSignatureService.new(secret).sign_url(url)
    end

    def domain
      @domain ||= Rails.application.secrets.forms["domain"]
    end

    def secret
      @secret ||= Rails.application.secrets.forms["secret"]
    end

    # LOW PRIORITY FIX: Added structured logging methods
    def log_invalid_page_id(page_id)
      Rails.logger.warn("[PlebisCms::PageController] Invalid page ID attempted: #{page_id.inspect} - IP: #{request.remote_ip}")
    end

    def log_page_not_found(page_id)
      Rails.logger.warn("[PlebisCms::PageController] Page not found: #{page_id} - IP: #{request.remote_ip}")
    end
  end
end
