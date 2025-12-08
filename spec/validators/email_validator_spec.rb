# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailValidator do
  # Named test class to avoid Rails 7.2 "Class name cannot be blank" error
  before(:all) do
    test_klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :email

      validates :email, email: true
    end
    Object.const_set(:EmailTestModel, test_klass)
  end

  after(:all) do
    Object.send(:remove_const, :EmailTestModel)
  end

  let(:record) { EmailTestModel.new }

  describe '#validate_each' do
    context 'with valid emails' do
      let(:valid_emails) do
        [
          'test@example.com',
          'user.name@domain.org',
          'user+tag@domain.co.uk',
          'user123@subdomain.domain.com',
          '"quoted"@example.com',
          'user_name@example.com',
          'user-name@example.com',
          'a@b.co',
        ]
      end

      it 'accepts valid email formats' do
        valid_emails.each do |email|
          record.email = email
          expect(record).to be_valid, "Expected #{email} to be valid"
        end
      end
    end

    context 'with blank values' do
      # Note: EmailValidator allows blank values by design
      # Use presence: true separately if blank should be rejected
      it 'allows nil value (by design)' do
        record.email = nil
        expect(record).to be_valid
      end

      it 'allows empty string (by design)' do
        record.email = ''
        expect(record).to be_valid
      end
    end

    context 'with accented characters' do
      it 'rejects email with accent' do
        record.email = 'josémaria@example.com'
        expect(record).not_to be_valid
        expect(record.errors[:email].first).to include('acentos')
      end

      it 'rejects email with tilde' do
        record.email = 'niño@example.com'
        expect(record).not_to be_valid
      end

      it 'rejects email with cedilla' do
        record.email = 'açucar@example.com'
        expect(record).not_to be_valid
      end
    end

    context 'with consecutive dots' do
      it 'rejects email with double dots' do
        record.email = 'user..name@example.com'
        expect(record).not_to be_valid
        expect(record.errors[:email].first).to include('dos puntos seguidos')
      end
    end

    context 'with invalid starting character' do
      it 'rejects email starting with dot' do
        record.email = '.user@example.com'
        expect(record).not_to be_valid
        expect(record.errors[:email].first).to include('comenzar con')
      end

      it 'rejects email starting with special character' do
        record.email = '@user@example.com'
        expect(record).not_to be_valid
      end

      it 'accepts email starting with number' do
        record.email = '123user@example.com'
        expect(record).to be_valid
      end

      it 'accepts email starting with quote' do
        record.email = '"user"@example.com'
        expect(record).to be_valid
      end
    end

    context 'with invalid ending character' do
      it 'rejects email ending with number' do
        record.email = 'user@example.com1'
        expect(record).not_to be_valid
        expect(record.errors[:email].first).to include('acabar con una letra')
      end

      it 'rejects email ending with dot' do
        record.email = 'user@example.'
        expect(record).not_to be_valid
      end
    end

    context 'with invalid domain' do
      it 'rejects email without domain' do
        record.email = 'user@'
        expect(record).not_to be_valid
      end

      it 'rejects email without dot in domain' do
        record.email = 'user@localhost'
        expect(record).not_to be_valid
      end

      it 'rejects email with domain starting with dot' do
        record.email = 'user@.example.com'
        expect(record).not_to be_valid
      end
    end

    context 'with comma in email' do
      it 'rejects unquoted comma' do
        record.email = 'user,name@example.com'
        expect(record).not_to be_valid
      end
    end

    context 'with malformed emails' do
      let(:invalid_emails) do
        [
          'user', # no @ sign
          '@example.com', # starts with @
          'user@.com', # domain starts with dot
          # Note: 'user @example.com' is accepted by Mail::Address library
        ]
      end

      it 'rejects malformed email formats' do
        invalid_emails.each do |email|
          record.email = email
          expect(record).not_to be_valid, "Expected #{email} to be invalid"
        end
      end
    end
  end

  describe 'error message handling' do
    it 'clears previous errors before adding new one' do
      record.email = 'josémaria@example.com'
      record.valid?
      expect(record.errors[:email].count).to eq(1)
    end

    it 'returns appropriate Spanish error message' do
      record.email = 'user..test@example.com'
      record.valid?
      expect(record.errors[:email].first).to be_a(String)
    end
  end
end

RSpec.describe ActiveModel::Validations::EmailValidatorHelpers do
  let(:helper_class) do
    Class.new do
      include ActiveModel::Validations::EmailValidatorHelpers
    end
  end

  let(:helper) { helper_class.new }

  describe '#validate_email' do
    it 'returns false for valid email (false means no error)' do
      expect(helper.validate_email('test@example.com')).to be false
    end

    it 'returns error string for invalid email' do
      result = helper.validate_email('josémaria@example.com')
      expect(result).to be_a(String)
    end

    it 'returns false for blank email (blank is allowed)' do
      expect(helper.validate_email(nil)).to be false
      expect(helper.validate_email('')).to be false
    end
  end
end
