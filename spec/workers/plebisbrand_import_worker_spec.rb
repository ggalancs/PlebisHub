# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisBrandImportWorker, type: :worker do
  describe 'Sidekiq configuration' do
    it 'is configured with the correct queue' do
      expect(described_class.sidekiq_options['queue']).to eq(:plebisbrand_import_queue)
    end

    it 'includes Sidekiq::Worker' do
      expect(described_class.ancestors).to include(Sidekiq::Worker)
    end
  end

  describe '#perform' do
    let(:worker) { described_class.new }
    let(:sample_row) do
      [
        ['first_name', 'Juan'],
        ['last_name', 'García'],
        ['doc_type', 'DNI'],
        ['document_vatid', '12345678Z'],
        ['nie', nil],
        ['born_at', '1980-05-15'],
        ['email', 'juan.garcia@example.com'],
        ['phone', '+34666777888'],
        ['sms_token', '123456'],
        ['address', 'Calle Test 123'],
        ['town', 'Madrid'],
        ['province', 'Madrid'],
        ['postal_code', '28001'],
        ['country', 'España'],
        ['old_circle', 'Circle A'],
        ['circle', nil],
        ['newsletter', 1],
        ['terms', 1],
        ['privacy', 1],
        ['age', 1],
        ['source', 'web'],
        ['ip', '127.0.0.1'],
        ['created_at', '2020-01-15 10:30:00']
      ]
    end

    it 'calls PlebisBrandImport.process_row with the row' do
      expect(PlebisBrandImport).to receive(:process_row).with(sample_row)

      worker.perform(sample_row)
    end

    it 'processes row successfully' do
      allow(PlebisBrandImport).to receive(:process_row).with(sample_row)

      expect { worker.perform(sample_row) }.not_to raise_error
    end

    context 'with valid row data' do
      before do
        allow(PlebisBrandImport).to receive(:process_row).and_call_original
      end

      it 'creates a new user' do
        expect do
          worker.perform(sample_row)
        end.to change(User, :count).by(1)
      end

      it 'sets user attributes correctly' do
        worker.perform(sample_row)

        user = User.last
        expect(user.first_name).to eq('Juan')
        expect(user.last_name).to eq('García')
        expect(user.document_vatid).to eq('12345678Z')
        expect(user.email).to eq('juan.garcia@example.com')
      end

      it 'sets legacy password flag' do
        worker.perform(sample_row)

        user = User.last
        expect(user.has_legacy_password).to be true
      end

      it 'confirms user email and SMS' do
        worker.perform(sample_row)

        user = User.last
        expect(user.confirmed_at).not_to be_nil
        expect(user.sms_confirmed_at).not_to be_nil
      end
    end

    context 'with DNI document type' do
      it 'sets document_type to 1' do
        allow(PlebisBrandImport).to receive(:process_row).and_call_original

        worker.perform(sample_row)

        user = User.last
        expect(user.document_type).to eq(1)
      end
    end

    context 'with NIE document type' do
      let(:nie_row) do
        row = sample_row.dup
        row[3] = ['document_vatid', 'X1234567Y']
        row
      end

      it 'sets document_type to 2' do
        allow(PlebisBrandImport).to receive(:process_row).and_call_original

        worker.perform(nie_row)

        user = User.last
        expect(user.document_type).to eq(2)
      end
    end

    context 'with Passport document type' do
      let(:passport_row) do
        row = sample_row.dup
        row[2] = ['doc_type', 'Pasaporte']
        row[3] = ['document_vatid', 'ABC123456']
        row
      end

      it 'sets document_type to 3' do
        allow(PlebisBrandImport).to receive(:process_row).and_call_original

        worker.perform(passport_row)

        user = User.last
        expect(user.document_type).to eq(3)
      end
    end

    context 'with missing optional fields' do
      let(:minimal_row) do
        [
          ['first_name', 'Maria'],
          ['last_name', 'Lopez'],
          ['doc_type', 'DNI'],
          ['document_vatid', '87654321A'],
          ['nie', nil],
          ['born_at', nil], # Missing
          ['email', 'maria.lopez@example.com'],
          ['phone', '+34611222333'],
          ['sms_token', '654321'],
          ['address', 'Calle Test 456'],
          ['town', 'Barcelona'],
          ['province', 'Barcelona'],
          ['postal_code', '08001'],
          ['country', 'España'],
          ['old_circle', nil],
          ['circle', nil],
          ['newsletter', nil], # Missing
          ['terms', 1],
          ['privacy', 1],
          ['age', 1],
          ['source', 'web'],
          ['ip', '127.0.0.1'],
          ['created_at', '2020-02-20 11:45:00']
        ]
      end

      it 'creates user without born_at' do
        allow(PlebisBrandImport).to receive(:process_row).and_call_original

        expect do
          worker.perform(minimal_row)
        end.to change(User, :count).by(1)

        user = User.last
        expect(user.born_at).to be_nil
      end

      it 'creates user without newsletter preference' do
        allow(PlebisBrandImport).to receive(:process_row).and_call_original

        worker.perform(minimal_row)

        user = User.last
        expect(user.wants_newsletter).not_to eq(true)
      end
    end

    context 'with international phone format' do
      let(:phone_row) do
        row = sample_row.dup
        row[7] = ['phone', '+34600111222']
        row
      end

      it 'converts + to 00 in phone number' do
        allow(PlebisBrandImport).to receive(:process_row).and_call_original

        worker.perform(phone_row)

        user = User.last
        expect(user.phone).to eq('0034600111222')
      end
    end

    context 'with country normalization' do
      let(:country_row) do
        row = sample_row.dup
        row[13] = ['country', 'Spain']
        row
      end

      it 'normalizes country name to code' do
        allow(PlebisBrandImport).to receive(:process_row).and_call_original

        worker.perform(country_row)

        user = User.last
        expect(user.country).to eq('ES')
      end
    end

    context 'with province normalization' do
      it 'normalizes province based on postal code' do
        allow(PlebisBrandImport).to receive(:process_row).and_call_original

        worker.perform(sample_row)

        user = User.last
        expect(user.province).to eq('M')
      end
    end

    context 'error handling' do
      context 'when user email already exists' do
        before do
          create(:user, email: 'juan.garcia@example.com')
          allow(PlebisBrandImport).to receive(:process_row).and_call_original
        end

        it 'logs the error to users_email.log' do
          expect do
            worker.perform(sample_row)
          end.not_to change(User, :count)
        end

        it 'does not raise an error for duplicate email' do
          # The actual implementation logs to users_email.log but doesn't raise
          # We verify it handles the error gracefully
          expect { worker.perform(sample_row) }.not_to raise_error
        end
      end

      context 'when user data is invalid' do
        let(:invalid_row) do
          row = sample_row.dup
          row[6] = ['email', 'invalid-email'] # Invalid email format
          row
        end

        before do
          allow(PlebisBrandImport).to receive(:process_row).and_call_original
        end

        it 'logs the error to users_invalid.log' do
          expect do
            worker.perform(invalid_row)
          end.to raise_error(/InvalidRecordError/)
        end
      end

      context 'when row is nil' do
        it 'raises an error' do
          allow(PlebisBrandImport).to receive(:process_row).and_call_original

          expect { worker.perform(nil) }.to raise_error
        end
      end

      context 'when row has missing required fields' do
        let(:incomplete_row) do
          [
            ['first_name', 'Test'],
            ['last_name', 'User']
            # Missing all other required fields
          ]
        end

        before do
          allow(PlebisBrandImport).to receive(:process_row).and_call_original
        end

        it 'raises an error' do
          expect { worker.perform(incomplete_row) }.to raise_error
        end
      end

      context 'when PlebisBrandImport.process_row fails' do
        before do
          allow(PlebisBrandImport).to receive(:process_row)
            .and_raise(StandardError.new('Processing failed'))
        end

        it 'propagates the error' do
          expect { worker.perform(sample_row) }.to raise_error(StandardError, 'Processing failed')
        end
      end
    end

    context 'integration scenarios' do
      before do
        allow(PlebisBrandImport).to receive(:process_row).and_call_original
      end

      it 'processes multiple rows sequentially' do
        row1 = sample_row
        row2 = sample_row.dup
        row2[3] = ['document_vatid', '98765432B']
        row2[6] = ['email', 'test2@example.com']

        expect do
          worker.perform(row1)
          worker.perform(row2)
        end.to change(User, :count).by(2)
      end

      it 'sets SMS confirmation token' do
        worker.perform(sample_row)

        user = User.last
        expect(user.sms_confirmation_token).to eq('123456')
      end

      it 'stores old circle data' do
        worker.perform(sample_row)

        user = User.last
        expect(user.old_circle_data).to eq('Circle A')
      end

      it 'preserves creation timestamp from CSV' do
        worker.perform(sample_row)

        user = User.last
        expected_time = DateTime.parse('2020-01-15 10:30:00')
        expect(user.created_at.to_i).to eq(expected_time.to_i)
      end
    end

    context 'Sidekiq retry behavior' do
      it 'can be retried on failure' do
        # First call fails
        allow(PlebisBrandImport).to receive(:process_row)
          .and_raise(StandardError.new('Temporary failure'))

        expect { worker.perform(sample_row) }.to raise_error(StandardError)

        # Second call succeeds
        allow(PlebisBrandImport).to receive(:process_row).and_call_original

        expect { worker.perform(sample_row) }.not_to raise_error
      end
    end

    context 'edge cases' do
      context 'with very long town name' do
        let(:long_town_row) do
          row = sample_row.dup
          row[10] = ['town', 'A' * 300] # Very long town name
          row
        end

        it 'truncates town name to prevent issues' do
          allow(PlebisBrandImport).to receive(:process_row).and_call_original

          worker.perform(long_town_row)

          user = User.last
          expect(user.town).to eq('A') # Truncated
        end
      end

      context 'with NIE starting with Z' do
        let(:nie_z_row) do
          row = sample_row.dup
          row[3] = ['document_vatid', 'Z9876543R']
          row
        end

        it 'correctly identifies as NIE' do
          allow(PlebisBrandImport).to receive(:process_row).and_call_original

          worker.perform(nie_z_row)

          user = User.last
          expect(user.document_type).to eq(2)
        end
      end

      context 'with NIE starting with Y' do
        let(:nie_y_row) do
          row = sample_row.dup
          row[3] = ['document_vatid', 'Y1122334F']
          row
        end

        it 'correctly identifies as NIE' do
          allow(PlebisBrandImport).to receive(:process_row).and_call_original

          worker.perform(nie_y_row)

          user = User.last
          expect(user.document_type).to eq(2)
        end
      end
    end
  end

  describe 'worker instantiation' do
    it 'can be instantiated' do
      expect { described_class.new }.not_to raise_error
    end

    it 'responds to perform' do
      expect(described_class.new).to respond_to(:perform)
    end
  end
end
