# frozen_string_literal: true

# ApplicationRecord is the base class for all models in Rails 5+
# Per Rails upgrade guide: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
