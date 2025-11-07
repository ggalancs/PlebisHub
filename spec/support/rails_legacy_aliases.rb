# frozen_string_literal: true

# Add legacy Rails aliases for backward compatibility with older controller code
# These were deprecated in Rails 5.0 and removed in later versions
# We keep them for testing to avoid modifying legacy controller code

if defined?(ActionController::Base)
  ActionController::Base.class_eval do
    class << self
      alias_method :before_filter, :before_action unless method_defined?(:before_filter)
      alias_method :after_filter, :after_action unless method_defined?(:after_filter)
      alias_method :around_filter, :around_action unless method_defined?(:around_filter)
      alias_method :skip_before_filter, :skip_before_action unless method_defined?(:skip_before_filter)
      alias_method :skip_after_filter, :skip_after_action unless method_defined?(:skip_after_filter)
      alias_method :skip_around_filter, :skip_around_action unless method_defined?(:skip_around_filter)
    end
  end
end
