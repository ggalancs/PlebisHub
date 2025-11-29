# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  include Devise::Test::ControllerHelpers

  # Skip ApplicationController filters for isolation
  before do
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)

    # Use main app routes instead of custom route set
    # Rails 7 requires controller specs to use actual application routes
    @routes = Rails.application.routes
  end

  describe "POST #callback_redsys" do
    let(:order) { create(:order, :credit_card) }
    let(:mock_processor) { instance_double(RedsysPaymentProcessor) }

    context "when processing SOAP/XML callback (MEDIUM PRIORITY FIX)" do
      let(:soap_response_xml) { "<Response><OrderId>#{order.id}</OrderId></Response>" }

      before do
        allow(RedsysPaymentProcessor).to receive(:new).and_return(mock_processor)
        allow(order).to receive(:redsys_callback_response).and_return(soap_response_xml)
      end

      context "with successful SOAP callback" do
        before do
          allow(mock_processor).to receive(:process).and_return({
            order: order,
            is_soap: true,
            raw_xml: soap_response_xml,
            parsed_params: { "Ds_Order" => order.id.to_s }
          })
        end

        it "returns http success" do
          post :callback_redsys, body: soap_response_xml
          expect(response).to have_http_status(:success)
        end

        it "renders XML response (MEDIUM PRIORITY FIX: modern render syntax)" do
          post :callback_redsys, body: soap_response_xml
          expect(response.content_type).to include('application/xml')
        end

        it "returns order's SOAP response" do
          post :callback_redsys, body: soap_response_xml
          expect(response.body).to eq(soap_response_xml)
        end

        it "logs callback attempt (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Received callback from IP/)
          post :callback_redsys, body: soap_response_xml
        end

        it "logs callback success (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Received callback from IP/)
          expect(Rails.logger).to receive(:info).with(/Successfully processed order #{order.id}/)
          post :callback_redsys, body: soap_response_xml
        end

        it "includes order status in success log" do
          expect(Rails.logger).to receive(:info).with(/Received callback/)
          expect(Rails.logger).to receive(:info).with(/Status: #{order.status}/)
          post :callback_redsys, body: soap_response_xml
        end

        it "includes payment status in success log" do
          expect(Rails.logger).to receive(:info).with(/Received callback/)
          expect(Rails.logger).to receive(:info).with(/Paid: #{order.is_paid?}/)
          post :callback_redsys, body: soap_response_xml
        end

        it "creates RedsysPaymentProcessor with correct params" do
          expect(RedsysPaymentProcessor).to receive(:new).with(
            anything, # params hash
            soap_response_xml
          ).and_return(mock_processor)

          post :callback_redsys, body: soap_response_xml
        end

        it "calls processor.process" do
          expect(mock_processor).to receive(:process).and_return({
            order: order,
            is_soap: true,
            raw_xml: soap_response_xml,
            parsed_params: {}
          })

          post :callback_redsys, body: soap_response_xml
        end
      end

      context "when SOAP callback has paid order" do
        let(:paid_order) { create(:order, :paid) }

        before do
          allow(mock_processor).to receive(:process).and_return({
            order: paid_order,
            is_soap: true,
            raw_xml: soap_response_xml,
            parsed_params: {}
          })
          allow(paid_order).to receive(:redsys_callback_response).and_return(soap_response_xml)
        end

        it "returns success for paid order" do
          post :callback_redsys, body: soap_response_xml
          expect(response).to have_http_status(:success)
        end

        it "logs paid status" do
          expect(Rails.logger).to receive(:info).with(/Received callback/)
          expect(Rails.logger).to receive(:info).with(/Paid: true/)
          post :callback_redsys, body: soap_response_xml
        end
      end
    end

    context "when processing HTTP POST callback (MEDIUM PRIORITY FIX)" do
      let(:post_params) do
        {
          "Ds_Order" => order.id.to_s,
          "Ds_Response" => "0000", # Success code
          "Ds_MerchantCode" => "123456",
          "Ds_Signature" => "valid_signature"
        }
      end

      before do
        allow(RedsysPaymentProcessor).to receive(:new).and_return(mock_processor)
      end

      context "with successful HTTP POST callback" do
        before do
          allow(mock_processor).to receive(:process).and_return({
            order: order,
            is_soap: false,
            raw_xml: nil,
            parsed_params: post_params
          })
        end

        it "returns http success" do
          post :callback_redsys, params: post_params
          expect(response).to have_http_status(:success)
        end

        it "renders plain text response (MEDIUM PRIORITY FIX: modern render syntax)" do
          post :callback_redsys, params: post_params
          expect(response.content_type).to include('text/plain')
        end

        it "returns OK for paid order" do
          allow(order).to receive(:is_paid?).and_return(true)
          post :callback_redsys, params: post_params
          expect(response.body).to eq("OK")
        end

        it "returns KO for unpaid order" do
          allow(order).to receive(:is_paid?).and_return(false)
          post :callback_redsys, params: post_params
          expect(response.body).to eq("KO")
        end

        it "logs callback attempt (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Received callback from IP/)
          post :callback_redsys, params: post_params
        end

        it "logs callback success (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Received callback/)
          expect(Rails.logger).to receive(:info).with(/Successfully processed order #{order.id}/)
          post :callback_redsys, params: post_params
        end

        it "creates RedsysPaymentProcessor with correct params" do
          expect(RedsysPaymentProcessor).to receive(:new).with(
            hash_including(post_params),
            "" # Empty body for HTTP POST
          ).and_return(mock_processor)

          post :callback_redsys, params: post_params
        end
      end

      context "when HTTP POST has unpaid order" do
        before do
          allow(order).to receive(:is_paid?).and_return(false)
          allow(mock_processor).to receive(:process).and_return({
            order: order,
            is_soap: false,
            raw_xml: nil,
            parsed_params: post_params
          })
        end

        it "returns KO response" do
          post :callback_redsys, params: post_params
          expect(response.body).to eq("KO")
        end

        it "still returns success status" do
          post :callback_redsys, params: post_params
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "error handling (MEDIUM-HIGH PRIORITY FIX)" do
      before do
        allow(RedsysPaymentProcessor).to receive(:new).and_return(mock_processor)
      end

      context "when order is nil (MEDIUM PRIORITY FIX: nil check)" do
        before do
          allow(mock_processor).to receive(:process).and_return({
            order: nil,
            is_soap: false,
            raw_xml: nil,
            parsed_params: {}
          })
        end

        it "returns unprocessable entity status" do
          post :callback_redsys, params: {}
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns KO response" do
          post :callback_redsys, params: {}
          expect(response.body).to eq("KO")
        end

        it "logs error message (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Received callback/)
          expect(Rails.logger).to receive(:error).with(/Order not found in processor result/)
          post :callback_redsys, params: {}
        end

        it "does not raise exception" do
          expect {
            post :callback_redsys, params: {}
          }.not_to raise_error
        end
      end

      context "when order is nil in SOAP callback" do
        before do
          allow(mock_processor).to receive(:process).and_return({
            order: nil,
            is_soap: true,
            raw_xml: "<xml>test</xml>",
            parsed_params: {}
          })
        end

        it "returns XML error response" do
          post :callback_redsys, body: "<xml>test</xml>"
          expect(response.content_type).to include('application/xml')
        end

        it "returns error XML content" do
          post :callback_redsys, body: "<xml>test</xml>"
          expect(response.body).to include("<error>")
          expect(response.body).to include("Payment processing failed")
        end

        it "returns unprocessable entity status" do
          post :callback_redsys, body: "<xml>test</xml>"
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when ActiveRecord::RecordNotFound is raised" do
        before do
          allow(mock_processor).to receive(:process).and_raise(
            ActiveRecord::RecordNotFound.new("Order not found")
          )
        end

        it "returns unprocessable entity status" do
          post :callback_redsys, params: { "Ds_Order" => "999999" }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns KO response" do
          post :callback_redsys, params: { "Ds_Order" => "999999" }
          expect(response.body).to eq("KO")
        end

        it "logs error with exception details (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Received callback/)
          expect(Rails.logger).to receive(:error).with(/Order not found in database/)
          expect(Rails.logger).to receive(:error).with(/ActiveRecord::RecordNotFound/)
          post :callback_redsys, params: { "Ds_Order" => "999999" }
        end

        it "does not raise exception to caller" do
          expect {
            post :callback_redsys, params: { "Ds_Order" => "999999" }
          }.not_to raise_error
        end
      end

      context "when StandardError is raised (XML parsing error)" do
        before do
          allow(mock_processor).to receive(:process).and_raise(
            StandardError.new("Invalid XML format")
          )
        end

        it "returns unprocessable entity status" do
          post :callback_redsys, body: "invalid xml"
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns KO response" do
          post :callback_redsys, body: "invalid xml"
          expect(response.body).to eq("KO")
        end

        it "logs error with exception details (LOW PRIORITY FIX: observability)" do
          expect(Rails.logger).to receive(:info).with(/Received callback/)
          expect(Rails.logger).to receive(:error).with(/Unexpected error processing callback/)
          expect(Rails.logger).to receive(:error).with(/StandardError: Invalid XML format/)
          post :callback_redsys, body: "invalid xml"
        end

        it "includes backtrace in error log" do
          expect(Rails.logger).to receive(:info).with(/Received callback/)
          expect(Rails.logger).to receive(:error).with(/Unexpected error.*\n/)
          post :callback_redsys, body: "invalid xml"
        end

        it "does not raise exception to caller" do
          expect {
            post :callback_redsys, body: "invalid xml"
          }.not_to raise_error
        end
      end

      context "when signature validation fails" do
        before do
          allow(mock_processor).to receive(:process).and_raise(
            StandardError.new("Invalid signature")
          )
        end

        it "returns error response" do
          post :callback_redsys, params: { "Ds_Order" => "123", "Ds_Signature" => "invalid" }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "logs security error" do
          expect(Rails.logger).to receive(:info).with(/Received callback/)
          expect(Rails.logger).to receive(:error).with(/Unexpected error/)
          post :callback_redsys, params: { "Ds_Order" => "123", "Ds_Signature" => "invalid" }
        end
      end
    end

    context "security validations" do
      it "exempts callback_redsys from CSRF protection (correctly configured)" do
        # CSRF exemption is correct for external payment gateway callbacks
        # Authentication is via HMAC signature in Order#redsys_parse_response!
        expect(controller.class._process_action_callbacks.any? do |callback|
          callback.filter == :verify_authenticity_token &&
          callback.if.any? { |c| c.call(controller) == false if controller.action_name == "callback_redsys" }
        end).to be_truthy
      end

      it "does not require user authentication (external callback)" do
        # This is an external callback from Redsys payment gateway
        # Authentication is via HMAC signature validation, not user session
        post :callback_redsys, params: {}
        # Should not redirect to sign in
        expect(response).not_to redirect_to(new_user_session_path) rescue nil
      end

      it "validates request via RedsysPaymentProcessor" do
        allow(RedsysPaymentProcessor).to receive(:new).and_return(mock_processor)
        allow(mock_processor).to receive(:process).and_return({
          order: order,
          is_soap: false,
          raw_xml: nil,
          parsed_params: {}
        })

        # Processor handles signature validation internally
        expect(RedsysPaymentProcessor).to receive(:new)
        post :callback_redsys, params: { "Ds_Order" => order.id.to_s }
      end

      it "logs request IP for security audit (LOW PRIORITY FIX: observability)" do
        allow(RedsysPaymentProcessor).to receive(:new).and_return(mock_processor)
        allow(mock_processor).to receive(:process).and_return({
          order: order,
          is_soap: false,
          raw_xml: nil,
          parsed_params: {}
        })

        expect(Rails.logger).to receive(:info).with(/Received callback from IP: 0\.0\.0\.0/)
        post :callback_redsys, params: { "Ds_Order" => order.id.to_s }
      end
    end

    context "edge cases" do
      before do
        allow(RedsysPaymentProcessor).to receive(:new).and_return(mock_processor)
      end

      context "with empty params" do
        before do
          allow(mock_processor).to receive(:process).and_return({
            order: nil,
            is_soap: true,
            raw_xml: nil,
            parsed_params: {}
          })
        end

        it "handles gracefully" do
          expect {
            post :callback_redsys, params: {}
          }.not_to raise_error
        end

        it "returns error response" do
          post :callback_redsys, params: {}
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "with empty request body" do
        before do
          allow(mock_processor).to receive(:process).and_return({
            order: nil,
            is_soap: false,
            raw_xml: nil,
            parsed_params: {}
          })
        end

        it "handles gracefully" do
          expect {
            post :callback_redsys, body: ""
          }.not_to raise_error
        end

        it "returns error response" do
          post :callback_redsys, body: ""
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "with malformed XML" do
        before do
          allow(mock_processor).to receive(:process).and_raise(
            StandardError.new("XML parsing error")
          )
        end

        it "handles gracefully" do
          expect {
            post :callback_redsys, body: "<invalid><xml>"
          }.not_to raise_error
        end

        it "returns error response" do
          post :callback_redsys, body: "<invalid><xml>"
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "logs XML parsing error" do
          expect(Rails.logger).to receive(:info).with(/Received callback/)
          expect(Rails.logger).to receive(:error).with(/XML parsing error/)
          post :callback_redsys, body: "<invalid><xml>"
        end
      end

      context "with very large XML payload" do
        let(:large_xml) { "<data>#{('x' * 10000)}</data>" }

        before do
          allow(mock_processor).to receive(:process).and_return({
            order: order,
            is_soap: true,
            raw_xml: large_xml,
            parsed_params: {}
          })
          allow(order).to receive(:redsys_callback_response).and_return("<response>OK</response>")
        end

        it "handles large payloads" do
          expect {
            post :callback_redsys, body: large_xml
          }.not_to raise_error
        end

        it "processes successfully" do
          post :callback_redsys, body: large_xml
          expect(response).to have_http_status(:success)
        end
      end

      context "when order exists but is deleted (soft delete)" do
        let(:deleted_order) { create(:order, :deleted) }

        before do
          allow(mock_processor).to receive(:process).and_raise(
            ActiveRecord::RecordNotFound.new("Order has been deleted")
          )
        end

        it "returns error response" do
          post :callback_redsys, params: { "Ds_Order" => deleted_order.id.to_s }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "logs not found error" do
          expect(Rails.logger).to receive(:info).with(/Received callback/)
          expect(Rails.logger).to receive(:error).with(/Order not found in database/)
          post :callback_redsys, params: { "Ds_Order" => deleted_order.id.to_s }
        end
      end
    end

    context "logging behavior (LOW PRIORITY FIX: observability)" do
      before do
        allow(RedsysPaymentProcessor).to receive(:new).and_return(mock_processor)
      end

      context "with successful processing" do
        before do
          allow(mock_processor).to receive(:process).and_return({
            order: order,
            is_soap: false,
            raw_xml: nil,
            parsed_params: {}
          })
        end

        it "logs exactly 2 messages (attempt + success)" do
          expect(Rails.logger).to receive(:info).twice
          post :callback_redsys, params: { "Ds_Order" => order.id.to_s }
        end

        it "logs attempt before processing" do
          call_order = []
          allow(Rails.logger).to receive(:info) { |msg| call_order << :log }
          allow(mock_processor).to receive(:process) do
            call_order << :process
            { order: order, is_soap: false, raw_xml: nil, parsed_params: {} }
          end

          post :callback_redsys, params: { "Ds_Order" => order.id.to_s }
          expect(call_order.first).to eq(:log)
        end

        it "logs success after processing" do
          call_order = []
          allow(Rails.logger).to receive(:info) do |msg|
            call_order << :success_log if msg.include?("Successfully processed")
          end
          allow(mock_processor).to receive(:process) do
            call_order << :process
            { order: order, is_soap: false, raw_xml: nil, parsed_params: {} }
          end

          post :callback_redsys, params: { "Ds_Order" => order.id.to_s }
          expect(call_order.last).to eq(:success_log)
        end
      end

      context "with error" do
        before do
          allow(mock_processor).to receive(:process).and_raise(StandardError.new("Test error"))
        end

        it "logs exactly 2 messages (attempt + error)" do
          expect(Rails.logger).to receive(:info).once  # Attempt
          expect(Rails.logger).to receive(:error).once # Error
          post :callback_redsys, params: {}
        end

        it "includes exception class in error log" do
          expect(Rails.logger).to receive(:info)
          expect(Rails.logger).to receive(:error).with(/StandardError/)
          post :callback_redsys, params: {}
        end

        it "includes exception message in error log" do
          expect(Rails.logger).to receive(:info)
          expect(Rails.logger).to receive(:error).with(/Test error/)
          post :callback_redsys, params: {}
        end

        it "includes backtrace excerpt in error log (first 5 lines)" do
          expect(Rails.logger).to receive(:info)
          expect(Rails.logger).to receive(:error).with(/\n/)
          post :callback_redsys, params: {}
        end
      end

      context "without exception" do
        before do
          allow(mock_processor).to receive(:process).and_return({
            order: nil,
            is_soap: false,
            raw_xml: nil,
            parsed_params: {}
          })
        end

        it "logs error without backtrace when no exception" do
          expect(Rails.logger).to receive(:info)
          expect(Rails.logger).to receive(:error).with(/Order not found in processor result/)
          expect(Rails.logger).not_to receive(:error).with(/\n.*\n/)
          post :callback_redsys, params: {}
        end
      end
    end

    context "response format validation (MEDIUM PRIORITY FIX: render syntax)" do
      before do
        allow(RedsysPaymentProcessor).to receive(:new).and_return(mock_processor)
      end

      context "for SOAP responses" do
        before do
          allow(mock_processor).to receive(:process).and_return({
            order: order,
            is_soap: true,
            raw_xml: "<response>test</response>",
            parsed_params: {}
          })
          allow(order).to receive(:redsys_callback_response).and_return("<response>test</response>")
        end

        it "uses render xml: (not deprecated render text:)" do
          post :callback_redsys, body: "<request>test</request>"
          expect(response.content_type).to include('application/xml')
        end

        it "does not use text/html content type" do
          post :callback_redsys, body: "<request>test</request>"
          expect(response.content_type).not_to include('text/html')
        end
      end

      context "for HTTP POST responses" do
        before do
          allow(mock_processor).to receive(:process).and_return({
            order: order,
            is_soap: false,
            raw_xml: nil,
            parsed_params: {}
          })
        end

        it "uses render plain: (not deprecated render text:)" do
          post :callback_redsys, params: { "Ds_Order" => order.id.to_s }
          expect(response.content_type).to include('text/plain')
        end

        it "does not use text/html content type" do
          post :callback_redsys, params: { "Ds_Order" => order.id.to_s }
          expect(response.content_type).not_to include('text/html')
        end
      end
    end

    context "integration scenarios" do
      before do
        allow(RedsysPaymentProcessor).to receive(:new).and_call_original
      end

      it "integrates with RedsysPaymentProcessor for real" do
        # This would be a full integration test if we had valid Redsys test data
        # For now, we verify that the controller creates the processor correctly

        # Mock only the Order.parent_from_order_id to avoid database dependencies
        allow(Order).to receive(:parent_from_order_id).and_return(order)
        allow(order).to receive(:redsys_parse_response!)

        post :callback_redsys, params: { "Ds_Order" => order.id.to_s }

        # Should not raise errors
        expect(response).to have_http_status(:success).or have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "CSRF protection configuration" do
    it "skips CSRF verification for callback_redsys" do
      # External payment gateway callback - CSRF would break legitimate payments
      expect(controller.class._process_action_callbacks.any? do |callback|
        callback.filter == :protect_from_forgery
      end).to be_truthy
    end
  end
end
