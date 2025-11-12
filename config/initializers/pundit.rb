# frozen_string_literal: true

# ================================================================
# Pundit Configuration - PlebisHub 2.0
# ================================================================
# Configures Pundit for authorization
# ================================================================

# Include Pundit in controllers
ActiveSupport.on_load(:action_controller) do
  include Pundit::Authorization

  # Rescue from unauthorized access
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referer || root_path)
  end
end
