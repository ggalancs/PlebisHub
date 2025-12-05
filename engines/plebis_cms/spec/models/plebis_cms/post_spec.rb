# frozen_string_literal: true

require 'rails_helper'

module PlebisCms
  RSpec.describe Post, type: :model do
    describe 'associations' do
      it { is_expected.to have_and_belong_to_many(:categories).class_name('PlebisCms::Category') }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:title) }
      it { is_expected.to validate_presence_of(:status) }
    end

    describe 'FriendlyId' do
      it 'generates slug from title' do
        post = create(:post, title: 'Test Post Title')
        expect(post.slug).to eq('test-post-title')
      end

      it 'can be found by slug' do
        post = create(:post, title: 'Findable Post')
        found = Post.friendly.find('findable-post')
        expect(found).to eq(post)
      end

      it 'handles slug conflicts with year' do
        create(:post, title: 'Duplicate Title')
        post = create(:post, title: 'Duplicate Title')
        expect(post.slug).to include('duplicate-title')
      end
    end

    describe 'paranoia (soft delete)' do
      it 'responds to acts_as_paranoid methods' do
        post = create(:post)
        expect(post).to respond_to(:deleted_at)
        expect(post).to respond_to(:deleted?)
      end

      it 'soft deletes the record' do
        post = create(:post)
        initial_count = Post.count
        post.destroy
        expect(Post.count).to eq(initial_count - 1)
        expect(Post.with_deleted.count).to eq(initial_count)
        expect(post.deleted_at).not_to be_nil
      end

      it 'does not include deleted posts in default scope' do
        active_post = create(:post)
        deleted_post = create(:post)
        deleted_post.destroy

        expect(Post.all).to include(active_post)
        expect(Post.all).not_to include(deleted_post)
      end

      it 'includes deleted posts in with_deleted scope' do
        active_post = create(:post)
        deleted_post = create(:post)
        deleted_post.destroy

        expect(Post.with_deleted).to include(active_post)
        expect(Post.with_deleted).to include(deleted_post)
      end
    end

    describe 'STATUS constant' do
      it 'defines draft status' do
        expect(Post::STATUS['Borrador']).to eq(0)
      end

      it 'defines published status' do
        expect(Post::STATUS['Publicado']).to eq(1)
      end

      it 'is frozen' do
        expect(Post::STATUS).to be_frozen
      end
    end

    describe 'scopes' do
      describe '.recent' do
        it 'orders posts by created_at descending' do
          old_post = create(:post, created_at: 2.days.ago)
          new_post = create(:post, created_at: 1.hour.ago)
          middle_post = create(:post, created_at: 1.day.ago)

          result = Post.recent.pluck(:id)
          expect(result).to eq([new_post.id, middle_post.id, old_post.id])
        end
      end

      describe '.created' do
        it 'returns only non-deleted posts' do
          active_post = create(:post)
          deleted_post = create(:post, deleted_at: Time.current)

          expect(Post.created).to include(active_post)
          expect(Post.created).not_to include(deleted_post)
        end
      end

      describe '.drafts' do
        it 'returns posts with status 0' do
          draft = create(:post, :draft)
          published = create(:post, :published)

          expect(Post.drafts).to include(draft)
          expect(Post.drafts).not_to include(published)
        end

        it 'returns multiple draft posts' do
          draft1 = create(:post, status: 0)
          draft2 = create(:post, status: 0)
          create(:post, status: 1)

          result = Post.drafts
          expect(result).to include(draft1, draft2)
          expect(result.count).to eq(2)
        end
      end

      describe '.published' do
        it 'returns posts with status 1' do
          draft = create(:post, :draft)
          published = create(:post, :published)

          expect(Post.published).to include(published)
          expect(Post.published).not_to include(draft)
        end

        it 'returns multiple published posts' do
          published1 = create(:post, status: 1)
          published2 = create(:post, status: 1)
          create(:post, status: 0)

          result = Post.published
          expect(result).to include(published1, published2)
          expect(result.count).to eq(2)
        end
      end

      describe '.deleted' do
        it 'returns only deleted posts' do
          active_post = create(:post)
          deleted_post = create(:post)
          deleted_post.destroy

          expect(Post.deleted).not_to include(active_post)
          expect(Post.deleted).to include(deleted_post)
        end

        it 'is an alias for only_deleted' do
          expect(Post.deleted.to_sql).to eq(Post.only_deleted.to_sql)
        end
      end
    end

    describe 'instance methods' do
      describe '#published?' do
        it 'returns true for published posts (status > 0)' do
          post = build(:post, status: 1)
          expect(post.published?).to be true
        end

        it 'returns false for draft posts (status = 0)' do
          post = build(:post, status: 0)
          expect(post.published?).to be false
        end

        it 'returns true for status greater than 1' do
          post = build(:post, status: 2)
          expect(post.published?).to be true
        end
      end

      describe '#slug_candidates' do
        it 'returns array of slug candidates' do
          post = Post.new(title: 'Test')
          candidates = post.slug_candidates
          expect(candidates).to be_an(Array)
          expect(candidates.first).to eq(:title)
        end

        it 'includes title with year as fallback' do
          post = Post.new(title: 'Test')
          candidates = post.slug_candidates
          expect(candidates[1]).to include(:title)
          expect(candidates[1]).to include(DateTime.now.year)
        end

        it 'includes title with year and month as fallback' do
          post = Post.new(title: 'Test')
          candidates = post.slug_candidates
          expect(candidates[2]).to include(:title)
          expect(candidates[2]).to include(DateTime.now.year)
          expect(candidates[2]).to include(DateTime.now.month)
        end

        it 'includes title with year, month, and day as final fallback' do
          post = Post.new(title: 'Test')
          candidates = post.slug_candidates
          expect(candidates[3]).to include(:title)
          expect(candidates[3]).to include(DateTime.now.year)
          expect(candidates[3]).to include(DateTime.now.month)
          expect(candidates[3]).to include(DateTime.now.day)
        end
      end
    end

    describe 'table name' do
      it 'uses posts table' do
        expect(Post.table_name).to eq('posts')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        post = build(:post)
        expect(post).to be_valid
      end

      it 'creates a post with all required attributes' do
        post = create(:post)
        expect(post).to be_persisted
        expect(post.title).to be_present
        expect(post.status).to be_present
      end

      it 'creates published post by default' do
        post = create(:post)
        expect(post.status).to eq(1)
      end
    end
  end
end
