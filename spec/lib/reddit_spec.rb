# frozen_string_literal: true

require 'rails_helper'
require_relative '../../lib/reddit'

RSpec.describe Reddit do
  let(:subreddit_name) { 'testsubreddit' }
  let(:reddit) { described_class.new(subreddit_name) }

  describe '#initialize' do
    it 'sets the base_url' do
      expect(reddit.base_url).to eq("https://api.reddit.com/r/#{subreddit_name}")
    end

    it 'sets default filter to top' do
      expect(reddit.filter).to eq('top')
    end

    it 'sets default limit to 100' do
      expect(reddit.limit).to eq(100)
    end

    it 'accepts different subreddit names' do
      custom_reddit = described_class.new('politics')
      expect(custom_reddit.base_url).to eq('https://api.reddit.com/r/politics')
    end
  end

  describe '#url' do
    it 'returns the correct API URL' do
      expected_url = 'https://api.reddit.com/r/testsubreddit/search?q=flair%3APropuestas' \
                     '&sort=top&restrict_sr=on&t=all&limit=100'
      expect(reddit.url).to eq(expected_url)
    end

    it 'uses the configured filter' do
      reddit.filter = 'new'
      expect(reddit.url).to include('&sort=new')
    end

    it 'uses the configured limit' do
      reddit.limit = 50
      expect(reddit.url).to include('&limit=50')
    end

    it 'includes flair filter for Propuestas' do
      expect(reddit.url).to include('q=flair%3APropuestas')
    end

    it 'restricts search to subreddit' do
      expect(reddit.url).to include('restrict_sr=on')
    end

    it 'searches all time' do
      expect(reddit.url).to include('t=all')
    end
  end

  describe '#proposals' do
    let(:mock_response) do
      {
        'data' => {
          'children' => [
            { 'data' => { 'title' => 'Proposal 1' } },
            { 'data' => { 'title' => 'Proposal 2' } }
          ]
        }
      }.to_json
    end

    it 'fetches and parses JSON from the URL' do
      allow(reddit).to receive(:open).with(reddit.url).and_return(StringIO.new(mock_response))

      proposals = reddit.proposals(reddit.url)
      expect(proposals).to be_an(Array)
      expect(proposals.length).to eq(2)
    end

    it 'returns the children array from the response' do
      allow(reddit).to receive(:open).with(reddit.url).and_return(StringIO.new(mock_response))

      proposals = reddit.proposals(reddit.url)
      expect(proposals[0]['data']['title']).to eq('Proposal 1')
      expect(proposals[1]['data']['title']).to eq('Proposal 2')
    end

    it 'handles empty response' do
      empty_response = { 'data' => { 'children' => [] } }.to_json
      allow(reddit).to receive(:open).with(reddit.url).and_return(StringIO.new(empty_response))

      proposals = reddit.proposals(reddit.url)
      expect(proposals).to be_empty
    end
  end

  describe '#map' do
    let(:reddit_data) do
      {
        'title' => 'Test Proposal',
        'selftext' => 'This is a test proposal',
        'ups' => 42,
        'author' => 'testuser',
        'url' => 'https://reddit.com/r/test/comments/abc123',
        'name' => 't3_abc123'
      }
    end

    it 'maps title correctly' do
      result = reddit.map(reddit_data)
      expect(result[:title]).to eq('Test Proposal')
    end

    it 'maps description from selftext' do
      result = reddit.map(reddit_data)
      expect(result[:description]).to eq('This is a test proposal')
    end

    it 'maps votes from ups' do
      result = reddit.map(reddit_data)
      expect(result[:votes]).to eq(42)
    end

    it 'maps author correctly' do
      result = reddit.map(reddit_data)
      expect(result[:author]).to eq('testuser')
    end

    it 'maps reddit_url correctly' do
      result = reddit.map(reddit_data)
      expect(result[:reddit_url]).to eq('https://reddit.com/r/test/comments/abc123')
    end

    it 'maps reddit_id from name field' do
      result = reddit.map(reddit_data)
      expect(result[:reddit_id]).to eq('t3_abc123')
    end

    it 'returns a hash with all expected keys' do
      result = reddit.map(reddit_data)
      expect(result.keys).to contain_exactly(:title, :description, :votes, :author, :reddit_url, :reddit_id)
    end

    it 'handles nil values' do
      data_with_nils = reddit_data.merge('selftext' => nil, 'author' => nil)
      result = reddit.map(data_with_nils)
      expect(result[:description]).to be_nil
      expect(result[:author]).to be_nil
    end
  end

  describe '#create_or_update' do
    let(:proposal_data) do
      {
        'data' => {
          'title' => 'New Proposal',
          'selftext' => 'Description here',
          'ups' => 10,
          'author' => 'reddit_user',
          'url' => 'https://reddit.com/r/test/comments/xyz',
          'name' => 't3_xyz'
        }
      }
    end

    let(:mapped_params) do
      {
        title: 'New Proposal',
        description: 'Description here',
        votes: 10,
        author: 'reddit_user',
        reddit_url: 'https://reddit.com/r/test/comments/xyz',
        reddit_id: 't3_xyz'
      }
    end

    before do
      allow(Proposal).to receive(:where).and_call_original
    end

    it 'creates a new proposal if it does not exist' do
      mock_proposal = instance_double(Proposal)
      allow(Proposal).to receive(:where).with(reddit_id: 't3_xyz').and_return(
        double(first_or_initialize: mock_proposal)
      )
      expect(mock_proposal).to receive(:update!).with(mapped_params)

      reddit.create_or_update(proposal_data)
    end

    it 'updates existing proposal' do
      existing_proposal = instance_double(Proposal)
      allow(Proposal).to receive(:where).with(reddit_id: 't3_xyz').and_return(
        double(first_or_initialize: existing_proposal)
      )
      expect(existing_proposal).to receive(:update!).with(mapped_params)

      reddit.create_or_update(proposal_data)
    end

    it 'maps the proposal data before updating' do
      mock_proposal = instance_double(Proposal)
      allow(Proposal).to receive(:where).and_return(double(first_or_initialize: mock_proposal))
      allow(mock_proposal).to receive(:update!)

      expect(reddit).to receive(:map).with(proposal_data['data']).and_call_original

      reddit.create_or_update(proposal_data)
    end

    it 'uses reddit_id to find or initialize proposal' do
      mock_proposal = instance_double(Proposal)
      expect(Proposal).to receive(:where).with(reddit_id: 't3_xyz').and_return(
        double(first_or_initialize: mock_proposal)
      )
      allow(mock_proposal).to receive(:update!)

      reddit.create_or_update(proposal_data)
    end
  end

  describe '#extract' do
    let(:mock_proposals) do
      [
        { 'data' => { 'title' => 'Proposal 1', 'selftext' => 'Text 1', 'ups' => 5,
                      'author' => 'user1', 'url' => 'url1', 'name' => 'id1' } },
        { 'data' => { 'title' => 'Proposal 2', 'selftext' => 'Text 2', 'ups' => 10,
                      'author' => 'user2', 'url' => 'url2', 'name' => 'id2' } }
      ]
    end

    it 'fetches proposals from the URL' do
      expect(reddit).to receive(:proposals).with(reddit.url).and_return(mock_proposals)
      allow(reddit).to receive(:create_or_update)

      reddit.extract
    end

    it 'creates or updates each proposal' do
      allow(reddit).to receive(:proposals).and_return(mock_proposals)
      expect(reddit).to receive(:create_or_update).with(mock_proposals[0])
      expect(reddit).to receive(:create_or_update).with(mock_proposals[1])

      reddit.extract
    end

    it 'processes all proposals' do
      allow(reddit).to receive(:proposals).and_return(mock_proposals)
      expect(reddit).to receive(:create_or_update).exactly(2).times

      reddit.extract
    end

    it 'handles empty proposal list' do
      allow(reddit).to receive(:proposals).and_return([])
      expect(reddit).not_to receive(:create_or_update)

      reddit.extract
    end
  end

  describe 'attribute accessors' do
    it 'allows setting and getting base_url' do
      reddit.base_url = 'https://custom.url'
      expect(reddit.base_url).to eq('https://custom.url')
    end

    it 'allows setting and getting filter' do
      reddit.filter = 'new'
      expect(reddit.filter).to eq('new')
    end

    it 'allows setting and getting limit' do
      reddit.limit = 25
      expect(reddit.limit).to eq(25)
    end
  end

  describe 'integration scenarios' do
    it 'constructs correct URL with custom settings' do
      reddit.filter = 'hot'
      reddit.limit = 50
      expected_url = 'https://api.reddit.com/r/testsubreddit/search?q=flair%3APropuestas' \
                     '&sort=hot&restrict_sr=on&t=all&limit=50'
      expect(reddit.url).to eq(expected_url)
    end
  end
end
