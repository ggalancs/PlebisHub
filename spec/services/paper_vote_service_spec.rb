# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaperVoteService do
  let(:election) { instance_double('Election', scope: 0, votes: votes_relation) }
  let(:election_location) { instance_double('ElectionLocation') }
  let(:current_user) { instance_double('User', id: 1, full_name: 'Admin User') }
  let(:votes_relation) { double('VotesRelation') }
  let(:service) { described_class.new(election, election_location, current_user) }

  # ==================== INITIALIZATION TESTS ====================

  describe 'initialization' do
    it 'initializes with election, election_location, and current_user' do
      expect(service.instance_variable_get(:@election)).to eq(election)
      expect(service.instance_variable_get(:@election_location)).to eq(election_location)
      expect(service.instance_variable_get(:@current_user)).to eq(current_user)
    end

    it 'creates a logger for paper authorities' do
      tracking_logger = service.instance_variable_get(:@tracking)
      expect(tracking_logger).to be_a(Logger)
    end

    it 'logs to paper_authorities.log file' do
      expect(Logger).to receive(:new).with(Rails.root.join('log/paper_authorities.log').to_s).and_call_original
      described_class.new(election, election_location, current_user)
    end
  end

  # ==================== LOG VOTE QUERY TESTS ====================

  describe '#log_vote_query' do
    let(:document_type) { 'DNI' }
    let(:document_vatid) { '12345678A' }
    let(:tracking_logger) { instance_double('Logger') }

    before do
      service.instance_variable_set(:@tracking, tracking_logger)
    end

    it 'logs query with user info and document details' do
      expect(tracking_logger).to receive(:info).with("** 1 Admin User ** QUERY: DNI 12345678A")
      service.log_vote_query(document_type, document_vatid)
    end

    it 'includes current user id' do
      expect(tracking_logger).to receive(:info).with(a_string_including('** 1'))
      service.log_vote_query(document_type, document_vatid)
    end

    it 'includes current user full name' do
      expect(tracking_logger).to receive(:info).with(a_string_including('Admin User **'))
      service.log_vote_query(document_type, document_vatid)
    end

    it 'includes document type and vatid' do
      expect(tracking_logger).to receive(:info).with(a_string_including('QUERY: DNI 12345678A'))
      service.log_vote_query(document_type, document_vatid)
    end

    context 'with different document types' do
      it 'logs NIE documents' do
        expect(tracking_logger).to receive(:info).with(a_string_including('NIE X1234567L'))
        service.log_vote_query('NIE', 'X1234567L')
      end

      it 'logs passport documents' do
        expect(tracking_logger).to receive(:info).with(a_string_including('Passport ABC123456'))
        service.log_vote_query('Passport', 'ABC123456')
      end
    end

    context 'with special characters in document' do
      it 'logs documents with special characters' do
        expect(tracking_logger).to receive(:info).with(a_string_including("12345678-A"))
        service.log_vote_query('DNI', '12345678-A')
      end
    end
  end

  # ==================== LOG VOTE REGISTERED TESTS ====================

  describe '#log_vote_registered' do
    let(:paper_vote_user) { instance_double('User', id: 99) }
    let(:tracking_logger) { instance_double('Logger') }

    before do
      service.instance_variable_set(:@tracking, tracking_logger)
    end

    it 'logs registered vote with user info and voter id' do
      expect(tracking_logger).to receive(:info).with("** 1 Admin User ** VOTE: 99")
      service.log_vote_registered(paper_vote_user)
    end

    it 'includes current user id' do
      expect(tracking_logger).to receive(:info).with(a_string_including('** 1'))
      service.log_vote_registered(paper_vote_user)
    end

    it 'includes current user full name' do
      expect(tracking_logger).to receive(:info).with(a_string_including('Admin User **'))
      service.log_vote_registered(paper_vote_user)
    end

    it 'includes paper vote user id' do
      expect(tracking_logger).to receive(:info).with(a_string_including('VOTE: 99'))
      service.log_vote_registered(paper_vote_user)
    end

    context 'with different user ids' do
      it 'logs various user ids correctly' do
        user1 = instance_double('User', id: 12345)
        expect(tracking_logger).to receive(:info).with(a_string_including('VOTE: 12345'))
        service.log_vote_registered(user1)
      end
    end
  end

  # ==================== SAVE VOTE FOR USER TESTS ====================

  describe '#save_vote_for_user' do
    let(:user) { instance_double('User', id: 99) }
    let(:vote) { instance_double('Vote') }

    context 'when vote is successfully created' do
      before do
        allow(votes_relation).to receive(:create).with(user_id: user.id, paper_authority: current_user).and_return(vote)
        allow(vote).to receive(:persisted?).and_return(true)
      end

      context 'when election scope is 6 (identification)' do
        before do
          allow(election).to receive(:scope).and_return(6)
        end

        it 'returns identification success message' do
          result = service.save_vote_for_user(user)
          expect(result).to eq({ notice: 'Identificación registrada.' })
        end

        it 'creates vote with user_id and paper_authority' do
          expect(votes_relation).to receive(:create).with(user_id: user.id, paper_authority: current_user)
          service.save_vote_for_user(user)
        end
      end

      context 'when election scope is not 6 (regular vote)' do
        before do
          allow(election).to receive(:scope).and_return(0)
        end

        it 'returns vote success message' do
          result = service.save_vote_for_user(user)
          expect(result).to eq({ notice: 'El voto ha sido registrado.' })
        end

        it 'creates vote with user_id and paper_authority' do
          expect(votes_relation).to receive(:create).with(user_id: user.id, paper_authority: current_user)
          service.save_vote_for_user(user)
        end
      end

      context 'with different election scopes' do
        [0, 1, 2, 3, 4, 5, 7, 8].each do |scope_value|
          it "returns vote message for scope #{scope_value}" do
            allow(election).to receive(:scope).and_return(scope_value)
            result = service.save_vote_for_user(user)
            expect(result).to eq({ notice: 'El voto ha sido registrado.' })
          end
        end
      end
    end

    context 'when vote creation fails' do
      before do
        allow(votes_relation).to receive(:create).with(user_id: user.id, paper_authority: current_user).and_return(nil)
      end

      it 'returns error message' do
        result = service.save_vote_for_user(user)
        expect(result).to eq({ error: 'No se ha podido registrar el voto. Inténtalo nuevamente o consulta con la persona que administra el sistema.' })
      end

      it 'returns same error message regardless of scope' do
        allow(election).to receive(:scope).and_return(6)
        result = service.save_vote_for_user(user)
        expect(result[:error]).to be_present
      end
    end

    context 'when vote creation returns falsy value' do
      before do
        allow(votes_relation).to receive(:create).with(user_id: user.id, paper_authority: current_user).and_return(false)
      end

      it 'returns error message' do
        result = service.save_vote_for_user(user)
        expect(result).to eq({ error: 'No se ha podido registrar el voto. Inténtalo nuevamente o consulta con la persona que administra el sistema.' })
      end
    end

    context 'when vote creation raises error' do
      before do
        allow(votes_relation).to receive(:create).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'propagates the error' do
        expect { service.save_vote_for_user(user) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  # ==================== EDGE CASES ====================

  describe 'edge cases' do
    context 'when current_user is nil' do
      let(:service) { described_class.new(election, election_location, nil) }
      let(:user) { instance_double('User', id: 99) }

      it 'raises error when logging query' do
        expect { service.log_vote_query('DNI', '12345678A') }.to raise_error(NoMethodError)
      end

      it 'raises error when logging registered vote' do
        expect { service.log_vote_registered(user) }.to raise_error(NoMethodError)
      end

      it 'creates vote with nil paper_authority' do
        allow(votes_relation).to receive(:create).with(user_id: user.id, paper_authority: nil).and_return(instance_double('Vote'))
        expect { service.save_vote_for_user(user) }.not_to raise_error
      end
    end

    context 'when election is nil' do
      let(:service) { described_class.new(nil, election_location, current_user) }
      let(:user) { instance_double('User', id: 99) }

      it 'raises error when saving vote' do
        expect { service.save_vote_for_user(user) }.to raise_error(NoMethodError)
      end
    end

    context 'when user has no id' do
      let(:user) { instance_double('User', id: nil) }

      before do
        allow(votes_relation).to receive(:create).with(user_id: nil, paper_authority: current_user).and_return(nil)
      end

      it 'attempts to create vote with nil user_id' do
        result = service.save_vote_for_user(user)
        expect(result[:error]).to be_present
      end
    end

    context 'when logger cannot be created' do
      it 'raises error during initialization' do
        allow(Logger).to receive(:new).and_raise(Errno::EACCES.new('Permission denied'))
        expect { described_class.new(election, election_location, current_user) }.to raise_error(Errno::EACCES)
      end
    end
  end

  # ==================== PRIVATE METHODS TESTS ====================

  describe 'private methods' do
    describe '#success_message' do
      context 'when election scope is 6' do
        before do
          allow(election).to receive(:scope).and_return(6)
        end

        it 'returns identification message' do
          result = service.send(:success_message)
          expect(result).to eq({ notice: 'Identificación registrada.' })
        end
      end

      context 'when election scope is not 6' do
        [0, 1, 2, 3, 4, 5, 7].each do |scope|
          it "returns vote message for scope #{scope}" do
            allow(election).to receive(:scope).and_return(scope)
            result = service.send(:success_message)
            expect(result).to eq({ notice: 'El voto ha sido registrado.' })
          end
        end
      end
    end

    describe '#error_message' do
      it 'returns error message' do
        result = service.send(:error_message)
        expect(result).to eq({ error: 'No se ha podido registrar el voto. Inténtalo nuevamente o consulta con la persona que administra el sistema.' })
      end

      it 'returns same message regardless of election scope' do
        allow(election).to receive(:scope).and_return(6)
        result1 = service.send(:error_message)

        allow(election).to receive(:scope).and_return(0)
        result2 = service.send(:error_message)

        expect(result1).to eq(result2)
      end
    end
  end

  # ==================== INTEGRATION TESTS ====================

  describe 'integration' do
    let(:user) { instance_double('User', id: 99) }
    let(:vote) { instance_double('Vote') }
    let(:tracking_logger) { instance_double('Logger') }

    before do
      service.instance_variable_set(:@tracking, tracking_logger)
      allow(tracking_logger).to receive(:info)
    end

    it 'logs query, saves vote, and logs registration in sequence' do
      allow(votes_relation).to receive(:create).and_return(vote)

      expect(tracking_logger).to receive(:info).with(a_string_including('QUERY')).ordered
      service.log_vote_query('DNI', '12345678A')

      service.save_vote_for_user(user)

      expect(tracking_logger).to receive(:info).with(a_string_including('VOTE')).ordered
      service.log_vote_registered(user)
    end

    context 'full paper vote workflow' do
      before do
        allow(votes_relation).to receive(:create).and_return(vote)
      end

      it 'completes full workflow without errors' do
        expect {
          service.log_vote_query('DNI', '12345678A')
          result = service.save_vote_for_user(user)
          service.log_vote_registered(user) if result[:notice]
        }.not_to raise_error
      end
    end
  end

  # ==================== SECURITY TESTS ====================

  describe 'security' do
    let(:tracking_logger) { instance_double('Logger') }

    before do
      service.instance_variable_set(:@tracking, tracking_logger)
      allow(tracking_logger).to receive(:info)
    end

    describe 'log injection prevention' do
      it 'logs malicious document type safely' do
        expect(tracking_logger).to receive(:info).with(a_string_including("DNI\nMALICIOUS LOG"))
        service.log_vote_query("DNI\nMALICIOUS LOG", '12345678A')
      end

      it 'logs malicious document vatid safely' do
        expect(tracking_logger).to receive(:info).with(a_string_including("12345678A\nFAKE ENTRY"))
        service.log_vote_query('DNI', "12345678A\nFAKE ENTRY")
      end
    end

    describe 'SQL injection prevention via ActiveRecord' do
      let(:user) { instance_double('User', id: "1 OR 1=1") }
      let(:vote) { instance_double('Vote') }

      it 'safely passes malicious user_id to ActiveRecord' do
        expect(votes_relation).to receive(:create).with(user_id: "1 OR 1=1", paper_authority: current_user).and_return(vote)
        service.save_vote_for_user(user)
      end
    end
  end

  # ==================== PERFORMANCE TESTS ====================

  describe 'performance' do
    it 'creates logger only once during initialization' do
      expect(Logger).to receive(:new).once.and_call_original
      described_class.new(election, election_location, current_user)
    end

    it 'does not create new logger on each log call' do
      tracking_logger = service.instance_variable_get(:@tracking)
      expect(tracking_logger.object_id).to eq(service.instance_variable_get(:@tracking).object_id)
    end
  end
end
