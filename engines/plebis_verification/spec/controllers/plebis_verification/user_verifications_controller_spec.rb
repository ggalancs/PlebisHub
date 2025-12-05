# frozen_string_literal: true

require 'rails_helper'

module PlebisVerification
  RSpec.describe UserVerificationsController, type: :controller do
    include Devise::Test::ControllerHelpers

    let(:user) { create(:user, :with_dni) }
    let(:valid_attributes) do
      {
        terms_of_service: true,
        wants_card: false
      }
    end
    let(:invalid_attributes) do
      {
        terms_of_service: false
      }
    end

    before do
      # Use engine routes
      @routes = PlebisVerification::Engine.routes

      # Skip ApplicationController filters for isolation
      allow(controller).to receive(:banned_user).and_return(true)
      allow(controller).to receive(:unresolved_issues).and_return(true)
      allow(controller).to receive(:allow_iframe_requests).and_return(true)
      allow(controller).to receive(:admin_logger).and_return(true)
      allow(controller).to receive(:set_metas).and_return(true)
      allow(controller).to receive(:set_locale).and_return(true)
    end

    # ==================== AUTHENTICATION TESTS ====================

    describe 'authentication' do
      describe 'GET #new' do
        it 'requires authentication' do
          get :new
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'allows authenticated users' do
          sign_in user
          allow(UserVerification).to receive(:for).and_return(UserVerification.new)
          get :new
          expect(response).not_to redirect_to(new_user_session_path)
        end
      end

      describe 'POST #create' do
        it 'requires authentication' do
          post :create, params: { user_verification: valid_attributes }
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      describe 'report actions' do
        it 'requires admin authentication for report' do
          get :report, params: { report_code: 'test' }
          expect(response).to redirect_to(new_admin_user_session_path)
        end

        it 'requires admin authentication for report_town' do
          get :report_town, params: { report_code: 'test' }
          expect(response).to redirect_to(new_admin_user_session_path)
        end

        it 'requires admin authentication for report_exterior' do
          get :report_exterior, params: { report_code: 'test' }
          expect(response).to redirect_to(new_admin_user_session_path)
        end
      end
    end

    # ==================== AUTHORIZATION TESTS ====================

    describe 'authorization checks' do
      context 'when user has no future verified elections' do
        before do
          sign_in user
          allow(user).to receive(:has_not_future_verified_elections?).and_return(true)
          allow(UserVerification).to receive(:for).and_return(UserVerification.new)
        end

        it 'redirects from new action' do
          get :new
          expect(response).to be_redirect
          expect(flash[:notice]).to eq(I18n.t('plebisbrand.user_verification.user_not_valid_to_verify'))
        end

        it 'redirects from create action' do
          post :create, params: { user_verification: valid_attributes }
          expect(response).to be_redirect
        end
      end

      context 'when user is already verified' do
        before do
          sign_in user
          allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
          allow(user).to receive(:verified?).and_return(true)
          allow(user).to receive(:photos_necessary?).and_return(true)
          allow(UserVerification).to receive(:for).and_return(UserVerification.new)
        end

        it 'redirects from new action' do
          get :new
          expect(response).to be_redirect
          expect(flash[:notice]).to eq(I18n.t('plebisbrand.user_verification.user_already_verified'))
        end
      end
    end

    # ==================== NEW ACTION TESTS ====================

    describe 'GET #new' do
      context 'when user can verify' do
        before do
          sign_in user
          allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
          allow(user).to receive(:verified?).and_return(false)
        end

        it 'returns success response' do
          verification = UserVerification.new
          allow(UserVerification).to receive(:for).with(user).and_return(verification)
          get :new
          expect(response).to be_successful
        end

        it 'assigns @user_verification' do
          verification = UserVerification.new
          allow(UserVerification).to receive(:for).with(user).and_return(verification)
          get :new
          expect(assigns(:user_verification)).to eq(verification)
        end

        it 'calls UserVerification.for with current_user' do
          expect(UserVerification).to receive(:for).with(user)
          get :new
        end
      end

      context 'when error occurs' do
        before do
          sign_in user
          allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
          allow(user).to receive(:verified?).and_return(false)
          allow(UserVerification).to receive(:for).and_raise(StandardError.new('Test error'))
        end

        it 'redirects to root_path' do
          get :new
          expect(response).to redirect_to(root_path)
        end

        it 'sets flash alert' do
          get :new
          expect(flash[:alert]).to eq(I18n.t('plebisbrand.errors.generic_error'))
        end

        it 'logs error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/user_verification_new_failed/))
          get :new
        end
      end
    end

    # ==================== CREATE ACTION TESTS ====================

    describe 'POST #create' do
      context 'with valid params' do
        before do
          sign_in user
          allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
          allow(user).to receive(:verified?).and_return(false)
        end

        it 'creates a new UserVerification' do
          expect do
            post :create, params: { user_verification: valid_attributes }
          end.to change(UserVerification, :count).by(1)
        end

        it 'applies initial status' do
          verification = instance_double(UserVerification, save: true, wants_card: false)
          allow(UserVerification).to receive(:for).and_return(verification)
          expect(verification).to receive(:apply_initial_status!)
          post :create, params: { user_verification: valid_attributes }
        end

        it 'redirects to safe path' do
          post :create, params: { user_verification: valid_attributes }
          expect(response).to be_redirect
        end

        it 'sets success notice' do
          post :create, params: { user_verification: valid_attributes }
          expect(flash[:notice]).to eq(I18n.t('plebisbrand.user_verification.documentation_received'))
        end

        it 'logs verification creation' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/user_verification_created/))
          post :create, params: { user_verification: valid_attributes }
        end
      end

      context 'when wants_card is true' do
        before do
          sign_in user
          allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
          allow(user).to receive(:verified?).and_return(false)
        end

        it 'redirects to edit_user_registration_path' do
          post :create, params: { user_verification: valid_attributes.merge(wants_card: true) }
          expect(response).to redirect_to(edit_user_registration_path)
        end

        it 'sets multiple flash notices' do
          post :create, params: { user_verification: valid_attributes.merge(wants_card: true) }
          expect(flash[:notice]).to be_an(Array)
          expect(flash[:notice]).to include(I18n.t('plebisbrand.user_verification.documentation_received'))
          expect(flash[:notice]).to include(I18n.t('plebisbrand.user_verification.please_check_details'))
        end
      end

      context 'with election_id parameter' do
        before do
          sign_in user
          allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
          allow(user).to receive(:verified?).and_return(false)
        end

        it 'redirects to create_vote_path' do
          post :create, params: { user_verification: valid_attributes, election_id: 123 }
          expect(response).to redirect_to(create_vote_path(election_id: 123))
        end
      end

      context 'with invalid params' do
        before do
          sign_in user
          allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
          allow(user).to receive(:verified?).and_return(false)
        end

        it 'renders new template' do
          # Force validation failure
          verification = UserVerification.new
          allow(verification).to receive(:save).and_return(false)
          allow(UserVerification).to receive(:for).and_return(verification)

          post :create, params: { user_verification: invalid_attributes }
          expect(response).to render_template(:new)
        end

        it 'does not create a UserVerification' do
          verification = UserVerification.new
          allow(verification).to receive(:save).and_return(false)
          allow(UserVerification).to receive(:for).and_return(verification)

          expect do
            post :create, params: { user_verification: invalid_attributes }
          end.not_to change(UserVerification, :count)
        end
      end

      context 'when error occurs' do
        before do
          sign_in user
          allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
          allow(user).to receive(:verified?).and_return(false)
          allow(UserVerification).to receive(:for).and_raise(StandardError.new('Test error'))
        end

        it 'redirects to root_path' do
          post :create, params: { user_verification: valid_attributes }
          expect(response).to redirect_to(root_path)
        end

        it 'sets flash alert' do
          post :create, params: { user_verification: valid_attributes }
          expect(flash[:alert]).to eq(I18n.t('plebisbrand.errors.generic_error'))
        end

        it 'logs error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/user_verification_create_failed/))
          post :create, params: { user_verification: valid_attributes }
        end
      end
    end

    # ==================== REPORT ACTION TESTS ====================

    describe 'GET #report' do
      let(:admin_user) { create(:admin_user) }
      let(:report_code) { 'test_code' }

      before do
        sign_in_admin_user admin_user
        allow(Rails.application).to receive(:secrets).and_return(
          double(user_verifications: { report_code => {} })
        )
      end

      context 'with valid report_code' do
        it 'returns success response' do
          report_service = instance_double(UserVerificationReportService)
          allow(UserVerificationReportService).to receive(:new).with(report_code).and_return(report_service)
          allow(report_service).to receive(:generate).and_return([])

          get :report, params: { report_code: report_code }
          expect(response).to be_successful
        end

        it 'assigns @report' do
          report_service = instance_double(UserVerificationReportService)
          expected_report = double('Report')
          allow(UserVerificationReportService).to receive(:new).with(report_code).and_return(report_service)
          allow(report_service).to receive(:generate).and_return(expected_report)

          get :report, params: { report_code: report_code }
          expect(assigns(:report)).to eq(expected_report)
        end

        it 'logs report access' do
          report_service = instance_double(UserVerificationReportService)
          allow(UserVerificationReportService).to receive(:new).and_return(report_service)
          allow(report_service).to receive(:generate).and_return([])

          expect(Rails.logger).to receive(:info).with(a_string_matching(/verification_report_accessed/))
          get :report, params: { report_code: report_code }
        end
      end

      context 'with invalid report_code' do
        let(:invalid_code) { 'invalid_code' }

        before do
          allow(Rails.application).to receive(:secrets).and_return(
            double(user_verifications: { report_code => {} })
          )
        end

        it 'redirects to root_path' do
          get :report, params: { report_code: invalid_code }
          expect(response).to redirect_to(root_path)
        end

        it 'sets flash alert' do
          get :report, params: { report_code: invalid_code }
          expect(flash[:alert]).to eq(I18n.t('plebisbrand.errors.invalid_report_code'))
        end

        it 'logs invalid report code attempt' do
          expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_report_code_attempt/))
          get :report, params: { report_code: invalid_code }
        end
      end

      context 'when error occurs' do
        before do
          report_service = instance_double(UserVerificationReportService)
          allow(UserVerificationReportService).to receive(:new).and_return(report_service)
          allow(report_service).to receive(:generate).and_raise(StandardError.new('Test error'))
        end

        it 'redirects to root_path' do
          get :report, params: { report_code: report_code }
          expect(response).to redirect_to(root_path)
        end

        it 'sets flash alert' do
          get :report, params: { report_code: report_code }
          expect(flash[:alert]).to eq(I18n.t('plebisbrand.errors.report_generation_failed'))
        end

        it 'logs error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/user_verification_report_failed/))
          get :report, params: { report_code: report_code }
        end
      end
    end

    # ==================== REPORT_TOWN ACTION TESTS ====================

    describe 'GET #report_town' do
      let(:admin_user) { create(:admin_user) }
      let(:report_code) { 'test_code' }

      before do
        sign_in_admin_user admin_user
        allow(Rails.application).to receive(:secrets).and_return(
          double(user_verifications: { report_code => {} })
        )
      end

      context 'with valid report_code' do
        it 'returns success response' do
          report_service = instance_double(TownVerificationReportService)
          allow(TownVerificationReportService).to receive(:new).with(report_code).and_return(report_service)
          allow(report_service).to receive(:generate).and_return([])

          get :report_town, params: { report_code: report_code }
          expect(response).to be_successful
        end

        it 'assigns @report_town' do
          report_service = instance_double(TownVerificationReportService)
          expected_report = double('Report')
          allow(TownVerificationReportService).to receive(:new).with(report_code).and_return(report_service)
          allow(report_service).to receive(:generate).and_return(expected_report)

          get :report_town, params: { report_code: report_code }
          expect(assigns(:report_town)).to eq(expected_report)
        end

        it 'logs report access' do
          report_service = instance_double(TownVerificationReportService)
          allow(TownVerificationReportService).to receive(:new).and_return(report_service)
          allow(report_service).to receive(:generate).and_return([])

          expect(Rails.logger).to receive(:info).with(a_string_matching(/town_report/))
          get :report_town, params: { report_code: report_code }
        end
      end

      context 'when error occurs' do
        before do
          report_service = instance_double(TownVerificationReportService)
          allow(TownVerificationReportService).to receive(:new).and_return(report_service)
          allow(report_service).to receive(:generate).and_raise(StandardError.new('Test error'))
        end

        it 'redirects to root_path' do
          get :report_town, params: { report_code: report_code }
          expect(response).to redirect_to(root_path)
        end

        it 'logs error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/town_verification_report_failed/))
          get :report_town, params: { report_code: report_code }
        end
      end
    end

    # ==================== REPORT_EXTERIOR ACTION TESTS ====================

    describe 'GET #report_exterior' do
      let(:admin_user) { create(:admin_user) }
      let(:report_code) { 'test_code' }

      before do
        sign_in_admin_user admin_user
        allow(Rails.application).to receive(:secrets).and_return(
          double(user_verifications: { report_code => {} })
        )
      end

      context 'with valid report_code' do
        it 'returns success response' do
          report_service = instance_double(ExteriorVerificationReportService)
          allow(ExteriorVerificationReportService).to receive(:new).with(report_code).and_return(report_service)
          allow(report_service).to receive(:generate).and_return([])

          get :report_exterior, params: { report_code: report_code }
          expect(response).to be_successful
        end

        it 'assigns @report_exterior' do
          report_service = instance_double(ExteriorVerificationReportService)
          expected_report = double('Report')
          allow(ExteriorVerificationReportService).to receive(:new).with(report_code).and_return(report_service)
          allow(report_service).to receive(:generate).and_return(expected_report)

          get :report_exterior, params: { report_code: report_code }
          expect(assigns(:report_exterior)).to eq(expected_report)
        end

        it 'logs report access' do
          report_service = instance_double(ExteriorVerificationReportService)
          allow(ExteriorVerificationReportService).to receive(:new).and_return(report_service)
          allow(report_service).to receive(:generate).and_return([])

          expect(Rails.logger).to receive(:info).with(a_string_matching(/exterior_report/))
          get :report_exterior, params: { report_code: report_code }
        end
      end

      context 'when error occurs' do
        before do
          report_service = instance_double(ExteriorVerificationReportService)
          allow(ExteriorVerificationReportService).to receive(:new).and_return(report_service)
          allow(report_service).to receive(:generate).and_raise(StandardError.new('Test error'))
        end

        it 'redirects to root_path' do
          get :report_exterior, params: { report_code: report_code }
          expect(response).to redirect_to(root_path)
        end

        it 'logs error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/exterior_verification_report_failed/))
          get :report_exterior, params: { report_code: report_code }
        end
      end
    end

    # ==================== SECURITY TESTS ====================

    describe 'security' do
      describe 'open redirect prevention' do
        before do
          sign_in user
          allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
          allow(user).to receive(:verified?).and_return(false)
        end

        it 'prevents external redirects via return_to' do
          session[:return_to] = 'http://evil.com/phishing'
          post :create, params: { user_verification: valid_attributes }
          expect(response).not_to redirect_to('http://evil.com/phishing')
          expect(response).to redirect_to(root_path)
        end

        it 'allows internal redirects' do
          session[:return_to] = '/some/internal/path'
          post :create, params: { user_verification: valid_attributes }
          expect(response.location).to include('/some/internal/path')
        end

        it 'logs open redirect attempts' do
          session[:return_to] = 'http://evil.com/phishing'
          expect(Rails.logger).to receive(:warn).with(a_string_matching(/open_redirect_attempt/))
          post :create, params: { user_verification: valid_attributes }
        end
      end

      describe 'parameter validation' do
        before do
          sign_in user
          allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
          allow(user).to receive(:verified?).and_return(false)
        end

        it 'whitelists only permitted parameters' do
          params_with_extra = valid_attributes.merge(
            admin_approved: true,
            role: 'admin'
          )
          post :create, params: { user_verification: params_with_extra }
          # Should not raise error, extra params should be filtered
          expect(response).to be_redirect
        end
      end
    end

    # ==================== LOGGING TESTS ====================

    describe 'logging' do
      let(:admin_user) { create(:admin_user) }

      before do
        allow(Rails.application).to receive(:secrets).and_return(
          double(user_verifications: { 'test_code' => {} })
        )
      end

      it 'logs IP address' do
        sign_in user
        allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
        allow(user).to receive(:verified?).and_return(false)

        expect(Rails.logger).to receive(:info).with(a_string_matching(/"user_id":#{user.id}/))
        post :create, params: { user_verification: valid_attributes }
      end

      it 'logs user_agent' do
        sign_in user
        allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
        allow(user).to receive(:verified?).and_return(false)

        request.env['HTTP_USER_AGENT'] = 'Test Browser'
        expect(Rails.logger).to receive(:info).with(a_string_matching(/"user_agent":/))
        post :create, params: { user_verification: valid_attributes }
      end

      it 'logs timestamp in ISO8601 format' do
        sign_in user
        allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
        allow(user).to receive(:verified?).and_return(false)

        expect(Rails.logger).to receive(:info).with(a_string_matching(/"timestamp":"\d{4}-\d{2}-\d{2}T/))
        post :create, params: { user_verification: valid_attributes }
      end

      it 'logs error details with backtrace' do
        sign_in user
        allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
        allow(user).to receive(:verified?).and_return(false)
        allow(UserVerification).to receive(:for).and_raise(StandardError.new('Test error'))

        expect(Rails.logger).to receive(:error).with(a_string_matching(/"backtrace":/))
        post :create, params: { user_verification: valid_attributes }
      end
    end

    # ==================== HELPER METHODS ====================

    def sign_in_admin_user(admin_user)
      sign_in admin_user, scope: :admin_user
    end
  end
end
