# frozen_string_literal: true

require 'plebisbrand_export'

namespace :plebisbrand do
  desc '[plebisbrand] Fill data of users in a file'
  task :fill_data_file, [:input_file] => :environment do |_t, args|
    args.with_defaults(input_file: nil)

    fill_data args.input_file, User.confirmed
  end
end
