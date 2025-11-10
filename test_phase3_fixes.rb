#!/usr/bin/env ruby
# frozen_string_literal: true

# Phase 3 Fixes Validation Script
# This script verifies all fixes applied to Phase 3 engines

puts "=" * 80
puts "PHASE 3 ENGINES - FIXES VALIDATION"
puts "=" * 80
puts

def check(description, &block)
  print "#{description}... "
  result = block.call
  if result[:success]
    puts "✅ PASS"
    puts "   #{result[:message]}" if result[:message]
  else
    puts "❌ FAIL"
    puts "   #{result[:message]}"
    @failures ||= []
    @failures << description
  end
  puts
  result[:success]
end

@failures = []

# CRITICAL-1: PlebisBrand alias
check("CRITICAL-1: PlebisBrand constant is defined") do
  if defined?(PlebisBrand)
    { success: true, message: "PlebisBrand constant exists" }
  else
    { success: false, message: "PlebisBrand constant not found" }
  end
end

check("CRITICAL-1: PlebisBrand equals Podemos") do
  if defined?(PlebisBrand) && defined?(Podemos) && PlebisBrand == Podemos
    { success: true, message: "PlebisBrand correctly aliased to Podemos" }
  else
    { success: false, message: "PlebisBrand is not correctly aliased" }
  end
end

check("CRITICAL-1: PlebisBrand::GeoExtra is accessible") do
  if defined?(PlebisBrand::GeoExtra)
    { success: true, message: "PlebisBrand::GeoExtra module accessible" }
  else
    { success: false, message: "PlebisBrand::GeoExtra not accessible" }
  end
end

check("CRITICAL-1: PlebisBrand::GeoExtra::ISLANDS exists") do
  if defined?(PlebisBrand::GeoExtra::ISLANDS) && PlebisBrand::GeoExtra::ISLANDS.is_a?(Hash)
    { success: true, message: "ISLANDS constant is a Hash with #{PlebisBrand::GeoExtra::ISLANDS.size} entries" }
  else
    { success: false, message: "ISLANDS constant not accessible" }
  end
end

check("CRITICAL-1: PlebisBrand::GeoExtra::AUTONOMIES exists") do
  if defined?(PlebisBrand::GeoExtra::AUTONOMIES) && PlebisBrand::GeoExtra::AUTONOMIES.is_a?(Hash)
    { success: true, message: "AUTONOMIES constant is a Hash with #{PlebisBrand::GeoExtra::AUTONOMIES.size} entries" }
  else
    { success: false, message: "AUTONOMIES constant not accessible" }
  end
end

# CRITICAL-2: CensusFileParser namespace
check("CRITICAL-2: CensusFileParser is in global namespace") do
  if defined?(::CensusFileParser)
    { success: true, message: "::CensusFileParser accessible" }
  else
    { success: false, message: "::CensusFileParser not found" }
  end
end

check("CRITICAL-2: VoteController references ::CensusFileParser") do
  source = File.read('engines/plebis_votes/app/controllers/plebis_votes/vote_controller.rb')
  if source.include?('::CensusFileParser.new')
    { success: true, message: "Found ::CensusFileParser.new in VoteController" }
  else
    { success: false, message: "::CensusFileParser.new not found in VoteController" }
  end
end

# HIGH-1: ElectionLocation namespace
check("HIGH-1: Election uses PlebisVotes::ElectionLocation") do
  source = File.read('engines/plebis_votes/app/models/plebis_votes/election.rb')
  if source.include?('PlebisVotes::ElectionLocation.transaction')
    { success: true, message: "Found PlebisVotes::ElectionLocation.transaction" }
  else
    { success: false, message: "PlebisVotes::ElectionLocation.transaction not found" }
  end
end

# HIGH-2-4: User namespace
check("HIGH-2-4: Election uses ::User references") do
  source = File.read('engines/plebis_votes/app/models/plebis_votes/election.rb')
  count_confirmed = source.scan(/::User\.confirmed\.not_banned/).size
  count_with_deleted = source.scan(/::User\.with_deleted\.not_banned/).size

  if count_confirmed >= 2 && count_with_deleted >= 2
    { success: true, message: "Found #{count_confirmed} ::User.confirmed and #{count_with_deleted} ::User.with_deleted references" }
  else
    { success: false, message: "Missing ::User references (found #{count_confirmed} confirmed, #{count_with_deleted} with_deleted)" }
  end
end

# HIGH-5: VoteCircle namespace
check("HIGH-5: ElectionLocation uses PlebisVotes::VoteCircle") do
  source = File.read('engines/plebis_votes/app/models/plebis_votes/election_location.rb')
  if source.include?('PlebisVotes::VoteCircle.where')
    { success: true, message: "Found PlebisVotes::VoteCircle.where" }
  else
    { success: false, message: "PlebisVotes::VoteCircle.where not found" }
  end
end

# HIGH-6: ElectionLocation namespace in ElectionLocationQuestion
check("HIGH-6: ElectionLocationQuestion uses PlebisVotes::ElectionLocation") do
  source = File.read('engines/plebis_votes/app/models/plebis_votes/election_location_question.rb')
  if source.include?('PlebisVotes::ElectionLocation::ELECTION_LAYOUTS')
    { success: true, message: "Found PlebisVotes::ElectionLocation::ELECTION_LAYOUTS" }
  else
    { success: false, message: "PlebisVotes::ElectionLocation::ELECTION_LAYOUTS not found" }
  end
end

# MEDIUM-1: Vote model callback
check("MEDIUM-1: Vote uses assignment instead of update_attribute") do
  source = File.read('engines/plebis_votes/app/models/plebis_votes/vote.rb')
  has_update_attribute = source.include?('update_attribute(:agora_id') || source.include?('update_attribute(:voter_id')
  has_assignment = source.include?('self.agora_id =') && source.include?('self.voter_id =')

  if !has_update_attribute && has_assignment
    { success: true, message: "Uses assignment (self.agora_id = / self.voter_id =)" }
  else
    { success: false, message: "Still uses update_attribute or missing assignment" }
  end
end

# MEDIUM-2: :orders association
check("MEDIUM-2: Collaboration uses plural :orders association") do
  source = File.read('engines/plebis_collaborations/app/models/plebis_collaborations/collaboration.rb')
  has_orders = source.match?(/has_many :orders[^a-z_]/)
  has_singular_order = source.match?(/has_many :order[^s]/)

  if has_orders && !has_singular_order
    { success: true, message: "Found has_many :orders (plural)" }
  else
    { success: false, message: "Association not correctly named" }
  end
end

check("MEDIUM-2: Collaboration references use .orders.") do
  model_source = File.read('engines/plebis_collaborations/app/models/plebis_collaborations/collaboration.rb')
  mailer_source = File.read('engines/plebis_collaborations/app/mailers/plebis_collaborations/collaborations_mailer.rb')
  admin_source = File.read('engines/plebis_collaborations/app/admin/collaboration.rb')

  # Check for .order. (singular) - should not exist
  has_singular_model = model_source.include?('self.order.')
  has_singular_mailer = mailer_source.include?('collaboration.order.')
  has_singular_admin = admin_source.include?('collaboration.order.')

  # Check for .orders. (plural) - should exist
  has_plural_model = model_source.include?('self.orders.')
  has_plural_mailer = mailer_source.include?('collaboration.orders.')
  has_plural_admin = admin_source.include?('collaboration.orders.')

  if !has_singular_model && !has_singular_mailer && !has_singular_admin &&
     has_plural_model && has_plural_mailer && has_plural_admin
    { success: true, message: "All references use .orders. (plural)" }
  else
    { success: false, message: "Some references still use .order. (singular)" }
  end
end

# MEDIUM-3: require_relative
check("MEDIUM-3: ActiveAdmin uses require_relative") do
  source = File.read('engines/plebis_collaborations/app/admin/collaboration.rb')
  has_require_relative = source.include?("require_relative '../../../lib/collaborations_on_paper'")
  has_bare_require = source.include?("require 'collaborations_on_paper'")

  if has_require_relative && !has_bare_require
    { success: true, message: "Uses require_relative" }
  else
    { success: false, message: "Still uses bare require or missing require_relative" }
  end
end

# LOW-1: Menu label
check("LOW-1: ActiveAdmin menu label is correct") do
  source = File.read('engines/plebis_votes/app/admin/election.rb')
  has_correct = source.include?('menu :parent => "Votación"')
  has_typo = source.include?('PlebisHubción')

  if has_correct && !has_typo
    { success: true, message: 'Menu parent is "Votación"' }
  else
    { success: false, message: "Menu label not corrected" }
  end
end

puts "=" * 80
puts "SUMMARY"
puts "=" * 80
puts

if @failures.empty?
  puts "✅ ALL TESTS PASSED! (#{@failures.size} failures)"
  puts
  puts "Phase 3 engines are ready for deployment! 🎉"
  exit 0
else
  puts "❌ #{@failures.size} TEST(S) FAILED:"
  @failures.each do |failure|
    puts "   - #{failure}"
  end
  puts
  puts "Please review and fix the failing tests."
  exit 1
end
