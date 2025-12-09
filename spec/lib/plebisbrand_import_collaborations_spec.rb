# frozen_string_literal: true

require 'rails_helper'

# Manually load the file to avoid Zeitwerk issues
load File.expand_path('../../lib/plebisbrand_import_collaborations.rb', __dir__)

RSpec.describe PlebisBrandImportCollaborations do
  describe '.log_to_file' do
    let(:filename) { Rails.root.join('tmp/test_log.txt').to_s }

    after do
      File.delete(filename) if File.exist?(filename)
    end

    it 'writes text to file' do
      described_class.log_to_file(filename, 'test content')
      expect(File.read(filename)).to include('test content')
    end

    it 'appends to existing file' do
      described_class.log_to_file(filename, 'first line')
      described_class.log_to_file(filename, 'second line')
      content = File.read(filename)
      expect(content).to include('first line')
      expect(content).to include('second line')
    end

    it 'creates file if it does not exist' do
      described_class.log_to_file(filename, 'new file')
      expect(File).to exist(filename)
    end
  end

  describe '.process_row' do
    let(:row) do
      {
        'DNI / NIE' => '12345678Z',
        'Nombre' => 'John',
        'Apellidos' => 'Doe',
        'Email' => 'john@example.com',
        'Entidad' => '1234',
        'Oficina' => '5678',
        'DC' => '90',
        'Cuenta' => '1234567890',
        'IBAN' => nil,
        'BIC/SWIFT' => nil,
        'Método de pago' => 'Suscripción con Tarjeta de Crédito/Débito',
        'Total' => '10',
        'Frecuencia de pago' => '1',
        'Creado' => '2024-01-01 10:00:00'
      }
    end

    it 'calls create_collaboration with processed params' do
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:document_vatid]).to eq('12345678Z')
        expect(params[:full_name]).to eq('John Doe')
        expect(params[:email]).to eq('john@example.com')
        expect(params[:amount]).to eq(1000.0)
        expect(params[:frequency]).to eq('1')
      end
      described_class.process_row(row)
    end

    it 'strips and upcases document_vatid' do
      row['DNI / NIE'] = '  12345678z  '
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:document_vatid]).to eq('12345678Z')
      end
      described_class.process_row(row)
    end

    it 'handles missing apellidos' do
      row.delete('Apellidos')
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:full_name]).to eq('John')
      end
      described_class.process_row(row)
    end

    it 'converts total to cents (multiplies by 100)' do
      row['Total'] = '50'
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:amount]).to eq(5000.0)
      end
      described_class.process_row(row)
    end

    it 'parses created_at date' do
      expect(described_class).to receive(:create_collaboration) do |params|
        expect(params[:created_at]).to be_a(DateTime)
      end
      described_class.process_row(row)
    end
  end

  describe '.create_collaboration' do
    let(:user) { create(:user, email: 'test@example.com', document_vatid: '12345678Z', document_type: 1) }
    let(:params) do
      {
        document_vatid: '12345678Z',
        full_name: 'Test User',
        email: 'test@example.com',
        amount: 1000.0,
        frequency: '1',
        payment_type: 'Suscripción con Tarjeta de Crédito/Débito',
        created_at: DateTime.now,
        ccc_1: nil,
        ccc_2: nil,
        ccc_3: nil,
        ccc_4: nil,
        iban_1: nil,
        iban_2: nil,
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

      it 'sets collaboration attributes correctly' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        collab = Collaboration.last
        expect(collab.user).to eq(user)
        expect(collab.amount).to eq(1000.0)
        # frequency may be stored as integer or string depending on database config
        expect(collab.frequency.to_s).to eq('1')
      end

      it 'sets payment_type to 1 for credit card' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        expect(Collaboration.last.payment_type).to eq(1)
      end
    end

    context 'when payment type is CCC' do
      before do
        user
        params.merge!(
          payment_type: 'Domiciliación en cuenta bancaria (CCC)',
          ccc_1: '1234',
          ccc_2: '5678',
          ccc_3: '90',
          ccc_4: '1234567890'
        )
      end

      it 'sets payment_type to 2' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        expect(Collaboration.last.payment_type).to eq(2)
      end

      it 'sets CCC fields' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        collab = Collaboration.last
        # CCC fields may be stored as integers or strings depending on database config
        expect(collab.ccc_entity.to_s).to eq('1234')
        expect(collab.ccc_office.to_s).to eq('5678')
        expect(collab.ccc_dc.to_s).to eq('90')
        expect(collab.ccc_account.to_s).to eq('1234567890')
      end
    end

    context 'when payment type is IBAN' do
      before do
        user
        params.merge!(
          payment_type: 'Domiciliación en cuenta extranjera (IBAN)',
          iban_1: 'ES1234567890123456789012',
          iban_2: 'SWIFT123'
        )
      end

      it 'sets payment_type to 3' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        expect(Collaboration.last.payment_type).to eq(3)
      end

      it 'sets IBAN fields' do
        allow(described_class).to receive(:log_to_file)
        described_class.create_collaboration(params)
        collab = Collaboration.last
        expect(collab.iban_account).to eq('ES1234567890123456789012')
        expect(collab.iban_bic).to eq('SWIFT123')
      end
    end

    context 'when user exists with matching email but different document' do
      before do
        user
        params[:document_vatid] = 'DIFFERENT'
        params[:full_name] = user.full_name
      end

      it 'creates collaboration when full_name matches' do
        allow(described_class).to receive(:log_to_file)
        expect {
          described_class.create_collaboration(params)
        }.to change(Collaboration, :count).by(1)
        # Verify collaboration was created for the existing user
        expect(Collaboration.last.user).to eq(user)
      end
    end

    context 'when user exists with matching document but different email' do
      before do
        user
        params[:email] = 'different@example.com'
        params[:full_name] = user.full_name
      end

      it 'creates collaboration when full_name matches' do
        allow(described_class).to receive(:log_to_file)
        expect {
          described_class.create_collaboration(params)
        }.to change(Collaboration, :count).by(1)
        # Verify collaboration was created for the existing user
        expect(Collaboration.last.user).to eq(user)
      end
    end

    context 'when user does not exist' do
      it 'logs to not_participation file' do
        expect(described_class).to receive(:log_to_file)
          .with(Rails.root.join('log/collaboration/not_participation.txt').to_s, anything)
        described_class.create_collaboration(params)
      end
    end

    context 'when IBAN is Spanish and missing BIC' do
      # Spanish IBAN format: ESxx + entity(4) + office(4) + dc(2) + account(10)
      # Use IBAN that produces known CCC values: entity=1234, office=5678, dc=90, account=1234567890
      let(:test_iban) { 'ESXX12345678901234567890' }

      before do
        user
        params.merge!(
          payment_type: 'Domiciliación en cuenta extranjera (IBAN)',
          iban_1: test_iban,
          iban_2: nil
        )
      end

      it 'converts Spanish IBAN to CCC and creates collaboration' do
        allow(described_class).to receive(:log_to_file)
        # Spanish IBAN without BIC should be converted to CCC and collaboration created
        expect {
          described_class.create_collaboration(params)
        }.to change(Collaboration, :count).by(1)

        # Verify the collaboration was created with converted CCC fields
        # IBAN[4..7]=entity, [8..11]=office, [12..13]=dc, [14..23]=account
        collab = Collaboration.last
        expect(collab.payment_type).to eq(2) # CCC payment type
        expect(collab.ccc_entity.to_s).to eq('1234')
        expect(collab.ccc_office.to_s).to eq('5678')
        expect(collab.ccc_dc.to_s).to eq('90')
        expect(collab.ccc_account.to_s).to eq('1234567890')
      end
    end
  end
end
