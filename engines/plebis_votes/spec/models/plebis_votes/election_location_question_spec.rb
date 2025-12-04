# frozen_string_literal: true

require 'rails_helper'

module PlebisVotes
  RSpec.describe ElectionLocationQuestion, type: :model do
    let(:election) do
      Election.create!(
        title: 'Test Election',
        starts_at: 1.day.ago,
        ends_at: 1.day.from_now,
        agora_election_id: 12_345,
        scope: 0
      )
    end

    let(:election_location) do
      ElectionLocation.create!(
        election: election,
        location: '01',
        agora_version: 0,
        title: 'Test Location',
        layout: 'simple',
        theme: 'default'
      )
    end

    let(:question) do
      ElectionLocationQuestion.create!(
        election_location: election_location,
        title: 'Test Question',
        voting_system: 'plurality-at-large',
        winners: 1,
        minimum: 0,
        maximum: 1,
        totals: 'over-total-valid-votes',
        options: 'Option 1'
      )
    end

    describe 'associations' do
      it 'belongs to election_location' do
        expect(question.election_location).to eq(election_location)
      end
    end

    describe 'validations' do
      it 'requires title' do
        question.title = nil
        expect(question.valid?).to be_falsey
        expect(question.errors[:title]).to include("can't be blank")
      end

      it 'requires voting_system' do
        question.voting_system = nil
        expect(question.valid?).to be_falsey
        expect(question.errors[:voting_system]).to include("can't be blank")
      end

      it 'requires winners' do
        question.winners = nil
        expect(question.valid?).to be_falsey
        expect(question.errors[:winners]).to include("can't be blank")
      end

      it 'requires minimum' do
        question.minimum = nil
        expect(question.valid?).to be_falsey
        expect(question.errors[:minimum]).to include("can't be blank")
      end

      it 'requires maximum' do
        question.maximum = nil
        expect(question.valid?).to be_falsey
        expect(question.errors[:maximum]).to include("can't be blank")
      end

      it 'requires totals' do
        question.totals = nil
        expect(question.valid?).to be_falsey
        expect(question.errors[:totals]).to include("can't be blank")
      end

      it 'requires options' do
        question.options = nil
        expect(question.valid?).to be_falsey
        expect(question.errors[:options]).to include("can't be blank")
      end

      it 'is valid with all required attributes' do
        expect(question.valid?).to be_truthy
      end
    end

    describe 'callbacks' do
      describe 'after_initialize' do
        it 'sets default voting_system for new record' do
          new_question = ElectionLocationQuestion.new
          expect(new_question.voting_system).to eq('plurality-at-large')
        end

        it 'sets default totals for new record' do
          new_question = ElectionLocationQuestion.new
          expect(new_question.totals).to eq('over-total-valid-votes')
        end

        it 'sets default random_order to true' do
          new_question = ElectionLocationQuestion.new
          expect(new_question.random_order).to be_truthy
        end

        it 'sets default winners to 1' do
          new_question = ElectionLocationQuestion.new
          expect(new_question.winners).to eq(1)
        end

        it 'sets default minimum to 0' do
          new_question = ElectionLocationQuestion.new
          expect(new_question.minimum).to eq(0)
        end

        it 'sets default maximum to 1' do
          new_question = ElectionLocationQuestion.new
          expect(new_question.maximum).to eq(1)
        end

        it 'does not set defaults for existing record' do
          question.voting_system = 'pairwise-beta'
          question.save
          reloaded = ElectionLocationQuestion.find(question.id)
          expect(reloaded.voting_system).to eq('pairwise-beta')
        end
      end
    end

    describe '#layout' do
      it 'returns "simple" for pairwise-beta voting system' do
        question.voting_system = 'pairwise-beta'
        expect(question.layout).to eq('simple')
      end

      it 'returns empty string for election layouts' do
        election_location.layout = 'pcandidates-election'
        question.voting_system = 'plurality-at-large'
        expect(question.layout).to eq('')
      end

      it 'returns election_location layout for other cases' do
        election_location.layout = 'accordion'
        question.voting_system = 'plurality-at-large'
        expect(question.layout).to eq('accordion')
      end
    end

    describe '#options_headers' do
      it 'returns headers from column when set' do
        question.options_headers = ['Header1', 'Header2']
        expect(question.options_headers).to eq(['Header1', 'Header2'])
      end

      it 'returns default headers when not set' do
        question[:options_headers] = nil
        headers = question.options_headers
        expect(headers).to be_an(Array)
        expect(headers.length).to eq(1)
      end

      it 'parses tab-separated headers' do
        question[:options_headers] = "Name\tDescription"
        expect(question.options_headers).to eq(['Name', 'Description'])
      end
    end

    describe '#options_headers=' do
      it 'sets headers as tab-separated string' do
        question.options_headers = %w[H1 H2 H3]
        expect(question[:options_headers]).to eq("H1\tH2\tH3")
      end

      it 'compacts blank values' do
        question.options_headers = ['H1', '', 'H2', nil]
        expect(question[:options_headers]).to eq("H1\tH2")
      end

      it 'handles nil input' do
        question.options_headers = nil
        expect(question[:options_headers]).to be_nil
      end

      it 'does not set if all values are blank' do
        question[:options_headers] = 'existing'
        question.options_headers = ['', nil]
        expect(question[:options_headers]).to eq('existing')
      end
    end

    describe '#options=' do
      it 'formats multi-line options' do
        question.options = "Option 1\nOption 2\nOption 3"
        expect(question.options).to eq("Option 1\nOption 2\nOption 3")
      end

      it 'handles tab-separated fields' do
        question.options = "Name1\tDesc1\nName2\tDesc2"
        options_lines = question.options.split("\n")
        expect(options_lines.length).to eq(2)
        expect(options_lines.first).to include('Name1')
      end

      it 'strips whitespace from options' do
        question.options = "  Option 1  \n  Option 2  "
        expect(question.options).not_to include('  ')
      end

      it 'skips empty lines' do
        question.options = "Option 1\n\n\nOption 2"
        lines = question.options.split("\n")
        expect(lines.length).to eq(2)
      end

      it 'handles single option' do
        question.options = 'Single Option'
        expect(question.options).to eq('Single Option')
      end
    end

    describe 'constants' do
      it 'defines VOTING_SYSTEMS' do
        expect(ElectionLocationQuestion::VOTING_SYSTEMS).to be_a(Hash)
        expect(ElectionLocationQuestion::VOTING_SYSTEMS).to include('plurality-at-large')
        expect(ElectionLocationQuestion::VOTING_SYSTEMS).to include('pairwise-beta')
      end

      it 'defines TOTALS' do
        expect(ElectionLocationQuestion::TOTALS).to be_a(Hash)
        expect(ElectionLocationQuestion::TOTALS).to include('over-total-valid-votes')
      end
    end

    describe '.headers' do
      it 'returns headers from configuration' do
        expect(ElectionLocationQuestion.headers).to be_a(Hash)
      end
    end

    describe 'full workflow' do
      it 'can create a complete question with options' do
        q = ElectionLocationQuestion.create!(
          election_location: election_location,
          title: 'Choose your favorite',
          description: 'Select one option',
          voting_system: 'plurality-at-large',
          winners: 1,
          minimum: 1,
          maximum: 1,
          totals: 'over-total-valid-votes',
          random_order: true,
          options: "Option A\nOption B\nOption C",
          options_headers: %w[Name]
        )

        expect(q).to be_persisted
        expect(q.options.split("\n").length).to eq(3)
        expect(q.options_headers).to eq(['Name'])
      end
    end
  end
end
