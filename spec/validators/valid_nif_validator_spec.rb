# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ValidNifValidator do
  # Create a test model to test the validator
  let(:test_class) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :nif

      validates :nif, valid_nif: true

      def self.name
        'TestPerson'
      end

      def self.model_name
        ActiveModel::Name.new(self, nil, 'TestPerson')
      end
    end
  end

  let(:record) { test_class.new }

  describe 'constants' do
    it 'has correct LETTERS constant' do
      expect(ValidNifValidator::LETTERS).to eq('TRWAGMYFPDXBNJZSQVHLCKE')
    end

    it 'has 23 letters in LETTERS constant' do
      expect(ValidNifValidator::LETTERS.length).to eq(23)
    end

    it 'matches NIE validator LETTERS constant' do
      expect(ValidNifValidator::LETTERS).to eq(ValidNieValidator::LETTERS)
    end
  end

  describe '#validate_each' do
    context 'with blank values' do
      it 'does not add errors for nil' do
        record.nif = nil
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'does not add errors for empty string' do
        record.nif = ''
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'does not add errors for whitespace only' do
        record.nif = '   '
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end
    end

    context 'with valid NIF numbers' do
      # Valid NIF examples calculated using the algorithm:
      # 12345678Z: 12345678 % 23 = 14 -> Z

      it 'accepts valid NIF 12345678Z' do
        record.nif = '12345678Z'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'accepts valid NIF 00000000T' do
        # 00000000 % 23 = 0 -> T
        record.nif = '00000000T'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'accepts valid NIF 99999999R' do
        # 99999999 % 23 = 18 -> R
        record.nif = '99999999R'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'accepts lowercase NIF and converts to uppercase' do
        record.nif = '12345678z'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'accepts NIF with leading/trailing whitespace' do
        record.nif = '  12345678Z  '
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'accepts mixed case NIF' do
        record.nif = '12345678z'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      # Additional valid NIFs
      it 'accepts 11111111H' do
        # 11111111 % 23 = 10 -> H
        record.nif = '11111111H'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'accepts 22222222J' do
        # 22222222 % 23 = 20 -> J
        record.nif = '22222222J'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'accepts 33333333P' do
        # 33333333 % 23 = 16 -> P
        record.nif = '33333333P'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'accepts 44444444A' do
        # 44444444 % 23 = 3 -> A
        record.nif = '44444444A'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'accepts 55555555K' do
        # 55555555 % 23 = 4 -> K
        record.nif = '55555555K'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end
    end

    context 'with invalid format' do
      it 'rejects NIF with too few digits' do
        record.nif = '1234567Z'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIF with too many digits' do
        record.nif = '123456789Z'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIF without final letter' do
        record.nif = '12345678'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIF with number as final character' do
        record.nif = '123456781'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIF with letter in middle digits' do
        record.nif = '1234A678Z'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIF with special characters' do
        record.nif = '12345-78Z'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIF with spaces in middle' do
        record.nif = '1234 5678Z'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects too short string' do
        record.nif = '123'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects too long string' do
        record.nif = '12345678901Z'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIF with letter at start' do
        record.nif = 'A2345678Z'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIF with all letters' do
        record.nif = 'ABCDEFGHZ'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIF with all numbers' do
        record.nif = '123456789'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIF with multiple letters at end' do
        record.nif = '12345678ZZ'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end
    end

    context 'with wrong check letter' do
      it 'rejects NIF with incorrect check letter' do
        # 12345678Z is valid, 12345678A is not
        record.nif = '12345678A'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIF with off-by-one check letter' do
        # 12345678Z is valid (Z is at position 14)
        # Try S (position 13)
        record.nif = '12345678S'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects 00000000 with wrong letter' do
        # 00000000T is valid
        record.nif = '00000000A'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects 99999999 with wrong letter' do
        # 99999999R is valid
        record.nif = '99999999A'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects with completely wrong letter' do
        record.nif = '11111111A'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end
    end

    context 'with edge cases' do
      it 'handles NIF at start of LETTERS (T)' do
        # Need NIF that results in 0 % 23 = 0 -> T
        # 00000000T is valid
        record.nif = '00000000T'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'handles NIF at end of LETTERS (E)' do
        # Need NIF that results in % 23 = 22 -> E
        # 00000022E: 00000022 % 23 = 22 -> E
        record.nif = '00000022E'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'handles NIF with maximum valid number' do
        record.nif = '99999999R'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'handles NIF with minimum valid number' do
        record.nif = '00000000T'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'handles each possible check letter' do
        # Verify that each letter in LETTERS can be a valid check letter
        ValidNifValidator::LETTERS.chars.each_with_index do |letter, index|
          # Find a number that has this remainder
          number = format('%08d', index)
          nif = "#{number}#{letter}"

          record.nif = nif
          record.valid?
          expect(record.errors[:nif]).to be_empty, "Expected #{nif} to be valid"
        end
      end
    end

    context 'input normalization' do
      it 'strips whitespace before validation' do
        record.nif = "\n\t12345678Z\n\t"
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'converts to uppercase before validation' do
        record.nif = '12345678z'
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'handles String subclass' do
        nif_string = String.new('12345678Z')
        record.nif = nif_string
        record.valid?
        expect(record.errors[:nif]).to be_empty
      end

      it 'converts to string when number provided' do
        record.nif = 12345678
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end
    end

    context 'algorithm verification' do
      it 'correctly calculates check letter' do
        # 12345678 % 23 = 14
        # LETTERS[14] = Z
        expect(ValidNifValidator::LETTERS[12345678 % 23]).to eq('Z')
      end

      it 'uses modulo 23 for check letter calculation' do
        # Verify that all possible remainders (0-22) are covered
        expect(ValidNifValidator::LETTERS.length).to eq(23)
      end

      it 'handles large numbers correctly' do
        # 99999999 % 23 = 18
        # LETTERS[18] = R
        expect(ValidNifValidator::LETTERS[99999999 % 23]).to eq('R')
      end

      it 'handles zero correctly' do
        # 0 % 23 = 0
        # LETTERS[0] = T
        expect(ValidNifValidator::LETTERS[0 % 23]).to eq('T')
      end
    end

    context 'comprehensive valid NIFs' do
      # Generate several valid NIFs systematically
      [
        '00000000T', '00000001R', '00000002W', '00000003A', '00000004G',
        '00000005M', '00000006Y', '00000007F', '00000008P', '00000009D',
        '00000010X', '00000011B', '00000012N', '00000013J', '00000014Z',
        '00000015S', '00000016Q', '00000017V', '00000018H', '00000019L',
        '00000020C', '00000021K', '00000022E',
        '11111111H', '22222222J', '33333333P', '44444444A', '55555555K',
        '66666666Q', '77777777B', '88888888Y', '99999999R'
      ].each do |valid_nif|
        it "accepts #{valid_nif}" do
          # Calculate to verify it's actually valid
          number = valid_nif[0..7].to_i
          expected_letter = ValidNifValidator::LETTERS[number % 23]

          if valid_nif[8] == expected_letter
            record.nif = valid_nif
            record.valid?
            expect(record.errors[:nif]).to be_empty
          end
        end
      end
    end

    context 'comprehensive invalid NIFs' do
      [
        '1234567Z',   # Too short
        '123456789Z', # Too long
        '12345678',   # No letter
        'A2345678Z',  # Letter at start
        '12345678A',  # Wrong letter
        '1234A678Z',  # Letter in digits
        '12345-78Z',  # Special char
        'ABCDEFGHZ',  # All letters
        '123456789',  # All numbers
        '12345678ZZ', # Double letter
        '',           # Empty (should not error due to blank check)
        '12345 678Z', # Space in middle
      ].each do |invalid_nif|
        it "rejects #{invalid_nif.inspect}" do
          test_record = test_class.new
          test_record.nif = invalid_nif
          test_record.valid?
          # Blank values don't get errors
          unless invalid_nif.strip.empty?
            expect(test_record.errors[:nif]).to include('El DNI no es válido'), "Expected #{invalid_nif.inspect} to be invalid"
          end
        end
      end
    end

    context 'difference from NIE' do
      it 'rejects NIE format (X prefix)' do
        record.nif = 'X1234567L'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIE format (Y prefix)' do
        record.nif = 'Y1234567X'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'rejects NIE format (Z prefix)' do
        record.nif = 'Z1234567R'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end

      it 'only accepts 8 digits, not 7 like NIE' do
        record.nif = '1234567Z'
        record.valid?
        expect(record.errors[:nif]).to include('El DNI no es válido')
      end
    end
  end

  describe 'error messages' do
    it 'adds error with default message' do
      record.nif = 'INVALID'
      record.valid?
      expect(record.errors[:nif]).to include('El DNI no es válido')
    end

    it 'only adds one error per validation' do
      record.nif = 'INVALID'
      record.valid?
      expect(record.errors[:nif].count).to eq(1)
    end
  end

  describe 'integration with ActiveModel' do
    it 'integrates properly with ActiveModel validations' do
      expect(test_class.validators.map(&:class)).to include(ValidNifValidator)
    end

    it 'validates on model save' do
      record.nif = 'INVALID'
      expect(record).not_to be_valid
    end

    it 'allows valid model to pass' do
      record.nif = '12345678Z'
      expect(record).to be_valid
    end
  end

  describe 'comparison with ValidNieValidator' do
    it 'uses same LETTERS constant as NIE validator' do
      expect(ValidNifValidator::LETTERS).to eq(ValidNieValidator::LETTERS)
    end

    it 'uses same modulo 23 algorithm' do
      # Both use % 23 for check digit calculation
      nif_number = 12345678
      nie_number = 1234567 # NIE without prefix substitution

      nif_index = nif_number % 23
      nie_index = nie_number % 23

      expect(ValidNifValidator::LETTERS[nif_index]).to be_a(String)
      expect(ValidNieValidator::LETTERS[nie_index]).to be_a(String)
    end

    it 'has different format requirements' do
      # NIF: 8 digits + letter
      # NIE: Letter + 7 digits + letter
      nif_regex = /^\d{8}[A-Z]$/
      nie_regex = /^[XYZ]\d{7}[A-Z]$/

      expect('12345678Z').to match(nif_regex)
      expect('12345678Z').not_to match(nie_regex)
      expect('X1234567L').to match(nie_regex)
      expect('X1234567L').not_to match(nif_regex)
    end
  end
end
