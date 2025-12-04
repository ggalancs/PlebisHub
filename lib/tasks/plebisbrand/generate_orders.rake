# frozen_string_literal: true

namespace :plebisbrand do
  desc '[plebisbrand] Generate orders for collaborations for a specific month'
  task :generate_orders, %i[month year] => :environment do |_t, args|
    args.with_defaults(month: Time.zone.today.month, year: Time.zone.today.year)
    date = DateTime.new(args.year.to_i, args.month.to_i, Rails.application.secrets.orders['creation_day'].to_i)
    Collaboration.find_each do |collaboration|
      collaboration.generate_order date
    end
  end
end

# colaboraciones mensuales/trimestrales/anuales
# - traerse ultima orden
# - generar nueva, si corresponde
