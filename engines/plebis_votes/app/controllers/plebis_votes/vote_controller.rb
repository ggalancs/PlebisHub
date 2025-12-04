# frozen_string_literal: true

module PlebisVotes
  # VoteController - Electronic Voting System
  #
  # CRITICAL SECURITY NOTICE:
  # This controller manages electronic voting for democratic processes.
  # Any security vulnerability could compromise election integrity.
  #
  # Security measures implemented:
  # - Timing-safe token comparison (secure_compare)
  # - Comprehensive input validation
  # - Complete error handling with logging
  # - Authorization logging
  #
  class VoteController < ApplicationController
    layout 'full', only: [:create]
    before_action :authenticate_user!, except: %i[election_votes_count election_location_votes_count]
    before_action :validate_election_id,
                  only: %i[send_sms_check sms_check create create_token check election_votes_count paper_vote]
    before_action :validate_election_location_id, only: %i[election_location_votes_count paper_vote]

    helper_method :election, :election_location, :paper_vote_user, :validation_token_for_paper_vote_user,
                  :paper_authority_votes_count

    def send_sms_check
      if current_user.send_sms_check!
        log_vote_event(:sms_check_sent, election_id: params[:election_id])
        redirect_to sms_check_vote_path(params[:election_id]), flash: { info: I18n.t('vote.sms_check.sent') }
      else
        log_vote_event(:sms_check_rate_limited, election_id: params[:election_id])
        redirect_to sms_check_vote_path(params[:election_id]), flash: { error: I18n.t('vote.sms_check.rate_limited') }
      end
    rescue StandardError => e
      log_vote_error(:sms_check_failed, e, election_id: params[:election_id])
      redirect_to root_path, flash: { error: I18n.t('vote.errors.sms_check_failed') }
    end

    def sms_check; end

    def create
      return back_to_home unless election.nvotes? && check_open_election && check_valid_user && check_valid_location
      return redirect_to(new_user_verification_path(params[:election_id])) unless check_verification

      if election.requires_sms_check?
        if params[:sms_check_token].nil?
          redirect_to sms_check_vote_path(params[:election_id])
        elsif !current_user.valid_sms_check?(params[:sms_check_token])
          log_vote_security_event(:invalid_sms_token, election_id: params[:election_id])
          redirect_to sms_check_vote_path(params[:election_id]),
                      flash: { error: I18n.t('vote.sms_check.invalid_token') }
        end
      end
      @scoped_agora_election_id = election.scoped_agora_election_id(current_user)
    rescue StandardError => e
      log_vote_error(:create_failed, e, election_id: params[:election_id])
      redirect_to root_path, flash: { error: I18n.t('vote.errors.create_failed') }
    end

    def create_token
      unless election.nvotes? && check_open_election && check_valid_user && check_valid_location && check_verification
        return send_to_home
      end

      vote = current_user.get_or_create_vote(election.id)
      message = vote.generate_message
      log_vote_event(:token_created, election_id: election.id, vote_id: vote.id)

      render content_type: 'text/plain', status: :ok, plain: "#{vote.generate_hash(message)}/#{message}"
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
      log_vote_error(:token_creation_failed, e, election_id: params[:election_id])
      send_to_home
    end

    def check
      return back_to_home unless check_valid_user && check_valid_location && check_verification

      @scoped_agora_election_id = election.scoped_agora_election_id(current_user)
    rescue StandardError => e
      log_vote_error(:check_failed, e, election_id: params[:election_id])
      redirect_to root_path, flash: { error: I18n.t('vote.errors.check_failed') }
    end

    def election_votes_count
      # SECURITY FIX: Use timing-safe comparison to prevent timing attacks
      unless election && ActiveSupport::SecurityUtils.secure_compare(
        election.counter_token.to_s,
        params[:token].to_s
      )
        log_vote_security_event(:invalid_counter_token, election_id: params[:election_id],
                                                        token_prefix: params[:token]&.first(8))
        return back_to_home
      end

      render 'votes_count', layout: 'minimal', locals: { votes: election.valid_votes_count }
    rescue StandardError => e
      log_vote_error(:votes_count_failed, e, election_id: params[:election_id])
      back_to_home
    end

    def election_location_votes_count
      # SECURITY FIX: Use timing-safe comparison to prevent timing attacks
      unless election_location && ActiveSupport::SecurityUtils.secure_compare(
        election_location.counter_token.to_s,
        params[:token].to_s
      )
        log_vote_security_event(:invalid_location_counter_token,
                                election_id: params[:election_id],
                                election_location_id: params[:election_location_id],
                                token_prefix: params[:token]&.first(8))
        return back_to_home
      end

      render 'votes_count', layout: 'minimal', locals: { votes: election_location.valid_votes_count }
    rescue StandardError => e
      log_vote_error(:location_votes_count_failed, e,
                     election_id: params[:election_id],
                     election_location_id: params[:election_location_id])
      back_to_home
    end

    def paper_vote
      # SECURITY FIX: Use timing-safe comparison for paper_token
      unless check_open_election && check_paper_authority? && election&.paper? &&
             election_location &&
             ActiveSupport::SecurityUtils.secure_compare(
               election_location.paper_token.to_s,
               params[:token].to_s
             )
        log_vote_security_event(:paper_vote_unauthorized,
                                election_id: params[:election_id],
                                election_location_id: params[:election_location_id])
        return back_to_home
      end

      paper_vote_service = PlebisVotes::PaperVoteService.new(election, election_location, current_user)
      can_vote = false

      if params[:validation_token].present?
        # Validate and register paper vote
        # SECURITY FIX: Replace deprecated redirect_to(:back)
        unless paper_vote_user? && check_validation_token(params[:validation_token])
          return redirect_back_or_to(root_path)
        end

        paper_vote_service.log_vote_registered(paper_vote_user)
        flash.merge!(paper_vote_service.save_vote_for_user(paper_vote_user))
        log_vote_event(:paper_vote_registered,
                       election_id: election.id,
                       user_id: paper_vote_user.id,
                       authority_id: current_user.id)
        return redirect_back_or_to(root_path)

      elsif params[:document_vatid].present? && params[:document_type].present?
        # Query for user in census
        # SECURITY: Input validation for document parameters
        return redirect_back_or_to(root_path) unless validate_document_params

        paper_vote_service.log_vote_query(params[:document_type], params[:document_vatid])

        unless paper_vote_user? && check_valid_user(paper_vote_user) &&
               check_valid_location(paper_vote_user, [election_location]) &&
               check_verification(paper_vote_user) && check_not_voted(paper_vote_user)
          return redirect_back_or_to(root_path)
        end
      end

      render 'paper_vote', locals: { can_vote: can_vote }
    rescue CSV::MalformedCSVError => e
      log_vote_error(:census_file_malformed, e, election_id: election.id)
      flash[:error] = I18n.t('vote.errors.census_file_error')
      redirect_back_or_to(root_path)
    rescue StandardError => e
      log_vote_error(:paper_vote_failed, e, election_id: params[:election_id])
      flash[:error] = I18n.t('vote.errors.paper_vote_failed')
      redirect_back_or_to(root_path)
    end

    private

    # SECURITY: Input validation before database queries
    def validate_election_id
      return if params[:election_id].to_s.match?(/\A\d+\z/)

      log_vote_security_event(:invalid_election_id, election_id: params[:election_id])
      flash[:error] = I18n.t('vote.errors.invalid_election')
      redirect_to root_path
    end

    def validate_election_location_id
      return if params[:election_location_id].to_s.match?(/\A\d+\z/)

      log_vote_security_event(:invalid_election_location_id,
                              election_location_id: params[:election_location_id])
      flash[:error] = I18n.t('vote.errors.invalid_location')
      redirect_to root_path
    end

    def validate_document_params
      # Validate document_type is reasonable (1-3 digits)
      unless params[:document_type].to_s.match?(/\A\d{1,3}\z/)
        flash[:error] = I18n.t('vote.errors.invalid_document_type')
        return false
      end

      # Validate document_vatid format (alphanumeric, reasonable length)
      unless params[:document_vatid].to_s.match?(/\A[A-Z0-9]{5,20}\z/i)
        flash[:error] = I18n.t('vote.errors.invalid_document_format')
        return false
      end

      true
    end

    def election
      @election ||= PlebisVotes::Election.find(params[:election_id])
    rescue ActiveRecord::RecordNotFound => e
      log_vote_error(:election_not_found, e, election_id: params[:election_id])
      nil
    end

    def election_location
      @election_location ||= election&.election_locations&.find(params[:election_location_id])
    rescue ActiveRecord::RecordNotFound => e
      log_vote_error(:election_location_not_found, e,
                     election_id: params[:election_id],
                     election_location_id: params[:election_location_id])
      nil
    end

    def paper_authority_votes_count
      @paper_authority_votes_count ||= PlebisVotes::Vote.where(election: election,
                                                               paper_authority_id: current_user.id).count
    rescue StandardError => e
      log_vote_error(:authority_votes_count_failed, e, election_id: election&.id)
      0
    end

    def get_paper_vote_user_from_csv
      parser = ::CensusFileParser.new(election)

      if params[:validation_token].present?
        parser.find_user_by_validation_token(params[:user_id], params[:validation_token])
      elsif params[:document_vatid].present? && params[:document_type].present?
        parser.find_user_by_document(params[:document_vatid], params[:document_type])
      end
    rescue CSV::MalformedCSVError => e
      log_vote_error(:census_parse_error, e, election_id: election.id)
      nil
    end

    def paper_vote_user
      if election.scope == 6 && election.census_file.file?
        @paper_vote_user ||= get_paper_vote_user_from_csv
      else
        @paper_vote_user ||= if params[:validation_token].present?
                               # SECURITY: SQL injection safe - uses parameterized query
                               paper_voters.find_by(id: params[:user_id])
                             elsif params[:document_vatid].present? && params[:document_type].present?
                               # SECURITY: SQL injection safe - uses parameterized query with placeholder
                               # The .downcase method is safe, and ? placeholder prevents injection
                               paper_voters.where('lower(document_vatid) = ?', params[:document_vatid].downcase)
                                           .find_by(document_type: params[:document_type])
                             end
      end
    rescue StandardError => e
      log_vote_error(:paper_vote_user_lookup_failed, e, election_id: election&.id)
      nil
    end

    def validation_token_for_paper_vote_user
      @validation_token_for_paper_vote_user ||= election.generate_access_token("#{paper_vote_user.id} #{election_location.id} #{Time.zone.today.iso8601}")
    rescue StandardError => e
      log_vote_error(:validation_token_generation_failed, e, election_id: election&.id)
      nil
    end

    def paper_voters
      ::User.confirmed.not_banned
    end

    def back_to_home
      redirect_to root_path
    end

    def send_to_home
      render content_type: 'text/plain', status: :gone, plain: root_url
    end

    def paper_vote_user?
      return true if paper_vote_user

      flash[:error] = I18n.t('vote.paper_vote.user_not_found')
      false
    end

    def check_open_election
      return true if election&.is_active?

      log_vote_event(:election_closed_attempt, election_id: election&.id)
      flash[:error] = I18n.t('vote.errors.election_closed')
      false
    end

    def check_valid_user(user = current_user)
      return true if election.has_valid_user_created_at?(user)

      log_vote_event(:user_not_eligible, election_id: election.id, user_id: user&.id)
      flash[:error] = I18n.t('vote.errors.user_not_eligible')
      false
    end

    def check_valid_location(user = current_user, valid_locations = nil)
      return true if election.has_valid_location_for?(user, valid_locations: valid_locations)

      log_vote_event(:location_not_valid, election_id: election.id, user_id: user&.id)
      flash[:error] = I18n.t('plebisbrand.election.no_location')
      false
    end

    def check_verification(user = current_user)
      return true unless election.requires_vatid_check? && !user.pass_vatid_check?

      log_vote_event(:verification_required, election_id: election.id, user_id: user&.id)
      flash[:notice] = I18n.t('vote.errors.verification_required')
      false
    end

    def check_paper_authority?
      is_authority = current_user.admin? || current_user.paper_authority?

      unless is_authority
        log_vote_security_event(:unauthorized_paper_authority_attempt,
                                election_id: election&.id,
                                user_id: current_user&.id)
      end

      is_authority
    end

    def check_not_voted(user = current_user)
      return true unless user.has_already_voted_in(election.id)

      flash[:error] = if election.scope == 6
                        t('plebisbrand.election.already_identified')
                      else
                        t('plebisbrand.election.already_voted')
                      end
      log_vote_event(:already_voted_attempt, election_id: election.id, user_id: user&.id)
      false
    end

    def check_validation_token(received_token)
      # SECURITY FIX: Timing-safe comparison to prevent timing attacks
      expected_token = validation_token_for_paper_vote_user
      return false unless expected_token

      valid = ActiveSupport::SecurityUtils.secure_compare(
        expected_token.to_s,
        received_token.to_s
      )

      unless valid
        log_vote_security_event(:invalid_validation_token,
                                election_id: election&.id,
                                user_id: paper_vote_user&.id)
        flash[:error] = t('plebisbrand.election.token_error')
      end

      valid
    end

    # Structured logging for vote events
    def log_vote_event(event_type, **details)
      Rails.logger.info({
        event: "vote_#{event_type}",
        user_id: current_user&.id,
        timestamp: Time.current.iso8601
      }.merge(details).to_json)
    end

    # Structured logging for vote errors
    def log_vote_error(event_type, error, **details)
      Rails.logger.error({
        event: "vote_error_#{event_type}",
        user_id: current_user&.id,
        error_class: error.class.name,
        error_message: error.message,
        backtrace: error.backtrace&.first(5),
        timestamp: Time.current.iso8601
      }.merge(details).to_json)
    end

    # Structured logging for security events
    def log_vote_security_event(event_type, **details)
      Rails.logger.warn({
        event: "vote_security_#{event_type}",
        user_id: current_user&.id,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        timestamp: Time.current.iso8601
      }.merge(details).to_json)
    end
  end
end
