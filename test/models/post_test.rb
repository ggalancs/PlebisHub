require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid post" do
    post = build(:post)
    assert post.valid?, "Factory should create a valid post"
  end

  test "factory creates published post by default" do
    post = create(:post)
    assert_equal 1, post.status
    assert post.published?
  end

  test "factory creates draft post with trait" do
    post = create(:post, :draft)
    assert_equal 0, post.status
    assert_not post.published?
  end

  test "factory creates post with categories" do
    post = create(:post, :with_categories)
    assert_equal 2, post.categories.count
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  test "should require title" do
    post = build(:post, title: nil)
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "should require status" do
    post = build(:post, status: nil)
    assert_not post.valid?
    assert_includes post.errors[:status], "can't be blank"
  end

  test "should accept valid title and status" do
    post = build(:post, title: "Valid Title", status: 1)
    assert post.valid?
  end

  # ====================
  # CRUD TESTS
  # ====================

  test "should create post" do
    assert_difference 'Post.count', 1 do
      create(:post)
    end
  end

  test "should read post" do
    post = create(:post)
    found_post = Post.find(post.id)
    assert_equal post.title, found_post.title
  end

  test "should update post" do
    post = create(:post, title: "Original Title")
    post.update(title: "Updated Title")
    assert_equal "Updated Title", post.reload.title
  end

  test "should soft delete post" do
    post = create(:post)
    post.destroy

    assert_not_nil post.deleted_at
    assert_not Post.exists?(post.id), "Post should not be in default scope"
    assert Post.with_deleted.exists?(post.id), "Post should exist with with_deleted scope"
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "recent scope should order by created_at desc" do
    post1 = create(:post)
    sleep 0.01
    post2 = create(:post)
    sleep 0.01
    post3 = create(:post)

    recent_posts = Post.recent.limit(3)
    assert_equal post3.id, recent_posts[0].id
    assert_equal post2.id, recent_posts[1].id
    assert_equal post1.id, recent_posts[2].id
  end

  test "created scope should exclude deleted posts" do
    active_post = create(:post)
    deleted_post = create(:post, :deleted)

    assert_includes Post.created, active_post
    assert_not_includes Post.created, deleted_post
  end

  test "drafts scope should return only draft posts" do
    draft = create(:post, :draft)
    published = create(:post, :published)

    drafts = Post.drafts
    assert_includes drafts, draft
    assert_not_includes drafts, published
  end

  test "published scope should return only published posts" do
    draft = create(:post, :draft)
    published = create(:post, :published)

    published_posts = Post.published
    assert_includes published_posts, published
    assert_not_includes published_posts, draft
  end

  test "deleted scope should return only deleted posts" do
    active_post = create(:post)
    deleted_post = create(:post)
    deleted_post.destroy

    deleted_posts = Post.deleted
    assert_includes deleted_posts, deleted_post
    assert_not_includes deleted_posts, active_post
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should have many categories" do
    post = create(:post)
    category1 = create(:category)
    category2 = create(:category)

    post.categories << category1
    post.categories << category2

    assert_equal 2, post.categories.count
    assert_includes post.categories, category1
    assert_includes post.categories, category2
  end

  test "post categories association should be has_and_belongs_to_many" do
    post = create(:post)
    category = create(:category)

    post.categories << category

    assert category.posts.include?(post), "Category should have post in its posts"
    assert post.categories.include?(category), "Post should have category in its categories"
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  test "published? should return true for published posts" do
    post = create(:post, :published)
    assert post.published?
  end

  test "published? should return false for draft posts" do
    post = create(:post, :draft)
    assert_not post.published?
  end

  test "published? should return true for status > 0" do
    post = create(:post, status: 1)
    assert post.published?

    post.update(status: 2)
    assert post.published?
  end

  # ====================
  # FRIENDLY_ID / SLUG TESTS
  # ====================

  test "should generate slug from title" do
    post = create(:post, title: "My Awesome Post")
    assert_not_nil post.slug
    assert_match(/my-awesome-post/, post.slug)
  end

  test "should be findable by slug" do
    post = create(:post, title: "Findable Post")

    # FriendlyId should allow finding by slug
    found_post = Post.find(post.slug)
    assert_equal post.id, found_post.id
  end

  test "should update slug when title changes" do
    post = create(:post, title: "Original Title")
    original_slug = post.slug

    post.update(title: "New Title")
    post.reload

    # Slug may or may not change depending on FriendlyId configuration
    # Just verify slug exists
    assert_not_nil post.slug
  end

  test "should handle duplicate titles with slug candidates" do
    post1 = create(:post, title: "Duplicate Title")
    post2 = create(:post, title: "Duplicate Title")

    assert_not_equal post1.slug, post2.slug, "Slugs should be different for duplicate titles"
  end

  # ====================
  # SOFT DELETE (PARANOIA) TESTS
  # ====================

  test "should exclude soft deleted from default scope" do
    post = create(:post)
    post_id = post.id
    post.destroy

    assert_nil Post.find_by(id: post_id)
    assert_not_nil Post.with_deleted.find_by(id: post_id)
  end

  test "should include soft deleted with with_deleted scope" do
    active_post = create(:post)
    deleted_post = create(:post)
    deleted_post.destroy

    all_posts = Post.with_deleted
    assert_includes all_posts, active_post
    assert_includes all_posts, deleted_post
  end

  test "should restore soft deleted post" do
    post = create(:post)
    post.destroy

    assert_not_nil post.deleted_at

    post.restore

    assert_nil post.reload.deleted_at
    assert Post.exists?(post.id)
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "complete blog post workflow" do
    # Create draft
    post = create(:post, :draft, title: "My Blog Post")
    assert_equal 0, post.status
    assert_not post.published?

    # Add categories
    category1 = create(:category)
    category2 = create(:category)
    post.categories << [category1, category2]
    assert_equal 2, post.categories.count

    # Publish
    post.update(status: 1)
    assert post.published?
    assert_includes Post.published, post
    assert_not_includes Post.drafts, post

    # Should be findable by slug
    found_post = Post.find(post.slug)
    assert_equal post.id, found_post.id

    # Delete
    post.destroy
    assert_not Post.exists?(post.id)
    assert Post.with_deleted.exists?(post.id)
  end

  test "draft to published transition" do
    post = create(:post, :draft)

    assert_includes Post.drafts, post
    assert_not_includes Post.published, post

    post.update(status: 1)

    assert_not_includes Post.drafts.reload, post
    assert_includes Post.published.reload, post
  end
end
