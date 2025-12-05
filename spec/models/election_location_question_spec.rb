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
      expect(question.errors[:title]).to include('no puede estar en blanco')
    end

    it 'requires voting_system' do
      question = build(:election_location_question, voting_system: nil)
      expect(question).not_to be_valid
      expect(question.errors[:voting_system]).to include('no puede estar en blanco')
    end

    it 'requires winners' do
      question = build(:election_location_question, winners: nil)
      expect(question).not_to be_valid
      expect(question.errors[:winners]).to include('no puede estar en blanco')
    end

    it 'requires minimum' do
      question = build(:election_location_question, minimum: nil)
      expect(question).not_to be_valid
      expect(question.errors[:minimum]).to include('no puede estar en blanco')
    end

    it 'requires maximum' do
      question = build(:election_location_question, maximum: nil)
      expect(question).not_to be_valid
      expect(question.errors[:maximum]).to include('no puede estar en blanco')
    end

    it 'requires totals' do
      question = build(:election_location_question, totals: nil)
      expect(question).not_to be_valid
      expect(question.errors[:totals]).to include('no puede estar en blanco')
    end

    it 'requires options' do
      question = build(:election_location_question)
      question[:options] = nil # Set directly to avoid getter calling headers.keys
      expect(question).not_to be_valid
      expect(question.errors[:options]).to include('no puede estar en blanco')
    end
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  describe 'after_initialize callback' do
    it 'sets defaults when title is blank' do
      election_location = build(:election_location)
      question = ElectionLocationQuestion.new(election_location: election_location)
      expect(question.voting_system).to eq(ElectionLocationQuestion::VOTING_SYSTEMS.keys.first)
      expect(question.totals).to eq(ElectionLocationQuestion::TOTALS.keys.first)
      expect(question.random_order).to eq(true)
      expect(question.winners).to eq(1)
      expect(question.minimum).to eq(0)
      expect(question.maximum).to eq(1)
    end

    it 'does not override when title is present' do
      election_location = build(:election_location)
      question = ElectionLocationQuestion.new(
        election_location: election_location,
        title: 'Test',
        voting_system: 'pairwise-beta',
        winners: 5
      )
      expect(question.title).to eq('Test')
      expect(question.voting_system).to eq('pairwise-beta')
      expect(question.winners).to eq(5)
    end

    it 'sets all default values in after_initialize' do
      election_location = build(:election_location)
      question = ElectionLocationQuestion.new(election_location: election_location, title: nil)
      # Verify each default assignment happens
      expect(question.voting_system).to eq('plurality-at-large')
      expect(question.totals).to eq('over-total-valid-votes')
      expect(question.random_order).to be true
      expect(question.winners).to eq(1)
      expect(question.minimum).to eq(0)
      expect(question.maximum).to eq(1)
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
        result = question.layout
        expect(result).to eq('simple')
      end

      it 'returns empty string for election layouts' do
        election_location = build(:election_location, layout: 'pcandidates-election')
        question = build(:election_location_question, election_location: election_location, voting_system: 'plurality-at-large')
        result = question.layout
        expect(result).to eq('')
      end

      it 'returns empty string for 2questions-conditional layout' do
        election_location = build(:election_location, layout: '2questions-conditional')
        question = build(:election_location_question, election_location: election_location, voting_system: 'plurality-at-large')
        result = question.layout
        expect(result).to eq('')
      end

      it 'returns election_location layout for non-election layouts' do
        election_location = build(:election_location, layout: 'simple')
        question = build(:election_location_question, election_location: election_location, voting_system: 'plurality-at-large')
        result = question.layout
        expect(result).to eq('simple')
      end

      it 'returns election_location layout for accordion layout' do
        election_location = build(:election_location, layout: 'accordion')
        question = build(:election_location_question, election_location: election_location, voting_system: 'plurality-at-large')
        result = question.layout
        expect(result).to eq('accordion')
      end

      it 'returns election_location layout for simultaneous-questions layout' do
        election_location = build(:election_location, layout: 'simultaneous-questions')
        question = build(:election_location_question, election_location: election_location, voting_system: 'plurality-at-large')
        result = question.layout
        expect(result).to eq('simultaneous-questions')
      end
    end

    describe '#options_headers' do
      it 'returns array split by tab' do
        question = build(:election_location_question)
        question[:options_headers] = "Text\tImage\tURL"
        result = question.options_headers
        expect(result).to eq(%w[Text Image URL])
      end

      it 'returns single element array split by tab' do
        question = build(:election_location_question)
        question[:options_headers] = 'Text'
        result = question.options_headers
        expect(result).to eq(['Text'])
      end

      it 'returns default headers when options_headers is nil' do
        # Mock the class method to return headers
        mock_headers = { 'text' => 'Text', 'url' => 'URL' }
        allow(ElectionLocationQuestion).to receive(:headers).and_return(mock_headers)

        question = build(:election_location_question)
        question[:options_headers] = nil
        result = question.options_headers

        expect(result).to eq(['text'])
      end
    end

    describe '#options_headers=' do
      it 'sets tab-separated string from array' do
        question = build(:election_location_question)
        question.options_headers = %w[Name Description URL]
        expect(question[:options_headers]).to eq("Name\tDescription\tURL")
      end

      it 'filters empty values' do
        question = build(:election_location_question)
        question.options_headers = ['Name', '', 'URL', nil]
        expect(question[:options_headers]).to eq("Name\tURL")
      end

      it 'handles nil value by not setting' do
        question = build(:election_location_question)
        original_headers = question[:options_headers]
        question.options_headers = nil
        expect(question[:options_headers]).to eq(original_headers)
      end

      it 'handles empty array' do
        question = build(:election_location_question)
        original_headers = question[:options_headers]
        question.options_headers = []
        expect(question[:options_headers]).to eq(original_headers)
      end

      it 'handles array with only blank values' do
        question = build(:election_location_question)
        original_headers = question[:options_headers]
        question.options_headers = ['', nil, '  ']
        expect(question[:options_headers]).to eq(original_headers)
      end
    end

    describe '#options=' do
      it 'processes multi-line tab-separated options' do
        question = build(:election_location_question)
        question.options_headers = %w[Text URL]
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

      it 'handles options with multiple tabs' do
        question = build(:election_location_question)
        question.options_headers = %w[Text Image URL Description]
        question.options = "Opt1\timg1.jpg\turl1\tDesc1\nOpt2\timg2.jpg\turl2\tDesc2"

        expected = "Opt1\timg1.jpg\turl1\tDesc1\nOpt2\timg2.jpg\turl2\tDesc2"
        expect(question[:options]).to eq(expected)
      end

      it 'handles single option' do
        question = build(:election_location_question)
        question.options_headers = ['Text']
        question.options = "Single Option"

        expect(question[:options]).to eq("Single Option")
      end

      it 'handles options with mixed whitespace' do
        question = build(:election_location_question)
        question.options_headers = ['Text']
        question.options = " Option 1 \n\n  Option 2  \n   \nOption 3"

        expected = "Option 1\nOption 2\nOption 3"
        expect(question[:options]).to eq(expected)
      end

      it 'processes options correctly with headers set' do
        question = build(:election_location_question)
        question.options_headers = %w[Text URL]
        # The options= method calls options_headers.length internally
        question.options = "Option 1\thttp://example.com/1"
        expect(question[:options]).to eq("Option 1\thttp://example.com/1")
      end

      it 'handles lines with no fields after strip' do
        question = build(:election_location_question)
        question.options_headers = ['Text']
        question.options = "Option 1\n\t\nOption 2"

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
      it 'returns agora options headers from Rails secrets' do
        # Mock the Rails secrets
        mock_secrets = double('secrets', agora: { 'options_headers' => { 'text' => 'Text', 'url' => 'URL' } })
        allow(Rails.application).to receive(:secrets).and_return(mock_secrets)

        # Clear the class variable to force reload
        ElectionLocationQuestion.class_variable_set(:@@headers, nil) if ElectionLocationQuestion.class_variable_defined?(:@@headers)

        headers = ElectionLocationQuestion.headers
        expect(headers).to eq({ 'text' => 'Text', 'url' => 'URL' })
      end

      it 'caches headers in class variable' do
        mock_secrets = double('secrets', agora: { 'options_headers' => { 'cached' => 'Value' } })
        allow(Rails.application).to receive(:secrets).and_return(mock_secrets)

        ElectionLocationQuestion.class_variable_set(:@@headers, nil) if ElectionLocationQuestion.class_variable_defined?(:@@headers)

        # First call should hit secrets
        first_call = ElectionLocationQuestion.headers
        # Second call should use cached value
        second_call = ElectionLocationQuestion.headers

        expect(first_call).to eq(second_call)
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

    it 'freezes VOTING_SYSTEMS constant' do
      expect(ElectionLocationQuestion::VOTING_SYSTEMS).to be_frozen
    end

    it 'freezes TOTALS constant' do
      expect(ElectionLocationQuestion::TOTALS).to be_frozen
    end
  end

  # ====================
  # INTEGRATION TESTS
  # ====================

  describe 'integration scenarios' do
    it 'creates and saves valid question with all attributes' do
      election_location = create(:election_location)
      question = ElectionLocationQuestion.new(
        election_location: election_location,
        title: 'Test Question',
        description: 'Test Description',
        voting_system: 'plurality-at-large',
        totals: 'over-total-valid-votes',
        random_order: false,
        winners: 2,
        minimum: 1,
        maximum: 3
      )
      question[:options_headers] = 'Text'
      question[:options] = 'Option A'

      expect(question.save).to be_truthy
      expect(question.persisted?).to be_truthy
    end

    it 'loads question from database and accesses all methods' do
      question = create(:election_location_question)
      loaded = ElectionLocationQuestion.find(question.id)

      expect(loaded.title).to eq(question.title)
      expect(loaded.layout).to eq(question.layout)
      expect(loaded.options_headers).to be_a(Array)
    end

    it 'updates question options after creation' do
      question = create(:election_location_question)
      question.options = "New Option 1\nNew Option 2"
      question.save!

      reloaded = ElectionLocationQuestion.find(question.id)
      expect(reloaded[:options]).to include('New Option')
    end
  end

  # ====================
  # EDGE CASES
  # ====================

  describe 'edge cases' do
    it 'handles blank title in after_initialize' do
      question = ElectionLocationQuestion.new(title: '')
      expect(question.voting_system).to eq(ElectionLocationQuestion::VOTING_SYSTEMS.keys.first)
    end

    it 'handles whitespace-only title in after_initialize' do
      question = ElectionLocationQuestion.new(title: '   ')
      # After trim, blank? is still false for whitespace-only strings in Ruby
      # but the initialization doesn't run because blank? returns false
      expect(question.title).to eq('   ')
    end

    it 'preserves existing values when title is not blank' do
      question = ElectionLocationQuestion.new(
        title: 'Test',
        voting_system: 'pairwise-beta',
        totals: 'custom-total',
        random_order: false,
        winners: 5,
        minimum: 2,
        maximum: 10
      )

      expect(question.voting_system).to eq('pairwise-beta')
      expect(question.totals).to eq('custom-total')
      expect(question.random_order).to eq(false)
      expect(question.winners).to eq(5)
      expect(question.minimum).to eq(2)
      expect(question.maximum).to eq(10)
    end

    it 'handles question with very long options' do
      question = build(:election_location_question)
      question.options_headers = ['Text']
      long_options = 100.times.map { |i| "Option #{i}" }.join("\n")
      question.options = long_options

      expect(question[:options].split("\n").length).to eq(100)
    end
  end
end
