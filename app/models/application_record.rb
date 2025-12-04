# frozen_string_literal: true

# ApplicationRecord is the base class for all models in Rails 5+
# Per Rails upgrade guide: https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-2-to-rails-5-0
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Ransack 4.0+ Breaking Change Compatibility
  # Ransack 4.0 requires explicit allowlisting of searchable attributes and associations.
  # These methods restore the pre-4.0 behavior for backward compatibility.
  # See: https://activerecord-hackery.github.io/ransack/going-further/other-notes/#authorization-allowlistingdenylisting
  def self.ransackable_attributes(_auth_object = nil)
    @ransackable_attributes ||= column_names + _ransackers.keys + _ransack_aliases.keys
  end

  def self.ransackable_associations(_auth_object = nil)
    @ransackable_associations ||= reflect_on_all_associations.map { |a| a.name.to_s }
  end
end
