require 'diff'

class MilitantRecord < ApplicationRecord
  include ActiveRecord::Diff
  diff exclude: [:created_at, :updated_at]
end
