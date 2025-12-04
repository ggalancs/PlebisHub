# frozen_string_literal: true

module PlebisMicrocredit
  module ApplicationHelper
    # Include main app route helpers to make them available in engine views
    # This allows engine views to use routes defined in the main app like new_collaboration_path
    def method_missing(method, *, &)
      if method.to_s.end_with?('_path', '_url') && main_app.respond_to?(method)
        main_app.send(method, *, &)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      (method.to_s.end_with?('_path', '_url') && main_app.respond_to?(method)) || super
    end
  end
end
