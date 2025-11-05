require 'reddit'

namespace :plebisbrand do
  desc "[plebisbrand] Extract best proposals from Reddit - Plaza PlebisBrand"
  task :reddit => :environment do
    plaza_plebisbrand = Reddit.new("PlebisBrand")
    plaza_plebisbrand.extract
  end
end