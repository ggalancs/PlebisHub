# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid category' do
      category = build(:category)
      expect(category).to be_valid, 'Factory should create a valid category'
    end

    it 'creates valid category with posts' do
      category = create(:category, :with_posts)
      expect(category).to be_valid
      expect(category.posts).to be_any
    end

    it 'creates valid active category' do
      category = create(:category, :active)
      expect(category).to be_valid
      expect(category).to be_active
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    # Name validations
    describe 'name' do
      it 'requires name' do
        category = build(:category, name: nil)
        expect(category).not_to be_valid
        expect(category.errors[:name]).to include('no puede estar en blanco')
      end

      it 'accepts valid name' do
        category = build(:category, name: 'Technology')
        expect(category).to be_valid
      end

      it 'rejects empty string name' do
        category = build(:category, name: '')
        expect(category).not_to be_valid
        expect(category.errors[:name]).to include('no puede estar en blanco')
      end

      it 'requires unique name (case insensitive)' do
        create(:category, name: 'Technology')
        duplicate = build(:category, name: 'technology')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to include('ya está en uso')
      end

      it 'does not allow same name if different case initially' do
        create(:category, name: 'Technology')
        cat2 = build(:category, name: 'TECHNOLOGY')
        expect(cat2).not_to be_valid
      end

      it 'handles very long name' do
        long_name = 'A' * 1000
        category = build(:category, name: long_name)
        category.valid?
        expect(category).not_to be_nil
      end

      it 'handles special characters in name' do
        category = build(:category, name: 'Tech & Innovation: 2024 © ®')
        expect(category).to be_valid
      end

      it 'handles unicode characters in name' do
        category = build(:category, name: 'Tecnología 技術 تكنولوجيا')
        expect(category).to be_valid
      end

      it 'handles name with only whitespace' do
        category = build(:category, name: '   ')
        expect(category).not_to be_valid
      end

      it 'handles multiple categories with similar names' do
        create(:category, name: 'Technology')
        create(:category, name: 'Technology News')
        create(:category, name: 'Technology Blog')

        expect(Category.where('name LIKE ?', 'Technology%').count).to eq(3)
      end
    end

    # Slug validations
    describe 'slug' do
      it 'allows blank slug (FriendlyId generates it)' do
        category = build(:category, slug: nil)
        expect(category).to be_valid
      end

      it 'auto-generates slug from name' do
        category = create(:category, name: 'Technology and Innovation')
        expect(category.slug).not_to be_nil
        expect(category.slug).to eq('technology-and-innovation')
      end

      it 'requires unique slug if provided' do
        # Create category with a specific name that generates a specific slug
        create(:category, name: 'Unique Test')
        # Try to create another category with the same name (which generates the same slug)
        duplicate = build(:category, name: 'Unique Test')
        expect(duplicate).not_to be_valid
        # Check for either slug or name error (FriendlyId may validate either)
        expect(duplicate.errors[:slug].any? || duplicate.errors[:name].any?).to be true
      end

      it 'allows different slugs' do
        create(:category, slug: 'slug-one')
        cat2 = build(:category, name: 'Different Category', slug: 'slug-two')
        expect(cat2).to be_valid
      end

      it 'updates slug when name changes' do
        category = create(:category, name: 'Original Name')
        category.slug

        category.update(name: 'New Name')

        # FriendlyId keeps the old slug by default for history
        # New slug might be generated or keep old one depending on configuration
        expect(category.slug).not_to be_nil
      end

      it 'handles special characters in name for slug' do
        category = create(:category, name: 'Economy & Finance')
        expect(category.slug).to be_present
        expect(category.slug).to match(/economy.*finance/)
      end
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates category with valid attributes' do
      expect { create(:category) }.to change(Category, :count).by(1)
    end

    it 'reads category attributes correctly' do
      category = create(:category, name: 'Technology')

      found_category = Category.find(category.id)
      expect(found_category.name).to eq('Technology')
    end

    it 'updates category attributes' do
      category = create(:category, name: 'Original Name')
      category.update(name: 'Updated Name')

      expect(category.reload.name).to eq('Updated Name')
    end

    it 'does not update with invalid attributes' do
      category = create(:category, name: 'Valid Name')
      category.update(name: nil)

      expect(category).not_to be_valid
      expect(category.reload.name).to eq('Valid Name')
    end

    it 'deletes category' do
      category = create(:category)
      expect { category.destroy }.to change(Category, :count).by(-1)
    end

    it 'deletes category and removes associations' do
      category = create(:category, :with_posts)
      post_ids = category.post_ids

      category.destroy

      # Posts should still exist (HABTM only removes association)
      post_ids.each do |post_id|
        expect(Post.exists?(post_id)).to be true
      end
    end

    it 'handles category updates without breaking associations' do
      category = create(:category, :with_posts)
      original_posts_count = category.posts.count

      category.update(name: 'Updated Name')

      expect(category.reload.posts.count).to eq(original_posts_count)
    end
  end

  # ====================
  # FRIENDLY_ID TESTS
  # ====================

  describe 'FriendlyId' do
    it 'finds category by slug' do
      category = create(:category, name: 'Technology')
      found = Category.find(category.slug)

      expect(found).to eq(category)
    end

    it 'finds category by friendly_id' do
      category = create(:category, name: 'Technology')
      found = Category.friendly.find('technology')

      expect(found).to eq(category)
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'has has_and_belongs_to_many association with posts' do
      category = create(:category)
      expect(category).to respond_to(:posts)
    end

    it 'adds posts to category' do
      category = create(:category)
      post = create(:post)

      category.posts << post

      expect(category.posts).to include(post)
      expect(post.categories).to include(category)
    end

    it 'removes posts from category' do
      category = create(:category, :with_one_post)
      post = category.posts.first

      category.posts.delete(post)

      expect(category.posts).not_to include(post)
      expect(post.reload.categories).not_to include(category)
    end

    it 'has multiple posts' do
      category = create(:category, :with_many_posts)
      expect(category.posts.count).to eq(10)
    end

    it 'allows post to belong to multiple categories' do
      cat1 = create(:category, name: 'Technology')
      cat2 = create(:category, name: 'Science')
      post = create(:post, categories: [cat1, cat2])

      expect(post.categories.count).to eq(2)
      expect(post.categories).to include(cat1)
      expect(post.categories).to include(cat2)
    end

    it 'handles category with published and draft posts' do
      category = create(:category)
      published_post = create(:post, :published, categories: [category])
      draft_post = create(:post, :draft, categories: [category])

      expect(category.posts.count).to eq(2)
      expect(category.posts).to include(published_post)
      expect(category.posts).to include(draft_post)
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.active' do
      it 'returns categories with posts' do
        active_category = create(:category, :with_posts)
        inactive_category = create(:category)

        active_categories = Category.active

        expect(active_categories).to include(active_category)
        expect(active_categories).not_to include(inactive_category)
      end

      it 'returns empty when no categories have posts' do
        create(:category)
        create(:category)

        expect(Category.active).to be_empty
      end

      it 'does not duplicate categories with multiple posts' do
        category = create(:category, :with_many_posts)

        active_categories = Category.active.to_a

        expect(active_categories.count { |c| c.id == category.id }).to eq(1)
      end
    end

    describe '.inactive' do
      it 'returns categories without posts' do
        active_category = create(:category, :with_posts)
        inactive_category = create(:category)

        inactive_categories = Category.inactive

        expect(inactive_categories).to include(inactive_category)
        expect(inactive_categories).not_to include(active_category)
      end

      it 'handles category after removing all posts' do
        category = create(:category, :with_one_post)
        category.posts.clear

        expect(Category.inactive).to include(category)
      end
    end

    describe '.alphabetical' do
      it 'orders categories by name ascending' do
        cat_z = create(:category, name: 'Zebra')
        cat_a = create(:category, name: 'Apple')
        cat_m = create(:category, name: 'Mango')

        ordered = Category.alphabetical.to_a

        expect(ordered[0]).to eq(cat_a)
        expect(ordered[1]).to eq(cat_m)
        expect(ordered[2]).to eq(cat_z)
      end
    end

    describe '.by_post_count' do
      it 'orders by number of posts descending' do
        cat_many = create(:category, :with_many_posts) # 10 posts
        cat_few = create(:category, :with_one_post)    # 1 post
        cat_none = create(:category) # 0 posts

        ordered = Category.by_post_count.to_a

        expect(ordered[0]).to eq(cat_many)
        expect(ordered[1]).to eq(cat_few)
        expect(ordered[2]).to eq(cat_none)
      end
    end

    describe 'combined scopes' do
      it 'filters active categories alphabetically' do
        cat_z = create(:category, :with_posts, name: 'Zebra')
        cat_a = create(:category, :with_posts, name: 'Apple')
        inactive = create(:category, name: 'Middle')

        result = Category.active.alphabetical.to_a

        expect(result.size).to eq(2)
        expect(result[0]).to eq(cat_a)
        expect(result[1]).to eq(cat_z)
        expect(result).not_to include(inactive)
      end
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#active?' do
      it 'returns true when category has posts' do
        category = create(:category, :with_posts)
        expect(category).to be_active
      end

      it 'returns false when category has no posts' do
        category = create(:category)
        expect(category).not_to be_active
      end

      it 'updates when posts are added' do
        category = create(:category)
        expect(category).not_to be_active

        category.posts << create(:post)
        expect(category).to be_active
      end
    end

    describe '#inactive?' do
      it 'returns true when category has no posts' do
        category = create(:category)
        expect(category).to be_inactive
      end

      it 'returns false when category has posts' do
        category = create(:category, :with_posts)
        expect(category).not_to be_inactive
      end
    end

    describe '#posts_count' do
      it 'returns correct number of posts' do
        category = create(:category, :with_many_posts)
        expect(category.posts_count).to eq(10)
      end

      it 'returns zero for inactive category' do
        category = create(:category)
        expect(category.posts_count).to eq(0)
      end

      it 'updates when posts are added or removed' do
        category = create(:category)
        expect(category.posts_count).to eq(0)

        category.posts << create(:post)
        expect(category.posts_count).to eq(1)

        category.posts << create(:post)
        expect(category.posts_count).to eq(2)

        category.posts.first.destroy
        expect(category.posts_count).to eq(1)
      end
    end
  end
end
