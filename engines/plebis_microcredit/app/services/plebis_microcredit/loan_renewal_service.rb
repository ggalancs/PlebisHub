# frozen_string_literal: true

require 'ostruct'

module PlebisMicrocredit
  # Service object to handle microcredit loan renewals
  # Extracts renewal logic from MicrocreditController
  class LoanRenewalService
    def initialize(microcredit, params = {})
      @microcredit = microcredit
      @params = params
    end

    def build_renewal(loan_id: nil, current_user: nil, validate: false)
      loan = find_initial_loan(loan_id, current_user)
      return nil unless valid_renewal_context?(loan, current_user)

      renewal = initialize_renewal(validate)
      populate_renewal_data(renewal, loan)
      validate_renewal(renewal) if validate

      renewal
    end

    private

    def find_initial_loan(loan_id, current_user)
      if loan_id
        PlebisMicrocredit::MicrocreditLoan.find_by(id: loan_id)
      elsif current_user
        PlebisMicrocredit::MicrocreditLoan.renewables.where(document_vatid: current_user.document_vatid).first ||
          PlebisMicrocredit::MicrocreditLoan.recently_renewed.where(document_vatid: current_user.document_vatid).first
      end
    end

    def valid_renewal_context?(loan, current_user)
      return false unless @microcredit && !@microcredit.has_finished?
      return false unless loan&.microcredit&.renewable?
      return false unless current_user || loan.unique_hash == @params[:hash]

      true
    end

    def initialize_renewal(validate)
      if validate
        OpenStruct.new(@params.require(:renewals).permit(:renewal_terms, :terms_of_service, loan_renewals: []))
      else
        OpenStruct.new(renewal_terms: false, terms_of_service: false, loan_renewals: [])
      end
    end

    def populate_renewal_data(renewal, loan)
      renewal.loans = PlebisMicrocredit::MicrocreditLoan.renewables.where(
        microcredit_id: loan.microcredit_id,
        document_vatid: loan.document_vatid
      )

      renewal.loan_renewals = renewal.loans.select { |l| renewal.loan_renewals.member?(l.id.to_s) }

      renewal.other_loans = PlebisMicrocredit::MicrocreditLoan.renewables
                                                              .where.not(microcredit_id: loan.microcredit_id)
                                                              .where(document_vatid: loan.document_vatid)
                                                              .to_a
                                                              .uniq(&:microcredit_id)

      renewal.recently_renewed_loans = PlebisMicrocredit::MicrocreditLoan.recently_renewed.where(
        microcredit_id: loan.microcredit_id,
        document_vatid: loan.document_vatid
      )

      renewal.loan = renewal.loans.first || renewal.recently_renewed_loans.first
      renewal.errors = {}
    end

    def validate_renewal(renewal)
      renewal.errors[:renewal_terms] = I18n.t('errors.messages.accepted') if renewal.renewal_terms == '0'
      renewal.errors[:terms_of_service] = I18n.t('errors.messages.accepted') if renewal.terms_of_service == '0'
      renewal.errors[:loan_renewals] = I18n.t('microcredit.loans_renewal.none_selected') if renewal.loan_renewals.empty?
      renewal.valid = renewal.errors.empty?
    end
  end
end

# Extend OpenStruct to work with formtastic forms
class OpenStruct
  def self.human_attribute_name(name)
    I18n.t("formtastic.labels.#{name}")
  end
end
