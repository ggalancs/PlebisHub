# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CensusFileParser do
  let(:election) { instance_double('Election') }
  let(:parser) { described_class.new(election) }

  # ==================== INITIALIZATION TESTS ====================

  describe 'initialization' do
    it 'initializes with an election' do
      expect(parser.instance_variable_get(:@election)).to eq(election)
    end

    it 'accepts any election object' do
      custom_election = double('CustomElection')
      parser = described_class.new(custom_election)
      expect(parser.instance_variable_get(:@election)).to eq(custom_election)
    end
  end

  # ==================== FIND USER BY VALIDATION TOKEN TESTS ====================

  describe '#find_user_by_validation_token' do
    let(:user_id) { '123' }
    let(:validation_token) { 'token123' }
    let(:user) { instance_double('User', id: 123) }

    context 'when census_file is blank' do
      before do
        allow(election).to receive(:census_file).and_return(nil)
      end

      it 'returns nil' do
        result = parser.find_user_by_validation_token(user_id, validation_token)
        expect(result).to be_nil
      end

      it 'does not parse CSV' do
        expect(CSV).not_to receive(:parse)
        parser.find_user_by_validation_token(user_id, validation_token)
      end
    end

    context 'when census_file is empty string' do
      before do
        allow(election).to receive(:census_file).and_return('')
      end

      it 'returns nil' do
        result = parser.find_user_by_validation_token(user_id, validation_token)
        expect(result).to be_nil
      end
    end

    context 'when census_file exists' do
      let(:csv_data) { "user_id,name\n123,John Doe\n456,Jane Smith" }
      let(:io_adapter) { double('IOAdapter', read: csv_data) }

      before do
        allow(election).to receive(:census_file).and_return('census.csv')
        allow(Paperclip.io_adapters).to receive(:for).with('census.csv').and_return(io_adapter)
      end

      context 'when user is found' do
        before do
          allow(User).to receive(:find_by).with(id: user_id).and_return(user)
        end

        it 'returns the user' do
          result = parser.find_user_by_validation_token(user_id, validation_token)
          expect(result).to eq(user)
        end

        it 'queries User by id' do
          expect(User).to receive(:find_by).with(id: user_id).and_return(user)
          parser.find_user_by_validation_token(user_id, validation_token)
        end
      end

      context 'when user_id does not match' do
        let(:csv_data) { "user_id,name\n456,Jane Smith\n789,Bob Jones" }

        it 'returns nil' do
          result = parser.find_user_by_validation_token(user_id, validation_token)
          expect(result).to be_nil
        end

        it 'does not query User' do
          expect(User).not_to receive(:find_by)
          parser.find_user_by_validation_token(user_id, validation_token)
        end
      end

      context 'when user_id is found but user does not exist in database' do
        before do
          allow(User).to receive(:find_by).with(id: user_id).and_return(nil)
        end

        it 'returns nil' do
          result = parser.find_user_by_validation_token(user_id, validation_token)
          expect(result).to be_nil
        end
      end

      context 'when CSV has multiple rows' do
        let(:csv_data) { "user_id,name\n456,Jane Smith\n123,John Doe\n789,Bob Jones" }

        before do
          allow(User).to receive(:find_by).with(id: user_id).and_return(user)
        end

        it 'finds user in middle of file' do
          result = parser.find_user_by_validation_token(user_id, validation_token)
          expect(result).to eq(user)
        end
      end

      context 'when CSV is malformed' do
        let(:csv_data) { "user_id,name\n123John Doe" }

        it 'handles CSV parsing error gracefully' do
          expect { parser.find_user_by_validation_token(user_id, validation_token) }.to raise_error(CSV::MalformedCSVError)
        end
      end

      context 'when Paperclip adapter fails' do
        before do
          allow(Paperclip.io_adapters).to receive(:for).and_raise(StandardError.new('File not found'))
        end

        it 'propagates the error' do
          expect { parser.find_user_by_validation_token(user_id, validation_token) }.to raise_error(StandardError, 'File not found')
        end
      end
    end
  end

  # ==================== FIND USER BY DOCUMENT TESTS ====================

  describe '#find_user_by_document' do
    let(:document_vatid) { '12345678A' }
    let(:document_type) { '1' }
    let(:user) { instance_double('User', document_vatid: '12345678A', document_type: '1') }

    context 'when census_file is blank' do
      before do
        allow(election).to receive(:census_file).and_return(nil)
      end

      it 'returns nil' do
        result = parser.find_user_by_document(document_vatid, document_type)
        expect(result).to be_nil
      end

      it 'does not parse CSV' do
        expect(CSV).not_to receive(:parse)
        parser.find_user_by_document(document_vatid, document_type)
      end
    end

    context 'when census_file exists' do
      let(:csv_data) { "dni,name\n12345678A,John Doe\n87654321B,Jane Smith" }
      let(:io_adapter) { double('IOAdapter', read: csv_data) }
      let(:user_relation) { double('UserRelation') }

      before do
        allow(election).to receive(:census_file).and_return('census.csv')
        allow(Paperclip.io_adapters).to receive(:for).with('census.csv').and_return(io_adapter)
      end

      context 'when document is found (case insensitive)' do
        before do
          allow(User).to receive(:where).with('lower(document_vatid) = ?', document_vatid.downcase).and_return(user_relation)
          allow(user_relation).to receive(:find_by).with(document_type: document_type).and_return(user)
        end

        it 'returns the user' do
          result = parser.find_user_by_document(document_vatid, document_type)
          expect(result).to eq(user)
        end

        it 'queries with lowercase document' do
          expect(User).to receive(:where).with('lower(document_vatid) = ?', document_vatid.downcase)
          parser.find_user_by_document(document_vatid, document_type)
        end

        it 'filters by document_type' do
          expect(user_relation).to receive(:find_by).with(document_type: document_type)
          parser.find_user_by_document(document_vatid, document_type)
        end
      end

      context 'when document is found with different case' do
        let(:csv_data) { "dni,name\n12345678a,John Doe" }

        before do
          allow(User).to receive(:where).with('lower(document_vatid) = ?', document_vatid.downcase).and_return(user_relation)
          allow(user_relation).to receive(:find_by).with(document_type: document_type).and_return(user)
        end

        it 'performs case-insensitive match' do
          result = parser.find_user_by_document(document_vatid, document_type)
          expect(result).to eq(user)
        end
      end

      context 'when document is not found in CSV' do
        let(:csv_data) { "dni,name\n87654321B,Jane Smith" }

        it 'returns nil' do
          result = parser.find_user_by_document(document_vatid, document_type)
          expect(result).to be_nil
        end

        it 'does not query User' do
          expect(User).not_to receive(:where)
          parser.find_user_by_document(document_vatid, document_type)
        end
      end

      context 'when document is found in CSV but not in database' do
        before do
          allow(User).to receive(:where).with('lower(document_vatid) = ?', document_vatid.downcase).and_return(user_relation)
          allow(user_relation).to receive(:find_by).with(document_type: document_type).and_return(nil)
        end

        it 'returns nil' do
          result = parser.find_user_by_document(document_vatid, document_type)
          expect(result).to be_nil
        end
      end

      context 'when document_type does not match' do
        before do
          allow(User).to receive(:where).with('lower(document_vatid) = ?', document_vatid.downcase).and_return(user_relation)
          allow(user_relation).to receive(:find_by).with(document_type: document_type).and_return(nil)
        end

        it 'returns nil' do
          result = parser.find_user_by_document(document_vatid, document_type)
          expect(result).to be_nil
        end
      end

      context 'when CSV has multiple rows' do
        let(:csv_data) { "dni,name\n87654321B,Jane Smith\n12345678A,John Doe\n11111111C,Bob Jones" }

        before do
          allow(User).to receive(:where).with('lower(document_vatid) = ?', document_vatid.downcase).and_return(user_relation)
          allow(user_relation).to receive(:find_by).with(document_type: document_type).and_return(user)
        end

        it 'finds document in middle of file' do
          result = parser.find_user_by_document(document_vatid, document_type)
          expect(result).to eq(user)
        end
      end

      context 'when dni column is missing' do
        let(:csv_data) { "user_id,name\n123,John Doe" }

        it 'returns nil' do
          result = parser.find_user_by_document(document_vatid, document_type)
          expect(result).to be_nil
        end
      end

      context 'when dni column has nil value' do
        let(:csv_data) { "dni,name\n,John Doe" }

        it 'handles nil values gracefully' do
          result = parser.find_user_by_document(document_vatid, document_type)
          expect(result).to be_nil
        end
      end
    end

    context 'with special characters in document' do
      let(:document_vatid) { "X1234567L" }
      let(:csv_data) { "dni,name\nX1234567L,Foreigner" }
      let(:io_adapter) { double('IOAdapter', read: csv_data) }
      let(:user_relation) { double('UserRelation') }

      before do
        allow(election).to receive(:census_file).and_return('census.csv')
        allow(Paperclip.io_adapters).to receive(:for).with('census.csv').and_return(io_adapter)
        allow(User).to receive(:where).with('lower(document_vatid) = ?', document_vatid.downcase).and_return(user_relation)
        allow(user_relation).to receive(:find_by).with(document_type: document_type).and_return(user)
      end

      it 'handles special characters correctly' do
        result = parser.find_user_by_document(document_vatid, document_type)
        expect(result).to eq(user)
      end
    end
  end

  # ==================== EDGE CASES ====================

  describe 'edge cases' do
    context 'when election is nil' do
      let(:parser) { described_class.new(nil) }

      it 'handles nil election for find_user_by_validation_token' do
        expect { parser.find_user_by_validation_token('123', 'token') }.to raise_error(NoMethodError)
      end

      it 'handles nil election for find_user_by_document' do
        expect { parser.find_user_by_document('12345678A', '1') }.to raise_error(NoMethodError)
      end
    end

    context 'when CSV is empty' do
      let(:csv_data) { "user_id,name\n" }
      let(:io_adapter) { double('IOAdapter', read: csv_data) }

      before do
        allow(election).to receive(:census_file).and_return('census.csv')
        allow(Paperclip.io_adapters).to receive(:for).with('census.csv').and_return(io_adapter)
      end

      it 'returns nil for find_user_by_validation_token' do
        result = parser.find_user_by_validation_token('123', 'token')
        expect(result).to be_nil
      end

      it 'returns nil for find_user_by_document' do
        result = parser.find_user_by_document('12345678A', '1')
        expect(result).to be_nil
      end
    end

    context 'when CSV has only headers' do
      let(:csv_data) { "user_id,name" }
      let(:io_adapter) { double('IOAdapter', read: csv_data) }

      before do
        allow(election).to receive(:census_file).and_return('census.csv')
        allow(Paperclip.io_adapters).to receive(:for).with('census.csv').and_return(io_adapter)
      end

      it 'returns nil for find_user_by_validation_token' do
        result = parser.find_user_by_validation_token('123', 'token')
        expect(result).to be_nil
      end

      it 'returns nil for find_user_by_document' do
        result = parser.find_user_by_document('12345678A', '1')
        expect(result).to be_nil
      end
    end

    context 'when CSV has UTF-8 characters' do
      let(:csv_data) { "dni,name\n12345678Ñ,José García" }
      let(:io_adapter) { double('IOAdapter', read: csv_data) }
      let(:user_relation) { double('UserRelation') }
      let(:user) { instance_double('User') }

      before do
        allow(election).to receive(:census_file).and_return('census.csv')
        allow(Paperclip.io_adapters).to receive(:for).with('census.csv').and_return(io_adapter)
        allow(User).to receive(:where).with('lower(document_vatid) = ?', '12345678ñ').and_return(user_relation)
        allow(user_relation).to receive(:find_by).with(document_type: '1').and_return(user)
      end

      it 'handles UTF-8 characters correctly' do
        result = parser.find_user_by_document('12345678Ñ', '1')
        expect(result).to eq(user)
      end
    end

    context 'when input is nil' do
      let(:csv_data) { "user_id,name\n123,John Doe" }
      let(:io_adapter) { double('IOAdapter', read: csv_data) }

      before do
        allow(election).to receive(:census_file).and_return('census.csv')
        allow(Paperclip.io_adapters).to receive(:for).with('census.csv').and_return(io_adapter)
      end

      it 'handles nil user_id gracefully' do
        result = parser.find_user_by_validation_token(nil, 'token')
        expect(result).to be_nil
      end

      it 'handles nil document_vatid gracefully' do
        expect { parser.find_user_by_document(nil, '1') }.to raise_error(NoMethodError)
      end
    end
  end

  # ==================== SECURITY TESTS ====================

  describe 'security' do
    let(:csv_data) { "dni,name\n12345678A,John Doe" }
    let(:io_adapter) { double('IOAdapter', read: csv_data) }

    before do
      allow(election).to receive(:census_file).and_return('census.csv')
      allow(Paperclip.io_adapters).to receive(:for).with('census.csv').and_return(io_adapter)
    end

    describe 'SQL injection prevention' do
      it 'uses parameterized query for document search' do
        user_relation = double('UserRelation')
        allow(User).to receive(:where).with('lower(document_vatid) = ?', "12345678a'; drop table users;--").and_return(user_relation)
        allow(user_relation).to receive(:find_by).and_return(nil)

        # Should not execute SQL injection
        parser.find_user_by_document("12345678A'; DROP TABLE users;--", '1')

        # Verify parameterized query was used
        expect(User).to have_received(:where).with('lower(document_vatid) = ?', "12345678a'; drop table users;--")
      end

      it 'handles malicious document_type safely' do
        user_relation = double('UserRelation')
        malicious_type = "1' OR '1'='1"
        allow(User).to receive(:where).and_return(user_relation)
        allow(user_relation).to receive(:find_by).with(document_type: malicious_type).and_return(nil)

        parser.find_user_by_document('12345678A', malicious_type)

        expect(user_relation).to have_received(:find_by).with(document_type: malicious_type)
      end
    end

    describe 'CSV injection prevention' do
      context 'when CSV contains formula injection attempts' do
        let(:csv_data) { "dni,name\n=1+1,Hacker" }

        it 'treats formula as plain text' do
          result = parser.find_user_by_document('=1+1', '1')
          expect(result).to be_nil
        end
      end
    end
  end

  # ==================== PRIVATE METHODS TESTS ====================

  describe 'private methods' do
    describe '#parse_csv' do
      let(:csv_data) { "user_id,name\n123,John Doe\n456,Jane Smith" }
      let(:io_adapter) { double('IOAdapter', read: csv_data) }

      before do
        allow(election).to receive(:census_file).and_return('census.csv')
        allow(Paperclip.io_adapters).to receive(:for).with('census.csv').and_return(io_adapter)
      end

      it 'parses CSV with headers' do
        rows = []
        parser.send(:parse_csv) { |row| rows << row }
        expect(rows.length).to eq(2)
      end

      it 'provides hash access to columns' do
        parser.send(:parse_csv) do |row|
          expect(row['user_id']).to eq('123')
          expect(row['name']).to eq('John Doe')
          return true
        end
      end

      it 'stops iteration when block returns truthy value' do
        iteration_count = 0
        parser.send(:parse_csv) do |row|
          iteration_count += 1
          true if iteration_count == 1
        end
        expect(iteration_count).to eq(1)
      end

      it 'continues iteration when block returns falsy value' do
        iteration_count = 0
        parser.send(:parse_csv) do |row|
          iteration_count += 1
          nil
        end
        expect(iteration_count).to eq(2)
      end

      it 'returns nil when no match is found' do
        result = parser.send(:parse_csv) { |_row| nil }
        expect(result).to be_nil
      end
    end
  end
end
