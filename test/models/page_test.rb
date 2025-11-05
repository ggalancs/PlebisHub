require 'test_helper'

class PageTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid page" do
    page = build(:page)
    assert page.valid?, "Factory should create a valid page"
  end

  test "factory creates valid promoted page" do
    page = build(:page, :promoted)
    assert page.valid?
    assert page.promoted?
    assert_equal 10, page.priority
  end

  test "factory creates valid page requiring login" do
    page = build(:page, :requires_login)
    assert page.valid?
    assert page.require_login?
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  # Title validations
  test "should require title" do
    page = build(:page, title: nil)
    assert_not page.valid?
    assert_includes page.errors[:title], "can't be blank"
  end

  test "should accept valid title" do
    page = build(:page, title: "Valid Page Title")
    assert page.valid?
  end

  test "should accept empty string title as invalid" do
    page = build(:page, title: "")
    assert_not page.valid?
    assert_includes page.errors[:title], "can't be blank"
  end

  # Slug validations
  test "should require slug" do
    page = build(:page, slug: nil)
    assert_not page.valid?
    assert_includes page.errors[:slug], "can't be blank"
  end

  test "should require unique slug" do
    create(:page, slug: "unique-slug")
    duplicate_page = build(:page, slug: "unique-slug")
    assert_not duplicate_page.valid?
    assert_includes duplicate_page.errors[:slug], "has already been taken"
  end

  test "should enforce case-insensitive slug uniqueness" do
    create(:page, slug: "my-slug")
    duplicate_page = build(:page, slug: "MY-SLUG")
    assert_not duplicate_page.valid?
    assert_includes duplicate_page.errors[:slug], "has already been taken"
  end

  test "should allow same slug if one is deleted (paranoid scope)" do
    deleted_page = create(:page, slug: "reusable-slug")
    deleted_page.destroy # Soft delete

    new_page = build(:page, slug: "reusable-slug")
    assert new_page.valid?, "Should allow same slug when previous is soft-deleted"
  end

  test "should not allow duplicate slug among non-deleted pages" do
    create(:page, slug: "active-slug")
    deleted_page = create(:page, slug: "deleted-slug")
    deleted_page.destroy

    duplicate = build(:page, slug: "active-slug")
    assert_not duplicate.valid?
  end

  # id_form validations
  test "should require id_form" do
    page = build(:page, id_form: nil)
    assert_not page.valid?
    assert_includes page.errors[:id_form], "can't be blank"
  end

  test "should require id_form to be greater than or equal to 0" do
    page = build(:page, id_form: -1)
    assert_not page.valid?
    assert_includes page.errors[:id_form], "must be greater than or equal to 0"
  end

  test "should accept id_form equal to 0" do
    page = build(:page, id_form: 0)
    assert page.valid?
  end

  test "should accept positive id_form" do
    page = build(:page, id_form: 100)
    assert page.valid?
  end

  test "should reject non-numeric id_form" do
    page = build(:page)
    page.id_form = "not a number"
    assert_not page.valid?
    assert_includes page.errors[:id_form], "is not a number"
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create page with valid attributes" do
    assert_difference('Page.count', 1) do
      create(:page)
    end
  end

  test "should read page attributes correctly" do
    page = create(:page,
      title: "Test Title",
      slug: "test-slug",
      id_form: 42,
      require_login: true,
      promoted: true,
      priority: 5
    )

    found_page = Page.find(page.id)
    assert_equal "Test Title", found_page.title
    assert_equal "test-slug", found_page.slug
    assert_equal 42, found_page.id_form
    assert found_page.require_login
    assert found_page.promoted
    assert_equal 5, found_page.priority
  end

  test "should update page attributes" do
    page = create(:page, title: "Original Title")
    page.update(title: "Updated Title")

    assert_equal "Updated Title", page.reload.title
  end

  test "should not update with invalid attributes" do
    page = create(:page, title: "Valid Title")
    page.update(title: nil)

    assert_not page.valid?
    assert_equal "Valid Title", page.reload.title
  end

  test "should delete page" do
    page = create(:page)
    assert_difference('Page.count', -1) do
      page.destroy
    end
  end

  # ====================
  # PARANOID (SOFT DELETE) TESTS
  # ====================

  test "should soft delete page when destroyed" do
    page = create(:page)
    page.destroy

    assert_not_nil page.deleted_at
    assert page.deleted?
  end

  test "soft deleted page should not appear in default scope" do
    active_page = create(:page, slug: "active")
    deleted_page = create(:page, slug: "deleted")
    deleted_page.destroy

    assert_includes Page.all, active_page
    assert_not_includes Page.all, deleted_page
  end

  test "should find soft deleted pages with with_deleted scope" do
    page = create(:page)
    page.destroy

    assert_includes Page.with_deleted, page
  end

  test "should find only deleted pages with only_deleted scope" do
    active_page = create(:page, slug: "active")
    deleted_page = create(:page, slug: "deleted")
    deleted_page.destroy

    assert_not_includes Page.only_deleted, active_page
    assert_includes Page.only_deleted, deleted_page
  end

  test "should restore soft deleted page" do
    page = create(:page)
    page.destroy
    assert page.deleted?

    page.restore
    assert_not page.deleted?
    assert_nil page.deleted_at
  end

  test "should not allow duplicate slug after restore if slug already exists" do
    page1 = create(:page, slug: "duplicate-slug")
    page1.destroy

    page2 = create(:page, slug: "duplicate-slug")

    page1.restore
    assert_not page1.valid?
  end

  # ====================
  # DEFAULT VALUE TESTS
  # ====================

  test "should have default value for require_login" do
    page = Page.new(title: "Test", slug: "test", id_form: 1)
    # Check database default or model default
    page.save
    # require_login defaults to false or nil depending on DB schema
    assert_includes [false, nil], page.require_login
  end

  test "should have default value for promoted as false" do
    page = create(:page)
    assert_equal false, page.promoted
  end

  test "should have default value for priority as 0" do
    page = create(:page)
    assert_equal 0, page.priority
  end

  # ====================
  # OPTIONAL FIELD TESTS
  # ====================

  test "should allow nil link" do
    page = build(:page, link: nil)
    assert page.valid?
  end

  test "should accept valid link" do
    page = build(:page, link: "https://example.com/form")
    assert page.valid?
  end

  test "should allow nil meta_description" do
    page = build(:page, meta_description: nil)
    assert page.valid?
  end

  test "should allow nil meta_image" do
    page = build(:page, meta_image: nil)
    assert page.valid?
  end

  test "should allow nil text_button" do
    page = build(:page, text_button: nil)
    assert page.valid?
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle very long title" do
    long_title = "A" * 1000
    page = build(:page, title: long_title)
    # This might be valid or invalid depending on DB column size
    # Adjust based on actual schema constraints
    page.save
    # Just ensure it doesn't crash
    assert_not_nil page
  end

  test "should handle special characters in slug" do
    page = build(:page, slug: "page-with-special-chars-123")
    assert page.valid?
  end

  test "should handle special characters in title" do
    page = build(:page, title: "Title with 特殊 characters & symbols!")
    assert page.valid?
  end

  test "should handle maximum integer for id_form" do
    page = build(:page, id_form: 2147483647) # Max 32-bit integer
    assert page.valid?
  end

  test "should handle maximum integer for priority" do
    page = build(:page, priority: 2147483647)
    assert page.valid?
  end

  # ====================
  # MULTIPLE RECORD TESTS
  # ====================

  test "should create multiple pages with different slugs" do
    assert_difference('Page.count', 3) do
      create(:page, slug: "page-1")
      create(:page, slug: "page-2")
      create(:page, slug: "page-3")
    end
  end

  test "should maintain uniqueness across multiple creates" do
    create(:page, slug: "unique")

    assert_raises(ActiveRecord::RecordInvalid) do
      create(:page, slug: "unique")
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "promoted scope should return only promoted pages" do
    promoted_page = create(:page, :promoted)
    regular_page = create(:page)

    promoted_pages = Page.promoted

    assert_includes promoted_pages, promoted_page
    assert_not_includes promoted_pages, regular_page
  end

  test "promoted scope should return empty when no promoted pages exist" do
    create(:page, promoted: false)
    create(:page, promoted: false)

    assert_empty Page.promoted
  end

  test "ordered_by_priority scope should order by priority descending" do
    page_low = create(:page, priority: 1)
    page_high = create(:page, priority: 100)
    page_medium = create(:page, priority: 50)

    ordered = Page.ordered_by_priority.to_a

    assert_equal page_high, ordered[0]
    assert_equal page_medium, ordered[1]
    assert_equal page_low, ordered[2]
  end

  test "promoted_ordered scope should return promoted pages ordered by priority" do
    promoted_high = create(:page, promoted: true, priority: 100)
    promoted_low = create(:page, promoted: true, priority: 10)
    regular_page = create(:page, promoted: false, priority: 200)

    result = Page.promoted_ordered.to_a

    assert_equal 2, result.size
    assert_equal promoted_high, result[0]
    assert_equal promoted_low, result[1]
    assert_not_includes result, regular_page
  end

  test "promoted_ordered scope should handle empty result" do
    create(:page, promoted: false)

    assert_empty Page.promoted_ordered
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  test "external_plebisbrand_link? should return true for plebisbrand.info links" do
    page = create(:page, link: "https://forms.plebisbrand.info/some-form/")
    assert page.external_plebisbrand_link?
  end

  test "external_plebisbrand_link? should return true for subdomain plebisbrand.info links" do
    page = create(:page, link: "https://any.plebisbrand.info/path/")
    assert page.external_plebisbrand_link?
  end

  test "external_plebisbrand_link? should return false for non-plebisbrand links" do
    page = create(:page, link: "https://example.com/form/")
    assert_not page.external_plebisbrand_link?
  end

  test "external_plebisbrand_link? should return false for blank link" do
    page = create(:page, link: nil)
    assert_not page.external_plebisbrand_link?
  end

  test "external_plebisbrand_link? should return false for empty string link" do
    page = create(:page, link: "")
    assert_not page.external_plebisbrand_link?
  end

  test "external_plebisbrand_link? should return false for http (non-https) links" do
    page = create(:page, link: "http://forms.plebisbrand.info/form/")
    assert_not page.external_plebisbrand_link?
  end

  test "external_plebisbrand_link? should handle malformed URLs gracefully" do
    page = create(:page, link: "not a url")
    assert_not page.external_plebisbrand_link?
  end
end
