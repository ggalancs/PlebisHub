# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ElectionLocationQuestion, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid election_location_question' do
      question = build(:election_location_question)
      expect(question).to be_valid, "Factory should create valid question. Errors: #{question.errors.full_messages.join(', ')}"
    end

    it 'creates valid question with pairwise trait' do
      question = build(:election_location_question, :pairwise)
      expect(question).to be_valid, "Factory with pairwise trait should be valid. Errors: #{question.errors.full_messages.join(', ')}"
      expect(question.voting_system).to eq('pairwise-beta')
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to election_location' do
      question = create(:election_location_question)
      expect(question).to respond_to(:election_location)
      expect(question.election_location).to be_a(ElectionLocation)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'requires title' do
      question = build(:election_location_question, title: nil)
      expect(question).not_to be_valid
      expect(question.errors[:title]).to include("no puede estar en blanco")
    end

    it 'requires voting_system' do
      question = build(:election_location_question, voting_system: nil)
      expect(question).not_to be_valid
      expect(question.errors[:voting_system]).to include("no puede estar en blanco")
    end

    it 'requires winners' do
      question = build(:election_location_question, winners: nil)
      expect(question).not_to be_valid
      expect(question.errors[:winners]).to include("no puede estar en blanco")
    end

    it 'requires minimum' do
      question = build(:election_location_question, minimum: nil)
      expect(question).not_to be_valid
      expect(question.errors[:minimum]).to include("no puede estar en blanco")
    end

    it 'requires maximum' do
      question = build(:election_location_question, maximum: nil)
      expect(question).not_to be_valid
      expect(question.errors[:maximum]).to include("no puede estar en blanco")
    end

    it 'requires totals' do
      question = build(:election_location_question, totals: nil)
      expect(question).not_to be_valid
      expect(question.errors[:totals]).to include("no puede estar en blanco")
    end

    it 'requires options' do
      question = build(:election_location_question)
      question[:options] = nil  # Set directly to avoid getter calling headers.keys
      expect(question).not_to be_valid
      expect(question.errors[:options]).to include("no puede estar en blanco")
    end
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  describe 'after_initialize callback' do
    it 'sets defaults when title is blank' do
      question = ElectionLocationQuestion.new
      expect(question.voting_system).to eq(ElectionLocationQuestion::VOTING_SYSTEMS.keys.first)
      expect(question.totals).to eq(ElectionLocationQuestion::TOTALS.keys.first)
      expect(question.random_order).to eq(true)
      expect(question.winners).to eq(1)
      expect(question.minimum).to eq(0)
      expect(question.maximum).to eq(1)
    end

    it 'does not override when title is present' do
      question = ElectionLocationQuestion.new(title: 'Test', voting_system: 'pairwise-beta', winners: 5)
      expect(question.title).to eq('Test')
      expect(question.voting_system).to eq('pairwise-beta')
      expect(question.winners).to eq(5)
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#layout' do
      it 'returns simple for pairwise-beta voting system' do
        election_location = build(:election_location, layout: 'pcandidates-election')
        question = build(:election_location_question, :pairwise, election_location: election_location)
        expect(question.layout).to eq('simple')
      end

      it 'returns empty string for election layouts' do
        election_location = build(:election_location, layout: 'pcandidates-election')
        question = build(:election_location_question, election_location: election_location, voting_system: 'plurality-at-large')
        expect(question.layout).to eq('')
      end

      it 'returns election_location layout for non-election layouts' do
        election_location = build(:election_location, layout: 'simple')
        question = build(:election_location_question, election_location: election_location, voting_system: 'plurality-at-large')
        expect(question.layout).to eq('simple')
      end
    end

    describe '#options_headers' do
      it 'returns array split by tab' do
        question = build(:election_location_question)
        question[:options_headers] = "Text\tImage\tURL"
        expect(question.options_headers).to eq(['Text', 'Image', 'URL'])
      end

      it 'returns default when nil' do
        skip('Requires Rails.application.secrets.agora["options_headers"] configuration')
        # This would test: question[:options_headers] = nil; question.options_headers
        # But Rails secrets not configured in test environment
      end
    end

    describe '#options_headers=' do
      it 'sets tab-separated string from array' do
        question = build(:election_location_question)
        question.options_headers = ['Name', 'Description', 'URL']
        expect(question[:options_headers]).to eq("Name\tDescription\tURL")
      end

      it 'filters empty values' do
        question = build(:election_location_question)
        question.options_headers = ['Name', '', 'URL', nil]
        expect(question[:options_headers]).to eq("Name\tURL")
      end
    end

    describe '#options=' do
      it 'processes multi-line tab-separated options' do
        question = build(:election_location_question)
        question.options_headers = ['Text', 'URL']
        question.options = "Option 1\thttp://example.com/1\nOption 2\thttp://example.com/2"

        expected = "Option 1\thttp://example.com/1\nOption 2\thttp://example.com/2"
        expect(question[:options]).to eq(expected)
      end

      it 'strips whitespace from options' do
        question = build(:election_location_question)
        question.options_headers = ['Text']
        question.options = "  Option 1  \n  Option 2  \n"

        expected = "Option 1\nOption 2"
        expect(question[:options]).to eq(expected)
      end

      it 'handles empty lines' do
        question = build(:election_location_question)
        question.options_headers = ['Text']
        question.options = "Option 1\n\nOption 2\n\n"

        expected = "Option 1\nOption 2"
        expect(question[:options]).to eq(expected)
      end
    end
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  describe 'class methods' do
    describe '.headers' do
      it 'returns agora options headers' do
        skip('Requires Rails.application.secrets.agora configuration')
        # This depends on test environment secrets configuration
        headers = ElectionLocationQuestion.headers
        expect(headers).to be_a(Hash)
      end
    end
  end

  # ====================
  # CONSTANTS TESTS
  # ====================

  describe 'constants' do
    it 'defines VOTING_SYSTEMS constant' do
      expect(ElectionLocationQuestion::VOTING_SYSTEMS).to be_a(Hash)
      expect(ElectionLocationQuestion::VOTING_SYSTEMS.keys).to include('plurality-at-large')
      expect(ElectionLocationQuestion::VOTING_SYSTEMS.keys).to include('pairwise-beta')
    end

    it 'defines TOTALS constant' do
      expect(ElectionLocationQuestion::TOTALS).to be_a(Hash)
      expect(ElectionLocationQuestion::TOTALS.keys).to include('over-total-valid-votes')
    end
  end
end
