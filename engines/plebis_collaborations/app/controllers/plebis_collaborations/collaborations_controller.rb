# frozen_string_literal: true

module PlebisCollaborations
  # CollaborationsController - Manages recurring and one-time monetary collaborations
  #
  # SECURITY NOTES:
  # - All collaborations are scoped to current_user to prevent IDOR attacks
  # - Input validation added for all user-provided IDs
  # - Comprehensive logging for audit trail
  # - Error handling for all database operations
  class CollaborationsController < ApplicationController
    include Redirectable
    helper_method :force_single?, :active_frequencies, :payment_types
    helper_method :only_recurrent?
    helper_method :pending_single_orders

    before_action :authenticate_user!
    before_action :set_collaboration, only: [:confirm, :confirm_bank, :edit, :modify, :destroy, :OK, :KO]

    def new
      redirect_to edit_collaboration_path and return if current_user.recurrent_collaboration && !force_single?
      @collaboration = PlebisCollaborations::Collaboration.new
      @collaboration.for_town_cc = true
      @collaboration.frequency = 0 if force_single?
    end

    def modify
      redirect_to new_collaboration_path and return unless @collaboration
      redirect_to confirm_collaboration_path and return unless @collaboration.has_payment?

      # update collaboration
      @collaboration.assign_attributes create_params

      if @collaboration.save
        log_collaboration_event(:modified, @collaboration)
        flash[:notice] = I18n.t('collaborations.modify.success')
        redirect_to edit_collaboration_path
      else
        render 'edit'
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
      log_collaboration_error(:modify_failed, @collaboration, e)
      flash.now[:alert] = I18n.t('collaborations.modify.error')
      render 'edit'
    end

    def create
      @collaboration = PlebisCollaborations::Collaboration.new(create_params)
      @collaboration.user = current_user

      if current_user.recurrent_collaboration && create_params[:frequency].to_i > 0
        flash[:alert] = I18n.t('collaborations.create.already_has_recurrent')
        render :new
        return
      end

      respond_to do |format|
        if @collaboration.save
          log_collaboration_event(:created, @collaboration)
          format.html { redirect_to confirm_collaboration_url(force_single: @collaboration.frequency == 0), notice: I18n.t('collaborations.create.success') }
          format.json { render :confirm, status: :created, location: confirm_collaboration_path }
        else
          format.html { render :new }
          format.json { render json: @collaboration.errors, status: :unprocessable_entity }
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      log_collaboration_error(:create_failed, nil, e)
      respond_to do |format|
        format.html do
          flash.now[:alert] = I18n.t('collaborations.create.error')
          render :new
        end
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
    end

    def edit
      redirect_to new_collaboration_path and return unless @collaboration
      redirect_to confirm_collaboration_path and return unless @collaboration.has_payment?
    end

    def destroy
      # SECURITY FIX: Validate and authorize single_collaboration_id parameter
      # Previous version had IDOR vulnerability allowing deletion of other users' collaborations
      if params[:single_collaboration_id].present?
        unless params[:single_collaboration_id].to_s.match?(/\A\d+\z/)
          flash[:alert] = I18n.t('collaborations.destroy.invalid_id')
          redirect_to new_collaboration_path and return
        end

        @collaboration = current_user.collaborations.find_by(id: params[:single_collaboration_id].to_i)
        unless @collaboration
          log_collaboration_security_event(:unauthorized_delete_attempt, params[:single_collaboration_id])
          flash[:alert] = I18n.t('collaborations.destroy.not_found')
          redirect_to new_collaboration_path and return
        end
      end

      redirect_to new_collaboration_path and return unless @collaboration

      collaboration_id = @collaboration.id
      @collaboration.destroy
      log_collaboration_event(:destroyed, @collaboration)

      respond_to do |format|
        notice_key = params[:single_collaboration_id].present? ? 'collaborations.destroy.success_single' : 'collaborations.destroy.success'
        format.html { redirect_to new_collaboration_path, notice: I18n.t(notice_key) }
        format.json { head :no_content }
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      log_collaboration_error(:destroy_failed, @collaboration, e)
      respond_to do |format|
        format.html do
          flash[:alert] = I18n.t('collaborations.destroy.error')
          redirect_to new_collaboration_path
        end
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
    end

    def confirm
      redirect_to new_collaboration_path and return unless @collaboration
      redirect_to edit_collaboration_path if @collaboration.frequency > 0 && @collaboration.has_payment?

      # Non-persisted order for credit card payment flow
      # Lifecycle: Created here, displayed in view, persisted during payment callback
      # Allows regenerating order ID for each payment attempt to prevent duplicate charges
      @order = @collaboration.create_order(Time.now, true) if @collaboration.is_credit_card?
    end

    def single
      # Static page showing pending single collaborations
    end

    def OK
      # SECURITY FIX: Previous logic error used OR instead of proper nil check
      # Old: unless @collaboration || force_single? (wrong - allows nil collaboration)
      # New: explicit nil check
      redirect_to new_collaboration_path and return unless @collaboration

      if !@collaboration.is_active?
        if @collaboration.is_credit_card?
          warning_message = I18n.t('collaborations.ok.credit_card_warning')
          @collaboration.set_warning!(warning_message)
          log_collaboration_event(:payment_warning, @collaboration)
        else
          @collaboration.set_active!
          log_collaboration_event(:activated, @collaboration)
          return_path = session.delete(:return_to) || root_path
          redirect_to return_path
        end
      end
    end

    def KO
      # Payment failure callback - display error page
      log_collaboration_event(:payment_failed, @collaboration) if @collaboration
    end

    private

    def payment_types
      PlebisCollaborations::Collaboration.available_payment_types(@collaboration)
    end

    def force_single?
      # Use ActiveModel::Type::Boolean for proper boolean casting
      ActiveModel::Type::Boolean.new.cast(params[:force_single])
    end

    def only_recurrent?
      # Use ActiveModel::Type::Boolean for proper boolean casting
      ActiveModel::Type::Boolean.new.cast(params[:only_recurrent])
    end

    def active_frequencies
      PlebisCollaborations::Collaboration.available_frequencies_for_user(
        current_user,
        force_single: force_single?,
        only_recurrent: only_recurrent?
      )
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_collaboration
      @collaboration = if force_single?
                         current_user.single_collaboration
                       else
                         current_user.recurrent_collaboration
                       end
      return unless @collaboration

      begin
        result = @collaboration.calculate_date_range_and_orders
        @orders = result[:orders]
      rescue StandardError => e
        log_collaboration_error(:calculate_orders_failed, @collaboration, e)
        @orders = []
      end
    end

    def pending_single_orders
      @pending_single_orders ||= current_user.pending_single_collaborations.map do |c|
        c.get_orders(Date.today).first
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def create_params
      params.require(:collaboration).permit(:amount, :frequency, :terms_of_service, :minimal_year_old, :payment_type, :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, :iban_account, :iban_bic, :territorial_assignment)
    end

    # Structured logging for collaboration events
    def log_collaboration_event(event_type, collaboration)
      Rails.logger.info({
        event: "collaboration_#{event_type}",
        user_id: current_user&.id,
        collaboration_id: collaboration&.id,
        frequency: collaboration&.frequency,
        amount: collaboration&.amount,
        payment_type: collaboration&.payment_type,
        timestamp: Time.current.iso8601
      }.to_json)
    end

    # Structured logging for collaboration errors
    def log_collaboration_error(event_type, collaboration, error)
      Rails.logger.error({
        event: "collaboration_#{event_type}",
        user_id: current_user&.id,
        collaboration_id: collaboration&.id,
        error_class: error.class.name,
        error_message: error.message,
        backtrace: error.backtrace&.first(5),
        timestamp: Time.current.iso8601
      }.to_json)
    end

    # Structured logging for security events
    def log_collaboration_security_event(event_type, target_id)
      Rails.logger.warn({
        event: "collaboration_security_#{event_type}",
        user_id: current_user&.id,
        target_id: target_id,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        timestamp: Time.current.iso8601
      }.to_json)
    end
  end
end
