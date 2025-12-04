# frozen_string_literal: true

require 'csv'

namespace :plebisbrand do
  desc '[plebisbrand] Fill data of vote_circles in a file'
  task create_vote_circles_from_file: :environment do
    path = Rails.root.join('db/plebisbrand/circulos.tsv')

    CSV.foreach(path, headers: true, col_sep: "\t", encoding: 'UTF-8') do |row|
      VoteCircle.create(row.to_hash)
    end
  end
end
