# frozen_string_literal: true

module PlebisCollaborations
  # Service object to process Redsys payment gateway callbacks
  # Handles both SOAP/XML and standard HTTP POST callbacks
  # Extracts payment processing logic from OrdersController
  class RedsysPaymentProcessor
    def initialize(request_params, request_body = nil)
      @request_params = request_params
      @request_body = request_body
    end

    def process
      parsed_params = parse_callback
      order = find_and_create_order(parsed_params)

      {
        order: order,
        is_soap: is_soap_callback?,
        raw_xml: @raw_xml,
        parsed_params: parsed_params
      }
    end

    private

    def is_soap_callback?
      @request_params.blank? || @request_params['Ds_Order'].blank?
    end

    def parse_callback
      if is_soap_callback?
        parse_soap_callback
      else
        @request_params
      end
    end

    def parse_soap_callback
      body = Hash.from_xml(@request_body)
      @raw_xml = body['Envelope']['Body']['procesaNotificacionSIS']['XML']
      xml = Hash.from_xml(@raw_xml)

      request_params = xml['Message']['Request']
      request_params['Ds_Signature'] = xml['Message']['Signature']
      request_params.merge!(@request_params || {})

      request_params
    end

    def find_and_create_order(parsed_params)
      redsys_order_id = parsed_params['Ds_Order']
      parent = PlebisCollaborations::Order.parent_from_order_id(redsys_order_id)

      order = parent.create_order(Time.zone.now, true)

      order.redsys_parse_response!(parsed_params, @raw_xml) if order.first && order.is_payable?

      order
    end
  end
end
