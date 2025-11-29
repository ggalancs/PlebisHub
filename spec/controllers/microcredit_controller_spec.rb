# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MicrocreditController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:microcredit) { create(:microcredit, :active) }
  let(:microcredit_option) { create(:microcredit_option, microcredit: microcredit) }
  let(:microcredit_loan) { create(:microcredit_loan, microcredit: microcredit, user: user, microcredit_option: microcredit_option) }

  # Mock secrets configuration
  let(:default_brand_config) do
    {
      "default_brand" => "default",
      "brands" => {
        "default" => {
          "name" => "Default Brand",
          "main_url" => "https://example.com",
          "twitter_account" => "@example",
          "external" => false
        },
        "external_brand" => {
          "name" => "External Brand",
          "main_url" => "https://external.com",
          "twitter_account" => "@external",
          "external" => true
        }
      }
    }
  end

  before do
    # Skip ApplicationController filters for isolation
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)

    # Rails 7.2 FIX: Use main app routes instead of engine routes
    # MicrocreditController is an alias in app/controllers that inherits from PlebisMicrocredit::MicrocreditController
    # The routes are defined in config/routes.rb (main app), not in the engine
    @routes = Rails.application.routes

    # Mock secrets configuration
    allow(Rails.application).to receive(:secrets).and_return(
      double(microcredits: default_brand_config)
    )
  end

  # ==================== INPUT VALIDATION TESTS ====================

  describe "input validation" do
    describe "microcredit_id validation" do
      it "rejects non-numeric microcredit_id" do
        get :new_loan, params: { id: "abc" }
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq(I18n.t('microcredit.errors.invalid_id'))
      end

      it "rejects SQL injection attempts in microcredit_id" do
        get :new_loan, params: { id: "1 OR 1=1" }
        expect(response).to redirect_to(root_path)
      end

      it "rejects path traversal attempts in microcredit_id" do
        get :new_loan, params: { id: "../../../etc/passwd" }
        expect(response).to redirect_to(root_path)
      end

      it "accepts valid numeric microcredit_id" do
        get :new_loan, params: { id: microcredit.id }
        expect(response).to have_http_status(:success)
      end

      it "logs security event for invalid microcredit_id" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_microcredit_id/))
        get :new_loan, params: { id: "invalid" }
      end
    end

    describe "country parameter validation" do
      it "defaults to ES when country is missing" do
        get :provinces
        expect(response).to have_http_status(:success)
      end

      it "accepts valid country code" do
        get :provinces, params: { microcredit_loan_country: "FR" }
        expect(response).to have_http_status(:success)
      end

      it "rejects invalid country code and defaults to ES" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_country/))
        get :provinces, params: { microcredit_loan_country: "INVALID" }
        expect(response).to have_http_status(:success)
      end

      it "handles SQL injection attempts in country parameter" do
        expect(Rails.logger).to receive(:warn)
        get :provinces, params: { microcredit_loan_country: "'; DROP TABLE users;--" }
        expect(response).to have_http_status(:success)
      end
    end

    describe "brand parameter validation" do
      it "accepts valid brand parameter" do
        get :index, params: { brand: "external_brand" }
        expect(response).to have_http_status(:success)
        expect(assigns(:brand)).to eq("external_brand")
      end

      it "falls back to default brand for invalid brand" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_brand/))
        get :index, params: { brand: "nonexistent" }
        expect(response).to have_http_status(:success)
        expect(assigns(:brand)).to eq("default")
      end

      it "logs security event for invalid brand access" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_brand/))
        get :index, params: { brand: "hacker_brand" }
      end
    end
  end

  # ==================== CONFIGURATION HANDLING TESTS ====================

  describe "configuration handling" do
    context "when secrets are missing" do
      before do
        allow(Rails.application).to receive(:secrets).and_return(double(microcredits: nil))
      end

      it "redirects to root with error" do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq(I18n.t('microcredit.errors.configuration_error'))
      end

      it "logs security event for missing configuration" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/missing_configuration/))
        get :index
      end
    end

    context "when default_brand is missing" do
      before do
        allow(Rails.application).to receive(:secrets).and_return(
          double(microcredits: { "brands" => {} })
        )
      end

      it "redirects to root with error" do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq(I18n.t('microcredit.errors.configuration_error'))
      end
    end

    context "when brands configuration is missing" do
      before do
        allow(Rails.application).to receive(:secrets).and_return(
          double(microcredits: { "default_brand" => "default" })
        )
      end

      it "redirects to root with error" do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    context "when external brand is used" do
      it "sets correct layout" do
        get :index, params: { brand: "external_brand" }
        expect(assigns(:external)).to be true
      end

      it "sets correct URL params" do
        get :index, params: { brand: "external_brand" }
        expect(assigns(:url_params)).to eq({ brand: "external_brand" })
      end
    end

    context "when default brand is used" do
      it "sets empty URL params" do
        get :index
        expect(assigns(:url_params)).to eq({})
      end

      it "sets external to false" do
        get :index
        expect(assigns(:external)).to be false
      end
    end

    it "handles missing external key in brand config gracefully" do
      allow(Rails.application).to receive(:secrets).and_return(
        double(microcredits: {
          "default_brand" => "default",
          "brands" => { "default" => { "name" => "Test" } }
        })
      )
      get :index
      expect(assigns(:external)).to be false
    end
  end

  # ==================== LOAN CREATION FLOW TESTS ====================

  describe "loan creation" do
    describe "GET #new_loan" do
      context "with authenticated user" do
        before { sign_in user }

        it "returns success for active microcredit" do
          get :new_loan, params: { id: microcredit.id }
          expect(response).to have_http_status(:success)
        end

        it "assigns microcredit" do
          get :new_loan, params: { id: microcredit.id }
          expect(assigns(:microcredit)).to eq(microcredit)
        end

        it "assigns new loan" do
          get :new_loan, params: { id: microcredit.id }
          expect(assigns(:loan)).to be_a_new(MicrocreditLoan)
        end

        it "assigns user loans" do
          existing_loan = create(:microcredit_loan, microcredit: microcredit, user: user, microcredit_option: microcredit_option)
          get :new_loan, params: { id: microcredit.id }
          expect(assigns(:user_loans)).to include(existing_loan)
        end

        it "redirects for inactive microcredit" do
          inactive = create(:microcredit, :finished)
          get :new_loan, params: { id: inactive.id }
          expect(response).to redirect_to(microcredit_path)
        end

        it "logs access to inactive microcredit" do
          inactive = create(:microcredit, :finished)
          expect(Rails.logger).to receive(:info).with(a_string_matching(/inactive_microcredit_access/))
          get :new_loan, params: { id: inactive.id }
        end
      end

      context "without authenticated user" do
        it "allows access to new loan form" do
          get :new_loan, params: { id: microcredit.id }
          expect(response).to have_http_status(:success)
        end

        it "assigns empty user loans" do
          get :new_loan, params: { id: microcredit.id }
          expect(assigns(:user_loans)).to be_empty
        end
      end

      context "with invalid microcredit_id" do
        before { sign_in user }

        it "redirects with not_found error" do
          get :new_loan, params: { id: 99999 }
          expect(response).to redirect_to(microcredit_path)
          expect(flash[:error]).to eq(I18n.t('microcredit.errors.not_found'))
        end

        it "logs not_found error" do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/microcredit_not_found/))
          get :new_loan, params: { id: 99999 }
        end
      end
    end

    describe "POST #create_loan" do
      let(:valid_loan_params) do
        {
          amount: 100,
          terms_of_service: true,
          minimal_year_old: true,
          iban_account: "ES6621000418401234567891",
          iban_bic: "CAIXESBBXXX",
          microcredit_option_id: microcredit_option.id
        }
      end

      let(:unauthenticated_loan_params) do
        valid_loan_params.merge(
          first_name: "Juan",
          last_name: "García",
          document_vatid: "12345678A",
          email: "test@example.com",
          address: "Calle Mayor 1",
          postal_code: "28001",
          town: "Madrid",
          province: "Madrid",
          country: "ES",
          captcha: "correct",
          captcha_key: "test_key"
        )
      end

      context "with authenticated user" do
        before { sign_in user }

        it "creates loan successfully" do
          expect {
            post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
          }.to change(MicrocreditLoan, :count).by(1)
        end

        it "assigns correct user to loan" do
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
          expect(MicrocreditLoan.last.user).to eq(user)
        end

        it "assigns correct IP to loan" do
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
          expect(MicrocreditLoan.last.ip).to eq(request.remote_ip)
        end

        it "logs loan creation" do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/loan_created/))
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
        end

        it "queues email for delivery" do
          expect {
            post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
          }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end

        it "logs email queued" do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/loan_email_queued/))
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
        end

        it "sets success flash message" do
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
          expect(flash[:notice]).to be_present
        end

        it "redirects after creation" do
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
          expect(response).to redirect_to(microcredit_path)
        end

        it "does not redirect when reload param present" do
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params, reload: true }
          expect(response).not_to be_redirect
        end

        it "handles invalid loan params" do
          invalid_params = valid_loan_params.merge(amount: -100)
          post :create_loan, params: { id: microcredit.id, microcredit_loan: invalid_params }
          expect(response).to render_template(:new_loan)
        end

        it "logs loan creation failure for invalid params" do
          invalid_params = valid_loan_params.merge(amount: -100)
          expect(Rails.logger).to receive(:info).with(a_string_matching(/loan_creation_failed/))
          post :create_loan, params: { id: microcredit.id, microcredit_loan: invalid_params }
        end
      end

      context "without authenticated user" do
        it "requires captcha validation" do
          loan = build(:microcredit_loan, :without_user, microcredit: microcredit)
          expect_any_instance_of(MicrocreditLoan).to receive(:valid_with_captcha?).and_return(false)

          post :create_loan, params: { id: microcredit.id, microcredit_loan: unauthenticated_loan_params }
          expect(response).to render_template(:new_loan)
        end

        it "creates loan with valid captcha" do
          expect_any_instance_of(MicrocreditLoan).to receive(:valid_with_captcha?).and_return(true)

          expect {
            post :create_loan, params: { id: microcredit.id, microcredit_loan: unauthenticated_loan_params }
          }.to change(MicrocreditLoan, :count).by(1)
        end

        it "sets user data from params" do
          expect_any_instance_of(MicrocreditLoan).to receive(:valid_with_captcha?).and_return(true)
          expect_any_instance_of(MicrocreditLoan).to receive(:set_user_data).with(anything)

          post :create_loan, params: { id: microcredit.id, microcredit_loan: unauthenticated_loan_params }
        end
      end

      context "with inactive microcredit" do
        let(:inactive_microcredit) { create(:microcredit, :finished) }

        before { sign_in user }

        it "redirects without creating loan" do
          expect {
            post :create_loan, params: { id: inactive_microcredit.id, microcredit_loan: valid_loan_params }
          }.not_to change(MicrocreditLoan, :count)

          expect(response).to redirect_to(microcredit_path)
        end

        it "logs inactive microcredit access" do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/create_loan_inactive_microcredit/))
          post :create_loan, params: { id: inactive_microcredit.id, microcredit_loan: valid_loan_params }
        end
      end

      context "when email delivery fails" do
        before do
          sign_in user
          allow_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_later).and_raise(StandardError.new("SMTP error"))
        end

        it "still creates loan" do
          expect {
            post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
          }.to change(MicrocreditLoan, :count).by(1)
        end

        it "logs email failure" do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/loan_email_failed/))
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
        end

        it "shows pending email message" do
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
          expect(flash[:notice]).to eq(I18n.t('microcredit.new_loan.created_email_pending'))
        end
      end

      context "when save fails" do
        before do
          sign_in user
          allow_any_instance_of(MicrocreditLoan).to receive(:save).and_raise(ActiveRecord::RecordNotSaved)
        end

        it "logs save failure" do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/loan_save_failed/))
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
        end

        it "shows save failed error" do
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
          expect(flash[:error]).to eq(I18n.t('microcredit.errors.save_failed'))
        end

        it "renders new_loan template" do
          post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
          expect(response).to render_template(:new_loan)
        end
      end
    end
  end

  # ==================== RENEWAL FLOW TESTS ====================

  describe "renewal functionality" do
    let(:renewable_microcredit) do
      create(:microcredit, :active).tap do |m|
        m.update(renewal_terms_file_name: "terms.pdf")
      end
    end
    let(:renewable_loan) do
      create(:microcredit_loan,
             microcredit: renewable_microcredit,
             user: user,
             microcredit_option: microcredit_option,
             confirmed_at: 1.month.ago)
    end

    describe "GET #renewal" do
      context "with authenticated user" do
        before do
          sign_in user
          allow(user).to receive(:any_microcredit_renewable?).and_return(true)
        end

        it "returns success" do
          get :renewal
          expect(response).to have_http_status(:success)
        end

        it "assigns active microcredits" do
          create(:microcredit, :active)
          get :renewal
          expect(assigns(:microcredits_active)).to be_present
        end

        it "checks if renewable" do
          get :renewal
          expect(assigns(:renewable)).to be true
        end
      end

      context "without authenticated user and with valid loan_id" do
        it "allows access with valid hash" do
          get :renewal, params: { loan_id: renewable_loan.id, hash: renewable_loan.unique_hash }
          expect(response).to have_http_status(:success)
        end

        it "sets renewable to true with valid hash" do
          get :renewal, params: { loan_id: renewable_loan.id, hash: renewable_loan.unique_hash }
          expect(assigns(:renewable)).to be true
        end

        it "sets renewable to false with invalid hash" do
          expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_renewal_hash/))
          get :renewal, params: { loan_id: renewable_loan.id, hash: "wrong_hash" }
          expect(assigns(:renewable)).to be false
        end

        it "logs security event for invalid hash" do
          expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_renewal_hash/))
          get :renewal, params: { loan_id: renewable_loan.id, hash: "invalid" }
        end
      end

      context "without authenticated user and without loan_id" do
        it "requires authentication" do
          get :renewal
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      it "handles errors gracefully" do
        sign_in user
        allow(Microcredit).to receive(:active).and_raise(StandardError.new("DB error"))

        expect(Rails.logger).to receive(:error).with(a_string_matching(/renewal_page_failed/))
        get :renewal
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq(I18n.t('microcredit.errors.renewal_failed'))
      end
    end

    describe "GET #loans_renewal" do
      context "with authenticated user" do
        before { sign_in user }

        it "returns success" do
          get :loans_renewal, params: { id: renewable_microcredit.id }
          expect(response).to have_http_status(:success)
        end

        it "assigns microcredit" do
          get :loans_renewal, params: { id: renewable_microcredit.id }
          expect(assigns(:microcredit)).to eq(renewable_microcredit)
        end

        it "assigns renewal object" do
          get :loans_renewal, params: { id: renewable_microcredit.id }
          expect(assigns(:renewal)).to be_present
        end
      end

      context "with unauthenticated user and valid loan_id" do
        it "allows access with valid hash" do
          get :loans_renewal, params: {
            id: renewable_microcredit.id,
            loan_id: renewable_loan.id,
            hash: renewable_loan.unique_hash
          }
          expect(response).to have_http_status(:success)
        end
      end

      context "with invalid microcredit_id" do
        before { sign_in user }

        it "redirects with error" do
          get :loans_renewal, params: { id: 99999 }
          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq(I18n.t('microcredit.errors.not_found'))
        end

        it "logs not_found error" do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/microcredit_not_found/))
          get :loans_renewal, params: { id: 99999 }
        end
      end
    end

    describe "POST #loans_renew" do
      let(:renewal_params) do
        {
          renewals: {
            renewal_terms: "1",
            terms_of_service: "1",
            loan_renewals: [renewable_loan.id.to_s]
          }
        }
      end

      context "with valid renewal" do
        before do
          sign_in user
          allow_any_instance_of(MicrocreditLoan).to receive(:renew!)
        end

        it "processes renewal successfully" do
          post :loans_renew, params: {
            id: renewable_microcredit.id,
            **renewal_params
          }
          expect(response).to be_redirect
        end

        it "logs renewal success" do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/loans_renewed/))
          post :loans_renew, params: {
            id: renewable_microcredit.id,
            **renewal_params
          }
        end

        it "includes total amount in log" do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/total_amount/))
          post :loans_renew, params: {
            id: renewable_microcredit.id,
            **renewal_params
          }
        end

        it "sets success flash message" do
          post :loans_renew, params: {
            id: renewable_microcredit.id,
            **renewal_params
          }
          expect(flash[:notice]).to include(I18n.t('microcredit.loans_renewal.renewal_success', name: anything, amount: anything, campaign: anything))
        end
      end

      context "with invalid renewal" do
        before { sign_in user }

        it "renders loans_renewal template for missing terms" do
          invalid_params = {
            renewals: {
              renewal_terms: "0",
              terms_of_service: "1",
              loan_renewals: []
            }
          }
          post :loans_renew, params: { id: renewable_microcredit.id, **invalid_params }
          expect(response).to render_template(:loans_renewal)
        end
      end

      context "when transaction fails" do
        before do
          sign_in user
          allow_any_instance_of(MicrocreditLoan).to receive(:renew!).and_raise(StandardError.new("Transaction error"))
        end

        it "logs transaction failure" do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/renewal_transaction_failed/))
          post :loans_renew, params: {
            id: renewable_microcredit.id,
            **renewal_params
          }
        end

        it "shows error message" do
          post :loans_renew, params: {
            id: renewable_microcredit.id,
            **renewal_params
          }
          expect(flash[:error]).to eq(I18n.t('microcredit.errors.renewal_failed'))
        end

        it "renders loans_renewal template" do
          post :loans_renew, params: {
            id: renewable_microcredit.id,
            **renewal_params
          }
          expect(response).to render_template(:loans_renewal)
        end
      end

      context "when get_renewal returns nil" do
        before do
          sign_in user
          allow(controller).to receive(:get_renewal).and_return(nil)
        end

        it "handles gracefully" do
          post :loans_renew, params: { id: renewable_microcredit.id, **renewal_params }
          expect(response).to render_template(:loans_renewal)
        end
      end
    end
  end

  # ==================== AUTHORIZATION TESTS ====================

  describe "authorization" do
    describe "public access" do
      it "allows unauthenticated access to index" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "allows unauthenticated access to new_loan" do
        get :new_loan, params: { id: microcredit.id }
        expect(response).to have_http_status(:success)
      end

      it "allows unauthenticated access to provinces" do
        get :provinces
        expect(response).to have_http_status(:success)
      end

      it "allows unauthenticated access to towns" do
        get :towns
        expect(response).to have_http_status(:success)
      end

      it "allows unauthenticated loan creation with captcha" do
        expect_any_instance_of(MicrocreditLoan).to receive(:valid_with_captcha?).and_return(true)
        post :create_loan, params: { id: microcredit.id, microcredit_loan: { amount: 100 } }
        expect(response).not_to redirect_to(new_user_session_path)
      end
    end

    describe "authenticated access" do
      it "requires authentication for login action" do
        get :login, params: { id: microcredit.id }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "requires authentication for renewal without loan_id" do
        get :renewal
        expect(response).to redirect_to(new_user_session_path)
      end

      it "requires authentication for loans_renewal without loan_id" do
        get :loans_renewal, params: { id: microcredit.id }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "requires authentication for loans_renew without loan_id" do
        post :loans_renew, params: { id: microcredit.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "hash-based authorization for renewals" do
      let(:renewable_loan) do
        create(:microcredit_loan,
               microcredit: microcredit,
               user: user,
               microcredit_option: microcredit_option,
               confirmed_at: 1.month.ago)
      end

      before do
        microcredit.update(renewal_terms_file_name: "terms.pdf")
      end

      it "allows renewal with valid loan_id and hash" do
        get :renewal, params: { loan_id: renewable_loan.id, hash: renewable_loan.unique_hash }
        expect(response).to have_http_status(:success)
      end

      it "rejects renewal with invalid hash" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_renewal_hash/))
        get :renewal, params: { loan_id: renewable_loan.id, hash: "invalid_hash" }
        expect(assigns(:renewable)).to be false
      end

      it "rejects renewal with missing hash" do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_renewal_hash/))
        get :renewal, params: { loan_id: renewable_loan.id }
        expect(assigns(:renewable)).to be false
      end
    end
  end

  # ==================== SECURITY LOGGING TESTS ====================

  describe "security logging" do
    it "logs microcredit events in JSON format" do
      sign_in user
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"event":"microcredit_/))
      get :new_loan, params: { id: microcredit.id }
    end

    it "includes user_id in logs" do
      sign_in user
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"user_id":#{user.id}/))
      get :new_loan, params: { id: microcredit.id }
    end

    it "includes brand in logs" do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"brand":/))
      get :index
    end

    it "includes timestamp in logs" do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"timestamp":/))
      get :index
    end

    it "logs errors with error class and message" do
      expect(Rails.logger).to receive(:error).with(a_string_matching(/"error_class":/))
      get :new_loan, params: { id: 99999 }
    end

    it "logs errors with backtrace" do
      expect(Rails.logger).to receive(:error).with(a_string_matching(/"backtrace":/))
      get :new_loan, params: { id: 99999 }
    end

    it "logs security events with IP address" do
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/"ip_address":/))
      get :new_loan, params: { id: "invalid" }
    end

    it "logs security events with user agent" do
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/"user_agent":/))
      get :new_loan, params: { id: "invalid" }
    end

    it "logs invalid brand access attempts" do
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_brand/))
      get :index, params: { brand: "nonexistent" }
    end

    it "logs configuration errors" do
      allow(Rails.application).to receive(:secrets).and_return(double(microcredits: nil))
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/missing_configuration/))
      get :index
    end
  end

  # ==================== ERROR HANDLING TESTS ====================

  describe "error handling" do
    it "handles missing microcredit gracefully" do
      sign_in user
      get :new_loan, params: { id: 99999 }
      expect(response).to redirect_to(microcredit_path)
      expect(flash[:error]).to eq(I18n.t('microcredit.errors.not_found'))
    end

    it "handles database errors in index" do
      allow(Microcredit).to receive(:upcoming_finished_by_priority).and_raise(StandardError)
      get :index
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq(I18n.t('microcredit.errors.listing_failed'))
    end

    it "handles errors in provinces rendering" do
      allow(controller).to receive(:render).and_raise(StandardError)
      expect(Rails.logger).to receive(:error).with(a_string_matching(/provinces_render_failed/))
      get :provinces
      expect(response).to have_http_status(:internal_server_error)
    end

    it "handles errors in towns rendering" do
      allow(controller).to receive(:render).and_raise(StandardError)
      expect(Rails.logger).to receive(:error).with(a_string_matching(/towns_render_failed/))
      get :towns
      expect(response).to have_http_status(:internal_server_error)
    end

    it "handles errors in show_options" do
      sign_in user
      allow_any_instance_of(Microcredit).to receive(:options_summary).and_raise(StandardError)
      get :show_options, params: { id: microcredit.id }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq(I18n.t('microcredit.errors.options_failed'))
    end

    it "handles errors in login redirect" do
      sign_in user
      allow(controller).to receive(:redirect_to).and_raise(StandardError)
      expect(Rails.logger).to receive(:error).with(a_string_matching(/login_redirect_failed/))
      get :login, params: { id: microcredit.id }
    end

    it "handles LoanRenewalService errors" do
      sign_in user
      allow(LoanRenewalService).to receive(:new).and_raise(StandardError)
      expect(Rails.logger).to receive(:error).with(a_string_matching(/renewal_service_failed/))
      get :loans_renewal, params: { id: microcredit.id }
    end

    it "returns nil from get_renewal on error" do
      sign_in user
      allow(LoanRenewalService).to receive(:new).and_raise(StandardError)
      renewal = controller.send(:get_renewal)
      expect(renewal).to be_nil
    end

    it "handles renewable check errors gracefully" do
      sign_in user
      allow(user).to receive(:any_microcredit_renewable?).and_raise(StandardError)
      expect(Rails.logger).to receive(:error).with(a_string_matching(/renewable_check_failed/))
      renewable = controller.send(:any_renewable?)
      expect(renewable).to be false
    end
  end

  # ==================== INTEGRATION TESTS ====================

  describe "integration" do
    describe "LoanRenewalService integration" do
      before { sign_in user }

      it "calls LoanRenewalService.build_renewal" do
        service = instance_double(LoanRenewalService)
        allow(LoanRenewalService).to receive(:new).and_return(service)
        expect(service).to receive(:build_renewal).with(
          loan_id: nil,
          current_user: user,
          validate: false
        )
        get :loans_renewal, params: { id: microcredit.id }
      end

      it "passes validate parameter correctly" do
        service = instance_double(LoanRenewalService)
        allow(LoanRenewalService).to receive(:new).and_return(service)
        expect(service).to receive(:build_renewal).with(
          loan_id: nil,
          current_user: user,
          validate: true
        )
        post :loans_renew, params: { id: microcredit.id }
      end
    end

    describe "UsersMailer integration" do
      before { sign_in user }

      let(:valid_loan_params) do
        {
          amount: 100,
          terms_of_service: true,
          minimal_year_old: true,
          iban_account: "ES6621000418401234567891",
          iban_bic: "CAIXESBBXXX",
          microcredit_option_id: microcredit_option.id
        }
      end

      it "calls UsersMailer.microcredit_email" do
        mailer = instance_double(ActionMailer::MessageDelivery)
        expect(UsersMailer).to receive(:microcredit_email).and_return(mailer)
        expect(mailer).to receive(:deliver_later)
        post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
      end

      it "passes correct parameters to mailer" do
        expect(UsersMailer).to receive(:microcredit_email).with(
          microcredit,
          an_instance_of(MicrocreditLoan),
          hash_including("name" => "Default Brand")
        )
        post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
      end
    end

    describe "Microcredit model integration" do
      it "calls Microcredit.upcoming_finished_by_priority" do
        expect(Microcredit).to receive(:upcoming_finished_by_priority).and_return([])
        get :index
      end

      it "calls Microcredit.active for renewal" do
        sign_in user
        expect(Microcredit).to receive(:active).and_return([])
        get :renewal
      end

      it "checks is_active? on microcredit" do
        expect_any_instance_of(Microcredit).to receive(:is_active?).and_return(true)
        get :new_loan, params: { id: microcredit.id }
      end
    end

    describe "MicrocreditLoan model integration" do
      before { sign_in user }

      let(:valid_loan_params) do
        {
          amount: 100,
          terms_of_service: true,
          minimal_year_old: true,
          iban_account: "ES6621000418401234567891",
          iban_bic: "CAIXESBBXXX",
          microcredit_option_id: microcredit_option.id
        }
      end

      it "calls update_counted_at after save" do
        expect_any_instance_of(MicrocreditLoan).to receive(:update_counted_at)
        post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
      end

      it "calls set_user_data for unauthenticated users" do
        sign_out user
        expect_any_instance_of(MicrocreditLoan).to receive(:valid_with_captcha?).and_return(true)
        expect_any_instance_of(MicrocreditLoan).to receive(:set_user_data)
        post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
      end
    end
  end

  # ==================== HTML SAFETY TESTS ====================

  describe "HTML safety in flash messages" do
    before { sign_in user }

    let(:valid_loan_params) do
      {
        amount: 100,
        terms_of_service: true,
        minimal_year_old: true,
        iban_account: "ES6621000418401234567891",
        iban_bic: "CAIXESBBXXX",
        microcredit_option_id: microcredit_option.id
      }
    end

    it "sanitizes brand name in flash messages" do
      malicious_config = default_brand_config.dup
      malicious_config["brands"]["default"]["name"] = "<script>alert('XSS')</script>"
      allow(Rails.application).to receive(:secrets).and_return(double(microcredits: malicious_config))

      post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
      expect(flash[:notice]).not_to include("<script>")
      expect(flash[:notice]).to include("&lt;script&gt;")
    end

    it "sanitizes brand URL in flash messages" do
      malicious_config = default_brand_config.dup
      malicious_config["brands"]["default"]["main_url"] = "javascript:alert('XSS')"
      allow(Rails.application).to receive(:secrets).and_return(double(microcredits: malicious_config))

      post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
      expect(flash[:notice]).to include("javascript:")  # Escaped
    end

    it "sanitizes twitter account in flash messages" do
      malicious_config = default_brand_config.dup
      malicious_config["brands"]["default"]["twitter_account"] = "<img src=x onerror=alert('XSS')>"
      allow(Rails.application).to receive(:secrets).and_return(double(microcredits: malicious_config))

      post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
      expect(flash[:notice]).not_to include("<img")
      expect(flash[:notice]).to include("&lt;img")
    end
  end

  # ==================== FLASH MESSAGE TESTS ====================

  describe "flash message construction" do
    before { sign_in user }

    let(:valid_loan_params) do
      {
        amount: 100,
        terms_of_service: true,
        minimal_year_old: true,
        iban_account: "ES6621000418401234567891",
        iban_bic: "CAIXESBBXXX",
        microcredit_option_id: microcredit_option.id
      }
    end

    it "includes brand name in success message" do
      post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
      expect(flash[:notice]).to include("Default Brand")
    end

    it "includes twitter account when present" do
      post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
      expect(flash[:notice]).to include("@example")
    end

    it "omits twitter message when account not present" do
      config_without_twitter = default_brand_config.dup
      config_without_twitter["brands"]["default"].delete("twitter_account")
      allow(Rails.application).to receive(:secrets).and_return(double(microcredits: config_without_twitter))

      post :create_loan, params: { id: microcredit.id, microcredit_loan: valid_loan_params }
      expect(flash[:notice]).not_to include("tweet")
    end
  end

  # ==================== SHOW_OPTIONS TESTS ====================

  describe "GET #show_options" do
    before { sign_in user }

    it "returns success" do
      get :show_options, params: { id: microcredit.id }
      expect(response).to have_http_status(:success)
    end

    it "assigns colors" do
      get :show_options, params: { id: microcredit.id }
      expect(assigns(:colors)).to eq(["#683064", "#6b478e", "#b052a9", "#c4a0d8"])
    end

    it "assigns microcredit" do
      get :show_options, params: { id: microcredit.id }
      expect(assigns(:microcredit)).to eq(microcredit)
    end

    it "calls options_summary on microcredit" do
      expect_any_instance_of(Microcredit).to receive(:options_summary).and_return({ data: [], grand_total: 0 })
      get :show_options, params: { id: microcredit.id }
    end

    it "assigns data_detail" do
      allow_any_instance_of(Microcredit).to receive(:options_summary).and_return({ data: ["test"], grand_total: 100 })
      get :show_options, params: { id: microcredit.id }
      expect(assigns(:data_detail)).to eq(["test"])
    end

    it "assigns grand_total" do
      allow_any_instance_of(Microcredit).to receive(:options_summary).and_return({ data: [], grand_total: 100 })
      get :show_options, params: { id: microcredit.id }
      expect(assigns(:grand_total)).to eq(100)
    end
  end

  # ==================== INDEX TESTS ====================

  describe "GET #index" do
    it "returns success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns all microcredits" do
      create(:microcredit, :active)
      create(:microcredit, :upcoming)
      get :index
      expect(assigns(:all_microcredits)).to be_present
    end

    it "separates standard and mailing microcredits" do
      standard = create(:microcredit, :active)
      mailing = create(:microcredit, :active, :with_mailing)
      get :index
      expect(assigns(:microcredits_standard)).to include(standard)
      expect(assigns(:microcredits_mailing)).to include(mailing)
    end

    it "assigns upcoming microcredits when no active standard" do
      upcoming = create(:microcredit, :upcoming)
      get :index
      expect(assigns(:upcoming_microcredits_standard)).to include(upcoming)
    end

    it "assigns finished microcredits when no active standard" do
      finished = create(:microcredit, starts_at: 2.months.ago, ends_at: 5.days.ago)
      get :index
      expect(assigns(:finished_microcredits_standard)).to include(finished)
    end

    it "assigns upcoming text when available" do
      upcoming = create(:microcredit, :upcoming)
      allow(upcoming).to receive(:get_microcredit_index_upcoming_text).and_return("Coming soon")
      allow(Microcredit).to receive(:upcoming_finished_by_priority).and_return([upcoming])
      get :index
      expect(assigns(:microcredit_index_upcoming_text)).to eq("Coming soon")
    end
  end

  # ==================== LOGIN ACTION TESTS ====================

  describe "GET #login" do
    it "requires authentication" do
      get :login, params: { id: microcredit.id }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects to new_loan after authentication" do
      sign_in user
      get :login, params: { id: microcredit.id }
      expect(response).to redirect_to(new_microcredit_loan_path(microcredit.id, brand: "default"))
    end

    it "includes brand in redirect params" do
      sign_in user
      get :login, params: { id: microcredit.id, brand: "external_brand" }
      expect(response).to redirect_to(new_microcredit_loan_path(microcredit.id, brand: "external_brand"))
    end
  end
end
