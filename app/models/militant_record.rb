# frozen_string_literal: true

require 'diff'

class MilitantRecord < ApplicationRecord
  include ActiveRecord::Diff

  diff exclude: %i[created_at updated_at]

  belongs_to :user
end
