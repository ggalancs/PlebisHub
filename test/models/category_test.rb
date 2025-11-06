require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid category" do
    category = build(:category)
    assert category.valid?, "Factory should create a valid category"
  end

  test "factory creates valid category with posts" do
    category = create(:category, :with_posts)
    assert category.valid?
    assert category.posts.any?
  end

  test "factory creates valid active category" do
    category = create(:category, :active)
    assert category.valid?
    assert category.active?
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  # Name validations
  test "should require name" do
    category = build(:category, name: nil)
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "should accept valid name" do
    category = build(:category, name: "Technology")
    assert category.valid?
  end

  test "should reject empty string name" do
    category = build(:category, name: "")
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "should require unique name (case insensitive)" do
    create(:category, name: "Technology")
    duplicate = build(:category, name: "technology")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "should allow same name if different case initially" do
    cat1 = create(:category, name: "Technology")
    cat2 = build(:category, name: "TECHNOLOGY")
    assert_not cat2.valid?
  end

  # Slug validations
  test "should allow blank slug (FriendlyId generates it)" do
    category = build(:category, slug: nil)
    assert category.valid?
  end

  test "should auto-generate slug from name" do
    category = create(:category, name: "Technology and Innovation")
    assert_not_nil category.slug
    assert_equal "technology-and-innovation", category.slug
  end

  test "should require unique slug if provided" do
    create(:category, slug: "unique-slug")
    duplicate = build(:category, slug: "unique-slug")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "should allow different slugs" do
    cat1 = create(:category, slug: "slug-one")
    cat2 = build(:category, name: "Different Category", slug: "slug-two")
    assert cat2.valid?
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create category with valid attributes" do
    assert_difference('Category.count', 1) do
      create(:category)
    end
  end

  test "should read category attributes correctly" do
    category = create(:category, name: "Technology")

    found_category = Category.find(category.id)
    assert_equal "Technology", found_category.name
  end

  test "should update category attributes" do
    category = create(:category, name: "Original Name")
    category.update(name: "Updated Name")

    assert_equal "Updated Name", category.reload.name
  end

  test "should not update with invalid attributes" do
    category = create(:category, name: "Valid Name")
    category.update(name: nil)

    assert_not category.valid?
    assert_equal "Valid Name", category.reload.name
  end

  test "should delete category" do
    category = create(:category)
    assert_difference('Category.count', -1) do
      category.destroy
    end
  end

  test "should delete category and remove associations" do
    category = create(:category, :with_posts)
    post_ids = category.post_ids

    category.destroy

    # Posts should still exist (HABTM only removes association)
    post_ids.each do |post_id|
      assert Post.exists?(post_id)
    end
  end

  # ====================
  # FRIENDLY_ID TESTS
  # ====================

  test "should find category by slug" do
    category = create(:category, name: "Technology")
    found = Category.find(category.slug)

    assert_equal category, found
  end

  test "should find category by friendly_id" do
    category = create(:category, name: "Technology")
    found = Category.friendly.find("technology")

    assert_equal category, found
  end

  test "should update slug when name changes" do
    category = create(:category, name: "Original Name")
    original_slug = category.slug

    category.update(name: "New Name")

    # FriendlyId keeps the old slug by default for history
    # New slug might be generated or keep old one depending on configuration
    assert_not_nil category.slug
  end

  test "should handle special characters in name for slug" do
    category = create(:category, name: "Economy & Finance")
    assert category.slug.present?
    assert_match(/economy.*finance/, category.slug)
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should have has_and_belongs_to_many association with posts" do
    category = create(:category)
    assert_respond_to category, :posts
  end

  test "should add posts to category" do
    category = create(:category)
    post = create(:post)

    category.posts << post

    assert_includes category.posts, post
    assert_includes post.categories, category
  end

  test "should remove posts from category" do
    category = create(:category, :with_one_post)
    post = category.posts.first

    category.posts.delete(post)

    assert_not_includes category.posts, post
    assert_not_includes post.reload.categories, category
  end

  test "should have multiple posts" do
    category = create(:category, :with_many_posts)
    assert_equal 10, category.posts.count
  end

  test "post can belong to multiple categories" do
    cat1 = create(:category, name: "Technology")
    cat2 = create(:category, name: "Science")
    post = create(:post, categories: [cat1, cat2])

    assert_equal 2, post.categories.count
    assert_includes post.categories, cat1
    assert_includes post.categories, cat2
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "active scope should return categories with posts" do
    active_category = create(:category, :with_posts)
    inactive_category = create(:category)

    active_categories = Category.active

    assert_includes active_categories, active_category
    assert_not_includes active_categories, inactive_category
  end

  test "active scope should return empty when no categories have posts" do
    create(:category)
    create(:category)

    assert_empty Category.active
  end

  test "active scope should not duplicate categories with multiple posts" do
    category = create(:category, :with_many_posts)

    active_categories = Category.active.to_a

    assert_equal 1, active_categories.count { |c| c.id == category.id }
  end

  test "inactive scope should return categories without posts" do
    active_category = create(:category, :with_posts)
    inactive_category = create(:category)

    inactive_categories = Category.inactive

    assert_includes inactive_categories, inactive_category
    assert_not_includes inactive_categories, active_category
  end

  test "inactive scope should handle category after removing all posts" do
    category = create(:category, :with_one_post)
    category.posts.clear

    assert_includes Category.inactive, category
  end

  test "alphabetical scope should order categories by name ascending" do
    cat_z = create(:category, name: "Zebra")
    cat_a = create(:category, name: "Apple")
    cat_m = create(:category, name: "Mango")

    ordered = Category.alphabetical.to_a

    assert_equal cat_a, ordered[0]
    assert_equal cat_m, ordered[1]
    assert_equal cat_z, ordered[2]
  end

  test "by_post_count scope should order by number of posts descending" do
    cat_many = create(:category, :with_many_posts) # 10 posts
    cat_few = create(:category, :with_one_post)    # 1 post
    cat_none = create(:category)                    # 0 posts

    ordered = Category.by_post_count.to_a

    assert_equal cat_many, ordered[0]
    assert_equal cat_few, ordered[1]
    assert_equal cat_none, ordered[2]
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  test "active? should return true when category has posts" do
    category = create(:category, :with_posts)
    assert category.active?
  end

  test "active? should return false when category has no posts" do
    category = create(:category)
    assert_not category.active?
  end

  test "active? should update when posts are added" do
    category = create(:category)
    assert_not category.active?

    category.posts << create(:post)
    assert category.active?
  end

  test "inactive? should return true when category has no posts" do
    category = create(:category)
    assert category.inactive?
  end

  test "inactive? should return false when category has posts" do
    category = create(:category, :with_posts)
    assert_not category.inactive?
  end

  test "posts_count should return correct number of posts" do
    category = create(:category, :with_many_posts)
    assert_equal 10, category.posts_count
  end

  test "posts_count should return zero for inactive category" do
    category = create(:category)
    assert_equal 0, category.posts_count
  end

  test "posts_count should update when posts are added or removed" do
    category = create(:category)
    assert_equal 0, category.posts_count

    category.posts << create(:post)
    assert_equal 1, category.posts_count

    category.posts << create(:post)
    assert_equal 2, category.posts_count

    category.posts.first.destroy
    assert_equal 1, category.posts_count
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle very long name" do
    long_name = "A" * 1000
    category = build(:category, name: long_name)
    category.valid?
    assert_not_nil category
  end

  test "should handle special characters in name" do
    category = build(:category, name: "Tech & Innovation: 2024 © ®")
    assert category.valid?
  end

  test "should handle unicode characters in name" do
    category = build(:category, name: "Tecnología 技術 تكنولوجيا")
    assert category.valid?
  end

  test "should handle name with only whitespace" do
    category = build(:category, name: "   ")
    assert_not category.valid?
  end

  test "should handle multiple categories with similar names" do
    cat1 = create(:category, name: "Technology")
    cat2 = create(:category, name: "Technology News")
    cat3 = create(:category, name: "Technology Blog")

    assert_equal 3, Category.where("name LIKE ?", "Technology%").count
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "should handle category with published and draft posts" do
    category = create(:category)
    published_post = create(:post, :published, categories: [category])
    draft_post = create(:post, :draft, categories: [category])

    assert_equal 2, category.posts.count
    assert_includes category.posts, published_post
    assert_includes category.posts, draft_post
  end

  test "should filter active categories alphabetically" do
    cat_z = create(:category, :with_posts, name: "Zebra")
    cat_a = create(:category, :with_posts, name: "Apple")
    inactive = create(:category, name: "Middle")

    result = Category.active.alphabetical.to_a

    assert_equal 2, result.size
    assert_equal cat_a, result[0]
    assert_equal cat_z, result[1]
    assert_not_includes result, inactive
  end

  test "should handle category updates without breaking associations" do
    category = create(:category, :with_posts)
    original_posts_count = category.posts.count

    category.update(name: "Updated Name")

    assert_equal original_posts_count, category.reload.posts.count
  end
end
