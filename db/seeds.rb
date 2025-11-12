def assign_vote_circle_territories
  internal_type = 0
  neighborhood_type = 1
  town_type = 2
  region_type = 3
  exterior_type = 4

  spain_types = [["TB%",neighborhood_type],["TM%",town_type],["TC%",region_type]]
  internal = ["IP%", internal_type]
  known_types  = ["TB%", "TM%", "TC%", "IP%"]
  spain_code ="ES"

  internal_circles = VoteCircle.all.where("code like ?",internal[0]) #.where(country_code:nil, autonomy_code: nil,province_code: nil)
  internal_circles.find_each do |vc|
    vc.kind = internal[1]
    vc.town = nil
    vc.province_code = nil
    vc.autonomy_code = nil
    vc.island_code = nil
    vc.country_code = nil
    vc.save!
  end

  spain_types.each do |type,type_code|
    VoteCircle.all.where("code like ?",type).where(country_code:nil, autonomy_code: nil,province_code: nil).find_each do |vc|
      vc.kind = type_code
      if vc.town.present?
        town_code = vc.town
        province_code = "p_#{vc.town[2,2]}"
        autonomy_code = PlebisBrand::GeoExtra::AUTONOMIES[province_code][0]
        island = PlebisBrand::GeoExtra::ISLANDS[vc.town]
        island_code = vc.island_code
        island_code = island.present? ? island[0] : nil unless island_code.present?
        country_code = spain_code
      else
        if vc.code_in_spain?
          town_code = nil
          autonomy_code = "c_#{vc.code[2,2]}"
          province_code = "p_#{vc.code[4,2]}"
          island_code = vc.island_code
          country_code = spain_code
        else
          town_code = nil
          province_code = nil
          autonomy_code = nil
          island_code = nil
          country_code = vc.code[0,2].upcase
        end
      end
      vc.town = town_code
      vc.province_code = province_code
      vc.autonomy_code = autonomy_code
      vc.island_code = island_code
      vc.country_code = country_code
      vc.save!
    end
  end

  exterior_circles = VoteCircle.all.where("code not like all(array[?])",known_types).where(country_code:nil, autonomy_code: nil,province_code: nil)
  exterior_circles.find_each do |vc|
    vc.kind = exterior_type
    vc.town = nil
    vc.province_code = nil
    vc.autonomy_code = nil
    vc.island_code = nil
    vc.country_code = vc.code[0,2].upcase
    vc.save!
  end
end

assign_vote_circle_territories

Order.where("payed_at > ?",Date.parse("2020-09-30")).find_each do |order|
  circle = VoteCircle.find(order.vote_circle_id) if order.vote_circle_id.present?
  if circle.present? && circle.comarcal?
    autonomy_code = circle.autonomy_code
    order.town_code = nil
    order.island_code = nil
    order.autonomy_code = autonomy_code
    order.vote_circle_town_code = nil
    order.vote_circle_island_code = nil
    order.vote_circle_autonomy_code = autonomy_code
  end
  order.save!
end

 Order.where("payed_at > ?",Date.parse("2020-09-30")).find_each do |order| #.where(target_territory:nil).find_each do |order|
   order.target_territory = order.generate_target_territory
   order.save!
 end

# Seed EngineActivations
# Creates disabled activation records for all available engines
puts "\n" + "="*80
puts "Seeding EngineActivations..."
puts "="*80

begin
  EngineActivation.seed_all

  # Enable ALL engines by default
  # IMPORTANT: User model has concerns that depend on all engines being active
  # Until dependencies are refactored, all engines must be enabled
  all_engines = PlebisCore::EngineRegistry.available_engines

  all_engines.each do |engine|
    activation = EngineActivation.find_by(engine_name: engine)
    if activation && !activation.enabled?
      activation.update!(enabled: true)
      puts "  ✓ #{engine} enabled"
    end
  end

  puts "\nEngineActivations seeded: #{EngineActivation.count} total"
  puts "  - All engines enabled by default (required by User model)"
  puts "  - To disable engines, see doc/PHASE_0_FIX_ACTION_PLAN.md"
  puts "="*80
rescue => e
  puts "  ⚠ Warning: Could not seed EngineActivations: #{e.message}"
  puts "  This is expected if migrations haven't been run yet."
  puts "="*80
end

# Seed BrandSettings
# Creates default brand settings with all predefined themes
puts "\n" + "="*80
puts "Seeding BrandSettings..."
puts "="*80

begin
  # Only seed if table exists and is empty
  if ActiveRecord::Base.connection.table_exists?('brand_settings')
    if BrandSetting.count.zero?
      # Create global default brand setting (active)
      default_setting = BrandSetting.create!(
        name: 'PlebisHub Default Theme',
        description: 'Official PlebisHub brand colors - active by default',
        scope: 'global',
        theme_id: 'default',
        active: true,
        metadata: {
          created_by: 'seed',
          notes: 'Default brand theme for the platform'
        }
      )
      puts "  ✓ Created default brand setting (active)"

      # Create example brand settings for each predefined theme (inactive)
      example_themes = [
        {
          name: 'Ocean Blue Theme',
          description: 'Cool blue tones for a professional look',
          theme_id: 'ocean',
          active: false
        },
        {
          name: 'Forest Green Theme',
          description: 'Natural green palette for environmental campaigns',
          theme_id: 'forest',
          active: false
        },
        {
          name: 'Sunset Orange Theme',
          description: 'Warm orange and red tones for energy and passion',
          theme_id: 'sunset',
          active: false
        },
        {
          name: 'Monochrome Theme',
          description: 'Classic black and white for formal events',
          theme_id: 'monochrome',
          active: false
        }
      ]

      example_themes.each do |theme_attrs|
        BrandSetting.create!(
          name: theme_attrs[:name],
          description: theme_attrs[:description],
          scope: 'global',
          theme_id: theme_attrs[:theme_id],
          active: theme_attrs[:active],
          metadata: {
            created_by: 'seed',
            notes: 'Example theme for demonstration'
          }
        )
        puts "  ✓ Created #{theme_attrs[:name]} (inactive)"
      end

      # Create an example with custom colors
      custom_setting = BrandSetting.create!(
        name: 'Custom Purple & Gold',
        description: 'Example of custom color overrides',
        scope: 'global',
        theme_id: 'default',
        primary_color: '#6B46C1',
        primary_light_color: '#9F7AEA',
        primary_dark_color: '#553C9A',
        secondary_color: '#D69E2E',
        secondary_light_color: '#ECC94B',
        secondary_dark_color: '#B7791F',
        active: false,
        metadata: {
          created_by: 'seed',
          notes: 'Example showing custom color overrides'
        }
      )
      puts "  ✓ Created custom color example (inactive)"

      puts "\nBrandSettings seeded: #{BrandSetting.count} total"
      puts "  - 1 active global theme (default)"
      puts "  - #{BrandSetting.inactive.count} inactive example themes"
      puts "  - Access at /admin/brand_settings to manage themes"
    else
      puts "  ⚠ BrandSettings already exist (#{BrandSetting.count} found), skipping seed"
    end
  else
    puts "  ⚠ brand_settings table doesn't exist yet"
    puts "  Run migrations first: rails db:migrate"
  end
  puts "="*80
rescue => e
  puts "  ⚠ Warning: Could not seed BrandSettings: #{e.message}"
  puts "  This is expected if migrations haven't been run yet."
  puts "="*80
end
