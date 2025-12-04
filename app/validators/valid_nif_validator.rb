# frozen_string_literal: true

# ValidNifValidator - Spanish DNI validation
# DNI format: 8 digits + 1 checksum letter
# Example: 12345678Z
# This overrides the gem's validator to allow blank values
module ActiveModel
  module Validations
    class ValidNifValidator < ActiveModel::EachValidator
      LETTERS = 'TRWAGMYFPDXBNJZSQVHLCKE'

      def validate_each(record, attribute, value)
        return if value.blank?

        value_clean = value.to_s.upcase.strip

        unless value_clean.match?(/^\d{8}[A-Z]$/)
          record.errors.add(attribute, error_message)
          return
        end

        number = value_clean[0..7].to_i
        letter = value_clean[8]
        expected_letter = LETTERS[number % 23]

        return unless letter != expected_letter

        record.errors.add(attribute, error_message)
      end

      private

      def error_message
        I18n.translate('errors.messages.not_valid_nif', default: 'is invalid')
      end
    end
  end
end

# Alias for Zeitwerk autoloading (expects ValidNifValidator at root)
ValidNifValidator = ActiveModel::Validations::ValidNifValidator
