class OrdersController < ApplicationController
  protect_from_forgery except: :callback_redsys

  def callback_redsys
    processor = RedsysPaymentProcessor.new(params, request.body.read)
    result = processor.process

    order = result[:order]

    if result[:is_soap]
      render text: order.redsys_callback_response, content_type: "text/xml"
    else
      render text: order.is_paid? ? "OK" : "KO"
    end
  end
end