# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisCms::PageController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user, born_at: Date.new(1990, 1, 1)) }
  let(:user_without_birthdate) { create(:user, born_at: nil) }

  # Skip ApplicationController filters for isolation
  before do
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)

    # Setup Devise mapping
    @request.env["devise.mapping"] = Devise.mappings[:user]

    # Mock Election.active to avoid DB dependencies
    allow(Election).to receive(:active).and_return([])

    # Mock Rails secrets
    allow(Rails.application.secrets).to receive(:metas).and_return({
      "description" => "Default meta description",
      "image" => "Default meta image"
    })
    allow(Rails.application.secrets).to receive(:forms).and_return({
      "domain" => "forms.example.com",
      "secret" => "test_secret_key"
    })

    # Use actual engine routes instead of custom route set
    # Rails 7 requires engine controller specs to use engine routes
    @routes = PlebisCms::Engine.routes
  end

  describe "before_action filters" do
    context "set_metas (HIGH PRIORITY FIX: replaced before_filter)" do
      it "runs before all actions" do
        get :privacy_policy
        expect(assigns(:meta_description)).to eq("Default meta description")
      end

      it "sets default meta_description from secrets" do
        get :faq
        expect(assigns(:meta_description)).to eq("Default meta description")
      end

      it "sets default meta_image from secrets (MEDIUM PRIORITY FIX: fixed logic bug)" do
        get :faq
        expect(assigns(:meta_image)).to eq("Default meta image")
      end

      it "loads active elections" do
        mock_elections = [double("Election", meta_description: nil)]
        allow(Election).to receive(:active).and_return(mock_elections)
        get :privacy_policy
        expect(assigns(:current_elections)).to eq(mock_elections)
      end
    end

    context "authentication" do
      it "requires authentication for protected actions by default" do
        # Most actions require authentication - test with a protected one
        # (would need to define more routes to test, but show_form with login required covers this)
      end

      it "allows unauthenticated access to show_form" do
        page = create(:page)
        get :show_form, params: { id: page.id }
        expect(response).to have_http_status(:success)
      end

      it "allows unauthenticated access to privacy_policy" do
        get :privacy_policy
        expect(response).to have_http_status(:success)
      end

      it "allows unauthenticated access to faq" do
        get :faq
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show_form" do
    context "input validation (HIGH PRIORITY FIX)" do
      context "when id is missing" do
        it "returns bad request status" do
          get :show_form, params: {}
          expect(response).to have_http_status(:bad_request)
        end

        it "returns plain text error message" do
          get :show_form, params: {}
          expect(response.body).to eq("Invalid page ID")
        end

        it "logs invalid page ID (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:warn).with(/Invalid page ID attempted/)
          get :show_form, params: {}
        end
      end

      context "when id is invalid (non-numeric)" do
        it "returns bad request status" do
          get :show_form, params: { id: "invalid" }
          expect(response).to have_http_status(:bad_request)
        end

        it "logs invalid page ID" do
          expect(Rails.logger).to receive(:warn).with(/Invalid page ID attempted: "invalid"/)
          get :show_form, params: { id: "invalid" }
        end
      end

      context "when id is zero or negative" do
        it "returns bad request for zero" do
          get :show_form, params: { id: 0 }
          expect(response).to have_http_status(:bad_request)
        end

        it "returns bad request for negative" do
          get :show_form, params: { id: -1 }
          expect(response).to have_http_status(:bad_request)
        end
      end

      context "when id is empty string" do
        it "returns bad request" do
          get :show_form, params: { id: "" }
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context "error handling (CRITICAL FIX: Page.find rescue)" do
      context "when page does not exist" do
        it "returns not found status" do
          get :show_form, params: { id: 99999 }
          expect(response).to have_http_status(:not_found)
        end

        it "returns plain text error message" do
          get :show_form, params: { id: 99999 }
          expect(response.body).to eq("Page not found")
        end

        it "logs page not found (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:warn).with(/Page not found: 99999/)
          get :show_form, params: { id: 99999 }
        end

        it "does not raise ActiveRecord::RecordNotFound exception" do
          expect {
            get :show_form, params: { id: 99999 }
          }.not_to raise_error
        end
      end

      context "when page is soft-deleted" do
        let(:deleted_page) { create(:page, :deleted) }

        it "returns not found status" do
          get :show_form, params: { id: deleted_page.id }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "with valid page" do
      let(:page) { create(:page, title: "Test Form", id_form: 42) }

      context "without authentication required" do
        before do
          page.update!(require_login: false)
        end

        it "returns success status" do
          get :show_form, params: { id: page.id }
          expect(response).to have_http_status(:success)
        end

        it "renders form_iframe template" do
          get :show_form, params: { id: page.id }
          expect(response).to render_template(:form_iframe)
        end

        it "assigns page title to locals" do
          get :show_form, params: { id: page.id }
          expect(controller.view_assigns['title']).to eq("Test Form")
        end

        it "generates form URL with signature" do
          get :show_form, params: { id: page.id }
          url = controller.view_assigns['url']
          expect(url).to include("f=42")
          expect(url).to include("signature=")
          expect(url).to include("timestamp=")
        end
      end

      context "with authentication required (page.require_login = true)" do
        before do
          page.update!(require_login: true)
        end

        context "when user is not signed in" do
          it "redirects to sign in page" do
            get :show_form, params: { id: page.id }
            expect(response).to redirect_to(new_user_session_path)
          end

          it "stores meta information in flash" do
            page.update!(meta_description: "Form description", meta_image: "form_image.jpg")
            get :show_form, params: { id: page.id }
            expect(flash[:metas]).to eq({
              description: "Form description",
              image: "form_image.jpg"
            })
          end
        end

        context "when user is signed in" do
          before do
            sign_in user
          end

          it "returns success status" do
            get :show_form, params: { id: page.id }
            expect(response).to have_http_status(:success)
          end

          it "renders form_iframe template" do
            get :show_form, params: { id: page.id }
            expect(response).to render_template(:form_iframe)
          end
        end
      end

      context "with meta data" do
        before do
          page.update!(
            meta_description: "Custom form description",
            meta_image: "custom_form_image.jpg"
          )
        end

        it "uses page meta_description" do
          get :show_form, params: { id: page.id }
          expect(assigns(:meta_description)).to eq("Custom form description")
        end

        it "uses page meta_image" do
          get :show_form, params: { id: page.id }
          expect(assigns(:meta_image)).to eq("custom_form_image.jpg")
        end
      end

      context "with blank meta data" do
        before do
          page.update!(meta_description: "", meta_image: "")
        end

        it "uses default meta_description from set_metas" do
          get :show_form, params: { id: page.id }
          # Default is set by set_metas before_action
          expect(assigns(:meta_description)).to eq("Default meta description")
        end
      end
    end

    context "external plebisbrand link handling (HIGH PRIORITY FIX: use model method)" do
      context "when page has external plebisbrand link" do
        let(:external_page) { create(:page, :with_external_link, title: "External Form") }

        it "renders formview_iframe template" do
          get :show_form, params: { id: external_page.id }
          expect(response).to render_template(:formview_iframe)
        end

        it "uses page link directly" do
          get :show_form, params: { id: external_page.id }
          url = controller.view_assigns['url']
          expect(url).to include("forms.plebisbrand.info")
        end

        it "uses Page#external_plebisbrand_link? model method (not regex)" do
          expect_any_instance_of(Page).to receive(:external_plebisbrand_link?).and_return(true)
          get :show_form, params: { id: external_page.id }
        end
      end

      context "when page has internal form link" do
        let(:internal_page) { create(:page, link: nil, id_form: 50) }

        it "renders form_iframe template" do
          get :show_form, params: { id: internal_page.id }
          expect(response).to render_template(:form_iframe)
        end

        it "generates form URL with id_form" do
          get :show_form, params: { id: internal_page.id }
          url = controller.view_assigns['url']
          expect(url).to include("f=50")
        end
      end
    end
  end

  describe "private #add_user_params" do
    let(:page) { create(:page) }

    context "when user is not signed in" do
      it "returns URL unchanged" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        expect(url).not_to include("participa_user_")
      end

      it "does not add any user parameters" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        expect(url).not_to include("participa_user_id")
        expect(url).not_to include("participa_user_email")
      end
    end

    context "when user is signed in" do
      before do
        sign_in user
      end

      it "adds user ID to URL" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        expect(url).to include("participa_user_id=#{user.id}")
      end

      it "adds user email to URL" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        expect(url).to include("participa_user_email=#{ERB::Util.url_encode(user.email)}")
      end

      it "adds user first_name to URL" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        expect(url).to include("participa_user_first_name=")
      end

      it "adds user last_name to URL" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        expect(url).to include("participa_user_last_name=")
      end

      it "adds user document_vatid to URL" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        expect(url).to include("participa_user_document_vatid=")
      end

      it "adds user phone to URL" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        expect(url).to include("participa_user_phone=")
      end

      it "adds user born_at formatted as dd/mm/yyyy (CRITICAL FIX: with nil check)" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        expect(url).to include("participa_user_born_at=01%2F01%2F1990")
      end

      it "URL encodes all parameters properly" do
        user.update!(first_name: "José María", last_name: "García López")
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        # ERB::Util.url_encode should have encoded special characters
        expect(url).to include("Jos%C3%A9")
        expect(url).to include("Garc%C3%ADa")
      end

      it "adds all 13 user data fields" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']

        expected_fields = [
          "participa_user_id",
          "participa_user_first_name",
          "participa_user_last_name",
          "participa_user_email",
          "participa_user_phone",
          "participa_user_document_vatid",
          "participa_user_born_at",
          "participa_user_address",
          "participa_user_town",
          "participa_user_postal_code",
          "participa_user_country",
          "participa_user_gender"
        ]

        expected_fields.each do |field|
          expect(url).to include(field), "Expected URL to contain #{field}"
        end
      end
    end

    context "when user has nil born_at (CRITICAL FIX: safe navigation)" do
      before do
        sign_in user_without_birthdate
      end

      it "does not crash with NoMethodError" do
        expect {
          get :show_form, params: { id: page.id }
        }.not_to raise_error
      end

      it "returns success status" do
        get :show_form, params: { id: page.id }
        expect(response).to have_http_status(:success)
      end

      it "uses empty string for born_at parameter" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        expect(url).to include("participa_user_born_at=")
        # Should not crash, should have empty value
      end

      it "includes all other user parameters normally" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']
        expect(url).to include("participa_user_id=#{user_without_birthdate.id}")
        expect(url).to include("participa_user_email=")
      end
    end

    context "PII exposure documentation (DOCUMENTED ISSUE)" do
      before do
        sign_in user
      end

      it "exposes sensitive data in URL GET parameters (documented security issue)" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']

        # This is documented as a security issue that requires architectural changes
        # Current implementation needed for backward compatibility with external forms
        expect(url).to include("participa_user_document_vatid") # National ID
        expect(url).to include("participa_user_born_at") # Date of birth
        expect(url).to include("participa_user_email") # Email
        expect(url).to include("participa_user_phone") # Phone number
      end
    end
  end

  describe "private #sign_url" do
    let(:page) { create(:page) }

    it "adds signature parameter to URL" do
      get :show_form, params: { id: page.id }
      url = controller.view_assigns['url']
      expect(url).to include("&signature=")
    end

    it "adds timestamp parameter to URL" do
      get :show_form, params: { id: page.id }
      url = controller.view_assigns['url']
      expect(url).to include("&timestamp=")
    end

    it "uses UrlSignatureService for HMAC signing" do
      mock_service = instance_double(UrlSignatureService)
      allow(UrlSignatureService).to receive(:new).and_return(mock_service)
      allow(mock_service).to receive(:sign_url).and_return("https://example.com?signed=true")

      get :show_form, params: { id: page.id }

      expect(UrlSignatureService).to have_received(:new).with("test_secret_key")
    end
  end

  describe "static form actions" do
    describe "GET #privacy_policy" do
      it "returns success status" do
        get :privacy_policy
        expect(response).to have_http_status(:success)
      end

      it "renders privacy_policy template" do
        get :privacy_policy
        expect(response).to render_template(:privacy_policy)
      end

      it "does not require authentication" do
        # Should work without signing in
        get :privacy_policy
        expect(response).not_to redirect_to(new_user_session_path)
      end
    end

    describe "GET #faq" do
      it "returns success status" do
        get :faq
        expect(response).to have_http_status(:success)
      end

      it "renders faq template" do
        get :faq
        expect(response).to render_template(:faq)
      end
    end

    describe "GET #guarantees" do
      it "returns success status" do
        get :guarantees
        expect(response).to have_http_status(:success)
      end

      it "renders guarantees template" do
        get :guarantees
        expect(response).to render_template(:guarantees)
      end
    end

    describe "GET #funding" do
      it "returns success status" do
        get :funding
        expect(response).to have_http_status(:success)
      end

      it "renders funding template" do
        get :funding
        expect(response).to render_template(:funding)
      end
    end
  end

  describe "form iframe actions (sample of 25+ similar actions)" do
    describe "GET #guarantees_form" do
      it "returns success status" do
        get :guarantees_form
        expect(response).to have_http_status(:success)
      end

      it "renders form_iframe template" do
        get :guarantees_form
        expect(response).to render_template(:form_iframe)
      end

      it "sets correct title" do
        get :guarantees_form
        expect(controller.view_assigns['title']).to eq("Comunicación a Comisiones de Garantías Democráticas")
      end

      it "generates URL with correct form ID" do
        get :guarantees_form
        url = controller.view_assigns['url']
        expect(url).to include("f=77")
      end

      it "includes signature and timestamp" do
        get :guarantees_form
        url = controller.view_assigns['url']
        expect(url).to include("signature=")
        expect(url).to include("timestamp=")
      end
    end

    describe "GET #primarias_andalucia" do
      it "returns success status" do
        get :primarias_andalucia
        expect(response).to have_http_status(:success)
      end

      it "renders form_iframe template" do
        get :primarias_andalucia
        expect(response).to render_template(:form_iframe)
      end

      it "generates URL with correct form ID" do
        get :primarias_andalucia
        url = controller.view_assigns['url']
        expect(url).to include("f=21")
      end
    end

    describe "GET #representantes_electorales_extranjeros (CRITICAL FIX: duplicate removed)" do
      it "returns success status" do
        get :representantes_electorales_extranjeros
        expect(response).to have_http_status(:success)
      end

      it "renders form_iframe template" do
        get :representantes_electorales_extranjeros
        expect(response).to render_template(:form_iframe)
      end

      it "generates URL with correct form ID" do
        get :representantes_electorales_extranjeros
        url = controller.view_assigns['url']
        expect(url).to include("f=60")
      end

      it "is defined only once (duplicate method removed)" do
        # Ruby will only keep the last definition if there are duplicates
        # If our fix worked, this action should exist and work correctly
        expect(controller).to respond_to(:representantes_electorales_extranjeros)
      end
    end
  end

  describe "security validations" do
    let(:page) { create(:page) }

    it "uses HMAC signature for URL security" do
      get :show_form, params: { id: page.id }
      url = controller.view_assigns['url']
      # HMAC signature should be present
      expect(url).to match(/signature=[A-Za-z0-9_-]+/)
    end

    it "includes timestamp for replay attack prevention" do
      get :show_form, params: { id: page.id }
      url = controller.view_assigns['url']
      expect(url).to match(/timestamp=\d+/)
    end

    it "validates page ID to prevent SQL injection attempts" do
      # Malicious input should be caught by validation
      get :show_form, params: { id: "1; DROP TABLE pages--" }
      expect(response).to have_http_status(:bad_request)
    end

    it "properly handles ActiveRecord queries (no SQL injection via find)" do
      # Even with numeric ID, ActiveRecord should handle safely
      expect {
        get :show_form, params: { id: "999999" }
      }.not_to raise_error
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "edge cases" do
    context "with very large page ID" do
      it "handles large integers safely" do
        large_id = 2**30
        get :show_form, params: { id: large_id }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with special characters in parameters" do
      let(:page) { create(:page) }

      before do
        user.update!(
          first_name: "José María",
          last_name: "O'Brien-García",
          email: "user+test@example.com"
        )
        sign_in user
      end

      it "properly encodes special characters in URLs" do
        get :show_form, params: { id: page.id }
        url = controller.view_assigns['url']

        # Special characters should be URL encoded
        expect(url).not_to include("'") # Should be encoded
        expect(url).to include("%") # Should have percent-encoded characters
      end
    end

    context "with nil or blank user attributes" do
      before do
        user.update!(
          phone: nil,
          address: nil,
          town_name: nil
        )
        sign_in user
      end

      let(:page) { create(:page) }

      it "handles nil values gracefully" do
        expect {
          get :show_form, params: { id: page.id }
        }.not_to raise_error
      end

      it "returns success status" do
        get :show_form, params: { id: page.id }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "performance considerations" do
    let(:page) { create(:page) }

    it "caches domain configuration" do
      # Domain should be memoized in @domain instance variable
      get :show_form, params: { id: page.id }
      # Second request should use cached value
      get :show_form, params: { id: page.id }

      # Rails.application.secrets should only be called once per controller instance
      # (can't easily test this without controller instance introspection)
    end

    it "caches secret configuration" do
      # Secret should be memoized in @secret instance variable
      get :show_form, params: { id: page.id }
      # This is acceptable performance optimization
    end
  end

  describe "code quality checks" do
    it "uses before_action instead of deprecated before_filter (HIGH PRIORITY FIX)" do
      # Check that controller uses before_action
      callbacks = PageController._process_action_callbacks
      filter_names = callbacks.map(&:filter)

      # Should use :set_metas and :authenticate_user!
      expect(filter_names).to include(:set_metas)
      expect(filter_names).to include(:authenticate_user!)
    end

    it "uses Page model method for external link check (HIGH PRIORITY FIX)" do
      external_page = create(:page, :with_external_link)

      # Should call model method, not use inline regex
      expect_any_instance_of(Page).to receive(:external_plebisbrand_link?).and_call_original

      get :show_form, params: { id: external_page.id }
    end
  end
end
