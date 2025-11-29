# frozen_string_literal: true

# Minimal Organization model to support brand_setting multi-tenancy
# This is a placeholder for future multi-tenancy features
class Organization < ApplicationRecord
  # Associations
  has_many :brand_settings, dependent: :nullify

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
end
