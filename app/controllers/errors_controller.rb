class ErrorsController < ApplicationController

  def show
    @code = (params[:code] || 500).to_s
    render status: http_status_code
  end

  private

  def http_status_code
    # Convert numeric codes to integers, otherwise use as symbol
    # This allows both numeric (404, 500) and symbolic (:not_found) status codes
    @code.match?(/^\d+$/) ? @code.to_i : @code.to_sym
  end
end
