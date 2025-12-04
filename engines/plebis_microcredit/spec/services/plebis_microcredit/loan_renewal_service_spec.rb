# frozen_string_literal: true

require 'rails_helper'
require 'ostruct'

module PlebisMicrocredit
  RSpec.describe LoanRenewalService, type: :service do
    let(:microcredit) { double('Microcredit', id: 1, has_finished?: false, renewable?: true) }
    let(:loan) do
      double('MicrocreditLoan',
             id: 1,
             microcredit_id: 1,
             microcredit: microcredit,
             document_vatid: '12345678A',
             unique_hash: 'abc123')
    end
    let(:current_user) { double('User', id: 1, document_vatid: '12345678A') }
    let(:params) { {} }

    subject { described_class.new(microcredit, params) }

    describe '#initialize' do
      it 'stores microcredit and params' do
        service = described_class.new(microcredit, { test: 'value' })
        expect(service.instance_variable_get(:@microcredit)).to eq(microcredit)
        expect(service.instance_variable_get(:@params)).to eq({ test: 'value' })
      end

      it 'handles empty params' do
        service = described_class.new(microcredit)
        expect(service.instance_variable_get(:@params)).to eq({})
      end
    end

    describe '#build_renewal' do
      let(:renewables_relation) { double('ActiveRecord::Relation') }
      let(:recently_renewed_relation) { double('ActiveRecord::Relation') }

      before do
        allow(PlebisMicrocredit::MicrocreditLoan).to receive(:renewables).and_return(renewables_relation)
        allow(PlebisMicrocredit::MicrocreditLoan).to receive(:recently_renewed).and_return(recently_renewed_relation)
        allow(renewables_relation).to receive(:where).and_return(renewables_relation)
        allow(recently_renewed_relation).to receive(:where).and_return(recently_renewed_relation)
        allow(renewables_relation).to receive(:first).and_return(loan)
        allow(recently_renewed_relation).to receive(:first).and_return(nil)
        allow(renewables_relation).to receive(:to_a).and_return([])
        allow(renewables_relation).to receive(:select).and_return([])
      end

      context 'with loan_id parameter' do
        it 'finds loan by ID' do
          expect(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by)
            .with(id: loan.id)
            .and_return(loan)

          subject.build_renewal(loan_id: loan.id, current_user: current_user)
        end

        it 'returns renewal object when loan found' do
          allow(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by).and_return(loan)

          result = subject.build_renewal(loan_id: loan.id, current_user: current_user)
          expect(result).to be_a(OpenStruct)
        end

        it 'returns nil when loan not found' do
          allow(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by).and_return(nil)

          result = subject.build_renewal(loan_id: 999)
          expect(result).to be_nil
        end
      end

      context 'with current_user parameter' do
        it 'finds renewable loans for user' do
          expect(renewables_relation).to receive(:where)
            .with(document_vatid: current_user.document_vatid)
            .and_return(renewables_relation)

          subject.build_renewal(current_user: current_user)
        end

        it 'falls back to recently renewed loans if no renewables' do
          allow(renewables_relation).to receive(:first).and_return(nil)
          expect(recently_renewed_relation).to receive(:where)
            .with(document_vatid: current_user.document_vatid)
            .and_return(recently_renewed_relation)

          subject.build_renewal(current_user: current_user)
        end

        it 'returns renewal object when loan found' do
          result = subject.build_renewal(current_user: current_user)
          expect(result).to be_a(OpenStruct)
        end
      end

      context 'without validate flag' do
        it 'initializes renewal with default values' do
          allow(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by).and_return(loan)

          result = subject.build_renewal(loan_id: loan.id, current_user: current_user, validate: false)

          expect(result.renewal_terms).to be false
          expect(result.terms_of_service).to be false
          expect(result.loan_renewals).to eq([])
        end

        it 'populates renewal data' do
          allow(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by).and_return(loan)

          result = subject.build_renewal(loan_id: loan.id, current_user: current_user, validate: false)

          expect(result).to respond_to(:loans)
          expect(result).to respond_to(:other_loans)
          expect(result).to respond_to(:recently_renewed_loans)
          expect(result).to respond_to(:errors)
        end
      end

      context 'with validate flag' do
        let(:params) do
          ActionController::Parameters.new(
            renewals: {
              renewal_terms: '1',
              terms_of_service: '1',
              loan_renewals: [loan.id.to_s]
            }
          )
        end

        subject { described_class.new(microcredit, params) }

        it 'extracts params using strong parameters' do
          allow(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by).and_return(loan)
          allow(renewables_relation).to receive(:select).and_return([loan])

          expect(params).to receive(:require).with(:renewals).and_call_original

          subject.build_renewal(loan_id: loan.id, current_user: current_user, validate: true)
        end

        it 'validates renewal data' do
          allow(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by).and_return(loan)
          allow(renewables_relation).to receive(:select).and_return([loan])

          result = subject.build_renewal(loan_id: loan.id, current_user: current_user, validate: true)

          expect(result.errors).to be_a(Hash)
          expect(result).to respond_to(:valid)
        end
      end

      context 'validation checks' do
        it 'returns nil when microcredit is nil' do
          service = described_class.new(nil, params)
          result = service.build_renewal(loan_id: loan.id)
          expect(result).to be_nil
        end

        it 'returns nil when microcredit has finished' do
          allow(microcredit).to receive(:has_finished?).and_return(true)
          allow(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by).and_return(loan)

          result = subject.build_renewal(loan_id: loan.id)
          expect(result).to be_nil
        end

        it 'returns nil when loan microcredit is not renewable' do
          allow(microcredit).to receive(:renewable?).and_return(false)
          allow(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by).and_return(loan)

          result = subject.build_renewal(loan_id: loan.id)
          expect(result).to be_nil
        end

        it 'returns nil when no current_user and hash does not match' do
          allow(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by).and_return(loan)
          service = described_class.new(microcredit, { hash: 'wrong_hash' })

          result = service.build_renewal(loan_id: loan.id)
          expect(result).to be_nil
        end

        it 'allows access with matching hash' do
          allow(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by).and_return(loan)
          service = described_class.new(microcredit, { hash: 'abc123' })

          result = service.build_renewal(loan_id: loan.id)
          expect(result).to be_a(OpenStruct)
        end
      end
    end

    describe '#find_initial_loan' do
      let(:renewables_relation) { double('ActiveRecord::Relation') }
      let(:recently_renewed_relation) { double('ActiveRecord::Relation') }

      before do
        allow(PlebisMicrocredit::MicrocreditLoan).to receive(:renewables).and_return(renewables_relation)
        allow(PlebisMicrocredit::MicrocreditLoan).to receive(:recently_renewed).and_return(recently_renewed_relation)
        allow(renewables_relation).to receive(:where).and_return(renewables_relation)
        allow(recently_renewed_relation).to receive(:where).and_return(recently_renewed_relation)
        allow(renewables_relation).to receive(:first).and_return(loan)
        allow(recently_renewed_relation).to receive(:first).and_return(nil)
      end

      it 'finds by loan_id when provided' do
        expect(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by)
          .with(id: loan.id)
          .and_return(loan)

        result = subject.send(:find_initial_loan, loan.id, nil)
        expect(result).to eq(loan)
      end

      it 'finds by current_user when loan_id not provided' do
        result = subject.send(:find_initial_loan, nil, current_user)
        expect(result).to eq(loan)
      end

      it 'returns nil when no loan_id or current_user' do
        result = subject.send(:find_initial_loan, nil, nil)
        expect(result).to be_nil
      end
    end

    describe '#valid_renewal_context?' do
      it 'returns false when microcredit is nil' do
        service = described_class.new(nil, params)
        result = service.send(:valid_renewal_context?, loan, current_user)
        expect(result).to be false
      end

      it 'returns false when microcredit has finished' do
        allow(microcredit).to receive(:has_finished?).and_return(true)
        result = subject.send(:valid_renewal_context?, loan, current_user)
        expect(result).to be false
      end

      it 'returns false when loan is nil' do
        result = subject.send(:valid_renewal_context?, nil, current_user)
        expect(result).to be false
      end

      it 'returns false when loan microcredit is not renewable' do
        allow(loan).to receive(:microcredit).and_return(microcredit)
        allow(microcredit).to receive(:renewable?).and_return(false)
        result = subject.send(:valid_renewal_context?, loan, current_user)
        expect(result).to be false
      end

      it 'returns false when no current_user and hash mismatch' do
        service = described_class.new(microcredit, { hash: 'wrong' })
        result = service.send(:valid_renewal_context?, loan, nil)
        expect(result).to be false
      end

      it 'returns true with current_user' do
        result = subject.send(:valid_renewal_context?, loan, current_user)
        expect(result).to be true
      end

      it 'returns true with matching hash' do
        service = described_class.new(microcredit, { hash: 'abc123' })
        result = service.send(:valid_renewal_context?, loan, nil)
        expect(result).to be true
      end
    end

    describe '#initialize_renewal' do
      context 'with validate false' do
        it 'returns OpenStruct with default values' do
          result = subject.send(:initialize_renewal, false)

          expect(result).to be_a(OpenStruct)
          expect(result.renewal_terms).to be false
          expect(result.terms_of_service).to be false
          expect(result.loan_renewals).to eq([])
        end
      end

      context 'with validate true' do
        let(:params) do
          ActionController::Parameters.new(
            renewals: {
              renewal_terms: '1',
              terms_of_service: '1',
              loan_renewals: ['1', '2']
            }
          )
        end

        subject { described_class.new(microcredit, params) }

        it 'extracts permitted params' do
          result = subject.send(:initialize_renewal, true)

          expect(result).to be_a(OpenStruct)
          expect(result.renewal_terms).to eq('1')
          expect(result.terms_of_service).to eq('1')
          expect(result.loan_renewals).to eq(['1', '2'])
        end
      end
    end

    describe '#populate_renewal_data' do
      let(:renewal) { OpenStruct.new(loan_renewals: [loan.id.to_s]) }
      let(:renewables_relation) { double('ActiveRecord::Relation') }
      let(:other_loan) { double('MicrocreditLoan', id: 2, microcredit_id: 2, document_vatid: '12345678A') }
      let(:recently_renewed) { double('MicrocreditLoan', id: 3, microcredit_id: 1, document_vatid: '12345678A') }

      before do
        allow(PlebisMicrocredit::MicrocreditLoan).to receive(:renewables).and_return(renewables_relation)
        allow(PlebisMicrocredit::MicrocreditLoan).to receive(:recently_renewed).and_return(renewables_relation)
        allow(renewables_relation).to receive(:where).and_return(renewables_relation)
        allow(renewables_relation).to receive(:to_a).and_return([other_loan])
        allow(renewables_relation).to receive(:uniq).and_return([other_loan])
        allow(renewables_relation).to receive(:first).and_return(loan)
        allow(renewables_relation).to receive(:select).and_return([loan])
      end

      it 'populates loans for same microcredit' do
        expect(renewables_relation).to receive(:where)
          .with(microcredit_id: loan.microcredit_id, document_vatid: loan.document_vatid)
          .and_return(renewables_relation)

        subject.send(:populate_renewal_data, renewal, loan)
        expect(renewal.loans).to be_present
      end

      it 'filters selected loan renewals' do
        subject.send(:populate_renewal_data, renewal, loan)
        expect(renewal.loan_renewals).to eq([loan])
      end

      it 'populates other loans from different microcredits' do
        allow(renewables_relation).to receive(:where).and_call_original
        allow(renewables_relation).to receive(:where)
          .with(microcredit_id: loan.microcredit_id, document_vatid: loan.document_vatid)
          .and_return(renewables_relation)

        other_relation = double('ActiveRecord::Relation')
        allow(renewables_relation).to receive(:where).and_return(other_relation)
        allow(other_relation).to receive(:where).with(document_vatid: loan.document_vatid).and_return(other_relation)
        allow(other_relation).to receive(:to_a).and_return([other_loan])
        allow(other_relation).to receive(:uniq).and_return([other_loan])

        subject.send(:populate_renewal_data, renewal, loan)
        expect(renewal).to respond_to(:other_loans)
      end

      it 'populates recently renewed loans' do
        recently_renewed_relation = double('ActiveRecord::Relation')
        allow(PlebisMicrocredit::MicrocreditLoan).to receive(:recently_renewed)
          .and_return(recently_renewed_relation)
        allow(recently_renewed_relation).to receive(:where).and_return(recently_renewed_relation)

        subject.send(:populate_renewal_data, renewal, loan)
        expect(renewal).to respond_to(:recently_renewed_loans)
      end

      it 'sets primary loan from loans or recently renewed' do
        subject.send(:populate_renewal_data, renewal, loan)
        expect(renewal.loan).to eq(loan)
      end

      it 'initializes empty errors hash' do
        subject.send(:populate_renewal_data, renewal, loan)
        expect(renewal.errors).to eq({})
      end
    end

    describe '#validate_renewal' do
      let(:renewal) do
        OpenStruct.new(
          renewal_terms: '1',
          terms_of_service: '1',
          loan_renewals: [loan],
          errors: {}
        )
      end

      it 'adds error when renewal_terms not accepted' do
        renewal.renewal_terms = '0'
        subject.send(:validate_renewal, renewal)

        expect(renewal.errors[:renewal_terms]).to be_present
        expect(renewal.valid).to be false
      end

      it 'adds error when terms_of_service not accepted' do
        renewal.terms_of_service = '0'
        subject.send(:validate_renewal, renewal)

        expect(renewal.errors[:terms_of_service]).to be_present
        expect(renewal.valid).to be false
      end

      it 'adds error when no loans selected' do
        renewal.loan_renewals = []
        subject.send(:validate_renewal, renewal)

        expect(renewal.errors[:loan_renewals]).to be_present
        expect(renewal.valid).to be false
      end

      it 'sets valid to true when all validations pass' do
        subject.send(:validate_renewal, renewal)

        expect(renewal.errors).to be_empty
        expect(renewal.valid).to be true
      end

      it 'sets valid to false when any validation fails' do
        renewal.renewal_terms = '0'
        subject.send(:validate_renewal, renewal)

        expect(renewal.valid).to be false
      end
    end

    describe 'OpenStruct extension' do
      it 'adds human_attribute_name method' do
        expect(OpenStruct).to respond_to(:human_attribute_name)
      end

      it 'translates attribute names' do
        allow(I18n).to receive(:t).with('formtastic.labels.test_field').and_return('Campo de Prueba')
        result = OpenStruct.human_attribute_name(:test_field)
        expect(result).to eq('Campo de Prueba')
      end
    end

    describe 'integration scenarios' do
      let(:renewables_relation) { double('ActiveRecord::Relation') }
      let(:params) do
        ActionController::Parameters.new(
          renewals: {
            renewal_terms: '1',
            terms_of_service: '1',
            loan_renewals: [loan.id.to_s]
          }
        )
      end

      before do
        allow(PlebisMicrocredit::MicrocreditLoan).to receive(:renewables).and_return(renewables_relation)
        allow(PlebisMicrocredit::MicrocreditLoan).to receive(:recently_renewed).and_return(renewables_relation)
        allow(PlebisMicrocredit::MicrocreditLoan).to receive(:find_by).and_return(loan)
        allow(renewables_relation).to receive(:where).and_return(renewables_relation)
        allow(renewables_relation).to receive(:first).and_return(loan)
        allow(renewables_relation).to receive(:to_a).and_return([])
        allow(renewables_relation).to receive(:uniq).and_return([])
        allow(renewables_relation).to receive(:select).and_return([loan])
      end

      it 'completes full renewal flow with validation' do
        service = described_class.new(microcredit, params)
        result = service.build_renewal(loan_id: loan.id, current_user: current_user, validate: true)

        expect(result).to be_a(OpenStruct)
        expect(result.renewal_terms).to eq('1')
        expect(result.terms_of_service).to eq('1')
        expect(result.valid).to be true
      end

      it 'fails validation with missing terms' do
        invalid_params = ActionController::Parameters.new(
          renewals: {
            renewal_terms: '0',
            terms_of_service: '0',
            loan_renewals: []
          }
        )

        service = described_class.new(microcredit, invalid_params)
        allow(renewables_relation).to receive(:select).and_return([])
        result = service.build_renewal(loan_id: loan.id, current_user: current_user, validate: true)

        expect(result.valid).to be false
        expect(result.errors.keys).to include(:renewal_terms, :terms_of_service, :loan_renewals)
      end
    end
  end
end
