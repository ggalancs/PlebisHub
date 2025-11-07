# frozen_string_literal: true

# ValidNieValidator - Spanish NIE (Foreigner ID) validation
# NIE format: X/Y/Z + 7 digits + 1 checksum letter
# Example: X1234567L
class ValidNieValidator < ActiveModel::EachValidator
  LETTERS = 'TRWAGMYFPDXBNJZSQVHLCKE'
  NIE_PREFIXES = { 'X' => 0, 'Y' => 1, 'Z' => 2 }

  def validate_each(record, attribute, value)
    return if value.blank?

    value_clean = value.to_s.upcase.strip

    unless value_clean.match?(/^[XYZ]\d{7}[A-Z]$/)
      record.errors.add(attribute, 'is invalid')
      return
    end

    prefix = value_clean[0]
    number = "#{NIE_PREFIXES[prefix]}#{value_clean[1..7]}".to_i
    letter = value_clean[8]
    expected_letter = LETTERS[number % 23]

    if letter != expected_letter
      record.errors.add(attribute, 'is invalid')
    end
  end
end
