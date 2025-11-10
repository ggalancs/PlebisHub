# frozen_string_literal: true

module PlebisMicrocredit
  # MicrocreditController - Microcredit/Loan Management System
  #
  # FINANCIAL SECURITY NOTICE:
  # This controller manages financial transactions (loans, renewals, payments).
  # Any security vulnerability could compromise financial integrity.
  #
  # Security measures implemented:
  # - Comprehensive input validation
  # - Complete error handling with logging
  # - Authorization logging
  # - Async email delivery
  # - Transaction safety
  #
  class MicrocreditController < ApplicationController
    include CollaborationsHelper

    before_action :init_env
    before_action :validate_microcredit_id, only: [:new_loan, :create_loan, :loans_renewal, :loans_renew, :show_options]
    before_action :check_renewal_authentication, only: [:renewal, :loans_renewal, :loans_renew]
    layout :external_layout

    def provinces
      # SECURITY: Validate and sanitize country parameter
      country = validate_country_param(params[:microcredit_loan_country])
      render partial: 'subregion_select', locals: {
        country: country,
        province: params[:microcredit_loan_province],
        disabled: false,
        required: true,
        title: "Provincia"
      }
    rescue StandardError => e
      log_microcredit_error(:provinces_render_failed, e)
      head :internal_server_error
    end

    def towns
      # SECURITY: Validate and sanitize country parameter
      country = validate_country_param(params[:microcredit_loan_country])
      render partial: 'municipies_select', locals: {
        country: country,
        province: params[:microcredit_loan_province],
        town: params[:microcredit_loan_town],
        disabled: false,
        required: true,
        title: "Municipio"
      }
    rescue StandardError => e
      log_microcredit_error(:towns_render_failed, e)
      head :internal_server_error
    end

    def init_env
      # SECURITY FIX: Validate configuration exists before accessing
      unless Rails.application.secrets.microcredits &&
             Rails.application.secrets.microcredits["default_brand"] &&
             Rails.application.secrets.microcredits["brands"]
        log_microcredit_security_event(:missing_configuration)
        flash[:error] = I18n.t('microcredit.errors.configuration_error')
        redirect_to root_path
        return
      end

      default_brand = Rails.application.secrets.microcredits["default_brand"]
      @brand = params[:brand].presence || default_brand
      @brand_config = Rails.application.secrets.microcredits["brands"][@brand]

      # SECURITY FIX: Validate brand exists
      if @brand_config.blank?
        log_microcredit_security_event(:invalid_brand, brand: params[:brand])
        @brand = default_brand
        @brand_config = Rails.application.secrets.microcredits["brands"][default_brand]

        # Double-check default brand exists
        if @brand_config.blank?
          log_microcredit_security_event(:missing_default_brand, brand: default_brand)
          flash[:error] = I18n.t('microcredit.errors.configuration_error')
          redirect_to root_path
          return
        end
      end

      @external = @brand_config["external"] || false
      @url_params = @brand == default_brand ? {} : { brand: @brand }
    rescue StandardError => e
      log_microcredit_error(:init_env_failed, e)
      flash[:error] = I18n.t('microcredit.errors.initialization_failed')
      redirect_to root_path
    end

    def external_layout
      @external ? "noheader" : "application"
    end

    def index
      @all_microcredits = PlebisMicrocredit::Microcredit.upcoming_finished_by_priority

      @microcredits_standard = @all_microcredits.select(&:is_active?).select(&:is_standard?)
      @microcredits_mailing = @all_microcredits.select(&:is_active?).select(&:is_mailing?)

      if @microcredits_standard.empty?
        @upcoming_microcredits_standard = @all_microcredits.select(&:is_standard?).select(&:is_upcoming?).sort_by(&:starts_at)
        @finished_microcredits_standard = @all_microcredits.select(&:is_standard?).select(&:recently_finished?).sort_by(&:ends_at).reverse
        @microcredit_index_upcoming_text = @upcoming_microcredits_standard.first&.get_microcredit_index_upcoming_text
      end

      if @microcredits_mailing.empty?
        @upcoming_microcredits_mailing = @all_microcredits.select(&:is_mailing?).select(&:is_upcoming?).sort_by(&:starts_at)
        @finished_microcredits_mailing = @all_microcredits.select(&:is_mailing?).select(&:recently_finished?).sort_by(&:ends_at).reverse
        @microcredit_index_upcoming_text ||= @upcoming_microcredits_mailing.first&.get_microcredit_index_upcoming_text
      end
    rescue StandardError => e
      log_microcredit_error(:index_failed, e)
      flash[:error] = I18n.t('microcredit.errors.listing_failed')
      redirect_to root_path
    end

    def login
      authenticate_user!
      redirect_to new_microcredit_loan_path(params[:id], brand: @brand)
    rescue StandardError => e
      log_microcredit_error(:login_redirect_failed, e)
      redirect_to root_path
    end

    def new_loan
      @microcredit = PlebisMicrocredit::Microcredit.find(params[:id])

      unless @microcredit.is_active?
        log_microcredit_event(:inactive_microcredit_access, microcredit_id: params[:id])
        redirect_to microcredit_path(brand: @brand)
        return
      end

      @loan = PlebisMicrocredit::MicrocreditLoan.new
      @user_loans = current_user ? @microcredit.loans.where(user: current_user) : []
    rescue ActiveRecord::RecordNotFound => e
      log_microcredit_error(:microcredit_not_found, e, microcredit_id: params[:id])
      flash[:error] = I18n.t('microcredit.errors.not_found')
      redirect_to microcredit_path(brand: @brand)
    rescue StandardError => e
      log_microcredit_error(:new_loan_failed, e, microcredit_id: params[:id])
      flash[:error] = I18n.t('microcredit.errors.load_failed')
      redirect_to microcredit_path(brand: @brand)
    end

    def create_loan
      @microcredit = PlebisMicrocredit::Microcredit.find(params[:id])

      unless @microcredit.is_active?
        log_microcredit_event(:create_loan_inactive_microcredit, microcredit_id: params[:id])
        redirect_to microcredit_path(brand: @brand)
        return
      end

      @user_loans = current_user ? @microcredit.loans.where(user: current_user) : []

      @loan = PlebisMicrocredit::MicrocreditLoan.new(loan_params) do |loan|
        loan.microcredit = @microcredit
        loan.user = current_user if current_user
        loan.ip = request.remote_ip
        child_id = params[:microcredit_loan]["microcredit_option_id_#{loan.microcredit_option_id}"] if params[:microcredit_loan].key?("microcredit_option_id_#{loan.microcredit_option_id}") && params[:microcredit_loan]["microcredit_option_id_#{loan.microcredit_option_id}"].present?
        loan.microcredit_option_id = child_id if child_id
      end

      @loan.set_user_data(loan_params) unless current_user

      # SECURITY FIX: Move email outside transaction to prevent rollback on email failures
      # Validate and save loan first
      if (current_user || @loan.valid_with_captcha?) && @loan.save
        begin
          @loan.update_counted_at
          log_microcredit_event(:loan_created,
                                microcredit_id: @microcredit.id,
                                loan_id: @loan.id,
                                amount: @loan.amount,
                                user_id: current_user&.id)

          # PERFORMANCE FIX: Async email delivery
          UsersMailer.microcredit_email(@microcredit, @loan, @brand_config).deliver_later

          # SECURITY FIX: Use view helper for HTML-safe flash messages
          flash[:notice] = build_loan_success_message
          log_microcredit_event(:loan_email_queued, loan_id: @loan.id)

          redirect_to microcredit_path(brand: @brand) unless params[:reload]
          return
        rescue StandardError => e
          # Email delivery failed but loan was created - log and continue
          log_microcredit_error(:loan_email_failed, e, loan_id: @loan.id)
          flash[:notice] = I18n.t('microcredit.new_loan.created_email_pending')
          redirect_to microcredit_path(brand: @brand) unless params[:reload]
          return
        end
      end

      # Validation failed
      log_microcredit_event(:loan_creation_failed,
                            microcredit_id: @microcredit.id,
                            errors: @loan.errors.full_messages)
      render :new_loan
    rescue ActiveRecord::RecordNotFound => e
      log_microcredit_error(:microcredit_not_found, e, microcredit_id: params[:id])
      flash[:error] = I18n.t('microcredit.errors.not_found')
      redirect_to microcredit_path(brand: @brand)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
      log_microcredit_error(:loan_save_failed, e, microcredit_id: params[:id])
      flash[:error] = I18n.t('microcredit.errors.save_failed')
      render :new_loan
    rescue StandardError => e
      log_microcredit_error(:create_loan_failed, e, microcredit_id: params[:id])
      flash[:error] = I18n.t('microcredit.errors.creation_failed')
      render :new_loan
    end

    def renewal
      @microcredits_active = PlebisMicrocredit::Microcredit.active
      @renewable = any_renewable?
    rescue StandardError => e
      log_microcredit_error(:renewal_page_failed, e)
      flash[:error] = I18n.t('microcredit.errors.renewal_failed')
      redirect_to root_path
    end

    def loans_renewal
      @microcredit = PlebisMicrocredit::Microcredit.find(params[:id])
      @renewal = get_renewal
    rescue ActiveRecord::RecordNotFound => e
      log_microcredit_error(:microcredit_not_found, e, microcredit_id: params[:id])
      flash[:error] = I18n.t('microcredit.errors.not_found')
      redirect_to root_path
    rescue StandardError => e
      log_microcredit_error(:loans_renewal_failed, e, microcredit_id: params[:id])
      flash[:error] = I18n.t('microcredit.errors.renewal_failed')
      redirect_to root_path
    end

    def loans_renew
      @microcredit = PlebisMicrocredit::Microcredit.find(params[:id])
      @renewal = get_renewal(true)

      if @renewal&.valid
        total_amount = 0

        begin
          PlebisMicrocredit::MicrocreditLoan.transaction do
            @renewal.loan_renewals.each do |l|
              l.renew!(@microcredit)
              total_amount += l.amount
            end
          end

          if total_amount > 0
            log_microcredit_event(:loans_renewed,
                                  microcredit_id: @microcredit.id,
                                  loan_id: @renewal.loan.id,
                                  total_amount: total_amount,
                                  loans_count: @renewal.loan_renewals.count)

            redirect_to loans_renewal_microcredit_loan_path(
              @microcredit.id,
              @renewal.loan.id,
              @renewal.loan.unique_hash
            ), notice: I18n.t('microcredit.loans_renewal.renewal_success',
                              name: @brand_config["name"],
                              amount: number_to_euro(total_amount * 100),
                              campaign: @microcredit.title)
            return
          end
        rescue StandardError => e
          log_microcredit_error(:renewal_transaction_failed, e,
                                microcredit_id: @microcredit.id,
                                total_amount: total_amount)
          flash[:error] = I18n.t('microcredit.errors.renewal_failed')
        end
      end

      render :loans_renewal
    rescue ActiveRecord::RecordNotFound => e
      log_microcredit_error(:microcredit_not_found, e, microcredit_id: params[:id])
      flash[:error] = I18n.t('microcredit.errors.not_found')
      redirect_to root_path
    rescue StandardError => e
      log_microcredit_error(:loans_renew_failed, e, microcredit_id: params[:id])
      flash[:error] = I18n.t('microcredit.errors.renewal_failed')
      render :loans_renewal
    end

    def show_options
      @colors = ["#683064", "#6b478e", "#b052a9", "#c4a0d8"]
      @microcredit = PlebisMicrocredit::Microcredit.find(params[:id])

      summary = @microcredit.options_summary
      @data_detail = summary[:data]
      @grand_total = summary[:grand_total]
    rescue ActiveRecord::RecordNotFound => e
      log_microcredit_error(:microcredit_not_found, e, microcredit_id: params[:id])
      flash[:error] = I18n.t('microcredit.errors.not_found')
      redirect_to root_path
    rescue StandardError => e
      log_microcredit_error(:show_options_failed, e, microcredit_id: params[:id])
      flash[:error] = I18n.t('microcredit.errors.options_failed')
      redirect_to root_path
    end

    private

    # SECURITY: Input validation before database queries
    def validate_microcredit_id
      unless params[:id].to_s.match?(/\A\d+\z/)
        log_microcredit_security_event(:invalid_microcredit_id, microcredit_id: params[:id])
        flash[:error] = I18n.t('microcredit.errors.invalid_id')
        redirect_to root_path
      end
    end

    # SECURITY: Validate country parameter against allowed list
    def validate_country_param(country_param)
      allowed_countries = %w[ES AD GB FR DE IT PT]
      country = country_param.presence || "ES"

      unless allowed_countries.include?(country)
        log_microcredit_security_event(:invalid_country, country: country)
        return "ES"
      end

      country
    end

    # SECURITY FIX: Extract inline before_action to named method
    def check_renewal_authentication
      # DESIGN DECISION: Allow unauthenticated renewal if loan_id provided
      # This enables email-based renewal links without requiring login
      # Security provided by unique_hash validation in any_renewable?
      authenticate_user! unless params[:loan_id]
    end

    # SECURITY FIX: HTML-safe flash message construction
    def build_loan_success_message
      message_parts = [
        I18n.t('microcredit.new_loan.will_receive_email', name: sanitize_brand_name)
      ]

      if @brand_config["twitter_account"].present?
        message_parts << I18n.t('microcredit.new_loan.tweet_campaign',
                                 main_url: sanitize_brand_url,
                                 twitter_account: sanitize_twitter_account)
      end

      # Join with HTML line break - will be marked html_safe in view
      message_parts.join("<br/>")
    end

    # SECURITY: Sanitize brand configuration values
    def sanitize_brand_name
      ERB::Util.html_escape(@brand_config["name"])
    end

    def sanitize_brand_url
      ERB::Util.html_escape(@brand_config["main_url"])
    end

    def sanitize_twitter_account
      ERB::Util.html_escape(@brand_config["twitter_account"])
    end

    def loan_params
      if current_user
        params.require(:microcredit_loan).permit(:amount, :terms_of_service, :minimal_year_old, :iban_account, :iban_bic, :microcredit_option_id)
      else
        params.require(:microcredit_loan).permit(:first_name, :last_name, :document_vatid, :email, :address, :postal_code, :town, :province, :country, :amount, :terms_of_service, :minimal_year_old, :captcha, :captcha_key, :iban_account, :iban_bic, :microcredit_option_id)
      end
    end

    def get_renewal(validate = false)
      service = LoanRenewalService.new(@microcredit, params)
      service.build_renewal(
        loan_id: params[:loan_id],
        current_user: current_user,
        validate: validate
      )
    rescue StandardError => e
      log_microcredit_error(:renewal_service_failed, e, microcredit_id: @microcredit&.id)
      nil
    end

    def any_renewable?
      return false unless @microcredits_active

      if params[:loan_id]
        loan = PlebisMicrocredit::MicrocreditLoan.find_by(id: params[:loan_id])

        # SECURITY: Hash validation prevents unauthorized renewal access
        if loan && loan.unique_hash == params[:hash] && loan.microcredit.renewable?
          return true
        else
          log_microcredit_security_event(:invalid_renewal_hash,
                                          loan_id: params[:loan_id],
                                          hash_provided: params[:hash].present?)
          return false
        end
      else
        current_user && current_user.any_microcredit_renewable?
      end
    rescue StandardError => e
      log_microcredit_error(:renewable_check_failed, e)
      false
    end

    # Structured logging for microcredit events
    def log_microcredit_event(event_type, **details)
      Rails.logger.info({
        event: "microcredit_#{event_type}",
        user_id: current_user&.id,
        brand: @brand,
        timestamp: Time.current.iso8601
      }.merge(details).to_json)
    end

    # Structured logging for microcredit errors
    def log_microcredit_error(event_type, error, **details)
      Rails.logger.error({
        event: "microcredit_error_#{event_type}",
        user_id: current_user&.id,
        brand: @brand,
        error_class: error.class.name,
        error_message: error.message,
        backtrace: error.backtrace&.first(5),
        timestamp: Time.current.iso8601
      }.merge(details).to_json)
    end

    # Structured logging for security events
    def log_microcredit_security_event(event_type, **details)
      Rails.logger.warn({
        event: "microcredit_security_#{event_type}",
        user_id: current_user&.id,
        brand: @brand,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        timestamp: Time.current.iso8601
      }.merge(details).to_json)
    end
  end
end
