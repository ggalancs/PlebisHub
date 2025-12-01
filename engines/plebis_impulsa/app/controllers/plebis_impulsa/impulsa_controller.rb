# frozen_string_literal: true

module PlebisImpulsa
  # ImpulsaController - Project Submission Wizard
  #
  # SECURITY FIXES IMPLEMENTED:
  # - Added path traversal protection in download action
  # - Added comprehensive authorization checks
  # - Added file validation (MIME type, extension)
  # - Added comprehensive error handling
  # - Added security audit logging
  # - Added step parameter validation
  # - Extracted strings to I18n
  class ImpulsaController < ApplicationController
    before_action :authenticate_user!, except: [:index]
    before_action :set_variables
    before_action :check_project, except: [:index]
    before_action :verify_project_ownership, only: [:download, :upload, :delete_file, :update, :update_step, :review, :delete]
    before_action :validate_step, only: [:project_step, :update_step]

    def index
      @upcoming = ImpulsaEdition.upcoming.first if @edition.nil?
    rescue StandardError => e
      log_error("impulsa_index_failed", e)
      redirect_to main_app.root_path, flash: { alert: t('impulsa.errors.generic') }
    end

    def project
    rescue StandardError => e
      log_error("impulsa_project_failed", e)
      redirect_to impulsa_path, flash: { alert: t('impulsa.errors.generic') }
    end

    def evaluation
    rescue StandardError => e
      log_error("impulsa_evaluation_failed", e)
      redirect_to impulsa_path, flash: { alert: t('impulsa.errors.generic') }
    end

    def project_step
      @show_errors = @project.wizard_status[@step][:filled]
      @project.valid? & @project.wizard_step_valid? if @show_errors
    rescue StandardError => e
      log_error("impulsa_project_step_failed", e, step: @step)
      redirect_to project_impulsa_path, flash: { alert: t('impulsa.errors.step_load_failed') }
    end

    def update
      return redirect_to project_impulsa_path unless @project.editable?

      if @project.save
        log_project_update("project_updated")
        redirect_to project_step_impulsa_path(step: @project.wizard_step)
      else
        render :project
      end
    rescue StandardError => e
      log_error("impulsa_update_failed", e)
      redirect_to project_impulsa_path, flash: { alert: t('impulsa.errors.save_failed') }
    end

    def review
      if @project.mark_for_review
        log_state_transition("marked_for_review")
        flash[:notice] = t('impulsa.messages.marked_for_review')
      else
        flash[:error] = t('impulsa.errors.cannot_mark_for_review')
      end
      redirect_to project_impulsa_path
    rescue StandardError => e
      log_error("impulsa_review_failed", e)
      redirect_to project_impulsa_path, flash: { alert: t('impulsa.errors.review_failed') }
    end

    def delete
      if @project.deleteable?
        handle_project_deletion
      else
        handle_project_resignation
      end
    rescue StandardError => e
      log_error("impulsa_delete_failed", e)
      redirect_to project_impulsa_path, flash: { alert: t('impulsa.errors.delete_failed') }
    end

    def update_step
      return redirect_to project_impulsa_path unless @project.saveable?

      changes = (@project.changes.keys - ["wizard_step"]).any?

      if @project.save
        log_project_update("wizard_step_updated", changes: changes)
        handle_step_navigation
        return
      end
      render :edit
    rescue StandardError => e
      log_error("impulsa_update_step_failed", e, step: @project.wizard_step)
      redirect_to project_impulsa_path, flash: { alert: t('impulsa.errors.step_save_failed') }
    end

    def upload
      # SECURITY: Validate field parameter format
      unless params[:field] =~ /\A[a-z0-9_]+\.[a-z0-9_]+\z/i
        log_security_event("invalid_upload_field", field: params[:field])
        return render json: [t('impulsa.errors.invalid_field')], status: :unprocessable_entity
      end

      gname, fname = params[:field].split(".")

      # Validate file is present
      unless params[:file].present?
        return render json: [t('impulsa.errors.no_file_provided')], status: :unprocessable_entity
      end

      result = @project.assign_wizard_value(gname, fname, params[:file])

      if handle_upload_result(result)
        @project.save
        log_file_operation("file_uploaded", field: params[:field], filename: @project.wizard_values[params[:field]])
        filename = @project.wizard_values[params[:field]]
        render json: {
          name: filename,
          path: download_impulsa_path(field: filename)
        }
      end
    rescue StandardError => e
      log_error("impulsa_upload_failed", e, field: params[:field])
      render json: [t('impulsa.errors.upload_failed')], status: :internal_server_error
    end

    def delete_file
      # SECURITY: Validate field parameter format
      unless params[:field] =~ /\A[a-z0-9_]+\.[a-z0-9_]+\z/i
        log_security_event("invalid_delete_field", field: params[:field])
        return render json: [t('impulsa.errors.invalid_field')], status: :unprocessable_entity
      end

      gname, fname = params[:field].split(".")
      result = @project.assign_wizard_value(gname, fname, nil)

      errors = case result
      when :wrong_field
        [t('impulsa.errors.wrong_field_delete')]
      else
        []
      end

      if errors.any?
        render json: errors, status: :unprocessable_entity
      else
        @project.save
        log_file_operation("file_deleted", field: params[:field])
        render json: {}
      end
    rescue StandardError => e
      log_error("impulsa_delete_file_failed", e, field: params[:field])
      render json: [t('impulsa.errors.delete_failed')], status: :internal_server_error
    end

    def download
      # SECURITY FIX: Validate field parameter to prevent path traversal
      unless params[:field] =~ /\A[a-z0-9_]+\.[a-z0-9_]+\.[a-z]+\z/i
        log_security_event("invalid_download_field", field: params[:field])
        return head :not_found
      end

      # Extract and validate components
      parts = params[:field].split(".")
      return head :not_found unless parts.length == 3

      gname, fname, _extension = parts

      # Get validated path (wizard_path now includes path traversal protection)
      file_path = @project.wizard_path(gname, fname)

      # Verify file exists and is within authorized directory
      # Note: wizard_path already validates against path traversal via File.basename
      # and verifies path is within authorized directory
      unless file_path && File.exist?(file_path)
        log_security_event("file_not_found_or_unauthorized", field: params[:field], path: file_path)
        return head :not_found
      end

      log_file_operation("file_downloaded", field: params[:field], path: file_path)
      # brakeman:disable:FileAccess
      send_file file_path
      # brakeman:enable:FileAccess
    rescue StandardError => e
      log_error("impulsa_download_failed", e, field: params[:field])
      head :internal_server_error
    end

    private

    def set_variables
      @edition = ImpulsaEdition.current
      return if @edition.nil? || !current_user

      @step = params[:step]
      @project = @edition.impulsa_projects.where(user: current_user).first

      if @project.nil? && @edition.allow_creation?
        @project = ImpulsaProject.new user: current_user
      end

      @available_categories = @edition.impulsa_edition_categories
      @available_categories = @available_categories.non_authors unless current_user.impulsa_author?

      if @project.present?
        @project.wizard_step = @step if @step
        @project.assign_attributes(project_params) unless params[:impulsa_project].blank?
      end
    rescue StandardError => e
      log_error("impulsa_set_variables_failed", e)
      raise
    end

    def project_params
      if !@project.persisted?
        params.require(:impulsa_project).permit(:name, :impulsa_edition_category_id)
      elsif @step.blank?
        if @project.editable?
          params.require(:impulsa_project).permit(:name)
        else
          {}
        end
      else
        params.require(:impulsa_project).permit(*@project.wizard_step_params)
      end
    end

    def check_project
      if @project.nil?
        log_security_event("project_access_without_project")
        redirect_to impulsa_path
      end
    end

    # SECURITY FIX: Verify project ownership
    def verify_project_ownership
      unless @project && @project.user_id == current_user.id
        log_security_event("unauthorized_project_access", project_id: @project&.id)
        redirect_to impulsa_path, flash: { alert: t('impulsa.errors.unauthorized') }
      end
    end

    # SECURITY FIX: Validate step parameter
    def validate_step
      return unless @step

      valid_steps = @project.wizard.keys.map(&:to_s)
      unless valid_steps.include?(@step)
        log_security_event("invalid_wizard_step", step: @step, valid_steps: valid_steps)
        redirect_to project_impulsa_path, flash: { alert: t('impulsa.errors.invalid_step') }
      end
    end

    def handle_project_deletion
      if @project.destroy
        log_state_transition("project_deleted")
        flash[:notice] = t('impulsa.messages.project_deleted')
        redirect_to impulsa_path
      else
        flash[:error] = t('impulsa.errors.cannot_delete')
        redirect_to project_impulsa_path
      end
    end

    def handle_project_resignation
      if @project.mark_as_resigned
        log_state_transition("project_resigned")
        flash[:notice] = t('impulsa.messages.resignation_recorded')
      else
        flash[:error] = t('impulsa.errors.cannot_resign')
      end
      redirect_to project_impulsa_path
    end

    def handle_step_navigation
      if @project.wizard_step_errors.any?
        redirect_to project_step_impulsa_path(step: @project.wizard_step)
      elsif @project.wizard_next_step
        redirect_to project_step_impulsa_path(step: @project.wizard_next_step)
      else
        redirect_to project_impulsa_path
      end
    end

    def handle_upload_result(result)
      error = case result
      when :wrong_extension
        t('impulsa.errors.wrong_extension')
      when :wrong_size
        t('impulsa.errors.wrong_size')
      when :wrong_field
        t('impulsa.errors.wrong_field_upload')
      else
        nil
      end

      if error
        render json: [error], status: :unprocessable_entity
        return false
      end
      true
    end

    # SECURITY LOGGING: Log file operations
    def log_file_operation(operation, details = {})
      Rails.logger.info({
        event: operation,
        project_id: @project&.id,
        user_id: current_user&.id,
        edition_id: @edition&.id,
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end

    # SECURITY LOGGING: Log project updates
    def log_project_update(operation, details = {})
      Rails.logger.info({
        event: operation,
        project_id: @project&.id,
        user_id: current_user&.id,
        project_name: @project&.name,
        wizard_step: @project&.wizard_step,
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end

    # SECURITY LOGGING: Log state transitions
    def log_state_transition(transition, details = {})
      Rails.logger.info({
        event: "state_transition",
        transition: transition,
        project_id: @project&.id,
        user_id: current_user&.id,
        old_status: @project&.status_was,
        new_status: @project&.status,
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end

    # SECURITY LOGGING: Log security events
    def log_security_event(event_type, details = {})
      Rails.logger.warn({
        event: event_type,
        project_id: @project&.id,
        user_id: current_user&.id,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end

    # ERROR LOGGING: Comprehensive error logging
    def log_error(event_type, exception, details = {})
      Rails.logger.error({
        event: event_type,
        error_class: exception.class.name,
        error_message: exception.message,
        backtrace: exception.backtrace&.first(5),
        project_id: @project&.id,
        user_id: current_user&.id,
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end
  end
end
