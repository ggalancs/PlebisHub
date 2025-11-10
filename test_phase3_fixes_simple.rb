#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

# Phase 3 Fixes Validation Script (Source Code Analysis)
# This script verifies all fixes by analyzing source code

puts "=" * 80
puts "PHASE 3 ENGINES - FIXES VALIDATION (Source Code Analysis)"
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

# CRITICAL-1: PlebisBrand alias file exists
check("CRITICAL-1: PlebisBrand alias initializer exists") do
  if File.exist?('config/initializers/plebis_brand_alias.rb')
    content = File.read('config/initializers/plebis_brand_alias.rb')
    if content.include?('PlebisBrand = Podemos')
      { success: true, message: "Alias file exists with correct content" }
    else
      { success: false, message: "Alias file exists but content is incorrect" }
    end
  else
    { success: false, message: "Alias file not found" }
  end
end

# CRITICAL-2: CensusFileParser namespace
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
  count = 0
  count += 1 if source.include?('base = ::User.confirmed.not_banned')
  count += 1 if source.include?('base = ::User.with_deleted.not_banned')

  if count >= 2
    { success: true, message: "Found #{count} ::User references in Election model" }
  else
    { success: false, message: "Missing ::User references (found #{count}, expected 2+)" }
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
  # Look for has_many :orders (not followed by a letter/underscore)
  has_orders = source =~ /has_many :orders[^a-zA-Z_]/
  # Make sure has_many :order (singular, not followed by 's') doesn't exist
  has_singular_order = source =~ /has_many :order[^s]/

  if has_orders && !has_singular_order
    { success: true, message: "Found has_many :orders (plural)" }
  else
    { success: false, message: "Association not correctly named (has_orders: #{!!has_orders}, has_singular: #{!!has_singular_order})" }
  end
end

check("MEDIUM-2: All .order. references changed to .orders.") do
  model_source = File.read('engines/plebis_collaborations/app/models/plebis_collaborations/collaboration.rb')
  mailer_source = File.read('engines/plebis_collaborations/app/mailers/plebis_collaborations/collaborations_mailer.rb')
  admin_source = File.read('engines/plebis_collaborations/app/admin/collaboration.rb')

  # Check for .order. (singular) association access - should not exist
  has_singular_model = model_source.include?('.order.sort') || model_source.include?('.order.where') ||
                       model_source.include?('.order.select') || model_source.include?('.order.pluck')
  has_singular_mailer = mailer_source.include?('.order.returned')
  has_singular_admin = admin_source.include?('.order.sort')

  # Check for .orders. (plural) - should exist
  has_plural_model = model_source.include?('.orders.sort') || model_source.include?('.orders.where') ||
                     model_source.include?('.orders.select') || model_source.include?('.orders.pluck')
  has_plural_mailer = mailer_source.include?('.orders.returned')
  has_plural_admin = admin_source.include?('.orders.sort')

  if !has_singular_model && !has_singular_mailer && !has_singular_admin &&
     has_plural_model && has_plural_mailer && has_plural_admin
    { success: true, message: "All references use .orders. (plural)" }
  else
    details = "Model sing:#{has_singular_model} plur:#{has_plural_model}, " \
              "Mailer sing:#{has_singular_mailer} plur:#{has_plural_mailer}, " \
              "Admin sing:#{has_singular_admin} plur:#{has_plural_admin}"
    { success: false, message: "Some references incorrect - #{details}" }
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
  has_correct = source.include?('menu :parent => "Votación"') || source.include?('menu :parent => "Votación"')
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

total_tests = 11
passed_tests = total_tests - @failures.size

puts "Passed: #{passed_tests}/#{total_tests}"
puts

if @failures.empty?
  puts "✅ ALL TESTS PASSED!"
  puts
  puts "Phase 3 engines are ready for deployment! 🎉"
  puts
  puts "All 11 issues have been fixed:"
  puts "  - 2 CRITICAL fixes ✅"
  puts "  - 5 HIGH priority fixes ✅"
  puts "  - 3 MEDIUM priority fixes ✅"
  puts "  - 1 LOW priority fix ✅"
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
