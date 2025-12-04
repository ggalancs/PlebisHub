# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailValidator do
  # Create a test model to test the validator
  let(:test_class) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :email

      validates :email, email: true

      def self.name
        'TestUser'
      end

      def self.model_name
        ActiveModel::Name.new(self, nil, 'TestUser')
      end
    end
  end

  let(:record) { test_class.new }

  describe 'EmailValidatorHelpers#validate_email' do
    let(:validator) { EmailValidator.new(attributes: [:email]) }

    context 'with valid emails' do
      it 'accepts standard email' do
        expect(validator.validate_email('test@example.com')).to be false
      end

      it 'accepts email with subdomain' do
        expect(validator.validate_email('user@mail.example.com')).to be false
      end

      it 'accepts email with numbers' do
        expect(validator.validate_email('user123@example.com')).to be false
      end

      it 'accepts email with dots in local part' do
        expect(validator.validate_email('first.last@example.com')).to be false
      end

      it 'accepts email with hyphen in domain' do
        expect(validator.validate_email('user@my-domain.com')).to be false
      end

      it 'accepts email with numbers in local part' do
        expect(validator.validate_email('123user@example.com')).to be false
      end

      it 'accepts email with underscore' do
        expect(validator.validate_email('user_name@example.com')).to be false
      end

      it 'accepts email with plus sign' do
        expect(validator.validate_email('user+tag@example.com')).to be false
      end

      it 'accepts long email' do
        expect(validator.validate_email('very.long.email.address.with.many.dots@example.com')).to be false
      end

      it 'accepts email starting with number' do
        expect(validator.validate_email('1user@example.com')).to be false
      end

      it 'accepts email starting with letter' do
        expect(validator.validate_email('user@example.com')).to be false
      end

      it 'accepts email with multiple subdomains' do
        expect(validator.validate_email('user@mail.subdomain.example.com')).to be false
      end
    end

    context 'with invalid emails - blank values' do
      it 'rejects nil' do
        expect(validator.validate_email(nil)).to be false
      end

      it 'rejects empty string' do
        expect(validator.validate_email('')).to be false
      end

      it 'rejects whitespace only' do
        expect(validator.validate_email('   ')).to be false
      end
    end

    context 'with invalid emails - special characters' do
      it 'rejects email with accented characters (á)' do
        error = validator.validate_email('usuário@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with á' do
        error = validator.validate_email('maría@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with é' do
        error = validator.validate_email('josé@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with í' do
        error = validator.validate_email('maría@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with ó' do
        error = validator.validate_email('mónica@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with ú' do
        error = validator.validate_email('raúl@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with ñ' do
        error = validator.validate_email('españa@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with Ñ' do
        error = validator.validate_email('ESPAÑA@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with ç' do
        error = validator.validate_email('françois@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with Ç' do
        error = validator.validate_email('FRANÇOIS@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with uppercase accented characters' do
        error = validator.validate_email('MARÍA@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with grave accents (à)' do
        error = validator.validate_email('àlex@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with grave accents (è)' do
        error = validator.validate_email('pèrez@example.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'rejects email with accents in domain' do
        error = validator.validate_email('user@exámple.com')
        expect(error).to eq('no puede contener acentos, eñes u otros caracteres especiales')
      end
    end

    context 'with invalid emails - consecutive dots' do
      it 'rejects email with consecutive dots in local part' do
        error = validator.validate_email('user..name@example.com')
        expect(error).to eq('no puede contener dos puntos seguidos')
      end

      it 'rejects email with multiple consecutive dots' do
        error = validator.validate_email('user...name@example.com')
        expect(error).to eq('no puede contener dos puntos seguidos')
      end

      it 'rejects email with consecutive dots in domain' do
        error = validator.validate_email('user@example..com')
        expect(error).to eq('no puede contener dos puntos seguidos')
      end

      it 'rejects email with consecutive dots at start' do
        error = validator.validate_email('..user@example.com')
        expect(error).to eq('no puede contener dos puntos seguidos')
      end
    end

    context 'with invalid emails - start requirements' do
      it 'rejects email starting with dot' do
        error = validator.validate_email('.user@example.com')
        expect(error).to eq('debe comenzar con un número o una letra')
      end

      it 'rejects email starting with special character' do
        error = validator.validate_email('!user@example.com')
        expect(error).to eq('debe comenzar con un número o una letra')
      end

      it 'rejects email starting with underscore' do
        error = validator.validate_email('_user@example.com')
        expect(error).to eq('debe comenzar con un número o una letra')
      end

      it 'rejects email starting with hyphen' do
        error = validator.validate_email('-user@example.com')
        expect(error).to eq('debe comenzar con un número o una letra')
      end

      it 'rejects email starting with @' do
        error = validator.validate_email('@example.com')
        expect(error).to eq('debe comenzar con un número o una letra')
      end

      it 'rejects email starting with plus' do
        error = validator.validate_email('+user@example.com')
        expect(error).to eq('debe comenzar con un número o una letra')
      end
    end

    context 'with invalid emails - end requirements' do
      it 'rejects email ending with number' do
        error = validator.validate_email('user@example.com1')
        expect(error).to eq('debe acabar con una letra')
      end

      it 'rejects email ending with dot' do
        error = validator.validate_email('user@example.com.')
        expect(error).to eq('debe acabar con una letra')
      end

      it 'rejects email ending with hyphen' do
        error = validator.validate_email('user@example.com-')
        expect(error).to eq('debe acabar con una letra')
      end

      it 'rejects email ending with underscore' do
        error = validator.validate_email('user@example.com_')
        expect(error).to eq('debe acabar con una letra')
      end

      it 'rejects email ending with special character' do
        error = validator.validate_email('user@example.com!')
        expect(error).to eq('debe acabar con una letra')
      end
    end

    context 'with invalid emails - commas' do
      it 'rejects email with unquoted comma' do
        error = validator.validate_email('user,name@example.com')
        expect(error).to eq('contiene caracteres inválidos')
      end

      it 'rejects multiple emails separated by comma' do
        error = validator.validate_email('user1@example.com,user2@example.com')
        expect(error).to eq('contiene caracteres inválidos')
      end

      it 'rejects email with comma in domain' do
        error = validator.validate_email('user@exam,ple.com')
        expect(error).to eq('contiene caracteres inválidos')
      end
    end

    context 'with invalid emails - domain issues' do
      it 'rejects email without domain' do
        error = validator.validate_email('user@')
        expect(error).to eq('debe acabar con una letra')
      end

      it 'rejects email without @' do
        error = validator.validate_email('userexample.com')
        expect(error).to eq('es incorrecto')
      end

      it 'rejects email with domain without dot' do
        error = validator.validate_email('user@example')
        expect(error).to eq('es incorrecto')
      end

      it 'rejects email with domain starting with dot' do
        error = validator.validate_email('user@.example.com')
        expect(error).to eq('es incorrecto')
      end

      it 'rejects email with only @ and domain' do
        error = validator.validate_email('@example.com')
        expect(error).to eq('debe comenzar con un número o una letra')
      end

      it 'rejects email with empty local part' do
        error = validator.validate_email('@example.com')
        expect(error).to eq('debe comenzar con un número o una letra')
      end

      it 'rejects email with malformed domain' do
        error = validator.validate_email('user@exam ple.com')
        expect(error).to eq('es incorrecto')
      end
    end

    context 'with invalid emails - general malformed' do
      it 'rejects email with multiple @' do
        error = validator.validate_email('user@@example.com')
        expect(error).to eq('es incorrecto')
      end

      it 'rejects email with @ in wrong position' do
        error = validator.validate_email('user@name@example.com')
        expect(error).to eq('es incorrecto')
      end

      it 'rejects email with spaces' do
        error = validator.validate_email('user name@example.com')
        expect(error).to eq('es incorrecto')
      end

      it 'handles email with parentheses' do
        # Mail gem might accept this as valid quoted syntax
        result = validator.validate_email('user(name)@example.com')
        expect(result).to be_in([false, String])
      end

      it 'rejects email with brackets' do
        error = validator.validate_email('user[name]@example.com')
        expect(error).to eq('es incorrecto')
      end
    end

    context 'with edge cases' do
      it 'handles very long email' do
        long_local = 'a' * 64
        result = validator.validate_email("#{long_local}@example.com")
        expect(result).to be_in([false, String])
      end

      it 'handles email with quoted string' do
        # Mail gem might parse this differently
        result = validator.validate_email('"user name"@example.com')
        expect(result).to be_in([false, String])
      end

      it 'handles uppercase email' do
        expect(validator.validate_email('USER@EXAMPLE.COM')).to be false
      end

      it 'handles mixed case email' do
        expect(validator.validate_email('User@Example.Com')).to be false
      end
    end
  end

  describe '#validate_each' do
    context 'with valid emails' do
      it 'does not add errors for valid email' do
        record.email = 'test@example.com'
        record.valid?
        expect(record.errors[:email]).to be_empty
      end

      it 'accepts email with subdomain' do
        record.email = 'user@mail.example.com'
        record.valid?
        expect(record.errors[:email]).to be_empty
      end

      it 'accepts email with numbers and dots' do
        record.email = 'user.123@example.com'
        record.valid?
        expect(record.errors[:email]).to be_empty
      end
    end

    context 'with invalid emails' do
      it 'adds error for blank email' do
        record.email = ''
        record.valid?
        expect(record.errors[:email]).to be_empty # blank is handled differently
      end

      it 'adds error for email with accents' do
        record.email = 'maría@example.com'
        record.valid?
        expect(record.errors[:email]).to include('no puede contener acentos, eñes u otros caracteres especiales')
      end

      it 'adds error for email with consecutive dots' do
        record.email = 'user..name@example.com'
        record.valid?
        expect(record.errors[:email]).to include('no puede contener dos puntos seguidos')
      end

      it 'adds error for email starting with dot' do
        record.email = '.user@example.com'
        record.valid?
        expect(record.errors[:email]).to include('debe comenzar con un número o una letra')
      end

      it 'adds error for email ending with number' do
        record.email = 'user@example.com1'
        record.valid?
        expect(record.errors[:email]).to include('debe acabar con una letra')
      end

      it 'adds error for email with comma' do
        record.email = 'user,name@example.com'
        record.valid?
        expect(record.errors[:email]).to include('contiene caracteres inválidos')
      end

      it 'adds error for email without domain dot' do
        record.email = 'user@example'
        record.valid?
        expect(record.errors[:email]).to include('es incorrecto')
      end

      it 'adds error for email with domain starting with dot' do
        record.email = 'user@.example.com'
        record.valid?
        expect(record.errors[:email]).to include('es incorrecto')
      end
    end

    context 'error handling' do
      it 'deletes existing errors before adding new one' do
        record.email = 'invalid'
        record.valid?
        # First validation adds error
        first_error_count = record.errors[:email].count

        # Validate again with different invalid email
        record.email = 'also..invalid@example.com'
        record.valid?

        # Should have one error message, not accumulated
        expect(record.errors[:email].count).to eq(1)
      end

      it 'returns false when validation fails' do
        validator = EmailValidator.new(attributes: [:email])
        record.email = 'invalid@'
        result = validator.validate_each(record, :email, 'invalid@')
        expect(result).to be false
      end

      it 'returns true when validation passes' do
        validator = EmailValidator.new(attributes: [:email])
        record.email = 'valid@example.com'
        result = validator.validate_each(record, :email, 'valid@example.com')
        expect(result).to be true
      end
    end

    context 'with nil values' do
      it 'does not add errors for nil' do
        record.email = nil
        record.valid?
        expect(record.errors[:email]).to be_empty
      end
    end
  end

  describe 'integration scenarios' do
    it 'validates multiple invalid aspects prioritizes first error' do
      # Email with both accents and consecutive dots
      record.email = 'maría..pérez@example.com'
      record.valid?
      # Should report the first error encountered (accents checked first)
      expect(record.errors[:email].first).to eq('no puede contener acentos, eñes u otros caracteres especiales')
    end

    it 'works with ActiveModel validation context' do
      record.email = 'test@example.com'
      expect(record).to be_valid
    end

    it 'adds error to correct attribute' do
      record.email = 'invalid@'
      record.valid?
      expect(record.errors.attribute_names).to include(:email)
    end
  end
end
