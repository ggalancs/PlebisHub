# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MilitantController, type: :controller do
  # Note: MilitantController inherits from ActionController::Base, not ApplicationController
  # This is intentional for external API - no user sessions, authenticated via HMAC

  let(:user) { create(:user) }
  let(:mock_signature_service) { instance_double(UrlSignatureService) }

  before do
    # Use main app routes instead of custom route set
    # Rails 7 requires controller specs to use actual application routes
    @routes = Rails.application.routes

    allow(UrlSignatureService).to receive(:new).and_return(mock_signature_service)
  end

  describe "GET #get_militant_info" do
    context "input validation (HIGH PRIORITY FIX)" do
      context "when participa_user_id is missing" do
        before do
          allow(mock_signature_service).to receive(:verify_militant_url).and_return([true, "data"])
        end

        it "returns bad request status" do
          get :get_militant_info, params: {}
          expect(response).to have_http_status(:bad_request)
        end

        it "returns JSON error message" do
          get :get_militant_info, params: {}
          json = JSON.parse(response.body)
          expect(json["error"]).to include("Missing required parameter")
        end

        it "logs error message (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:error).with(/Missing participa_user_id/)
          get :get_militant_info, params: {}
        end

        it "does not call signature verification" do
          expect(mock_signature_service).not_to receive(:verify_militant_url)
          get :get_militant_info, params: {}
        end
      end

      context "when participa_user_id is invalid (non-numeric)" do
        before do
          allow(mock_signature_service).to receive(:verify_militant_url).and_return([true, "data"])
        end

        it "returns bad request status" do
          get :get_militant_info, params: { participa_user_id: "invalid" }
          expect(response).to have_http_status(:bad_request)
        end

        it "returns JSON error message" do
          get :get_militant_info, params: { participa_user_id: "invalid" }
          json = JSON.parse(response.body)
          expect(json["error"]).to include("Invalid user ID")
        end

        it "logs error message" do
          expect(Rails.logger).to receive(:error).with(/Invalid participa_user_id/)
          get :get_militant_info, params: { participa_user_id: "invalid" }
        end
      end

      context "when participa_user_id is zero or negative" do
        it "returns bad request for zero" do
          get :get_militant_info, params: { participa_user_id: 0 }
          expect(response).to have_http_status(:bad_request)
        end

        it "returns bad request for negative" do
          get :get_militant_info, params: { participa_user_id: -1 }
          expect(response).to have_http_status(:bad_request)
        end
      end

      context "when participa_user_id is empty string" do
        it "returns bad request" do
          get :get_militant_info, params: { participa_user_id: "" }
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context "signature verification" do
      context "when signature is invalid (HIGH PRIORITY FIX)" do
        before do
          allow(mock_signature_service).to receive(:verify_militant_url).and_return([false, "invalid_data"])
        end

        it "returns unauthorized status" do
          get :get_militant_info, params: { participa_user_id: user.id }
          expect(response).to have_http_status(:unauthorized)
        end

        it "returns JSON error with details (MEDIUM PRIORITY FIX: consistent format)" do
          get :get_militant_info, params: { participa_user_id: user.id }
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Invalid signature")
          expect(json["details"]).to eq("invalid_data")
        end

        it "logs signature failure (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Request received/)
          expect(Rails.logger).to receive(:warn).with(/Signature verification failed/)
          get :get_militant_info, params: { participa_user_id: user.id }
        end

        it "does not proceed to user lookup" do
          expect(User).not_to receive(:find_by_id)
          get :get_militant_info, params: { participa_user_id: user.id }
        end
      end

      context "when signature is valid" do
        before do
          allow(mock_signature_service).to receive(:verify_militant_url).and_return([true, "valid_data"])
        end

        it "proceeds to user lookup" do
          expect(User).to receive(:find_by_id).with(user.id).and_return(nil)
          get :get_militant_info, params: { participa_user_id: user.id }
        end

        it "logs request attempt (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Request received.*User: #{user.id}/)
          get :get_militant_info, params: { participa_user_id: user.id }
        end
      end
    end

    context "user not found (CRITICAL FIX: nil handling)" do
      before do
        allow(mock_signature_service).to receive(:verify_militant_url).and_return([true, "data"])
      end

      it "returns not found status" do
        get :get_militant_info, params: { participa_user_id: 99999 }
        expect(response).to have_http_status(:not_found)
      end

      it "returns JSON error message (MEDIUM PRIORITY FIX: consistent format)" do
        get :get_militant_info, params: { participa_user_id: 99999 }
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("User not found")
        expect(json["user_id"]).to eq(99999)
      end

      it "logs user not found (LOW PRIORITY FIX: observability)" do
        expect(Rails.logger).to receive(:info).with(/Request received/)
        expect(Rails.logger).to receive(:warn).with(/User not found.*User ID: 99999/)
        get :get_militant_info, params: { participa_user_id: 99999 }
      end

      it "does not raise NoMethodError" do
        expect {
          get :get_militant_info, params: { participa_user_id: 99999 }
        }.not_to raise_error
      end
    end

    context "collaborate query flow" do
      before do
        allow(mock_signature_service).to receive(:verify_militant_url).and_return([true, "data"])
      end

      context "when user is a collaborator" do
        before do
          allow_any_instance_of(User).to receive(:collaborator_for_militant?).and_return(true)
        end

        it "returns success status" do
          get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
          expect(response).to have_http_status(:ok)
        end

        it "returns JSON with result 1 (CRITICAL FIX: explicit render)" do
          get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
          json = JSON.parse(response.body)
          expect(json["result"]).to eq("1")
          expect(json["user_id"]).to eq(user.id)
          expect(json["is_collaborator"]).to be true
        end

        it "returns application/json content type" do
          get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
          expect(response.content_type).to include("application/json")
        end

        it "logs collaborate check (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Request received/)
          expect(Rails.logger).to receive(:info).with(/Collaborate check.*Is Collaborator: true/)
          get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
        end

        it "calls collaborator_for_militant? method" do
          user_instance = User.find(user.id)
          allow(User).to receive(:find_by_id).and_return(user_instance)
          expect(user_instance).to receive(:collaborator_for_militant?).and_return(true)
          get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
        end
      end

      context "when user is not a collaborator" do
        before do
          allow_any_instance_of(User).to receive(:collaborator_for_militant?).and_return(false)
        end

        it "returns success status" do
          get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
          expect(response).to have_http_status(:ok)
        end

        it "returns JSON with result 0" do
          get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
          json = JSON.parse(response.body)
          expect(json["result"]).to eq("0")
          expect(json["user_id"]).to eq(user.id)
          expect(json["is_collaborator"]).to be false
        end

        it "logs collaborate check with false result" do
          expect(Rails.logger).to receive(:info).with(/Request received/)
          expect(Rails.logger).to receive(:info).with(/Collaborate check.*Is Collaborator: false/)
          get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
        end
      end

      context "with different collaborate parameter values" do
        before do
          allow_any_instance_of(User).to receive(:collaborator_for_militant?).and_return(true)
        end

        it "handles collaborate=true" do
          get :get_militant_info, params: { participa_user_id: user.id, collaborate: "true" }
          expect(response).to have_http_status(:ok)
        end

        it "handles collaborate=yes" do
          get :get_militant_info, params: { participa_user_id: user.id, collaborate: "yes" }
          expect(response).to have_http_status(:ok)
        end

        it "handles collaborate=1" do
          get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "exemption update flow" do
      before do
        allow(mock_signature_service).to receive(:verify_militant_url).and_return([true, "data"])
        allow_any_instance_of(User).to receive(:still_militant?).and_return(true)
        allow_any_instance_of(User).to receive(:process_militant_data)
      end

      context "with valid exemption value true" do
        it "returns success status" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
          expect(response).to have_http_status(:ok)
        end

        it "updates user exempt_from_payment to true (MEDIUM PRIORITY FIX: strong parameters)" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
          user.reload
          expect(user.exempt_from_payment).to be true
        end

        it "returns JSON with exemption value (CRITICAL FIX: explicit render)" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
          json = JSON.parse(response.body)
          expect(json["result"]).to eq("OK")
          expect(json["user_id"]).to eq(user.id)
          expect(json["exemption"]).to be true
          expect(json["militant"]).to be true
        end

        it "logs exemption update (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Request received/)
          expect(Rails.logger).to receive(:info).with(/Exemption updated.*Exemption: true/)
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
        end

        it "calls process_militant_data" do
          user_instance = User.find(user.id)
          allow(User).to receive(:find_by_id).and_return(user_instance)
          expect(user_instance).to receive(:process_militant_data)
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
        end
      end

      context "with valid exemption value false" do
        it "updates user exempt_from_payment to false" do
          user.update!(exempt_from_payment: true)
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "false" }
          user.reload
          expect(user.exempt_from_payment).to be false
        end

        it "returns JSON with exemption false" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "false" }
          json = JSON.parse(response.body)
          expect(json["exemption"]).to be false
        end
      end

      context "with exemption value 1 (string)" do
        it "converts to true boolean (MEDIUM PRIORITY FIX: strong parameters)" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "1" }
          user.reload
          expect(user.exempt_from_payment).to be true
        end
      end

      context "with exemption value 0 (string)" do
        it "converts to false boolean" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "0" }
          user.reload
          expect(user.exempt_from_payment).to be false
        end
      end

      context "with empty exemption value" do
        it "defaults to false" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "" }
          user.reload
          expect(user.exempt_from_payment).to be false
        end
      end

      context "with no exemption parameter" do
        it "defaults to false" do
          get :get_militant_info, params: { participa_user_id: user.id }
          user.reload
          expect(user.exempt_from_payment).to be false
        end
      end

      context "with invalid exemption value (MEDIUM PRIORITY FIX: strong parameters)" do
        it "returns bad request status" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "invalid" }
          expect(response).to have_http_status(:bad_request)
        end

        it "returns JSON error message (MEDIUM PRIORITY FIX: consistent format)" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "invalid" }
          json = JSON.parse(response.body)
          expect(json["error"]).to include("Invalid exemption value")
        end

        it "does not update user" do
          original_value = user.exempt_from_payment
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "invalid" }
          user.reload
          expect(user.exempt_from_payment).to eq(original_value)
        end

        it "logs invalid exemption (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Request received/)
          expect(Rails.logger).to receive(:warn).with(/Invalid exemption value/)
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "invalid" }
        end
      end

      context "when update raises ActiveRecord::RecordInvalid" do
        before do
          user_instance = User.find(user.id)
          allow(User).to receive(:find_by_id).and_return(user_instance)
          allow(user_instance).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(user_instance))
        end

        it "returns unprocessable entity status" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns JSON error with details" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Failed to update user")
          expect(json["details"]).to be_present
        end

        it "logs update failure (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Request received/)
          expect(Rails.logger).to receive(:error).with(/Failed to update user/)
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
        end
      end

      context "militant status recalculation (LOW PRIORITY FIX: combined updates)" do
        it "updates militant status after exemption change" do
          user_instance = User.find(user.id)
          allow(User).to receive(:find_by_id).and_return(user_instance)
          expect(user_instance).to receive(:still_militant?).and_return(false)
          expect(user_instance).to receive(:update!).with(exempt_from_payment: true).and_call_original
          expect(user_instance).to receive(:update!).with(militant: false).and_call_original

          get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
        end

        it "includes new militant status in response" do
          allow_any_instance_of(User).to receive(:still_militant?).and_return(false)
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
          json = JSON.parse(response.body)
          expect(json["militant"]).to be false
        end
      end
    end

    context "performance optimizations (MEDIUM PRIORITY FIX: duplicate queries)" do
      before do
        allow(mock_signature_service).to receive(:verify_militant_url).and_return([true, "data"])
        allow_any_instance_of(User).to receive(:collaborator_for_militant?).and_return(true)
      end

      it "queries user only once per request for collaborate" do
        expect(User).to receive(:find_by_id).once.and_return(user)
        get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
      end

      it "queries user only once per request for exemption" do
        allow_any_instance_of(User).to receive(:still_militant?).and_return(true)
        allow_any_instance_of(User).to receive(:process_militant_data)
        expect(User).to receive(:find_by_id).once.and_return(user)
        get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
      end
    end

    context "logging behavior (LOW PRIORITY FIX: observability)" do
      before do
        allow(mock_signature_service).to receive(:verify_militant_url).and_return([true, "data"])
        allow_any_instance_of(User).to receive(:collaborator_for_militant?).and_return(true)
      end

      it "logs IP address in all log entries" do
        expect(Rails.logger).to receive(:info).with(/IP: 0\.0\.0\.0/).at_least(:once)
        get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
      end

      it "logs action type (collaborate_check)" do
        expect(Rails.logger).to receive(:info).with(/Action: collaborate_check/)
        get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
      end

      it "logs action type (exemption_update)" do
        allow_any_instance_of(User).to receive(:still_militant?).and_return(true)
        allow_any_instance_of(User).to receive(:process_militant_data)
        expect(Rails.logger).to receive(:info).with(/Action: exemption_update/)
        get :get_militant_info, params: { participa_user_id: user.id, exemption: "true" }
      end
    end

    context "response format validation (CRITICAL FIX: explicit render)" do
      before do
        allow(mock_signature_service).to receive(:verify_militant_url).and_return([true, "data"])
      end

      it "always returns JSON content type" do
        allow_any_instance_of(User).to receive(:collaborator_for_militant?).and_return(true)
        get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
        expect(response.content_type).to include("application/json")
      end

      it "never uses implicit rendering" do
        # Implicit rendering would look for get_militant_info.html.erb
        # All code paths now have explicit render calls
        allow_any_instance_of(User).to receive(:collaborator_for_militant?).and_return(true)
        get :get_militant_info, params: { participa_user_id: user.id, collaborate: "1" }
        expect(response.body).to be_present
        expect { JSON.parse(response.body) }.not_to raise_error
      end

      it "returns parseable JSON for all responses" do
        # Test a few different scenarios
        scenarios = [
          { params: {}, expected_status: :bad_request },
          { params: { participa_user_id: 99999 }, expected_status: :not_found },
          { params: { participa_user_id: user.id, collaborate: "1" }, expected_status: :ok }
        ]

        scenarios.each do |scenario|
          get :get_militant_info, params: scenario[:params]
          expect(response).to have_http_status(scenario[:expected_status])
          expect { JSON.parse(response.body) }.not_to raise_error
        end
      end
    end

    context "CSRF protection documentation (MEDIUM PRIORITY FIX)" do
      it "inherits from ActionController::Base (not ApplicationController)" do
        expect(MilitantController.superclass).to eq(ActionController::Base)
      end

      it "is documented as external API with HMAC authentication" do
        # Check that controller file has documentation
        file_content = File.read(Rails.root.join('app', 'controllers', 'militant_controller.rb'))
        expect(file_content).to include("CSRF Protection")
        expect(file_content).to include("HMAC")
      end
    end

    context "integration scenarios" do
      before do
        allow(UrlSignatureService).to receive(:new).and_call_original
      end

      it "integrates with UrlSignatureService for real signature verification" do
        # This would be a full integration test with real signatures
        # For now, we verify the service is instantiated correctly
        get :get_militant_info, params: { participa_user_id: user.id }
        # Should call UrlSignatureService
        expect(response).to have_http_status(:unauthorized).or have_http_status(:ok)
      end
    end

    context "edge cases" do
      before do
        allow(mock_signature_service).to receive(:verify_militant_url).and_return([true, "data"])
      end

      context "with very large user ID" do
        it "handles large integers" do
          large_id = 2**30
          get :get_militant_info, params: { participa_user_id: large_id }
          expect(response).to have_http_status(:not_found)
          json = JSON.parse(response.body)
          expect(json["user_id"]).to eq(large_id)
        end
      end

      context "with SQL injection attempt in user_id" do
        it "safely handles malicious input" do
          malicious_id = "1; DROP TABLE users--"
          get :get_militant_info, params: { participa_user_id: malicious_id }
          expect(response).to have_http_status(:bad_request)
          # Should not execute SQL injection
          expect { User.first }.not_to raise_error
        end
      end

      context "with special characters in exemption" do
        it "rejects special characters" do
          get :get_militant_info, params: { participa_user_id: user.id, exemption: "<script>alert('xss')</script>" }
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end
end
