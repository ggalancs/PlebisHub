# frozen_string_literal: true

# Collaboration concern for payment methods and bank account handling
module Collaboration::PaymentMethods
  extend ActiveSupport::Concern

  included do
    # Validations for bank accounts
    validates :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, numericality: true, if: :has_ccc_account?
    validates :ccc_entity, :ccc_office, :ccc_dc, :ccc_account, presence: true, if: :has_ccc_account?
    validate :validates_ccc, if: :has_ccc_account?

    validates :iban_account, presence: true, if: :has_iban_account?
    validate :validates_iban, if: :has_iban_account?

    # Callbacks
    before_save :check_spanish_bic
  end

  # Payment type checks
  def is_credit_card?
    payment_type == 1
  end

  def is_bank?
    payment_type != 1
  end

  def is_bank_national?
    is_bank? && !is_bank_international?
  end

  def is_bank_international?
    has_iban_account? && !iban_account.start_with?('ES')
  end

  def has_ccc_account?
    payment_type == 2
  end

  def has_iban_account?
    payment_type == 3
  end

  def payment_type_name
    Order::PAYMENT_TYPES.invert[payment_type]
  end

  # Bank account validations
  def validates_ccc
    return unless ccc_entity && ccc_office && ccc_dc && ccc_account
    return if BankCccValidator.validate(ccc_full.to_s)

    errors.add(:ccc_dc, 'Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.')
  end

  def iban_valid?
    return false if iban_account.nil?

    iban_account.strip!
    iban_validation = IBANTools::IBAN.valid?(iban_account)
    ccc_validation = iban_account&.start_with?('ES') ? BankCccValidator.validate(iban_account[4..]) : true
    iban_validation && ccc_validation
  end

  def validates_iban
    return if iban_valid?

    errors.add(:iban_account, 'Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.')
    self.iban_bic = nil
  end

  # Bank account formatting
  def ccc_full
    return unless ccc_entity && ccc_office && ccc_dc && ccc_account

    format('%04d%04d%02d%010d', ccc_entity, ccc_office, ccc_dc, ccc_account)
  end

  def pretty_ccc_full
    format('%04d %04d %02d %010d', ccc_entity, ccc_office, ccc_dc, ccc_account) if ccc_account
  end

  def calculate_iban
    iban = nil
    if iban_account.blank? && ccc_account.present?
      ccc = ccc_full
      iban = 98 - ("#{ccc}142800".to_i % 97)
      iban = "ES#{iban.to_s.rjust(2, '0')}#{ccc}"
    end
    iban = iban_account.gsub(' ', '') if iban.nil? && iban_account.present?
    iban
  end

  def calculate_bic
    clean_iban = calculate_iban
    bic = Podemos::SpanishBIC[clean_iban[4..7].to_i] if !bic && clean_iban.present? && (clean_iban[0..1] == 'ES')
    bic = iban_bic.gsub(' ', '') if !bic && iban_bic.present?
    bic
  end

  def check_spanish_bic
    set_warning! 'Marcada como alerta porque el número de cuenta indica un código de entidad inválido o no encontrado en la base de datos de BICs españoles.' if [
      2, 3
    ].include?(status) && is_bank_national? && calculate_bic.nil?
  end

  # Payment identifier for orders
  def payment_identifier
    if is_credit_card?
      redsys_identifier
    elsif has_ccc_account?
      "#{calculate_iban}/#{calculate_bic}"
    else
      "#{iban_account}/#{iban_bic}"
    end
  end

  # Payment processing
  def payment_processed!(order)
    if order.is_paid?
      if order.has_warnings?
        set_warning! 'Marcada como alerta porque se han producido alertas al procesar el pago.'
      else
        set_ok!
      end

      if is_credit_card? && order.first
        update(redsys_identifier: order.payment_identifier, redsys_expiration: order.redsys_expiration)
      end
    elsif has_payment?
      set_error! 'Marcada como error porque se ha producido un error al procesar el pago.'
    end
  end

  # Class methods
  module ClassMethods
    def available_payment_types(collaboration)
      types = [[t('podemos.collaboration.credit_card'), 1]]

      # Allow SEPA if user has a Spanish phone or is from Spain
      if collaboration.user&.phone_prefix.to_s == '34' || collaboration.user&.country == 'ES'
        types << [t('podemos.collaboration.bank_national'), 2]
      end

      # Allow international SEPA
      types << [t('podemos.collaboration.bank_international'), 3]

      types
    end
  end
end
