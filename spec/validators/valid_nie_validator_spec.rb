# frozen_string_literal: true

require 'rails_helper'

# Explicitly load the app's custom validator to override the gem's version
require Rails.root.join('app/validators/valid_nie_validator')

# Test the custom ValidNieValidator from app/validators
# Note: The app overrides spanish_vat_validators gem to allow blank values
RSpec.describe ValidNieValidator do
  # Get the actual app validator class
  let(:validator_class) { ValidNieValidator }

  describe '#validate_each' do
    let(:validator) { validator_class.new(attributes: [:document_vatid]) }
    let(:record) { double('record').as_null_object }

    before do
      allow(record).to receive(:errors).and_return(ActiveModel::Errors.new(record))
    end

    context 'with blank value' do
      it 'allows nil value' do
        validator.validate_each(record, :document_vatid, nil)
        expect(record.errors[:document_vatid]).to be_empty
      end

      it 'allows empty string' do
        validator.validate_each(record, :document_vatid, '')
        expect(record.errors[:document_vatid]).to be_empty
      end

      it 'allows whitespace only' do
        validator.validate_each(record, :document_vatid, '   ')
        expect(record.errors[:document_vatid]).to be_empty
      end
    end

    context 'with valid NIE' do
      # Valid NIE examples (X/Y/Z + 7 digits + checksum letter)
      # X maps to 0, Y maps to 1, Z maps to 2
      # Formula: number = "{prefix_value}{7digits}".to_i, letter = LETTERS[number % 23]
      #
      # X0000000: "00000000" % 23 = 0 -> T
      # Y0000000: "10000000" % 23 = 14 -> Z
      # Z0000000: "20000000" % 23 = 5 -> M

      it 'accepts valid NIE with X prefix' do
        validator.validate_each(record, :document_vatid, 'X0000000T')
        expect(record.errors[:document_vatid]).to be_empty
      end

      it 'accepts valid NIE with Y prefix' do
        validator.validate_each(record, :document_vatid, 'Y0000000Z')
        expect(record.errors[:document_vatid]).to be_empty
      end

      it 'accepts valid NIE with Z prefix' do
        validator.validate_each(record, :document_vatid, 'Z0000000M')
        expect(record.errors[:document_vatid]).to be_empty
      end

      it 'accepts lowercase prefix and letter' do
        validator.validate_each(record, :document_vatid, 'x0000000t')
        expect(record.errors[:document_vatid]).to be_empty
      end

      it 'handles leading/trailing whitespace' do
        validator.validate_each(record, :document_vatid, '  X0000000T  ')
        expect(record.errors[:document_vatid]).to be_empty
      end
    end

    context 'with invalid NIE format' do
      it 'rejects NIE with invalid prefix' do
        validator.validate_each(record, :document_vatid, 'A1234567Z')
        expect(record.errors[:document_vatid]).not_to be_empty
      end

      it 'rejects NIE with wrong number of digits' do
        validator.validate_each(record, :document_vatid, 'X123456Z') # only 6 digits
        expect(record.errors[:document_vatid]).not_to be_empty
      end

      it 'rejects NIE with too many digits' do
        validator.validate_each(record, :document_vatid, 'X12345678Z') # 8 digits
        expect(record.errors[:document_vatid]).not_to be_empty
      end

      it 'rejects NIE without letter at end' do
        validator.validate_each(record, :document_vatid, 'X1234567')
        expect(record.errors[:document_vatid]).not_to be_empty
      end

      it 'rejects NIE with number instead of prefix' do
        validator.validate_each(record, :document_vatid, '11234567Z')
        expect(record.errors[:document_vatid]).not_to be_empty
      end

      it 'rejects NIE with special characters' do
        validator.validate_each(record, :document_vatid, 'X123-456Z')
        expect(record.errors[:document_vatid]).not_to be_empty
      end
    end

    context 'with invalid checksum' do
      it 'rejects NIE with wrong checksum letter' do
        validator.validate_each(record, :document_vatid, 'X0000000R') # should be T
        expect(record.errors[:document_vatid]).not_to be_empty
      end

      it 'rejects NIE with another wrong checksum' do
        validator.validate_each(record, :document_vatid, 'Y0000000T') # should be Z
        expect(record.errors[:document_vatid]).not_to be_empty
      end
    end
  end

  describe 'NIE_PREFIXES constant' do
    it 'maps X to 0' do
      expect(ValidNieValidator::NIE_PREFIXES['X']).to eq(0)
    end

    it 'maps Y to 1' do
      expect(ValidNieValidator::NIE_PREFIXES['Y']).to eq(1)
    end

    it 'maps Z to 2' do
      expect(ValidNieValidator::NIE_PREFIXES['Z']).to eq(2)
    end
  end

  describe 'LETTERS constant' do
    it 'has 23 characters' do
      expect(ValidNieValidator::LETTERS.length).to eq(23)
    end

    it 'contains expected characters' do
      expect(ValidNieValidator::LETTERS).to eq('TRWAGMYFPDXBNJZSQVHLCKE')
    end
  end

  describe 'error message' do
    let(:validator) { ValidNieValidator.new(attributes: [:document_vatid]) }
    let(:record) { double('record').as_null_object }

    before do
      allow(record).to receive(:errors).and_return(ActiveModel::Errors.new(record))
    end

    it 'uses I18n translation' do
      validator.validate_each(record, :document_vatid, 'X0000000R')
      expect(record.errors[:document_vatid].first).to be_present
    end
  end
end
