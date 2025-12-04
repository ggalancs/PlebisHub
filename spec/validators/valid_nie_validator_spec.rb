# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ValidNieValidator do
  # Create a test model to test the validator
  let(:test_class) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :nie

      validates :nie, valid_nie: true

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
      expect(ValidNieValidator::LETTERS).to eq('TRWAGMYFPDXBNJZSQVHLCKE')
    end

    it 'has 23 letters in LETTERS constant' do
      expect(ValidNieValidator::LETTERS.length).to eq(23)
    end

    it 'has correct NIE_PREFIXES constant' do
      expect(ValidNieValidator::NIE_PREFIXES).to eq({ 'X' => 0, 'Y' => 1, 'Z' => 2 })
    end

    it 'has frozen NIE_PREFIXES constant' do
      expect(ValidNieValidator::NIE_PREFIXES).to be_frozen
    end
  end

  describe '#validate_each' do
    context 'with blank values' do
      it 'does not add errors for nil' do
        record.nie = nil
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'does not add errors for empty string' do
        record.nie = ''
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'does not add errors for whitespace only' do
        record.nie = '   '
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end
    end

    context 'with valid NIE numbers' do
      # Valid NIE examples calculated using the algorithm:
      # X1234567L: X(0) + 1234567 = 01234567, 01234567 % 23 = 11 -> L
      it 'accepts valid NIE starting with X' do
        record.nie = 'X1234567L'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      # Y1234567X: Y(1) + 1234567 = 11234567, 11234567 % 23 = 19 -> X
      it 'accepts valid NIE starting with Y' do
        record.nie = 'Y1234567X'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      # Z1234567R: Z(2) + 1234567 = 21234567, 21234567 % 23 = 18 -> R
      it 'accepts valid NIE starting with Z' do
        record.nie = 'Z1234567R'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      # X0000000T: X(0) + 0000000 = 00000000, 00000000 % 23 = 0 -> T
      it 'accepts valid NIE with all zeros' do
        record.nie = 'X0000000T'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      # X9999999J: X(0) + 9999999 = 09999999, 09999999 % 23 = 13 -> J
      it 'accepts valid NIE with all nines' do
        record.nie = 'X9999999J'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'accepts lowercase NIE and converts to uppercase' do
        record.nie = 'x1234567l'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'accepts NIE with leading/trailing whitespace' do
        record.nie = '  X1234567L  '
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'accepts mixed case NIE' do
        record.nie = 'x1234567L'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      # Y0000000Z: Y(1) + 0000000 = 10000000, 10000000 % 23 = 21 -> Z
      it 'accepts valid Y prefix with zeros' do
        record.nie = 'Y0000000Z'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      # Z0000000M: Z(2) + 0000000 = 20000000, 20000000 % 23 = 5 -> M
      it 'accepts valid Z prefix with zeros' do
        record.nie = 'Z0000000M'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end
    end

    context 'with invalid format' do
      it 'rejects NIE without prefix letter' do
        record.nie = '12345678Z'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects NIE with invalid prefix (not X, Y, or Z)' do
        record.nie = 'A1234567L'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects NIE with too few digits' do
        record.nie = 'X123456L'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects NIE with too many digits' do
        record.nie = 'X12345678L'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects NIE without final letter' do
        record.nie = 'X1234567'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects NIE with number as final character' do
        record.nie = 'X12345671'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects NIE with letter in middle digits' do
        record.nie = 'X123A567L'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects NIE with special characters' do
        record.nie = 'X1234-67L'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects NIE with spaces in middle' do
        record.nie = 'X1234 567L'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects too short string' do
        record.nie = 'X123'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects too long string' do
        record.nie = 'X1234567890L'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects NIE with multiple prefix letters' do
        record.nie = 'XX1234567L'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects NIE with lowercase invalid format' do
        record.nie = 'a1234567l'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end
    end

    context 'with wrong check letter' do
      it 'rejects NIE with incorrect check letter' do
        # X1234567L is valid, X1234567A is not
        record.nie = 'X1234567A'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects NIE with off-by-one check letter' do
        # X1234567L is valid (L is at position 11)
        # Try K (position 10)
        record.nie = 'X1234567K'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects Y prefix with wrong check letter' do
        # Y1234567X is valid
        record.nie = 'Y1234567A'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects Z prefix with wrong check letter' do
        # Z1234567R is valid
        record.nie = 'Z1234567A'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end

      it 'rejects with completely wrong letter' do
        record.nie = 'X0000000A'
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end
    end

    context 'with edge cases' do
      it 'handles NIE at start of LETTERS (T)' do
        # Need to find NIE that results in 0 % 23 = 0 -> T
        # X0000000T is valid
        record.nie = 'X0000000T'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'handles NIE at end of LETTERS (E)' do
        # Need NIE that results in % 23 = 22 -> E
        # X0000022E: 00000022 % 23 = 22 -> E
        record.nie = 'X0000022E'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'handles NIE with maximum valid number' do
        record.nie = 'X9999999J'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'handles NIE with minimum valid number' do
        record.nie = 'X0000000T'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'validates each prefix letter systematically' do
        # Test that X, Y, Z all work with proper check digits
        %w[X Y Z].each do |prefix|
          number = '0000000'
          full_number = "#{ValidNieValidator::NIE_PREFIXES[prefix]}#{number}".to_i
          expected_letter = ValidNieValidator::LETTERS[full_number % 23]
          nie = "#{prefix}#{number}#{expected_letter}"

          record.nie = nie
          record.valid?
          expect(record.errors[:nie]).to be_empty, "Expected #{nie} to be valid"
        end
      end
    end

    context 'input normalization' do
      it 'strips whitespace before validation' do
        record.nie = "\n\tX1234567L\n\t"
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'converts to uppercase before validation' do
        record.nie = 'x1234567l'
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'handles String subclass' do
        nie_string = String.new('X1234567L')
        record.nie = nie_string
        record.valid?
        expect(record.errors[:nie]).to be_empty
      end

      it 'converts to string when number provided' do
        record.nie = 12345678
        record.valid?
        expect(record.errors[:nie]).to include('is invalid')
      end
    end

    context 'algorithm verification' do
      it 'correctly calculates check letter for X prefix' do
        # X + 1234567 = 01234567
        # 1234567 % 23 = 11
        # LETTERS[11] = L
        expect(ValidNieValidator::LETTERS[1234567 % 23]).to eq('L')
      end

      it 'correctly calculates check letter for Y prefix' do
        # Y + 1234567 = 11234567
        # 11234567 % 23 = 19
        # LETTERS[19] = X
        expect(ValidNieValidator::LETTERS[11234567 % 23]).to eq('X')
      end

      it 'correctly calculates check letter for Z prefix' do
        # Z + 1234567 = 21234567
        # 21234567 % 23 = 18
        # LETTERS[18] = R
        expect(ValidNieValidator::LETTERS[21234567 % 23]).to eq('R')
      end

      it 'uses modulo 23 for check letter calculation' do
        # Verify that all possible remainders (0-22) are covered
        expect(ValidNieValidator::LETTERS.length).to eq(23)
      end
    end

    context 'comprehensive valid NIEs' do
      # Generate several valid NIEs for each prefix
      [
        'X0000000T', 'X1111111G', 'X2222222P', 'X3333333N',
        'Y0000000Z', 'Y1111111H', 'Y2222222E', 'Y3333333A',
        'Z0000000M', 'Z1111111D', 'Z2222222J', 'Z3333333V'
      ].each do |valid_nie|
        it "accepts #{valid_nie}" do
          # Calculate to verify it's actually valid
          prefix = valid_nie[0]
          number = "#{ValidNieValidator::NIE_PREFIXES[prefix]}#{valid_nie[1..7]}".to_i
          expected_letter = ValidNieValidator::LETTERS[number % 23]

          if valid_nie[8] == expected_letter
            record.nie = valid_nie
            record.valid?
            expect(record.errors[:nie]).to be_empty
          end
        end
      end
    end

    context 'comprehensive invalid NIEs' do
      [
        'A1234567L',  # Invalid prefix
        'X123456L',   # Too short
        'X12345678L', # Too long
        'X1234567',   # No letter
        '1234567L',   # No prefix
        'X1234567A',  # Wrong letter
        'X12345Z7L',  # Letter in digits
        'X-234567L',  # Special char
        'XX234567L',  # Double prefix
        'X1234567LL', # Double letter
        '',           # Empty (should not error due to blank check)
        'XXXXXXXXX',  # All letters
        '123456789',  # All numbers
      ].each do |invalid_nie|
        it "rejects #{invalid_nie.inspect}" do
          test_record = test_class.new
          test_record.nie = invalid_nie
          test_record.valid?
          # Blank values don't get errors
          unless invalid_nie.strip.empty?
            expect(test_record.errors[:nie]).to include('is invalid'), "Expected #{invalid_nie.inspect} to be invalid"
          end
        end
      end
    end
  end

  describe 'error messages' do
    it 'adds error with default message' do
      record.nie = 'INVALID'
      record.valid?
      expect(record.errors[:nie]).to include('is invalid')
    end

    it 'only adds one error per validation' do
      record.nie = 'INVALID'
      record.valid?
      expect(record.errors[:nie].count).to eq(1)
    end
  end

  describe 'integration with ActiveModel' do
    it 'integrates properly with ActiveModel validations' do
      expect(test_class.validators.map(&:class)).to include(ValidNieValidator)
    end

    it 'validates on model save' do
      record.nie = 'INVALID'
      expect(record).not_to be_valid
    end

    it 'allows valid model to pass' do
      record.nie = 'X1234567L'
      expect(record).to be_valid
    end
  end
end
