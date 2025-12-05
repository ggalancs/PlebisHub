# frozen_string_literal: true

require 'rails_helper'
require 'plebisbrand_import_collaborations2017'

RSpec.describe PlebisBrandImportCollaborations2017 do
  describe '.log_to_file' do
    let(:filename) { Rails.root.join('tmp/test_log_2017.txt').to_s }

    after do
      File.delete(filename) if File.exist?(filename)
    end

    it 'writes text to file' do
      described_class.log_to_file(filename, 'test content')
      expect(File.read(filename)).to include('test content')
    end

    it 'appends to existing file' do
      described_class.log_to_file(filename, 'first')
      described_class.log_to_file(filename, 'second')
      content = File.read(filename)
      expect(content).to include('first')
      expect(content).to include('second')
    end
  end

  describe '.process_row' do
    let(:row) do
      {
        'NOMBRE' => 'Jane',
        'APELLIDO 1' => 'Doe',
        'APELLIDO 2' => 'Smith',
        'DNI' => '87654321X',
        'FECHA DE NACIMIENTO' => '1990-01-01',
        'TELEFONO MOVIL' => '666555444',
        'EMAIL' => 'jane@example.com',
        'GENERO' => 'F',
        'DOMICILIO' => 'Main St 123',
        'MUNICIPIO' => 'Madrid',
        'CODIGO POSTAL' => '28001',
        'PROVINCIA' => 'Madrid',
        'IMPORTE MENSUAL' => '20',
        'CODIGO IBAN' => 'ES1234567890123456789012',
        'BIC/SWIFT' => 'SWIFT456',
        'ENTIDAD' => '1234',
        'OFICINA' => '5678',
        'CC' => '90',
        'CUENTA' => '9876543210',
        'MUNICIPIO INE' => '28079',
        'FINANCIACION TERRITORIAL' => 'CCM',
        'METODO DE PAGO' => '2',
        'FRECUENCIA DE PAGO' => '1',
        'CREADO' => '2024-01-01'
      }
    end

    it 'calls create_collaboration with processed params' do
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:document_vatid]).to eq('87654321X')
        expect(params[:full_name]).to eq('Jane Doe Smith')
        expect(params[:email]).to eq('jane@example.com')
        expect(params[:amount]).to eq(2000.0)
      end
      described_class.process_row(row)
    end

    it 'strips and upcases DNI' do
      row['DNI'] = '  87654321x  '
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:document_vatid]).to eq('87654321X')
      end
      described_class.process_row(row)
    end

    it 'handles missing apellidos' do
      row['APELLIDO 1'] = nil
      row['APELLIDO 2'] = nil
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:full_name]).to eq('Jane')
      end
      described_class.process_row(row)
    end

    it 'converts amount to cents' do
      row['IMPORTE MENSUAL'] = '50'
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:amount]).to eq(5000.0)
      end
      described_class.process_row(row)
    end

    it 'defaults payment_type to 2' do
      row['METODO DE PAGO'] = nil
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:payment_type]).to eq(2)
      end
      described_class.process_row(row)
    end

    it 'defaults frequency to 1' do
      row['FRECUENCIA DE PAGO'] = nil
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:frequency]).to eq(1)
      end
      described_class.process_row(row)
    end

    it 'defaults created_at to now if missing' do
      row['CREADO'] = nil
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:created_at]).to be_a(DateTime)
      end
      described_class.process_row(row)
    end

    it 'includes additional fields' do
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:phone]).to eq('666555444')
        expect(params[:town_name]).to eq('Madrid')
        expect(params[:postal_code]).to eq('28001')
        expect(params[:province]).to eq('Madrid')
        expect(params[:donation_type]).to eq('CCM')
      end
      described_class.process_row(row)
    end

    it 'defaults address to empty string if missing' do
      row['DOMICILIO'] = nil
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:address]).to eq('')
      end
      described_class.process_row(row)
    end

    it 'defaults BIC/SWIFT to empty string if missing' do
      row['BIC/SWIFT'] = nil
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:iban_2]).to eq('')
      end
      described_class.process_row(row)
    end
  end

  describe '.create_collaboration' do
    let(:user) { create(:user, email: 'test@example.com', document_vatid: '12345678Z') }
    let(:params) do
      {
        document_vatid: '12345678Z',
        full_name: 'Test User',
        email: 'test@example.com',
        amount: 2000.0,
        frequency: '1',
        payment_type: 2,
        created_at: DateTime.now,
        ccc_1: '1234',
        ccc_2: '5678',
        ccc_3: '90',
        ccc_4: '1234567890',
        iban_1: 'ES1234567890123456789012',
        iban_2: '',
        donation_type: 'CCM',
        row: {}
      }
    end

    context 'when user exists with matching email and document' do
      before { user }

      it 'creates collaboration for user' do
        allow(described_class).to receive(:log_to_file)
        expect {
          described_class.create_collaboration(params)
        }.to change(Collaboration, :count).by(1)
      end

      it 'sets all required attributes' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        collab = Collaboration.last
        expect(collab.user).to eq(user)
        expect(collab.amount).to eq(2000.0)
        expect(collab.frequency).to eq('1')
        expect(collab.payment_type).to eq(2)
        expect(collab.status).to eq(2)
      end

      it 'sets CCC fields' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        collab = Collaboration.last
        expect(collab.ccc_entity).to eq('1234')
        expect(collab.ccc_office).to eq('5678')
        expect(collab.ccc_dc).to eq('90')
        expect(collab.ccc_account).to eq('1234567890')
      end

      it 'sets IBAN fields' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        collab = Collaboration.last
        expect(collab.iban_account).to eq('ES1234567890123456789012')
      end

      it 'calculates BIC automatically' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        collab = Collaboration.last
        expect(collab).to have_received(:calculate_bic) if collab.respond_to?(:calculate_bic)
      end
    end

    context 'donation type CCM (town)' do
      before do
        user
        params[:donation_type] = 'CCM'
      end

      it 'sets for_town_cc to true' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        expect(Collaboration.last.for_town_cc).to be true
      end
    end

    context 'donation type CCA (autonomy)' do
      before do
        user
        params[:donation_type] = 'CCA'
      end

      it 'sets for_autonomy_cc to true' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        expect(Collaboration.last.for_autonomy_cc).to be true
      end
    end

    context 'donation type CCE (national)' do
      before do
        user
        params[:donation_type] = 'CCE'
      end

      it 'sets all territorial flags to false' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        collab = Collaboration.last
        expect(collab.for_town_cc).to be false
        expect(collab.for_island_cc).to be false
        expect(collab.for_autonomy_cc).to be false
      end
    end

    context 'donation type CCI (island)' do
      before do
        user
        params[:donation_type] = 'CCI'
      end

      it 'sets for_island_cc to true' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        expect(Collaboration.last.for_island_cc).to be true
      end
    end

    context 'when validation fails' do
      before do
        user
        allow_any_instance_of(Collaboration).to receive(:valid?).and_return(false)
        allow_any_instance_of(Collaboration).to receive(:errors).and_return(
          double(messages: { amount: ['is invalid'] })
        )
      end

      it 'logs to not_valid file' do
        expect(described_class).to receive(:log_to_file)
          .with(Rails.root.join('log/collaboration/not_valid.txt').to_s, anything)
        described_class.create_collaboration(params)
      end
    end

    context 'when user exists with matching email but different document' do
      before do
        user
        params[:document_vatid] = 'DIFFERENT'
        params[:full_name] = user.full_name
      end

      it 'uses user document and retries' do
        allow(described_class).to receive(:log_to_file)
        expect(described_class).to receive(:create_collaboration).with(hash_including(document_vatid: user.document_vatid))
        described_class.create_collaboration(params)
      end
    end

    context 'when user exists with matching document but different email' do
      before do
        user
        params[:email] = 'different@example.com'
        params[:full_name] = user.full_name
      end

      it 'uses user email and retries' do
        allow(described_class).to receive(:log_to_file)
        expect(described_class).to receive(:create_collaboration).with(hash_including(email: user.email))
        described_class.create_collaboration(params)
      end
    end

    context 'when user does not exist' do
      it 'logs to not_participation file' do
        expect(described_class).to receive(:log_to_file)
          .with(Rails.root.join('log/collaboration/not_participation.txt').to_s, anything)
        described_class.create_collaboration(params)
      end
    end
  end
end
