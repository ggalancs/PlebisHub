# frozen_string_literal: true

require 'rails_helper'

# Explicitly load the app's custom validator to override the gem's version
require Rails.root.join('app/validators/valid_nif_validator')

# Test the custom ValidNifValidator from app/validators
# Note: The app overrides spanish_vat_validators gem to allow blank values
RSpec.describe ValidNifValidator do
  # Get the actual app validator class (not the gem's version)
  let(:validator_class) { ValidNifValidator }

  describe 'LETTERS constant' do
    it 'has 23 characters' do
      expect(validator_class::LETTERS.length).to eq(23)
    end

    it 'contains expected characters' do
      expect(validator_class::LETTERS).to eq('TRWAGMYFPDXBNJZSQVHLCKE')
    end
  end

  describe '#validate_each' do
    # Create validator instance directly for testing
    let(:validator) { validator_class.new(attributes: [:document_vatid]) }
    let(:record) do
      double('record').as_null_object
    end

    before do
      # Reset errors for each test
      allow(record).to receive(:errors).and_return(ActiveModel::Errors.new(record))
    end

    context 'with blank value' do
      # The custom validator returns early for blank values (no error added)
      it 'does not add error for nil value' do
        validator.validate_each(record, :document_vatid, nil)
        expect(record.errors[:document_vatid]).to be_empty
      end

      it 'does not add error for empty string' do
        validator.validate_each(record, :document_vatid, '')
        expect(record.errors[:document_vatid]).to be_empty
      end

      it 'does not add error for whitespace only' do
        validator.validate_each(record, :document_vatid, '   ')
        expect(record.errors[:document_vatid]).to be_empty
      end
    end

    context 'with valid NIF' do
      # Valid NIF examples (8 digits + checksum letter)
      # Formula: letter = LETTERS[number % 23]
      it 'accepts 12345678Z' do
        # 12345678 % 23 = 14 -> Z
        validator.validate_each(record, :document_vatid, '12345678Z')
        expect(record.errors[:document_vatid]).to be_empty
      end

      it 'accepts 00000000T' do
        # 0 % 23 = 0 -> T
        validator.validate_each(record, :document_vatid, '00000000T')
        expect(record.errors[:document_vatid]).to be_empty
      end

      it 'accepts lowercase letters' do
        validator.validate_each(record, :document_vatid, '12345678z')
        expect(record.errors[:document_vatid]).to be_empty
      end

      it 'accepts with leading/trailing whitespace' do
        validator.validate_each(record, :document_vatid, '  12345678Z  ')
        expect(record.errors[:document_vatid]).to be_empty
      end
    end

    context 'with invalid NIF format' do
      it 'rejects NIF with wrong number of digits' do
        validator.validate_each(record, :document_vatid, '1234567Z')
        expect(record.errors[:document_vatid]).not_to be_empty
      end

      it 'rejects NIF with too many digits' do
        validator.validate_each(record, :document_vatid, '123456789Z')
        expect(record.errors[:document_vatid]).not_to be_empty
      end

      it 'rejects NIF without letter' do
        validator.validate_each(record, :document_vatid, '12345678')
        expect(record.errors[:document_vatid]).not_to be_empty
      end

      it 'rejects NIF with letter at wrong position' do
        validator.validate_each(record, :document_vatid, 'Z12345678')
        expect(record.errors[:document_vatid]).not_to be_empty
      end
    end

    context 'with invalid checksum' do
      it 'rejects NIF with wrong checksum letter' do
        # 12345678 should have Z, not A
        validator.validate_each(record, :document_vatid, '12345678A')
        expect(record.errors[:document_vatid]).not_to be_empty
      end

      it 'rejects NIF with another wrong checksum' do
        # 00000000 should have T, not R
        validator.validate_each(record, :document_vatid, '00000000R')
        expect(record.errors[:document_vatid]).not_to be_empty
      end
    end
  end

  describe 'error message' do
    let(:validator) { ValidNifValidator.new(attributes: [:document_vatid]) }
    let(:record) { double('record').as_null_object }

    before do
      allow(record).to receive(:errors).and_return(ActiveModel::Errors.new(record))
    end

    it 'adds error when checksum is invalid' do
      validator.validate_each(record, :document_vatid, '12345678A')
      expect(record.errors[:document_vatid]).to be_present
    end
  end
end
