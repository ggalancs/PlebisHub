# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaEditionCategory, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid impulsa_edition_category' do
      category = build(:impulsa_edition_category)
      expect(category).to be_valid, 'Factory should create a valid impulsa_edition_category'
    end

    it 'creates category with associations' do
      category = create(:impulsa_edition_category)
      expect(category.impulsa_edition).not_to be_nil
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'requires name' do
      category = build(:impulsa_edition_category, name: nil)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("no puede estar en blanco")
    end

    it 'requires category_type' do
      category = build(:impulsa_edition_category, category_type: nil)
      expect(category).not_to be_valid
      expect(category.errors[:category_type]).to include("no puede estar en blanco")
    end

    it 'requires winners' do
      category = build(:impulsa_edition_category, winners: nil)
      expect(category).not_to be_valid
      expect(category.errors[:winners]).to include("no puede estar en blanco")
    end

    it 'requires prize' do
      category = build(:impulsa_edition_category, prize: nil)
      expect(category).not_to be_valid
      expect(category.errors[:prize]).to include("no puede estar en blanco")
    end

    it 'accepts valid attributes' do
      category = build(:impulsa_edition_category,
        name: 'Valid Category',
        category_type: 1,
        winners: 5,
        prize: 10000
      )
      expect(category).to be_valid
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.non_authors' do
      it 'excludes only_authors categories' do
        normal = create(:impulsa_edition_category, only_authors: false)
        authors_only = create(:impulsa_edition_category, only_authors: true)

        results = ImpulsaEditionCategory.non_authors

        expect(results).to include(normal)
        expect(results).not_to include(authors_only)
      end
    end

    describe '.state' do
      it 'returns only state categories' do
        state = create(:impulsa_edition_category, :state)
        internal = create(:impulsa_edition_category, :internal)
        territorial = create(:impulsa_edition_category, :territorial)

        results = ImpulsaEditionCategory.state

        expect(results).to include(state)
        expect(results).not_to include(internal)
        expect(results).not_to include(territorial)
      end
    end

    describe '.territorial' do
      it 'returns only territorial categories' do
        territorial = create(:impulsa_edition_category, :territorial)
        state = create(:impulsa_edition_category, :state)

        results = ImpulsaEditionCategory.territorial

        expect(results).to include(territorial)
        expect(results).not_to include(state)
      end
    end

    describe '.internal' do
      it 'returns only internal categories' do
        internal = create(:impulsa_edition_category, :internal)
        state = create(:impulsa_edition_category, :state)

        results = ImpulsaEditionCategory.internal

        expect(results).to include(internal)
        expect(results).not_to include(state)
      end
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#category_type_name' do
      it 'returns correct name for internal' do
        category = create(:impulsa_edition_category, :internal)
        expect(category.category_type_name).to eq(:internal)
      end

      it 'returns correct name for state' do
        category = create(:impulsa_edition_category, :state)
        expect(category.category_type_name).to eq(:state)
      end

      it 'returns correct name for territorial' do
        category = create(:impulsa_edition_category, :territorial)
        expect(category.category_type_name).to eq(:territorial)
      end
    end

    describe '#has_territory?' do
      it 'returns true for territorial categories' do
        category = create(:impulsa_edition_category, :territorial)
        expect(category.has_territory?).to be true
      end

      it 'returns false for non-territorial categories' do
        state = create(:impulsa_edition_category, :state)
        internal = create(:impulsa_edition_category, :internal)

        expect(state.has_territory?).not_to be true
        expect(internal.has_territory?).not_to be true
      end
    end

    describe '#translatable?' do
      it 'returns true when coofficial_language is present' do
        category = create(:impulsa_edition_category, :with_coofficial_language)
        expect(category.translatable?).to be true
      end

      it 'returns false when coofficial_language is blank' do
        category = create(:impulsa_edition_category, coofficial_language: nil)
        expect(category.translatable?).not_to be true
      end
    end

    describe '#coofficial_language_name' do
      it 'returns language name when present' do
        category = create(:impulsa_edition_category, :with_coofficial_language)
        # Should return the locale name for :ca (Catalan)
        expect(category.coofficial_language_name).not_to be_nil
      end

      it 'returns nil when not present' do
        category = create(:impulsa_edition_category, coofficial_language: nil)
        expect(category.coofficial_language_name).to be_nil
      end
    end

    describe '#territories' do
      it 'parses pipe-separated values' do
        category = create(:impulsa_edition_category)
        # Set the internal field directly to avoid calling the setter which expects an array
        category.update_column(:territories, 'a_01|a_02|a_03')

        expect(category.territories).to eq(['a_01', 'a_02', 'a_03'])
      end

      it 'returns empty array when nil' do
        category = create(:impulsa_edition_category)
        category.update_column(:territories, nil)

        expect(category.territories).to eq([])
      end
    end

    describe '#territories=' do
      it 'joins array with pipes' do
        category = create(:impulsa_edition_category)
        category.territories = ['a_01', 'a_02', 'a_03']

        expect(category[:territories]).to eq('a_01|a_02|a_03')
      end

      it 'filters out blank values' do
        category = create(:impulsa_edition_category)
        category.territories = ['a_01', '', 'a_02', nil, 'a_03']

        expect(category[:territories]).to eq('a_01|a_02|a_03')
      end
    end

    describe '#prewinners' do
      it 'returns double the winners' do
        category = create(:impulsa_edition_category, winners: 5)
        expect(category.prewinners).to eq(10)
      end
    end

    describe '#wizard_raw' do
      it 'returns YAML string without ActiveSupport hash prefix' do
        category = create(:impulsa_edition_category)
        category.wizard = { step1: 'value1', step2: 'value2' }

        result = category.wizard_raw
        expect(result).to be_a(String)
        expect(result).not_to include('!ruby/hash:ActiveSupport::HashWithIndifferentAccess')
      end
    end

    describe '#wizard_raw=' do
      it 'parses YAML and sets wizard' do
        category = create(:impulsa_edition_category)
        yaml_string = "---\nstep1: value1\nstep2: value2\n"

        category.wizard_raw = yaml_string

        expect(category.wizard['step1']).to eq('value1')
        expect(category.wizard['step2']).to eq('value2')
      end
    end

    describe '#evaluation_raw' do
      it 'returns YAML string without ActiveSupport hash prefix' do
        category = create(:impulsa_edition_category)
        category.evaluation = { criteria1: 'value1', criteria2: 'value2' }

        result = category.evaluation_raw
        expect(result).to be_a(String)
        expect(result).not_to include('!ruby/hash:ActiveSupport::HashWithIndifferentAccess')
      end
    end

    describe '#evaluation_raw=' do
      it 'parses YAML and sets evaluation' do
        category = create(:impulsa_edition_category)
        yaml_string = "---\ncriteria1: value1\ncriteria2: value2\n"

        category.evaluation_raw = yaml_string

        expect(category.evaluation['criteria1']).to eq('value1')
        expect(category.evaluation['criteria2']).to eq('value2')
      end
    end
  end

  # ====================
  # FLAG TESTS
  # ====================

  describe 'flags' do
    describe 'has_votings' do
      it 'defaults to false' do
        category = create(:impulsa_edition_category)
        expect(category.has_votings?).not_to be true
      end

      it 'is settable to true' do
        category = create(:impulsa_edition_category, :with_votings)
        expect(category.has_votings?).to be true
      end

      it 'is toggleable' do
        category = create(:impulsa_edition_category)

        category.has_votings = true
        category.save
        expect(category.reload.has_votings?).to be true

        category.has_votings = false
        category.save
        expect(category.reload.has_votings?).not_to be true
      end
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to impulsa_edition' do
      category = create(:impulsa_edition_category)
      expect(category).to respond_to(:impulsa_edition)
      expect(category.impulsa_edition).to be_a(ImpulsaEdition)
    end

    it 'has many impulsa_projects' do
      category = create(:impulsa_edition_category)
      expect(category).to respond_to(:impulsa_projects)
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles zero winners' do
      category = build(:impulsa_edition_category, winners: 0)
      expect(category).to be_valid
      expect(category.prewinners).to eq(0)
    end

    it 'handles zero prize' do
      category = build(:impulsa_edition_category, prize: 0)
      expect(category).to be_valid
    end

    it 'handles very long name' do
      category = build(:impulsa_edition_category, name: 'A' * 1000)
      expect(category).to be_valid
    end

    it 'handles special characters in name' do
      category = build(:impulsa_edition_category, name: 'Category with émojis 🎉 and symbols')
      expect(category).to be_valid
    end

    it 'handles empty wizard store' do
      category = create(:impulsa_edition_category)
      expect(category.wizard).not_to be_nil
    end

    it 'handles empty evaluation store' do
      category = create(:impulsa_edition_category)
      expect(category.evaluation).not_to be_nil
    end
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  describe 'combined scenarios' do
    it 'creates multiple categories for same edition' do
      edition = create(:impulsa_edition)

      cat1 = create(:impulsa_edition_category, :internal, impulsa_edition: edition)
      cat2 = create(:impulsa_edition_category, :state, impulsa_edition: edition)
      cat3 = create(:impulsa_edition_category, :territorial, impulsa_edition: edition)

      expect(edition.impulsa_edition_categories.count).to eq(3)
    end

    it 'handles all category types correctly' do
      internal = create(:impulsa_edition_category, :internal)
      state = create(:impulsa_edition_category, :state)
      territorial = create(:impulsa_edition_category, :territorial)

      expect(internal.category_type).to eq(0)
      expect(state.category_type).to eq(1)
      expect(territorial.category_type).to eq(2)

      expect(internal.category_type_name).to eq(:internal)
      expect(state.category_type_name).to eq(:state)
      expect(territorial.category_type_name).to eq(:territorial)
    end

    it 'maintains territorial data correctly' do
      category = create(:impulsa_edition_category, :territorial)
      category.territories = ['a_13', 'a_09', 'a_01']
      category.save

      expect(category.has_territory?).to be true
      expect(category.territories.count).to eq(3)
      expect(category.territories).to include('a_13')
    end
  end
end
