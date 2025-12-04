# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VoteController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:election) { create(:election, :active) }
  let(:election_location) { create(:election_location, election: election) }

  before do
    sign_in user

    # Use main app routes instead of custom route set
    # Rails 7 requires controller specs to use actual application routes
    @routes = Rails.application.routes
  end

  # ============================================================================
  # DESCRIBE Input Validation (CRITICAL SECURITY)
  # ============================================================================
  describe 'input validation' do
    describe '#validate_election_id' do
      context 'with invalid election_id' do
        it 'rejects non-numeric election_id' do
          get :create, params: { election_id: 'abc' }
          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq(I18n.t('vote.errors.invalid_election'))
        end

        it 'rejects SQL injection attempts' do
          get :create, params: { election_id: '1 OR 1=1' }
          expect(response).to redirect_to(root_path)
        end

        it 'rejects empty election_id' do
          get :create, params: { election_id: '' }
          expect(response).to redirect_to(root_path)
        end

        it 'logs security event for invalid election_id' do
          allow(Rails.logger).to receive(:warn).and_call_original
          get :create, params: { election_id: 'malicious' }
          expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_election_id/))
        end
      end

      context 'with valid election_id' do
        it 'accepts numeric election_id' do
          allow_any_instance_of(Election).to receive(:nvotes?).and_return(true)
          allow_any_instance_of(Election).to receive(:is_active?).and_return(true)
          allow_any_instance_of(Election).to receive(:has_valid_user_created_at?).and_return(true)
          allow_any_instance_of(Election).to receive(:has_valid_location_for?).and_return(true)
          allow_any_instance_of(Election).to receive(:requires_vatid_check?).and_return(false)
          allow_any_instance_of(Election).to receive(:requires_sms_check?).and_return(false)
          allow_any_instance_of(Election).to receive(:scoped_agora_election_id).and_return('1234')

          get :create, params: { election_id: election.id }
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe '#validate_election_location_id' do
      it 'rejects non-numeric election_location_id' do
        get :election_location_votes_count, params: {
          election_id: election.id,
          election_location_id: 'abc',
          token: 'test'
        }
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq(I18n.t('vote.errors.invalid_location'))
      end

      it 'logs security event for invalid location_id' do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :election_location_votes_count, params: {
          election_id: election.id,
          election_location_id: 'hack',
          token: 'test'
        }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_election_location_id/))
      end
    end

    describe '#validate_document_params' do
      let!(:paper_election) { create(:election, :active, :paper, scope: 6) }
      let!(:paper_election_location) { create(:election_location, election: paper_election) }
      let(:paper_token) { paper_election_location.paper_token }
      let(:paper_authority) { create(:user, :admin) }
      let(:paper_vote_service) { instance_double(PaperVoteService) }

      before do
        sign_in paper_authority
        # Set referrer for redirect_back to work
        request.env['HTTP_REFERER'] = root_path
        # Mock PaperVoteService to avoid errors
        allow(PaperVoteService).to receive(:new).and_return(paper_vote_service)
        allow(paper_vote_service).to receive(:log_vote_query)
      end

      it 'rejects invalid document_type' do
        get :paper_vote, params: {
          election_id: paper_election.id,
          election_location_id: paper_election_location.id,
          token: paper_token,
          document_type: 'abc',
          document_vatid: '12345678A'
        }
        expect(flash[:error]).to eq(I18n.t('vote.errors.invalid_document_type'))
      end

      it 'rejects document_vatid with invalid characters' do
        get :paper_vote, params: {
          election_id: paper_election.id,
          election_location_id: paper_election_location.id,
          token: paper_token,
          document_type: '1',
          document_vatid: "12345'; DROP TABLE--"
        }
        expect(flash[:error]).to eq(I18n.t('vote.errors.invalid_document_format'))
      end

      it 'accepts valid document params' do
        # Mock paper_vote_user to return a valid user
        test_user = create(:user)
        allow(controller).to receive(:paper_vote_user).and_return(test_user)
        allow(controller).to receive(:check_valid_user).and_return(true)
        allow(controller).to receive(:check_valid_location).and_return(true)
        allow(controller).to receive(:check_verification).and_return(true)
        allow(controller).to receive(:check_not_voted).and_return(true)

        get :paper_vote, params: {
          election_id: paper_election.id,
          election_location_id: paper_election_location.id,
          token: paper_token,
          document_type: '1',
          document_vatid: '12345678A'
        }
        expect(response).to have_http_status(:success)
      end
    end
  end

  # ============================================================================
  # DESCRIBE Timing Attack Prevention (CRITICAL SECURITY)
  # ============================================================================
  describe 'timing attack prevention' do
    describe '#election_votes_count' do
      it 'uses secure_compare for token validation' do
        expect(ActiveSupport::SecurityUtils).to receive(:secure_compare).and_call_original
        get :election_votes_count, params: {
          election_id: election.id,
          token: 'wrong_token'
        }
      end

      it 'logs security event for invalid token' do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :election_votes_count, params: {
          election_id: election.id,
          token: 'wrong'
        }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_counter_token/))
      end

      it 'returns votes count with valid token' do
        valid_token = election.counter_token
        get :election_votes_count, params: {
          election_id: election.id,
          token: valid_token
        }
        expect(response).to have_http_status(:success)
      end
    end

    describe '#election_location_votes_count' do
      it 'uses secure_compare for token validation' do
        expect(ActiveSupport::SecurityUtils).to receive(:secure_compare).and_call_original
        get :election_location_votes_count, params: {
          election_id: election.id,
          election_location_id: election_location.id,
          token: 'wrong'
        }
      end

      it 'logs security event for invalid location token' do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :election_location_votes_count, params: {
          election_id: election.id,
          election_location_id: election_location.id,
          token: 'wrong'
        }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_location_counter_token/))
      end
    end

    describe '#check_validation_token' do
      let(:election) { create(:election, :active, :paper) }
      let(:paper_voter) { create(:user) }

      before do
        allow(controller).to receive(:paper_vote_user).and_return(paper_voter)
        allow(controller).to receive(:election).and_return(election)
        allow(controller).to receive(:election_location).and_return(election_location)
      end

      it 'uses secure_compare for validation token' do
        expected_token = election.generate_access_token("#{paper_voter.id} #{election_location.id} #{Time.zone.today.iso8601}")
        expect(ActiveSupport::SecurityUtils).to receive(:secure_compare).with(
          expected_token.to_s,
          'wrong_token'
        ).and_call_original

        controller.send(:check_validation_token, 'wrong_token')
      end

      it 'logs security event for invalid validation token' do
        allow(Rails.logger).to receive(:warn).and_call_original
        controller.send(:check_validation_token, 'wrong')
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_validation_token/))
      end
    end
  end

  # ============================================================================
  # DESCRIBE Error Handling
  # ============================================================================
  describe 'error handling' do
    describe '#send_sms_check' do
      it 'handles errors gracefully' do
        allow_any_instance_of(User).to receive(:send_sms_check!).and_raise(StandardError.new('Test error'))

        expect do
          get :send_sms_check, params: { election_id: election.id }
        end.not_to raise_error

        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq(I18n.t('vote.errors.sms_check_failed'))
      end

      it 'logs errors' do
        allow_any_instance_of(User).to receive(:send_sms_check!).and_raise(StandardError.new('Test error'))
        allow(Rails.logger).to receive(:error).and_call_original

        get :send_sms_check, params: { election_id: election.id }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/sms_check_failed/))
      end
    end

    describe '#create_token' do
      before do
        allow_any_instance_of(Election).to receive(:nvotes?).and_return(true)
        allow_any_instance_of(Election).to receive(:is_active?).and_return(true)
        allow_any_instance_of(Election).to receive(:has_valid_user_created_at?).and_return(true)
        allow_any_instance_of(Election).to receive(:has_valid_location_for?).and_return(true)
        allow_any_instance_of(Election).to receive(:requires_vatid_check?).and_return(false)
        allow(user).to receive(:pass_vatid_check?).and_return(true)
      end

      it 'handles RecordInvalid errors' do
        allow_any_instance_of(User).to receive(:get_or_create_vote).and_raise(ActiveRecord::RecordInvalid.new(Vote.new))

        expect do
          get :create_token, params: { election_id: election.id }
        end.not_to raise_error

        expect(response).to have_http_status(:gone)
      end

      it 'logs token creation errors' do
        allow_any_instance_of(User).to receive(:get_or_create_vote).and_raise(ActiveRecord::RecordInvalid.new(Vote.new))
        allow(Rails.logger).to receive(:error).and_call_original

        get :create_token, params: { election_id: election.id }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/token_creation_failed/))
      end
    end

    describe '#election (private)' do
      it 'returns nil for non-existent election' do
        expect(controller.send(:election)).to be_nil
      end

      it 'logs error for election not found' do
        allow(Rails.logger).to receive(:error).and_call_original
        controller.params[:election_id] = '999999'
        controller.send(:election)
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/election_not_found/))
      end
    end

    describe 'CSV parsing errors' do
      let(:election) { create(:election, :active, :paper, scope: 6) }

      before do
        allow(election).to receive_message_chain(:census_file, :file?).and_return(true)
        allow(controller).to receive(:election).and_return(election)
      end

      # RAILS 7.2 FIX: CSV::MalformedCSVError requires line number in Ruby 3.4+
      it 'handles CSV::MalformedCSVError gracefully' do
        allow_any_instance_of(CensusFileParser).to receive(:find_user_by_document).and_raise(CSV::MalformedCSVError.new('Bad CSV', 1))

        controller.params[:document_vatid] = '12345678A'
        controller.params[:document_type] = '1'

        result = controller.send(:get_paper_vote_user_from_csv)
        expect(result).to be_nil
      end

      it 'logs CSV parsing errors' do
        allow_any_instance_of(CensusFileParser).to receive(:find_user_by_document).and_raise(CSV::MalformedCSVError.new('Bad CSV', 1))
        allow(Rails.logger).to receive(:error).and_call_original

        controller.params[:document_vatid] = '12345678A'
        controller.params[:document_type] = '1'
        controller.send(:get_paper_vote_user_from_csv)
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/census_parse_error/))
      end
    end
  end

  # ============================================================================
  # DESCRIBE Security Logging
  # ============================================================================
  describe 'security logging' do
    describe '#log_vote_event' do
      it 'logs vote events in JSON format' do
        expect(Rails.logger).to receive(:info) do |json_str|
          log = JSON.parse(json_str)
          expect(log['event']).to eq('vote_test_event')
          expect(log['user_id']).to eq(user.id)
          expect(log['timestamp']).to be_present
          expect(log['election_id']).to eq(election.id)
        end

        controller.send(:log_vote_event, :test_event, election_id: election.id)
      end
    end

    describe '#log_vote_error' do
      it 'logs errors with backtrace in JSON format' do
        error = StandardError.new('Test error')
        # Set backtrace on the error (errors don't have backtrace until raised)
        error.set_backtrace(caller)

        expect(Rails.logger).to receive(:error) do |json_str|
          log = JSON.parse(json_str)
          expect(log['event']).to eq('vote_error_test_error')
          expect(log['error_class']).to eq('StandardError')
          expect(log['error_message']).to eq('Test error')
          expect(log['backtrace']).to be_an(Array)
        end

        controller.send(:log_vote_error, :test_error, error, election_id: election.id)
      end
    end

    describe '#log_vote_security_event' do
      it 'logs security events with IP and user agent' do
        expect(Rails.logger).to receive(:warn) do |json_str|
          log = JSON.parse(json_str)
          expect(log['event']).to eq('vote_security_test_security')
          expect(log['user_id']).to eq(user.id)
          expect(log['ip_address']).to be_present
          expect(log['user_agent']).to be_present
        end

        controller.send(:log_vote_security_event, :test_security, election_id: election.id)
      end
    end
  end

  # ============================================================================
  # DESCRIBE send_sms_check
  # ============================================================================
  describe 'GET #send_sms_check' do
    context 'when SMS sent successfully' do
      before do
        allow_any_instance_of(User).to receive(:send_sms_check!).and_return(true)
      end

      it 'redirects to sms_check page' do
        get :send_sms_check, params: { election_id: election.id }
        expect(response).to redirect_to(sms_check_vote_path(election.id))
      end

      it 'shows success message' do
        get :send_sms_check, params: { election_id: election.id }
        expect(flash[:info]).to eq(I18n.t('vote.sms_check.sent'))
      end

      it 'logs the event' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :send_sms_check, params: { election_id: election.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/sms_check_sent/))
      end
    end

    context 'when SMS rate limited' do
      before do
        allow_any_instance_of(User).to receive(:send_sms_check!).and_return(false)
      end

      it 'shows rate limit error' do
        get :send_sms_check, params: { election_id: election.id }
        expect(flash[:error]).to eq(I18n.t('vote.sms_check.rate_limited'))
      end

      it 'logs rate limit event' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :send_sms_check, params: { election_id: election.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/sms_check_rate_limited/))
      end
    end
  end

  # ============================================================================
  # DESCRIBE create
  # ============================================================================
  describe 'GET #create' do
    before do
      allow_any_instance_of(Election).to receive(:nvotes?).and_return(true)
      allow_any_instance_of(Election).to receive(:is_active?).and_return(true)
      allow_any_instance_of(Election).to receive(:has_valid_user_created_at?).and_return(true)
      allow_any_instance_of(Election).to receive(:has_valid_location_for?).and_return(true)
      allow_any_instance_of(Election).to receive(:requires_vatid_check?).and_return(false)
      allow_any_instance_of(Election).to receive(:scoped_agora_election_id).and_return('1234')
    end

    context 'with valid conditions' do
      it 'returns http success' do
        get :create, params: { election_id: election.id }
        expect(response).to have_http_status(:success)
      end

      it 'assigns scoped_agora_election_id' do
        get :create, params: { election_id: election.id }
        expect(assigns(:scoped_agora_election_id)).to eq('1234')
      end
    end

    context 'when election is not nvotes' do
      before do
        allow_any_instance_of(Election).to receive(:nvotes?).and_return(false)
      end

      it 'redirects to home' do
        get :create, params: { election_id: election.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when election is closed' do
      before do
        allow_any_instance_of(Election).to receive(:is_active?).and_return(false)
      end

      it 'redirects to home' do
        get :create, params: { election_id: election.id }
        expect(response).to redirect_to(root_path)
      end

      it 'logs the attempt' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :create, params: { election_id: election.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/election_closed_attempt/))
      end
    end

    context 'when user not eligible' do
      before do
        allow_any_instance_of(Election).to receive(:has_valid_user_created_at?).and_return(false)
      end

      it 'shows error message' do
        get :create, params: { election_id: election.id }
        expect(flash[:error]).to eq(I18n.t('vote.errors.user_not_eligible'))
      end

      it 'logs ineligibility' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :create, params: { election_id: election.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/user_not_eligible/))
      end
    end

    context 'when SMS check required' do
      before do
        allow_any_instance_of(Election).to receive(:requires_sms_check?).and_return(true)
      end

      it 'redirects to SMS check if token not provided' do
        get :create, params: { election_id: election.id }
        expect(response).to redirect_to(sms_check_vote_path(election.id))
      end

      it 'shows error for invalid SMS token' do
        allow_any_instance_of(User).to receive(:valid_sms_check?).and_return(false)
        get :create, params: { election_id: election.id, sms_check_token: 'wrong' }
        expect(flash[:error]).to eq(I18n.t('vote.sms_check.invalid_token'))
      end

      it 'logs invalid SMS token attempt' do
        allow_any_instance_of(User).to receive(:valid_sms_check?).and_return(false)
        allow(Rails.logger).to receive(:warn).and_call_original
        get :create, params: { election_id: election.id, sms_check_token: 'wrong' }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_sms_token/))
      end
    end
  end

  # ============================================================================
  # DESCRIBE create_token
  # ============================================================================
  describe 'GET #create_token' do
    let(:vote) { create(:vote, user: user, election: election) }

    before do
      allow_any_instance_of(Election).to receive(:nvotes?).and_return(true)
      allow_any_instance_of(Election).to receive(:is_active?).and_return(true)
      allow_any_instance_of(Election).to receive(:has_valid_user_created_at?).and_return(true)
      allow_any_instance_of(Election).to receive(:has_valid_location_for?).and_return(true)
      allow_any_instance_of(Election).to receive(:requires_vatid_check?).and_return(false)
    end

    context 'with valid conditions' do
      before do
        allow(user).to receive(:get_or_create_vote).and_return(vote)
      end

      it 'returns vote token' do
        get :create_token, params: { election_id: election.id }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('text/plain; charset=utf-8')
      end

      it 'logs token creation' do
        allow(Rails.logger).to receive(:info).and_call_original
        get :create_token, params: { election_id: election.id }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/token_created/))
      end
    end

    context 'when conditions not met' do
      before do
        allow_any_instance_of(Election).to receive(:is_active?).and_return(false)
      end

      it 'returns gone status' do
        get :create_token, params: { election_id: election.id }
        expect(response).to have_http_status(:gone)
      end
    end
  end

  # ============================================================================
  # DESCRIBE paper_vote
  # ============================================================================
  describe 'GET #paper_vote' do
    let(:election) { create(:election, :active, :paper) }
    let(:paper_authority) { create(:user, :admin) }
    let(:paper_token) { election_location.paper_token }

    before do
      sign_in paper_authority
    end

    context 'SECURITY: paper token validation' do
      it 'uses timing-safe comparison' do
        expect(ActiveSupport::SecurityUtils).to receive(:secure_compare).and_call_original
        get :paper_vote, params: {
          election_id: election.id,
          election_location_id: election_location.id,
          token: 'wrong'
        }
      end

      it 'logs unauthorized attempts' do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :paper_vote, params: {
          election_id: election.id,
          election_location_id: election_location.id,
          token: 'wrong'
        }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/paper_vote_unauthorized/))
      end
    end

    context 'with valid token and authority' do
      it 'renders paper_vote page' do
        # Set referrer for redirect_back calls
        request.env['HTTP_REFERER'] = root_path

        get :paper_vote, params: {
          election_id: election.id,
          election_location_id: election_location.id,
          token: paper_token
        }
        expect(response).to have_http_status(:success)
        expect(response).to render_template('paper_vote')
      end
    end

    context 'when not paper authority' do
      let(:regular_user) { create(:user) }

      before do
        sign_in regular_user
      end

      it 'logs unauthorized attempt' do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :paper_vote, params: {
          election_id: election.id,
          election_location_id: election_location.id,
          token: paper_token
        }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/unauthorized_paper_authority_attempt/))
      end
    end
  end

  # ============================================================================
  # DESCRIBE Authorization Checks
  # ============================================================================
  describe 'authorization checks' do
    describe '#check_paper_authority?' do
      context 'when user is admin' do
        let(:admin) { create(:user, :admin) }

        before do
          sign_in admin
        end

        it 'returns true' do
          expect(controller.send(:check_paper_authority?)).to be true
        end

        it 'does not log security event' do
          expect(Rails.logger).not_to receive(:warn)
          controller.send(:check_paper_authority?)
        end
      end

      context 'when user is regular user' do
        it 'returns false' do
          expect(controller.send(:check_paper_authority?)).to be false
        end

        it 'logs unauthorized attempt' do
          allow(controller).to receive(:election).and_return(election)
          allow(Rails.logger).to receive(:warn).and_call_original
          controller.send(:check_paper_authority?)
          expect(Rails.logger).to have_received(:warn).with(a_string_matching(/unauthorized_paper_authority_attempt/))
        end
      end
    end

    describe '#check_not_voted' do
      before do
        allow(controller).to receive(:election).and_return(election)
      end

      it 'logs already voted attempts' do
        allow(user).to receive(:has_already_voted_in).and_return(true)
        allow(Rails.logger).to receive(:info).and_call_original
        controller.send(:check_not_voted, user)
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/already_voted_attempt/))
      end
    end
  end

  # ============================================================================
  # DESCRIBE Internationalization
  # ============================================================================
  describe 'internationalization' do
    it 'uses I18n for SMS check messages' do
      allow_any_instance_of(User).to receive(:send_sms_check!).and_return(true)
      get :send_sms_check, params: { election_id: election.id }
      expect(flash[:info]).to eq(I18n.t('vote.sms_check.sent'))
    end

    it 'uses I18n for error messages' do
      get :create, params: { election_id: 'invalid' }
      expect(flash[:error]).to eq(I18n.t('vote.errors.invalid_election'))
    end

    it 'uses I18n for paper vote user not found' do
      allow(controller).to receive(:paper_vote_user).and_return(nil)
      controller.send(:paper_vote_user?)
      expect(flash[:error]).to eq(I18n.t('vote.paper_vote.user_not_found'))
    end
  end

  # ============================================================================
  # DESCRIBE Authentication
  # ============================================================================
  describe 'authentication' do
    before do
      sign_out user
    end

    it 'requires authentication for send_sms_check' do
      get :send_sms_check, params: { election_id: election.id }
      expect(response).to redirect_to(%r{/users/sign_in})
    end

    it 'requires authentication for create' do
      get :create, params: { election_id: election.id }
      expect(response).to redirect_to(%r{/users/sign_in})
    end

    it 'does NOT require authentication for election_votes_count' do
      valid_token = election.counter_token
      get :election_votes_count, params: { election_id: election.id, token: valid_token }
      expect(response).not_to redirect_to(new_user_session_path)
    end

    it 'does NOT require authentication for election_location_votes_count' do
      valid_token = election_location.counter_token
      get :election_location_votes_count, params: {
        election_id: election.id,
        election_location_id: election_location.id,
        token: valid_token
      }
      expect(response).not_to redirect_to(new_user_session_path)
    end
  end

  # ============================================================================
  # DESCRIBE Deprecated Redirects Fixed
  # ============================================================================
  describe 'deprecated redirects fixed' do
    let(:election) { create(:election, :active, :paper) }
    let(:paper_authority) { create(:user, :admin) }
    let(:paper_token) { election_location.paper_token }

    before do
      sign_in paper_authority
    end

    it 'uses redirect_back instead of redirect_to(:back)' do
      # This would fail if redirect_to(:back) was used
      expect do
        get :paper_vote, params: {
          election_id: election.id,
          election_location_id: election_location.id,
          token: paper_token,
          validation_token: 'wrong'
        }
      end.not_to raise_error
    end
  end
end
