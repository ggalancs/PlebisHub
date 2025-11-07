# frozen_string_literal: true

# Payment gateway callback endpoint for Redsys (Spanish payment processor)
# Handles both SOAP/XML and HTTP POST callback formats
class OrdersController < ApplicationController
  # CSRF exemption is correct: external callback authenticated via HMAC signature
  protect_from_forgery except: :callback_redsys

  def callback_redsys
    # LOW PRIORITY FIX: Added observability logging
    log_callback_attempt

    # MEDIUM-HIGH PRIORITY FIX: Added comprehensive error handling
    begin
      processor = RedsysPaymentProcessor.new(params, request.body.read)
      result = processor.process
      order = result[:order]

      # MEDIUM PRIORITY FIX: Added nil check for order
      unless order
        log_callback_error("Order not found in processor result")
        render_error_response(result[:is_soap])
        return
      end

      # MEDIUM PRIORITY FIX: Replaced deprecated render text: with modern syntax
      if result[:is_soap]
        render xml: order.redsys_callback_response
      else
        render plain: order.is_paid? ? "OK" : "KO"
      end

      log_callback_success(order)
    rescue ActiveRecord::RecordNotFound => e
      # Order ID was parsed but order doesn't exist in database
      log_callback_error("Order not found in database", e)
      render_error_response(false)
    rescue StandardError => e
      # Catch-all for XML parsing errors, signature validation failures, etc.
      log_callback_error("Unexpected error processing callback", e)
      render_error_response(false)
    end
  end

  private

  # LOW PRIORITY FIX: Added structured logging methods
  def log_callback_attempt
    Rails.logger.info("[Redsys Callback] Received callback from IP: #{request.remote_ip}")
  end

  def log_callback_success(order)
    Rails.logger.info(
      "[Redsys Callback] Successfully processed order #{order.id} - " \
      "Status: #{order.status}, Paid: #{order.is_paid?}"
    )
  end

  def log_callback_error(message, exception = nil)
    if exception
      Rails.logger.error(
        "[Redsys Callback] #{message} - #{exception.class}: #{exception.message}\n" \
        "#{exception.backtrace.first(5).join("\n")}"
      )
    else
      Rails.logger.error("[Redsys Callback] #{message}")
    end
  end

  # MEDIUM-HIGH PRIORITY FIX: Added error response method
  def render_error_response(is_soap)
    if is_soap
      # SOAP error response format
      render xml: "<error>Payment processing failed</error>", status: :unprocessable_entity
    else
      # HTTP POST error response
      render plain: "KO", status: :unprocessable_entity
    end
  end
end
