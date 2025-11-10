# frozen_string_literal: true

module PlebisMicrocredit
  class MicrocreditOption < ApplicationRecord
    self.table_name = 'microcredit_options'

    belongs_to :microcredit, class_name: "PlebisMicrocredit::Microcredit"
    belongs_to :parent, class_name: "PlebisMicrocredit::MicrocreditOption", optional: true
    has_many :children, foreign_key: :parent_id, class_name: "PlebisMicrocredit::MicrocreditOption", inverse_of: :parent, dependent: :destroy
    validates :name, presence: true

    scope :root_parents, -> {where(parent_id: nil)}
    scope :without_children, -> { includes(:children).where("children_microcredit_options"=>{id:nil})}
  end
end
