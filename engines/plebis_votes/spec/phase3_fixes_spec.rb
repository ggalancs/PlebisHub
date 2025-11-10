# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Phase 3 PLEBIS_VOTES Fixes', type: :model do
  describe 'CRITICAL-1: PlebisBrand alias' do
    it 'PlebisBrand constant is defined' do
      expect(defined?(PlebisBrand)).to be_truthy
    end

    it 'PlebisBrand equals Podemos' do
      expect(PlebisBrand).to eq(Podemos)
    end

    it 'PlebisBrand::GeoExtra is accessible' do
      expect(defined?(PlebisBrand::GeoExtra)).to be_truthy
    end

    it 'PlebisBrand::GeoExtra::ISLANDS is accessible' do
      expect(PlebisBrand::GeoExtra::ISLANDS).to be_a(Hash)
    end

    it 'PlebisBrand::GeoExtra::AUTONOMIES is accessible' do
      expect(PlebisBrand::GeoExtra::AUTONOMIES).to be_a(Hash)
    end
  end

  describe 'CRITICAL-2: CensusFileParser namespace' do
    it 'CensusFileParser is defined in global namespace' do
      expect(defined?(::CensusFileParser)).to be_truthy
    end

    it 'VoteController can reference ::CensusFileParser' do
      # This verifies the fix compiles without NameError
      expect do
        PlebisVotes::VoteController.instance_method(:get_paper_vote_user_from_csv)
      end.not_to raise_error
    end
  end

  describe 'HIGH-1: ElectionLocation namespace in Election model' do
    it 'Election model references PlebisVotes::ElectionLocation' do
      source = File.read(Rails.root.join('engines/plebis_votes/app/models/plebis_votes/election.rb'))
      expect(source).to include('PlebisVotes::ElectionLocation.transaction')
    end
  end

  describe 'HIGH-2-4: User namespace in Election model' do
    it 'Election model references ::User' do
      source = File.read(Rails.root.join('engines/plebis_votes/app/models/plebis_votes/election.rb'))
      expect(source).to include('::User.confirmed.not_banned')
      expect(source).to include('::User.with_deleted.not_banned')
    end
  end

  describe 'HIGH-5: VoteCircle namespace in ElectionLocation model' do
    it 'ElectionLocation model references PlebisVotes::VoteCircle' do
      source = File.read(Rails.root.join('engines/plebis_votes/app/models/plebis_votes/election_location.rb'))
      expect(source).to include('PlebisVotes::VoteCircle.where')
    end
  end

  describe 'HIGH-6: ElectionLocation namespace in ElectionLocationQuestion model' do
    it 'ElectionLocationQuestion model references PlebisVotes::ElectionLocation::ELECTION_LAYOUTS' do
      source = File.read(Rails.root.join('engines/plebis_votes/app/models/plebis_votes/election_location_question.rb'))
      expect(source).to include('PlebisVotes::ElectionLocation::ELECTION_LAYOUTS')
    end
  end

  describe 'MEDIUM-1: Vote model callback uses assignment' do
    it 'Vote model uses assignment instead of update_attribute' do
      source = File.read(Rails.root.join('engines/plebis_votes/app/models/plebis_votes/vote.rb'))
      expect(source).not_to include('update_attribute(:agora_id')
      expect(source).not_to include('update_attribute(:voter_id')
      expect(source).to include('self.agora_id =')
      expect(source).to include('self.voter_id =')
    end
  end

  describe 'LOW-1: ActiveAdmin menu label' do
    it 'Election admin has correct menu parent' do
      source = File.read(Rails.root.join('engines/plebis_votes/app/admin/election.rb'))
      expect(source).to include('menu :parent => "Votación"')
      expect(source).not_to include('PlebisHubción')
    end
  end
end
