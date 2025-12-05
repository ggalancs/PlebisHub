# frozen_string_literal: true

require 'rails_helper'

module PlebisCms
  RSpec.describe Category, type: :model do
    describe 'associations' do
      it { is_expected.to have_and_belong_to_many(:posts).class_name('PlebisCms::Post') }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:name) }

      describe 'uniqueness validations' do
        subject { create(:category) }
        it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
        it { is_expected.to validate_uniqueness_of(:slug).case_insensitive.allow_nil }
      end
    end

    describe 'FriendlyId' do
      it 'generates slug from name' do
        category = create(:category, name: 'Test Category')
        expect(category.slug).to eq('test-category')
      end

      it 'can be found by slug' do
        category = create(:category, name: 'Findable Category')
        found = Category.friendly.find('findable-category')
        expect(found).to eq(category)
      end

      it 'regenerates slug when name changes' do
        category = create(:category, name: 'Original Name')
        original_slug = category.slug
        category.update(name: 'Updated Name')
        expect(category.slug).not_to eq(original_slug)
        expect(category.slug).to eq('updated-name')
      end

      it 'uses slug candidates when slug is taken' do
        create(:category, name: 'Duplicate')
        category = create(:category, name: 'Duplicate')
        expect(category.slug).to include('duplicate')
        expect(category.slug).to match(/duplicate-\d+/)
      end
    end

    describe 'scopes' do
      describe '.active' do
        it 'returns categories with posts' do
          active_category = create(:category, :with_one_post)
          inactive_category = create(:category)

          expect(Category.active).to include(active_category)
          expect(Category.active).not_to include(inactive_category)
        end

        it 'returns distinct categories when category has multiple posts' do
          category = create(:category, :with_posts)
          result = Category.active
          expect(result.count).to eq(1)
        end
      end

      describe '.inactive' do
        it 'returns categories without posts' do
          active_category = create(:category, :with_one_post)
          inactive_category = create(:category)

          expect(Category.inactive).to include(inactive_category)
          expect(Category.inactive).not_to include(active_category)
        end
      end

      describe '.alphabetical' do
        it 'orders categories by name ascending' do
          charlie = create(:category, name: 'Charlie')
          alpha = create(:category, name: 'Alpha')
          bravo = create(:category, name: 'Bravo')

          result = Category.alphabetical.pluck(:id)
          expect(result).to eq([alpha.id, bravo.id, charlie.id])
        end
      end

      describe '.by_post_count' do
        it 'orders categories by post count descending' do
          no_posts = create(:category)
          few_posts = create(:category, :with_one_post)
          many_posts = create(:category, :with_posts)

          result = Category.by_post_count.to_a
          expect(result.first).to eq(many_posts)
          expect(result.last).to eq(no_posts)
        end
      end
    end

    describe 'instance methods' do
      describe '#active?' do
        it 'returns true when category has posts' do
          category = create(:category, :with_one_post)
          expect(category.active?).to be true
        end

        it 'returns false when category has no posts' do
          category = create(:category)
          expect(category.active?).to be false
        end
      end

      describe '#inactive?' do
        it 'returns false when category has posts' do
          category = create(:category, :with_one_post)
          expect(category.inactive?).to be false
        end

        it 'returns true when category has no posts' do
          category = create(:category)
          expect(category.inactive?).to be true
        end
      end

      describe '#posts_count' do
        it 'returns the number of posts' do
          category = create(:category, :with_posts)
          expect(category.posts_count).to eq(3)
        end

        it 'returns 0 when category has no posts' do
          category = create(:category)
          expect(category.posts_count).to eq(0)
        end
      end

      describe '#slug_candidates' do
        it 'returns array of slug candidates' do
          category = Category.new(name: 'Test')
          candidates = category.slug_candidates
          expect(candidates).to be_an(Array)
          expect(candidates).to include(:name)
        end
      end

      describe '#should_generate_new_friendly_id?' do
        it 'returns true when name changes' do
          category = create(:category, name: 'Original')
          category.name = 'Changed'
          expect(category.should_generate_new_friendly_id?).to be true
        end

        it 'returns true when slug is blank' do
          category = Category.new(name: 'Test')
          category.slug = nil
          expect(category.should_generate_new_friendly_id?).to be true
        end

        it 'returns false when name unchanged and slug present' do
          category = create(:category)
          expect(category.should_generate_new_friendly_id?).to be false
        end
      end
    end

    describe 'table name' do
      it 'uses categories table' do
        expect(Category.table_name).to eq('categories')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        category = build(:category)
        expect(category).to be_valid
      end

      it 'creates a category with all required attributes' do
        category = create(:category)
        expect(category).to be_persisted
        expect(category.name).to be_present
        expect(category.slug).to be_present
      end
    end
  end
end
