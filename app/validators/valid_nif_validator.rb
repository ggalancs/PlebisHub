# frozen_string_literal: true

# ValidNifValidator - Spanish DNI validation
# DNI format: 8 digits + 1 checksum letter
# Example: 12345678Z
class ValidNifValidator < ActiveModel::EachValidator
  LETTERS = 'TRWAGMYFPDXBNJZSQVHLCKE'

  def validate_each(record, attribute, value)
    return if value.blank?

    value_clean = value.to_s.upcase.strip

    unless value_clean.match?(/^\d{8}[A-Z]$/)
      record.errors.add(attribute, 'is invalid')
      return
    end

    number = value_clean[0..7].to_i
    letter = value_clean[8]
    expected_letter = LETTERS[number % 23]

    if letter != expected_letter
      record.errors.add(attribute, 'is invalid')
    end
  end
end
