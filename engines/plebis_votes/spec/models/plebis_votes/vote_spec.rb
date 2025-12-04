# frozen_string_literal: true

require 'rails_helper'

module PlebisVotes
  RSpec.describe Vote, type: :model do
    let(:user) { create(:user) }
    let(:election) do
      Election.create!(
        title: 'Test Election',
        starts_at: 1.day.ago,
        ends_at: 1.day.from_now,
        agora_election_id: 12_345,
        scope: 0,
        counter_key: 'test_counter_key_123'
      )
    end

    let(:vote) do
      Vote.new(
        user: user,
        election: election
      )
    end

    describe 'paranoia' do
      it 'uses acts_as_paranoid' do
        expect(Vote.ancestors.map(&:to_s)).to include('Paranoia')
      end

      it 'soft deletes instead of hard delete' do
        vote.save!
        vote.destroy
        expect(vote.deleted_at).not_to be_nil
        expect(Vote.with_deleted.find_by(id: vote.id)).to eq(vote)
      end
    end

    describe 'associations' do
      it 'belongs to user' do
        expect(vote.user).to eq(user)
      end

      it 'belongs to election' do
        expect(vote.election).to eq(election)
      end

      it 'can belong to paper_authority' do
        authority = create(:user)
        vote.paper_authority = authority
        vote.save!
        expect(vote.paper_authority).to eq(authority)
      end

      it 'allows nil paper_authority' do
        vote.paper_authority = nil
        vote.save!
        expect(vote.paper_authority).to be_nil
      end

      it 'requires user' do
        vote.user = nil
        expect(vote.valid?).to be_falsey
      end

      it 'requires election' do
        vote.election = nil
        expect(vote.valid?).to be_falsey
      end
    end

    describe 'validations' do
      before do
        vote.save!
      end

      it 'requires voter_id' do
        vote_without_id = Vote.new(user: user, election: election)
        vote_without_id.voter_id = nil
        expect(vote_without_id.valid?).to be_falsey
        expect(vote_without_id.errors[:voter_id]).to include("can't be blank")
      end

      it 'requires unique voter_id scoped to user' do
        duplicate_vote = Vote.new(
          user: user,
          election: election,
          voter_id: vote.voter_id
        )
        expect(duplicate_vote.valid?).to be_falsey
        expect(duplicate_vote.errors[:voter_id]).to include('has already been taken')
      end

      it 'allows same voter_id for different users' do
        other_user = create(:user)
        other_vote = Vote.new(
          user: other_user,
          election: election,
          voter_id: vote.voter_id
        )
        expect(other_vote.valid?).to be_truthy
      end
    end

    describe 'callbacks' do
      describe 'before_validation on create' do
        it 'generates voter_id automatically' do
          new_vote = Vote.new(user: user, election: election)
          new_vote.save
          expect(new_vote.voter_id).to be_present
          expect(new_vote.voter_id.length).to eq(64)
        end

        it 'generates agora_id automatically' do
          new_vote = Vote.new(user: user, election: election)
          new_vote.save
          expect(new_vote.agora_id).to be_present
        end

        it 'adds error when election is missing' do
          new_vote = Vote.new(user: user, election: nil)
          new_vote.valid?
          expect(new_vote.errors[:voter_id]).to include('No se pudo generar')
        end

        it 'adds error when user is missing' do
          new_vote = Vote.new(user: nil, election: election)
          new_vote.valid?
          expect(new_vote.errors[:voter_id]).to include('No se pudo generar')
        end
      end
    end

    describe '#generate_voter_id' do
      it 'generates a SHA256 hash' do
        voter_id = vote.generate_voter_id
        expect(voter_id).to be_a(String)
        expect(voter_id.length).to eq(64)
        expect(voter_id).to match(/^[a-f0-9]{64}$/)
      end

      it 'generates different IDs for different users' do
        other_user = create(:user)
        vote1 = Vote.new(user: user, election: election)
        vote2 = Vote.new(user: other_user, election: election)
        expect(vote1.generate_voter_id).not_to eq(vote2.generate_voter_id)
      end

      it 'uses default template when voter_id_template is nil' do
        election.voter_id_template = nil
        voter_id = vote.generate_voter_id
        expect(voter_id).to be_present
      end

      it 'uses custom template when provided' do
        election.voter_id_template = '%<user_id>s:%<election_id>s'
        voter_id = vote.generate_voter_id
        expect(voter_id).to be_present
      end
    end

    describe '#scoped_agora_election_id' do
      it 'delegates to election' do
        expect(election).to receive(:scoped_agora_election_id).with(user)
        vote.scoped_agora_election_id
      end
    end

    describe '#generate_message' do
      before do
        vote.save!
      end

      it 'generates message with voter_id' do
        message = vote.generate_message
        expect(message).to include(vote.voter_id)
        expect(message).to include('AuthEvent')
        expect(message).to include('vote')
      end

      it 'includes scoped_agora_election_id' do
        allow(vote).to receive(:scoped_agora_election_id).and_return(999)
        message = vote.generate_message
        expect(message).to include('999')
      end

      it 'includes timestamp' do
        message = vote.generate_message
        expect(message).to match(/:\d+$/)
      end
    end

    describe '#generate_hash' do
      it 'generates HMAC hash' do
        message = 'test_message'
        hash = vote.generate_hash(message)
        expect(hash).to be_a(String)
        expect(hash.length).to eq(64)
        expect(hash).to match(/^[a-f0-9]{64}$/)
      end

      it 'generates different hashes for different messages' do
        hash1 = vote.generate_hash('message1')
        hash2 = vote.generate_hash('message2')
        expect(hash1).not_to eq(hash2)
      end

      it 'generates same hash for same message' do
        message = 'test_message'
        hash1 = vote.generate_hash(message)
        hash2 = vote.generate_hash(message)
        expect(hash1).to eq(hash2)
      end
    end

    describe '#url' do
      before do
        vote.save!
        allow(election).to receive(:server_url).and_return('http://test.com/')
      end

      it 'generates voting URL' do
        url = vote.url
        expect(url).to start_with('http://test.com/booth/')
        expect(url).to include('/vote/')
      end

      it 'includes hash in URL' do
        url = vote.url
        parts = url.split('/')
        expect(parts[-2].length).to eq(64)
      end

      it 'includes message in URL' do
        url = vote.url
        expect(url).to include('AuthEvent')
      end
    end

    describe '#test_url' do
      before do
        vote.save!
        allow(election).to receive(:server_url).and_return('http://test.com/')
      end

      it 'generates test HMAC URL' do
        url = vote.test_url
        expect(url).to start_with('http://test.com/test_hmac/')
      end

      it 'includes shared key' do
        allow(election).to receive(:server_shared_key).and_return('test_key')
        url = vote.test_url
        expect(url).to include('test_key')
      end
    end

    describe '#normalize_identifier' do
      it 'removes non-alphanumeric characters' do
        result = vote.send(:normalize_identifier, 'ABC-123.456')
        expect(result).to eq('ABC123456')
      end

      it 'converts to uppercase' do
        result = vote.send(:normalize_identifier, 'abc123xyz')
        expect(result).to eq('ABC123XYZ')
      end

      it 'removes leading zeros from number groups' do
        result = vote.send(:normalize_identifier, '00123ABC00456')
        expect(result).to eq('123ABC456')
      end

      it 'handles mixed alphanumeric correctly' do
        result = vote.send(:normalize_identifier, '12345678A')
        expect(result).to eq('12345678A')
      end
    end

    describe '#normalized_vatid' do
      it 'prefixes with DNI for spanish NIF' do
        result = vote.send(:normalized_vatid, true, '12345678A')
        expect(result).to start_with('DNI')
      end

      it 'prefixes with PASS for passport' do
        result = vote.send(:normalized_vatid, false, 'ABC123456')
        expect(result).to start_with('PASS')
      end

      it 'normalizes the identifier' do
        result = vote.send(:normalized_vatid, true, '01234567-A')
        expect(result).to eq('DNI1234567A')
      end
    end

    describe '#number?' do
      it 'returns true for digit characters' do
        expect(vote.send(:number?, '0')).to be_truthy
        expect(vote.send(:number?, '9')).to be_truthy
      end

      it 'returns false for letter characters' do
        expect(vote.send(:number?, 'A')).to be_falsey
        expect(vote.send(:number?, 'Z')).to be_falsey
      end
    end

    describe 'NUMBERS constant' do
      it 'defines NUMBERS as a set' do
        expect(Vote::NUMBERS).to be_a(Set)
      end

      it 'includes all digits' do
        ('0'..'9').each do |digit|
          expect(Vote::NUMBERS).to include(digit)
        end
      end
    end

    describe 'voter_id_template_values' do
      it 'provides template values' do
        values = vote.send(:voter_id_template_values)
        expect(values[:user_id]).to eq(user.id)
        expect(values[:election_id]).to eq(election.id)
      end

      it 'memoizes the hash' do
        values1 = vote.send(:voter_id_template_values)
        values2 = vote.send(:voter_id_template_values)
        expect(values1.object_id).to eq(values2.object_id)
      end

      it 'returns placeholder for unknown keys' do
        values = vote.send(:voter_id_template_values)
        expect(values[:unknown_key]).to eq('%<key>s')
      end
    end

    describe 'complete voting workflow' do
      it 'can create, save, and generate URL for vote' do
        new_vote = Vote.create!(user: user, election: election)
        expect(new_vote).to be_persisted
        expect(new_vote.voter_id).to be_present
        expect(new_vote.agora_id).to be_present

        allow(election).to receive(:server_url).and_return('http://test.com/')
        url = new_vote.url
        expect(url).to be_a(String)
        expect(url).to include('http://test.com/booth/')
      end
    end
  end
end
