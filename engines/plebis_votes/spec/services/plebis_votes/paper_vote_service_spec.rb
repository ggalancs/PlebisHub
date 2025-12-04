# frozen_string_literal: true

require 'rails_helper'

module PlebisVotes
  RSpec.describe PaperVoteService, type: :service do
    let(:election) { double('Election', id: 1, scope: 5, votes: votes_relation) }
    let(:election_location) { double('ElectionLocation', id: 1) }
    let(:current_user) { double('User', id: 1, full_name: 'John Doe') }
    let(:paper_vote_user) { double('User', id: 2, full_name: 'Jane Smith') }
    let(:votes_relation) { double('ActiveRecord::Relation') }
    let(:vote) { double('Vote', id: 1) }
    let(:log_file_path) { Rails.root.join('log/paper_authorities.log') }

    subject { described_class.new(election, election_location, current_user) }

    describe '#initialize' do
      it 'stores election' do
        expect(subject.instance_variable_get(:@election)).to eq(election)
      end

      it 'stores election_location' do
        expect(subject.instance_variable_get(:@election_location)).to eq(election_location)
      end

      it 'stores current_user' do
        expect(subject.instance_variable_get(:@current_user)).to eq(current_user)
      end

      it 'creates logger for paper authorities' do
        logger = subject.instance_variable_get(:@tracking)
        expect(logger).to be_a(Logger)
      end

      it 'uses correct log file path' do
        allow(Logger).to receive(:new).with(log_file_path.to_s).and_call_original
        described_class.new(election, election_location, current_user)
      end
    end

    describe '#log_vote_query' do
      let(:logger) { instance_double(Logger) }
      let(:document_type) { 'DNI' }
      let(:document_vatid) { '12345678A' }

      before do
        subject.instance_variable_set(:@tracking, logger)
      end

      it 'logs query with user info and document details' do
        expected_message = "** #{current_user.id} #{current_user.full_name} ** QUERY: #{document_type} #{document_vatid}"
        expect(logger).to receive(:info).with(expected_message)

        subject.log_vote_query(document_type, document_vatid)
      end

      it 'includes document type in log' do
        expect(logger).to receive(:info).with(/DNI/)
        subject.log_vote_query('DNI', document_vatid)
      end

      it 'includes document vatid in log' do
        expect(logger).to receive(:info).with(/12345678A/)
        subject.log_vote_query(document_type, '12345678A')
      end

      it 'includes current user ID in log' do
        expect(logger).to receive(:info).with(/\*\* #{current_user.id} /)
        subject.log_vote_query(document_type, document_vatid)
      end

      it 'includes current user full name in log' do
        expect(logger).to receive(:info).with(/#{current_user.full_name}/)
        subject.log_vote_query(document_type, document_vatid)
      end
    end

    describe '#log_vote_registered' do
      let(:logger) { instance_double(Logger) }

      before do
        subject.instance_variable_set(:@tracking, logger)
      end

      it 'logs registered vote with user info' do
        expected_message = "** #{current_user.id} #{current_user.full_name} ** VOTE: #{paper_vote_user.id}"
        expect(logger).to receive(:info).with(expected_message)

        subject.log_vote_registered(paper_vote_user)
      end

      it 'includes current user details' do
        expect(logger).to receive(:info).with(/\*\* #{current_user.id} #{current_user.full_name}/)
        subject.log_vote_registered(paper_vote_user)
      end

      it 'includes paper vote user ID' do
        expect(logger).to receive(:info).with(/VOTE: #{paper_vote_user.id}/)
        subject.log_vote_registered(paper_vote_user)
      end
    end

    describe '#save_vote_for_user' do
      let(:user) { double('User', id: 3) }

      context 'when vote is successfully created' do
        before do
          allow(votes_relation).to receive(:create).and_return(vote)
        end

        it 'creates vote for user' do
          expect(votes_relation).to receive(:create)
            .with(user_id: user.id, paper_authority: current_user)
            .and_return(vote)

          subject.save_vote_for_user(user)
        end

        it 'returns success message for standard election' do
          allow(election).to receive(:scope).and_return(5)
          result = subject.save_vote_for_user(user)

          expect(result).to eq({ notice: 'El voto ha sido registrado.' })
        end

        it 'returns identification message for scope 6 election' do
          allow(election).to receive(:scope).and_return(6)
          result = subject.save_vote_for_user(user)

          expect(result).to eq({ notice: 'Identificación registrada.' })
        end

        it 'differentiates between scope 6 and other scopes' do
          allow(election).to receive(:scope).and_return(3)
          result = subject.save_vote_for_user(user)

          expect(result[:notice]).not_to eq('Identificación registrada.')
          expect(result[:notice]).to eq('El voto ha sido registrado.')
        end
      end

      context 'when vote creation fails' do
        before do
          allow(votes_relation).to receive(:create).and_return(nil)
        end

        it 'returns error message' do
          result = subject.save_vote_for_user(user)

          expect(result).to have_key(:error)
          expect(result[:error]).to include('No se ha podido registrar el voto')
        end

        it 'provides helpful error message' do
          result = subject.save_vote_for_user(user)

          expect(result[:error]).to include('Inténtalo nuevamente')
          expect(result[:error]).to include('consulta con la persona que administra el sistema')
        end
      end

      context 'with different election scopes' do
        [1, 2, 3, 4, 5, 7].each do |scope|
          it "returns standard vote message for scope #{scope}" do
            allow(election).to receive(:scope).and_return(scope)
            allow(votes_relation).to receive(:create).and_return(vote)

            result = subject.save_vote_for_user(user)
            expect(result[:notice]).to eq('El voto ha sido registrado.')
          end
        end

        it 'returns identification message only for scope 6' do
          allow(election).to receive(:scope).and_return(6)
          allow(votes_relation).to receive(:create).and_return(vote)

          result = subject.save_vote_for_user(user)
          expect(result[:notice]).to eq('Identificación registrada.')
        end
      end
    end

    describe '#success_message' do
      it 'returns identification message for scope 6' do
        allow(election).to receive(:scope).and_return(6)
        result = subject.send(:success_message)

        expect(result).to eq({ notice: 'Identificación registrada.' })
      end

      it 'returns vote registered message for other scopes' do
        allow(election).to receive(:scope).and_return(1)
        result = subject.send(:success_message)

        expect(result).to eq({ notice: 'El voto ha sido registrado.' })
      end
    end

    describe '#error_message' do
      it 'returns error hash with message' do
        result = subject.send(:error_message)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:error)
      end

      it 'provides helpful error message' do
        result = subject.send(:error_message)

        expect(result[:error]).to include('No se ha podido registrar el voto')
      end
    end

    describe 'integration scenarios' do
      let(:logger) { instance_double(Logger, info: true) }

      before do
        subject.instance_variable_set(:@tracking, logger)
        allow(votes_relation).to receive(:create).and_return(vote)
      end

      it 'completes full paper vote flow' do
        # Query for voter
        subject.log_vote_query('DNI', '12345678A')

        # Register vote
        subject.log_vote_registered(paper_vote_user)

        # Save vote
        result = subject.save_vote_for_user(paper_vote_user)

        expect(result).to have_key(:notice)
      end

      it 'logs multiple queries for same session' do
        expect(logger).to receive(:info).exactly(3).times

        subject.log_vote_query('DNI', '11111111A')
        subject.log_vote_query('DNI', '22222222B')
        subject.log_vote_query('DNI', '33333333C')
      end

      it 'handles multiple vote registrations' do
        user1 = double('User', id: 10)
        user2 = double('User', id: 11)
        user3 = double('User', id: 12)

        expect(logger).to receive(:info).exactly(3).times

        subject.log_vote_registered(user1)
        subject.log_vote_registered(user2)
        subject.log_vote_registered(user3)
      end

      it 'processes votes for different document types' do
        %w[DNI NIE Pasaporte].each do |doc_type|
          expect(logger).to receive(:info).with(/#{doc_type}/)
          subject.log_vote_query(doc_type, '12345678A')
        end
      end
    end

    describe 'logger behavior' do
      it 'writes to correct log file' do
        # Create a temporary service to test logger creation
        service = described_class.new(election, election_location, current_user)
        logger = service.instance_variable_get(:@tracking)

        expect(logger).to be_a(Logger)
      end

      it 'persists logs across multiple calls' do
        logger = instance_double(Logger)
        allow(Logger).to receive(:new).and_return(logger)

        service = described_class.new(election, election_location, current_user)
        service.instance_variable_set(:@tracking, logger)

        expect(logger).to receive(:info).twice

        service.log_vote_query('DNI', '12345678A')
        service.log_vote_registered(paper_vote_user)
      end
    end

    describe 'error handling' do
      it 'handles vote creation errors gracefully' do
        allow(votes_relation).to receive(:create).and_return(false)

        result = subject.save_vote_for_user(paper_vote_user)

        expect(result).to have_key(:error)
      end

      it 'handles nil vote creation' do
        allow(votes_relation).to receive(:create).and_return(nil)

        result = subject.save_vote_for_user(paper_vote_user)

        expect(result).to have_key(:error)
      end
    end
  end
end
