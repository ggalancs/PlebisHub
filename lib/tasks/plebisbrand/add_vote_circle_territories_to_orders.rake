# frozen_string_literal: true

namespace :plebisbrand do
  desc '[plebisbrand] Assign vote_circle territories to orders from a specific month and year'
  task :add_vote_circle_territories_to_orders, %i[month year] => :environment do |_t, args|
    args.with_defaults(month: Time.zone.today.month, year: Time.zone.today.year)
    min_date = Date.civil(args.year.to_i, args.month.to_i, 1)
    max_date = Time.zone.today
    os = Order.where('created_at between ? and ?', min_date, max_date).order(created_at: 'ASC')
    os.each do |o|
      next unless o.user_id

      u = User.with_deleted.find(o.user_id)
      u.version_at(o.created_at)
      if u.vote_circle_id.present?
        circle = u.vote_circle
        if circle.town.present?
          town_code = circle.town
          autonomy_code = circle.autonomy_code
          island = PlebisBrand::GeoExtra::ISLANDS[circle.town]
          island_code = circle.island_code
          island_code = island.present? ? island[0] : o.island_code if island_code.blank?
        else
          town_code = o.town_code
          if circle.in_spain?
            autonomy_code = circle.autonomy_code
            island_code = circle.island_code
            island_code = o.island_code if island_code.blank?
          else
            autonomy_code = o.autonomy_code
            island_code = o.island_code
          end
        end
        circle_code = circle.code =~ /\AIP/ ? nil : circle.id
      else
        town_code = o.town_code
        autonomy_code = o.autonomy_code
        island_code = o.island_code
        circle_code = nil
      end
      o.vote_circle_id = circle_code
      o.vote_circle_town_code = town_code if o.town_code.present?
      o.vote_circle_autonomy_code = autonomy_code if o.autonomy_code.present?
      o.vote_circle_island_code = island_code if o.island_code.present?
      o.save!
    end
  end
end
