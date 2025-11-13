# frozen_string_literal: true

class GraphqlController < ApplicationController
  # Disable CSRF protection for GraphQL API
  skip_before_action :verify_authenticity_token

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user: current_user,
      request: request,
      session: session
    }

    result = PlebishubSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )

    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development(e)
  end

  private

  def current_user
    # Implement authentication logic here
    # For example, using JWT tokens or session-based auth
    return nil unless request.headers['Authorization'].present?

    # Example JWT auth (customize based on your auth system)
    token = request.headers['Authorization'].split(' ').last
    decode_auth_token(token)
  rescue StandardError
    nil
  end

  def decode_auth_token(token)
    # Implement your token decoding logic here
    # Example:
    # payload = JWT.decode(token, Rails.application.secrets.secret_key_base).first
    # User.find(payload['user_id'])
    nil
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(error)
    logger.error error.message
    logger.error error.backtrace.join("\n")

    render json: {
      errors: [
        {
          message: error.message,
          backtrace: error.backtrace
        }
      ],
      data: {}
    }, status: 500
  end
end
