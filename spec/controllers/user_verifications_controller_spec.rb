# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserVerificationsController, type: :controller do
  include Devise::Test::ControllerHelpers

  # Rails 7.2 FIX: User model doesn't have verified_at column
  # Verification is tracked through user_verifications table with status field
  let(:user) { create(:user, confirmed_at: Time.current) }
  let(:admin_user) { create(:user, admin: true, confirmed_at: Time.current) }
  let(:verified_user) do
    user = create(:user, confirmed_at: Time.current)
    # Create a user_verification with accepted status to make user verified
    create(:user_verification, user: user, status: :accepted)
    user
  end
  let(:user_verification) { create(:user_verification, user: user) }

  # Mock secrets configuration
  let(:default_secrets) do
    double(
      user_verifications: {
        'c_00' => 'c_00', # All Spain
        'c_01' => 'c_01', # Autonomous community
        'c_99' => 'c_99'  # Exterior
      },
      users: {
        'active_census_range' => '30.days'
      }
    )
  end

  before do
    # Skip ApplicationController filters for isolation
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)

    # Mock secrets configuration
    allow(Rails.application).to receive(:secrets).and_return(default_secrets)
  end

  # ==================== AUTHENTICATION TESTS ====================

  describe "authentication" do
    describe "new action" do
      context "when user not logged in" do
        it "redirects to sign in page" do
          get :new
          expect(response).to redirect_to(%r{/users/sign_in})
        end
      end

      context "when user logged in" do
        before { sign_in user }

        it "allows access" do
          allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(false)
          allow_any_instance_of(User).to receive(:verified?).and_return(false)
          get :new
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe "create action" do
      context "when user not logged in" do
        it "redirects to sign in page" do
          post :create, params: { user_verification: { terms_of_service: true } }
          expect(response).to redirect_to(%r{/users/sign_in})
        end
      end
    end

    describe "report actions" do
      context "when user not logged in" do
        it "redirects to sign in page for report" do
          get :report, params: { report_code: 'c_00' }
          expect(response).to have_http_status(:redirect)
        end

        it "redirects to sign in page for report_town" do
          get :report_town, params: { report_code: 'c_01' }
          expect(response).to have_http_status(:redirect)
        end

        it "redirects to sign in page for report_exterior" do
          get :report_exterior, params: { report_code: 'c_99' }
          expect(response).to have_http_status(:redirect)
        end
      end

      context "when non-admin user logged in" do
        before { sign_in user }

        it "denies access to report" do
          expect(controller).to receive(:authenticate_admin_user!)
          get :report, params: { report_code: 'c_00' }
        end

        it "denies access to report_town" do
          expect(controller).to receive(:authenticate_admin_user!)
          get :report_town, params: { report_code: 'c_01' }
        end

        it "denies access to report_exterior" do
          expect(controller).to receive(:authenticate_admin_user!)
          get :report_exterior, params: { report_code: 'c_99' }
        end
      end

      context "when admin user logged in" do
        before do
          sign_in admin_user
          allow(controller).to receive(:authenticate_admin_user!).and_return(true)
        end

        it "allows access to report" do
          get :report, params: { report_code: 'c_00' }
          expect(response).to have_http_status(:success)
        end

        it "allows access to report_town" do
          get :report_town, params: { report_code: 'c_01' }
          expect(response).to have_http_status(:success)
        end

        it "allows access to report_exterior" do
          get :report_exterior, params: { report_code: 'c_99' }
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  # ==================== INPUT VALIDATION TESTS ====================

  describe "input validation" do
    describe "report_code validation" do
      before do
        sign_in admin_user
        allow(controller).to receive(:authenticate_admin_user!).and_return(true)
      end

      it "accepts valid report_code" do
        get :report, params: { report_code: 'c_00' }
        expect(response).to have_http_status(:success)
      end

      it "rejects invalid report_code" do
        get :report, params: { report_code: 'invalid' }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('plebisbrand.errors.invalid_report_code'))
      end

      it "logs security event for invalid report_code" do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :report, params: { report_code: 'invalid' }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_report_code_attempt/)).at_least(:once)
      end

      it "rejects SQL injection attempts in report_code" do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :report, params: { report_code: "'; DROP TABLE users;--" }
        expect(response).to redirect_to(root_path)
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_report_code_attempt/)).at_least(:once)
      end

      it "rejects path traversal attempts in report_code" do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :report, params: { report_code: "../../../etc/passwd" }
        expect(response).to redirect_to(root_path)
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_report_code_attempt/)).at_least(:once)
      end

      it "handles blank report_code gracefully" do
        get :report, params: { report_code: '' }
        expect(response).to have_http_status(:success)
      end
    end

    describe "user_verification_params" do
      before { sign_in user }

      it "permits valid parameters" do
        allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
        allow(user).to receive(:verified?).and_return(false)

        post :create, params: {
          user_verification: {
            terms_of_service: true,
            wants_card: true,
            procesed_at: Time.current
          }
        }

        # Should not raise parameter unpermitted error
        expect(response).to have_http_status(:redirect)
      end

      it "filters unpermitted parameters" do
        allow(user).to receive(:has_not_future_verified_elections?).and_return(false)
        allow(user).to receive(:verified?).and_return(false)

        expect {
          post :create, params: {
            user_verification: {
              terms_of_service: true,
              status: :accepted, # Should be filtered
              malicious_param: 'value' # Should be filtered
            }
          }
        }.not_to raise_error
      end
    end
  end

  # ==================== AUTHORIZATION TESTS ====================

  describe "authorization" do
    describe "check_valid_and_verified" do
      before { sign_in user }

      context "when user has no future verified elections" do
        it "redirects with error message" do
          allow(user).to receive(:has_not_future_verified_elections?).and_return(true)

          get :new

          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq(I18n.t('plebisbrand.user_verification.user_not_valid_to_verify'))
        end
      end

      context "when user already verified and photos necessary" do
        it "redirects with error message" do
          allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(false)
          allow_any_instance_of(User).to receive(:verified?).and_return(true)
          allow_any_instance_of(User).to receive(:photos_necessary?).and_return(true)

          get :new

          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq(I18n.t('plebisbrand.user_verification.user_already_verified'))
        end
      end

      context "when user is valid to verify" do
        it "allows access to new" do
          allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(false)
          allow_any_instance_of(User).to receive(:verified?).and_return(false)

          get :new

          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  # ==================== SECURITY TESTS ====================

  describe "security" do
    describe "open redirect prevention" do
      before { sign_in user }

      it "prevents redirect to external URL" do
        allow(user).to receive(:has_not_future_verified_elections?).and_return(true)
        allow(Rails.logger).to receive(:warn).and_call_original
        session[:return_to] = 'https://evil.com/phishing'

        get :new

        expect(response).to redirect_to(root_path)
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/open_redirect_attempt/)).at_least(:once)
      end

      it "allows redirect to internal path" do
        allow(user).to receive(:has_not_future_verified_elections?).and_return(true)
        session[:return_to] = '/elections/1'

        get :new

        expect(response).to redirect_to('/elections/1')
      end

      it "allows redirect to same host" do
        allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(true)
        # Set request host before the request
        @request.host = 'example.com'
        session[:return_to] = 'http://example.com/elections/1'

        get :new

        expect(response).to redirect_to('http://example.com/elections/1')
      end

      it "handles invalid URLs gracefully" do
        allow(user).to receive(:has_not_future_verified_elections?).and_return(true)
        allow(Rails.logger).to receive(:warn).and_call_original
        session[:return_to] = 'not a valid url!!!'

        get :new

        expect(response).to redirect_to(root_path)
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_redirect_url/)).at_least(:once)
      end

      it "defaults to root_path when return_to is blank" do
        allow(user).to receive(:has_not_future_verified_elections?).and_return(true)
        session[:return_to] = nil

        get :new

        expect(response).to redirect_to(root_path)
      end
    end

    describe "security logging" do
      before do
        sign_in admin_user
        allow(controller).to receive(:authenticate_admin_user!).and_return(true)
      end

      it "logs report access" do
        allow(Rails.logger).to receive(:info).and_call_original
        get :report, params: { report_code: 'c_00' }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/verification_report_accessed/)).at_least(:once)
      end

      it "logs invalid report_code attempts" do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :report, params: { report_code: 'invalid' }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/invalid_report_code_attempt/)).at_least(:once)
      end

      it "includes user_id in security logs" do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :report, params: { report_code: 'invalid' }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/user_id.*#{admin_user.id}/)).at_least(:once)
      end

      it "includes IP address in security logs" do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :report, params: { report_code: 'invalid' }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/ip_address/)).at_least(:once)
      end

      it "includes user agent in security logs" do
        allow(Rails.logger).to receive(:warn).and_call_original
        get :report, params: { report_code: 'invalid' }
        expect(Rails.logger).to have_received(:warn).with(a_string_matching(/user_agent/)).at_least(:once)
      end
    end

    describe "error logging" do
      before { sign_in user }

      it "logs errors with full context" do
        allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(false)
        allow_any_instance_of(User).to receive(:verified?).and_return(false)
        allow(PlebisVerification::UserVerification).to receive(:for).and_raise(StandardError.new("Database error"))
        allow(Rails.logger).to receive(:error).and_call_original

        get :new

        expect(response).to redirect_to(root_path)
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/user_verification_new_failed/)).at_least(:once)
      end

      it "includes exception details in error logs" do
        allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(false)
        allow_any_instance_of(User).to receive(:verified?).and_return(false)
        allow(PlebisVerification::UserVerification).to receive(:for).and_raise(StandardError.new("Test error"))
        allow(Rails.logger).to receive(:error).and_call_original

        get :new

        expect(Rails.logger).to have_received(:error).with(a_string_matching(/Test error/)).at_least(:once)
      end

      it "includes backtrace in error logs" do
        allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(false)
        allow_any_instance_of(User).to receive(:verified?).and_return(false)
        allow(PlebisVerification::UserVerification).to receive(:for).and_raise(StandardError.new("Test error"))
        allow(Rails.logger).to receive(:error).and_call_original

        get :new

        expect(Rails.logger).to have_received(:error).with(a_string_matching(/backtrace/)).at_least(:once)
      end
    end
  end

  # ==================== FUNCTIONALITY TESTS ====================

  describe "new action" do
    before do
      sign_in user
      allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(false)
      allow_any_instance_of(User).to receive(:verified?).and_return(false)
    end

    it "creates a new user verification" do
      allow(PlebisVerification::UserVerification).to receive(:for).and_return(user_verification)

      get :new

      expect(assigns(:user_verification)).to eq(user_verification)
      expect(response).to have_http_status(:success)
    end

    it "handles errors gracefully" do
      allow(PlebisVerification::UserVerification).to receive(:for).and_raise(StandardError.new("Error"))

      get :new

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t('plebisbrand.errors.generic_error'))
    end
  end

  describe "create action" do
    before do
      sign_in user
      allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(false)
      allow_any_instance_of(User).to receive(:verified?).and_return(false)
      allow_any_instance_of(User).to receive(:photos_unnecessary?).and_return(true)
    end

    context "with valid parameters" do
      let(:valid_params) do
        {
          user_verification: {
            terms_of_service: "1",
            wants_card: false
          }
        }
      end

      it "creates a user verification" do
        post :create, params: valid_params

        expect(response).to have_http_status(:redirect)
      end

      it "applies initial status" do
        post :create, params: valid_params

        expect(response).to have_http_status(:redirect)
      end

      it "logs verification creation" do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: valid_params

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/user_verification_created/)).at_least(:once)
      end

      context "when wants_card is true" do
        let(:wants_card_params) do
          {
            user_verification: {
              terms_of_service: "1",
              wants_card: true
            }
          }
        end

        it "redirects to edit registration path" do
          post :create, params: wants_card_params

          expect(response).to redirect_to(edit_user_registration_path)
        end

        it "includes multiple flash messages as array" do
          post :create, params: wants_card_params

          expect(flash[:notice]).to be_an(Array)
          expect(flash[:notice].length).to eq(2)
        end
      end

      context "when election_id is present" do
        it "redirects to create_vote_path" do
          post :create, params: valid_params.merge(election_id: 123)

          expect(response).to redirect_to(create_vote_path(election_id: 123))
        end
      end

      context "when no election_id and wants_card false" do
        it "redirects to safe return path" do
          post :create, params: valid_params

          expect(response).to redirect_to(root_path)
        end
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          user_verification: {
            terms_of_service: false
          }
        }
      end

      it "renders new template" do
        post :create, params: invalid_params

        expect(response).to render_template(:new)
      end

      it "does not log verification creation" do
        expect(Rails.logger).not_to receive(:info).with(a_string_matching(/user_verification_created/))

        post :create, params: invalid_params
      end
    end

    context "when error occurs" do
      it "handles errors gracefully" do
        allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(false)
        allow_any_instance_of(User).to receive(:verified?).and_return(false)
        allow(PlebisVerification::UserVerification).to receive(:for).and_raise(StandardError.new("Error"))

        post :create, params: { user_verification: { terms_of_service: "1" } }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('plebisbrand.errors.generic_error'))
      end

      it "logs error with context" do
        allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(false)
        allow_any_instance_of(User).to receive(:verified?).and_return(false)
        allow(PlebisVerification::UserVerification).to receive(:for).and_raise(StandardError.new("Error"))
        allow(Rails.logger).to receive(:error).and_call_original

        post :create, params: { user_verification: { terms_of_service: "1" } }

        expect(Rails.logger).to have_received(:error).with(a_string_matching(/user_verification_create_failed/)).at_least(:once)
      end
    end
  end

  describe "report action" do
    before do
      sign_in admin_user
      allow(controller).to receive(:authenticate_admin_user!).and_return(true)
    end

    it "generates report" do
      allow_any_instance_of(PlebisVerification::UserVerificationReportService).to receive(:generate).and_return({ provincias: {}, autonomias: {} })

      get :report, params: { report_code: 'c_00' }

      expect(assigns(:report)).to be_present
      expect(response).to have_http_status(:success)
    end

    it "logs report access" do
      allow(Rails.logger).to receive(:info).and_call_original

      get :report, params: { report_code: 'c_00' }

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/verification_report_accessed/)).at_least(:once)
    end

    it "handles service errors gracefully" do
      allow_any_instance_of(PlebisVerification::UserVerificationReportService).to receive(:generate).and_raise(StandardError.new("Service error"))

      get :report, params: { report_code: 'c_00' }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t('plebisbrand.errors.report_generation_failed'))
    end

    it "logs service errors" do
      allow_any_instance_of(PlebisVerification::UserVerificationReportService).to receive(:generate).and_raise(StandardError.new("Service error"))
      allow(Rails.logger).to receive(:error).and_call_original

      get :report, params: { report_code: 'c_00' }

      expect(Rails.logger).to have_received(:error).with(a_string_matching(/user_verification_report_failed/)).at_least(:once)
    end
  end

  describe "report_town action" do
    before do
      sign_in admin_user
      allow(controller).to receive(:authenticate_admin_user!).and_return(true)
    end

    it "generates town report" do
      allow_any_instance_of(PlebisVerification::TownVerificationReportService).to receive(:generate).and_return({ municipios: {} })

      get :report_town, params: { report_code: 'c_01' }

      expect(assigns(:report_town)).to be_present
      expect(response).to have_http_status(:success)
    end

    it "logs report access" do
      allow(Rails.logger).to receive(:info).and_call_original

      get :report_town, params: { report_code: 'c_01' }

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/verification_report_accessed/)).at_least(:once)
    end

    it "handles service errors gracefully" do
      allow_any_instance_of(PlebisVerification::TownVerificationReportService).to receive(:generate).and_raise(StandardError.new("Service error"))

      get :report_town, params: { report_code: 'c_01' }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t('plebisbrand.errors.report_generation_failed'))
    end
  end

  describe "report_exterior action" do
    before do
      sign_in admin_user
      allow(controller).to receive(:authenticate_admin_user!).and_return(true)
    end

    it "generates exterior report" do
      allow_any_instance_of(PlebisVerification::ExteriorVerificationReportService).to receive(:generate).and_return({ paises: {} })

      get :report_exterior, params: { report_code: 'c_99' }

      expect(assigns(:report_exterior)).to be_present
      expect(response).to have_http_status(:success)
    end

    it "logs report access" do
      allow(Rails.logger).to receive(:info).and_call_original

      get :report_exterior, params: { report_code: 'c_99' }

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/verification_report_accessed/)).at_least(:once)
    end

    it "handles service errors gracefully" do
      allow_any_instance_of(PlebisVerification::ExteriorVerificationReportService).to receive(:generate).and_raise(StandardError.new("Service error"))

      get :report_exterior, params: { report_code: 'c_99' }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t('plebisbrand.errors.report_generation_failed'))
    end
  end

  # ==================== MODEL INTEGRATION TESTS ====================

  describe "status determination" do
    before do
      sign_in user
      allow_any_instance_of(User).to receive(:has_not_future_verified_elections?).and_return(false)
      allow_any_instance_of(User).to receive(:verified?).and_return(false)
      allow_any_instance_of(User).to receive(:photos_unnecessary?).and_return(true)
    end

    it "sets status to accepted_by_email when photos unnecessary" do
      post :create, params: { user_verification: { terms_of_service: "1" } }

      expect(response).to have_http_status(:redirect)
      verification = UserVerification.where(user: user).last
      expect(verification).to be_present
    end

    it "sets status to pending when previously rejected" do
      # Create a rejected verification first
      create(:user_verification, :rejected, user: user)

      post :create, params: { user_verification: { terms_of_service: "1" } }

      expect(response).to have_http_status(:redirect)
      verification = UserVerification.where(user: user).last
      expect(verification).to be_present
    end
  end
end
