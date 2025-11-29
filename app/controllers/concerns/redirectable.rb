module Redirectable
  extend ActiveSupport::Concern
  included do
    # Rails 7.1+ raises errors if :only actions don't exist in the controller
    # Removed :only restriction since storable_location? already guards GET requests
    before_action :store_user_location!, if: :storable_location?
    def after_update_path_for(resource)
      session.delete(:return_to) || super
    end

    def storable_location?
      request.get? && is_navigational_format?  && !request.xhr?
    end

    def store_user_location!
      session[:return_to] ||= request.referer
    end
  end
end