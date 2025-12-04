#!/usr/bin/env ruby
# frozen_string_literal: true

# Helper script to generate valid Spanish ID numbers and bank accounts

# NIF/NIE check letter calculation
LETTERS = 'TRWAGMYFPDXBNJZSQVHLCKE'
NIE_PREFIXES = { 'X' => 0, 'Y' => 1, 'Z' => 2 }

def nif_check_letter(number)
  LETTERS[number.to_i % 23]
end

def nie_check_letter(prefix, number)
  full_number = "#{NIE_PREFIXES[prefix]}#{number}".to_i
  LETTERS[full_number % 23]
end

def bank_ccc_check_digit(ary)
  key = [1, 2, 4, 8, 5, 10, 9, 7, 3, 6]
  sumatory = 0
  key.each_with_index { |number, index| sumatory += number * ary[index] }
  result = 11 - (sumatory % 11)
  result = 1 if result == 10
  result = 0 if result == 11
  result
end

def generate_valid_ccc(entity, office, account)
  entity_digits = entity.to_s.rjust(4, '0').chars.map(&:to_i)
  office_digits = office.to_s.rjust(4, '0').chars.map(&:to_i)
  account_digits = account.to_s.rjust(10, '0').chars.map(&:to_i)

  # First control digit: 00 + entity (4) + office (4)
  first_control = bank_ccc_check_digit([0, 0] + entity_digits + office_digits)

  # Second control digit: account (10)
  second_control = bank_ccc_check_digit(account_digits)

  "#{entity.to_s.rjust(4, '0')}#{office.to_s.rjust(4, '0')}#{first_control}#{second_control}#{account.to_s.rjust(10, '0')}"
end

puts "=== Valid NIFs ==="
[
  '00000000', '00000001', '00000002', '00000003', '00000004',
  '00000005', '00000006', '00000007', '00000008', '00000009',
  '00000010', '00000011', '00000012', '00000013', '00000014',
  '00000015', '00000016', '00000017', '00000018', '00000019',
  '00000020', '00000021', '00000022',
  '11111111', '22222222', '33333333', '44444444', '55555555',
  '66666666', '77777777', '88888888', '99999999', '12345678'
].each do |num|
  letter = nif_check_letter(num)
  puts "#{num}#{letter}"
end

puts "\n=== Valid NIEs (X prefix) ==="
['0000000', '1111111', '2222222', '3333333', '9999999', '1234567', '0000022'].each do |num|
  letter = nie_check_letter('X', num)
  puts "X#{num}#{letter}"
end

puts "\n=== Valid NIEs (Y prefix) ==="
['0000000', '1111111', '2222222', '3333333', '1234567'].each do |num|
  letter = nie_check_letter('Y', num)
  puts "Y#{num}#{letter}"
end

puts "\n=== Valid NIEs (Z prefix) ==="
['0000000', '1111111', '2222222', '3333333', '1234567'].each do |num|
  letter = nie_check_letter('Z', num)
  puts "Z#{num}#{letter}"
end

puts "\n=== Valid Bank CCCs ==="
# Test the known examples from the spec
puts "Example 1: #{generate_valid_ccc(2100, 418, 200051332)}"
puts "Example 2: #{generate_valid_ccc(182, 1666, 201503283)}"

# Generate some more examples
puts "All zeros: #{generate_valid_ccc(0, 0, 0)}"
puts "Entity 9999: #{generate_valid_ccc(9999, 418, 200051332)}"
puts "Office 9999: #{generate_valid_ccc(2100, 9999, 200051332)}"
puts "Account 9999999999: #{generate_valid_ccc(2100, 418, 9999999999)}"
