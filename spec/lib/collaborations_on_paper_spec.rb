# frozen_string_literal: true

require 'rails_helper'
require 'collaborations_on_paper'

RSpec.describe CollaborationsOnPaper do
  let(:csv_file) { Rails.root.join('spec/fixtures/files/collaborations.csv') }
  let(:user) { create(:user, :with_dni, email: 'test@example.com', document_vatid: '12345678Z', first_name: 'Juan', last_name_1: 'García') }

  before do
    # Create CSV file for testing
    FileUtils.mkdir_p(File.dirname(csv_file))
    CSV.open(csv_file, 'w', col_sep: "\t") do |csv|
      csv << ['NOMBRE', 'APELLIDO 1', 'APELLIDO 2', 'DNI', 'FECHA DE NACIMIENTO', 'TELEFONO MOVIL',
              'EMAIL', 'GENERO', 'DOMICILIO', 'MUNICIPIO', 'CODIGO POSTAL', 'PROVINCIA',
              'IMPORTE MENSUAL', 'CODIGO IBAN', 'BIC/SWIFT', 'ENTIDAD', 'OFICINA', 'CC',
              'CUENTA', 'MUNICIPIO INE', 'FINANCIACION TERRITORIAL', 'METODO DE PAGO',
              'FRECUENCIA DE PAGO', 'CREADO']
      csv << ['Juan', 'García', 'López', '12345678Z', '01/01/1980', '600123456',
              'test@example.com', 'M', 'Calle Principal 1', 'Madrid', '28001', 'Madrid',
              '10', 'ES0000000000000000000000', 'BANKESMMXXX', '1234', '5678', '90',
              '1234567890', '28079', 'CCM', '2', '1', '2024-01-01']
    end
  end

  after do
    FileUtils.rm_f(csv_file)
  end

  describe '#initialize' do
    context 'with valid CSV data' do
      before { user }

      it 'processes the CSV file' do
        processor = described_class.new(csv_file)
        expect(processor.collaborations_processed).not_to be_empty
      end

      it 'creates results for each row' do
        processor = described_class.new(csv_file)
        expect(processor.results).not_to be_empty
      end

      it 'tracks processed collaborations' do
        processor = described_class.new(csv_file)
        expect(processor.collaborations_processed.first).to be_a(Collaboration)
      end
    end

    context 'with custom column separator' do
      let(:csv_comma) { Rails.root.join('spec/fixtures/files/collaborations_comma.csv') }

      before do
        CSV.open(csv_comma, 'w', col_sep: ',') do |csv|
          csv << ['NOMBRE', 'APELLIDO 1', 'APELLIDO 2', 'DNI', 'EMAIL', 'IMPORTE MENSUAL',
                  'ENTIDAD', 'OFICINA', 'CC', 'CUENTA']
          csv << ['Test', 'User', 'Last', '12345678Z', 'test@example.com', '10',
                  '1234', '5678', '90', '1234567890']
        end
        user
      end

      after { FileUtils.rm_f(csv_comma) }

      it 'accepts custom column separator' do
        processor = described_class.new(csv_comma, ',')
        expect(processor.collaborations_processed).not_to be_empty
      end
    end
  end

  describe '#all_ok?' do
    before { user }

    it 'returns true when all results are ok' do
      processor = described_class.new(csv_file)
      expect(processor.all_ok?).to be true
    end

    context 'with errors' do
      let(:error_csv) { Rails.root.join('spec/fixtures/files/collaborations_error.csv') }

      before do
        CSV.open(error_csv, 'w', col_sep: "\t") do |csv|
          csv << ['NOMBRE', 'APELLIDO 1', 'APELLIDO 2', 'DNI', 'EMAIL', 'IMPORTE MENSUAL',
                  'ENTIDAD', 'OFICINA', 'CC', 'CUENTA']
          csv << ['Test', 'User', 'Last', 'INVALID_DNI', 'test@example.com', '10',
                  '1234', '5678', '90', '1234567890']
        end
      end

      after { FileUtils.rm_f(error_csv) }

      it 'returns false when errors exist' do
        processor = described_class.new(error_csv)
        expect(processor.all_ok?).to be false
      end
    end
  end

  describe '#has_errors_on_save?' do
    before { user }

    it 'returns false when no save errors' do
      processor = described_class.new(csv_file)
      expect(processor.has_errors_on_save?).to be false
    end

    context 'with save errors' do
      it 'returns true when save errors exist' do
        processor = described_class.new(csv_file)
        # Mock a collaboration to fail save
        allow_any_instance_of(Collaboration).to receive(:valid?).and_return(false)
        allow_any_instance_of(Collaboration).to receive(:errors).and_return(
          double(messages: { amount: ['is invalid'] })
        )
        processor.instance_variable_set(:@errors_on_save, [['error', 'row']])
        expect(processor.has_errors_on_save?).to be true
      end
    end
  end

  describe 'constants' do
    it 'defines DEFAULT_STATUS' do
      expect(described_class::DEFAULT_STATUS).to eq(2)
    end

    it 'defines DEFAULT_COUNTRY' do
      expect(described_class::DEFAULT_COUNTRY).to eq('ES')
    end

    it 'defines SUPPORT_FOR_TOWN' do
      expect(described_class::SUPPORT_FOR_TOWN).to eq('CCM')
    end

    it 'defines SUPPORT_FOR_AUTONOMY' do
      expect(described_class::SUPPORT_FOR_AUTONOMY).to eq('CCA')
    end

    it 'defines SUPPORT_FOR_COUNTRY' do
      expect(described_class::SUPPORT_FOR_COUNTRY).to eq('CCE')
    end

    it 'defines SUPPORT_FOR_ISLAND' do
      expect(described_class::SUPPORT_FOR_ISLAND).to eq('CCI')
    end
  end

  describe 'field processing' do
    let(:processor) { described_class.new(csv_file) }

    before { user }

    it 'processes document_vatid field' do
      collaboration = processor.collaborations_processed.first
      expect(collaboration).to respond_to(:user)
    end

    it 'processes amount field and converts to cents' do
      collaboration = processor.collaborations_processed.first
      expect(collaboration.amount).to eq(1000) # 10 * 100
    end

    it 'sets default payment_type when not provided' do
      collaboration = processor.collaborations_processed.first
      expect(collaboration.payment_type).to be_present
    end

    it 'sets default frequency when not provided' do
      collaboration = processor.collaborations_processed.first
      expect(collaboration.frequency).to eq(1)
    end

    it 'processes created_at timestamp' do
      collaboration = processor.collaborations_processed.first
      expect(collaboration.created_at).to be_a(DateTime)
    end
  end

  describe 'donation type processing' do
    let(:processor) { described_class.new(csv_file) }

    before { user }

    context 'with SUPPORT_FOR_TOWN' do
      it 'sets for_town_cc flag' do
        collaboration = processor.collaborations_processed.first
        expect(collaboration.for_town_cc).to be true
      end
    end

    context 'with SUPPORT_FOR_AUTONOMY' do
      let(:autonomy_csv) { Rails.root.join('spec/fixtures/files/collaborations_autonomy.csv') }

      before do
        CSV.open(autonomy_csv, 'w', col_sep: "\t") do |csv|
          csv << ['NOMBRE', 'APELLIDO 1', 'APELLIDO 2', 'DNI', 'EMAIL', 'IMPORTE MENSUAL',
                  'ENTIDAD', 'OFICINA', 'CC', 'CUENTA', 'FINANCIACION TERRITORIAL']
          csv << ['Juan', 'García', 'López', '12345678Z', 'test@example.com', '10',
                  '1234', '5678', '90', '1234567890', 'CCA']
        end
      end

      after { FileUtils.rm_f(autonomy_csv) }

      it 'sets for_autonomy_cc flag' do
        processor = described_class.new(autonomy_csv)
        collaboration = processor.collaborations_processed.first
        expect(collaboration.for_autonomy_cc).to be true
      end
    end

    context 'with SUPPORT_FOR_COUNTRY' do
      let(:country_csv) { Rails.root.join('spec/fixtures/files/collaborations_country.csv') }

      before do
        CSV.open(country_csv, 'w', col_sep: "\t") do |csv|
          csv << ['NOMBRE', 'APELLIDO 1', 'APELLIDO 2', 'DNI', 'EMAIL', 'IMPORTE MENSUAL',
                  'ENTIDAD', 'OFICINA', 'CC', 'CUENTA', 'FINANCIACION TERRITORIAL']
          csv << ['Juan', 'García', 'López', '12345678Z', 'test@example.com', '10',
                  '1234', '5678', '90', '1234567890', 'CCE']
        end
      end

      after { FileUtils.rm_f(country_csv) }

      it 'sets all flags to false for country support' do
        processor = described_class.new(country_csv)
        collaboration = processor.collaborations_processed.first
        expect(collaboration.for_town_cc).to be false
        expect(collaboration.for_island_cc).to be false
        expect(collaboration.for_autonomy_cc).to be false
      end
    end

    context 'with SUPPORT_FOR_ISLAND' do
      let(:island_csv) { Rails.root.join('spec/fixtures/files/collaborations_island.csv') }

      before do
        CSV.open(island_csv, 'w', col_sep: "\t") do |csv|
          csv << ['NOMBRE', 'APELLIDO 1', 'APELLIDO 2', 'DNI', 'EMAIL', 'IMPORTE MENSUAL',
                  'ENTIDAD', 'OFICINA', 'CC', 'CUENTA', 'FINANCIACION TERRITORIAL']
          csv << ['Juan', 'García', 'López', '12345678Z', 'test@example.com', '10',
                  '1234', '5678', '90', '1234567890', 'CCI']
        end
      end

      after { FileUtils.rm_f(island_csv) }

      it 'sets for_island_cc flag' do
        processor = described_class.new(island_csv)
        collaboration = processor.collaborations_processed.first
        expect(collaboration.for_island_cc).to be true
      end
    end
  end

  describe 'user matching' do
    context 'with existing user by email' do
      before { user }

      it 'associates collaboration with user' do
        processor = described_class.new(csv_file)
        collaboration = processor.collaborations_processed.first
        expect(collaboration.user).to eq(user)
      end

      it 'marks result as ok' do
        processor = described_class.new(csv_file)
        expect(processor.results.first[1]).to eq(:ok)
      end
    end

    context 'with existing user by document_vatid' do
      let(:vatid_user) { create(:user, :with_dni, email: 'different@example.com', document_vatid: '12345678Z', first_name: 'Juan', last_name_1: 'García') }
      let(:different_csv) { Rails.root.join('spec/fixtures/files/collaborations_vatid.csv') }

      before do
        vatid_user
        CSV.open(different_csv, 'w', col_sep: "\t") do |csv|
          csv << ['NOMBRE', 'APELLIDO 1', 'APELLIDO 2', 'DNI', 'EMAIL', 'IMPORTE MENSUAL',
                  'ENTIDAD', 'OFICINA', 'CC', 'CUENTA']
          csv << ['Juan', 'García', 'López', '12345678Z', 'other@example.com', '10',
                  '1234', '5678', '90', '1234567890']
        end
      end

      after { FileUtils.rm_f(different_csv) }

      it 'finds user by document_vatid when email does not match' do
        processor = described_class.new(different_csv)
        collaboration = processor.collaborations_processed.first
        expect(collaboration.user).to eq(vatid_user)
      end
    end

    context 'without existing user' do
      let(:new_user_csv) { Rails.root.join('spec/fixtures/files/collaborations_new_user.csv') }

      before do
        CSV.open(new_user_csv, 'w', col_sep: "\t") do |csv|
          csv << ['NOMBRE', 'APELLIDO 1', 'APELLIDO 2', 'DNI', 'EMAIL', 'IMPORTE MENSUAL',
                  'ENTIDAD', 'OFICINA', 'CC', 'CUENTA', 'TELEFONO MOVIL', 'DOMICILIO',
                  'MUNICIPIO', 'CODIGO POSTAL', 'PROVINCIA', 'GENERO', 'MUNICIPIO INE']
          csv << ['Pedro', 'Martínez', 'Ruiz', '87654321A', 'newuser@example.com', '20',
                  '1234', '5678', '90', '1234567890', '600123456', 'Calle Nueva 1',
                  'Barcelona', '08001', 'Barcelona', 'M', '08019']
        end
      end

      after { FileUtils.rm_f(new_user_csv) }

      it 'creates collaboration without user' do
        processor = described_class.new(new_user_csv)
        collaboration = processor.collaborations_processed.first
        expect(collaboration.user).to be_nil
      end

      it 'marks result as ok_non_user' do
        processor = described_class.new(new_user_csv)
        expect(processor.results.first[1]).to eq(:ok_non_user)
      end

      it 'stores non-user information' do
        processor = described_class.new(new_user_csv)
        collaboration = processor.collaborations_processed.first
        expect(collaboration.non_user_document_vatid).to eq('87654321A')
        expect(collaboration.non_user_email).to eq('newuser@example.com')
      end
    end
  end

  describe 'validation error handling' do
    context 'with invalid DNI' do
      let(:invalid_csv) { Rails.root.join('spec/fixtures/files/collaborations_invalid.csv') }

      before do
        CSV.open(invalid_csv, 'w', col_sep: "\t") do |csv|
          csv << ['NOMBRE', 'APELLIDO 1', 'APELLIDO 2', 'DNI', 'EMAIL', 'IMPORTE MENSUAL',
                  'ENTIDAD', 'OFICINA', 'CC', 'CUENTA']
          csv << ['Test', 'User', 'Last', 'INVALID', 'test@example.com', '10',
                  '1234', '5678', '90', '1234567890']
        end
      end

      after { FileUtils.rm_f(invalid_csv) }

      it 'adds error for invalid DNI' do
        processor = described_class.new(invalid_csv)
        expect(processor.results.first[1]).to eq(:vatid_invalid)
      end

      it 'pushes nil to collaborations_processed' do
        processor = described_class.new(invalid_csv)
        expect(processor.collaborations_processed.first).to be_nil
      end
    end
  end

  describe 'logging' do
    before { user }

    context 'with logging enabled' do
      it 'can enable logging to file' do
        processor = described_class.new(csv_file)
        processor.logging_to_file = true
        expect(processor.logging_to_file).to be true
      end

      it 'defaults logging to false' do
        processor = described_class.new(csv_file)
        expect(processor.logging_to_file).to be false
      end
    end
  end

  describe 'bank account processing' do
    before { user }

    it 'processes CCC fields' do
      processor = described_class.new(csv_file)
      collaboration = processor.collaborations_processed.first
      expect(collaboration.ccc_entity).to eq('1234')
      expect(collaboration.ccc_office).to eq('5678')
      expect(collaboration.ccc_dc).to eq('90')
      expect(collaboration.ccc_account).to eq('1234567890')
    end

    it 'calculates IBAN from CCC' do
      processor = described_class.new(csv_file)
      collaboration = processor.collaborations_processed.first
      expect(collaboration.iban_account).to be_present
    end

    it 'calculates BIC from CCC' do
      processor = described_class.new(csv_file)
      collaboration = processor.collaborations_processed.first
      expect(collaboration.iban_bic).to be_present
    end
  end

  describe 'full name validation' do
    let(:mismatch_user) { create(:user, :with_dni, email: 'mismatch@example.com', document_vatid: '12345678Z', first_name: 'Wrong', last_name_1: 'Name') }
    let(:mismatch_csv) { Rails.root.join('spec/fixtures/files/collaborations_mismatch.csv') }

    before do
      mismatch_user
      CSV.open(mismatch_csv, 'w', col_sep: "\t") do |csv|
        csv << ['NOMBRE', 'APELLIDO 1', 'APELLIDO 2', 'DNI', 'EMAIL', 'IMPORTE MENSUAL',
                'ENTIDAD', 'OFICINA', 'CC', 'CUENTA']
        csv << ['Juan', 'García', 'López', '12345678Z', 'test@example.com', '10',
                '1234', '5678', '90', '1234567890']
      end
    end

    after { FileUtils.rm_f(mismatch_csv) }

    it 'validates full name matches' do
      processor = described_class.new(mismatch_csv)
      result = processor.results.first
      # The full name doesn't match, so it should add an error
      expect(result[1]).to eq(:vatid_invalid)
    end
  end

  describe 'integration' do
    before { user }

    it 'completes full processing cycle' do
      processor = described_class.new(csv_file)
      expect(processor.all_ok?).to be true
      expect(processor.collaborations_processed).not_to be_empty
      expect(processor.results).not_to be_empty
      expect(processor.has_errors_on_save?).to be false
    end

    it 'saves collaborations when all ok' do
      expect do
        described_class.new(csv_file)
      end.to change(Collaboration, :count)
    end
  end
end
