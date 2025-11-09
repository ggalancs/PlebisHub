# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Page, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid page' do
      page = build(:page)
      expect(page).to be_valid, "Factory should create a valid page"
    end

    it 'creates valid promoted page' do
      page = build(:page, :promoted)
      expect(page).to be_valid
      expect(page).to be_promoted
      expect(page.priority).to eq(10)
    end

    it 'creates valid page requiring login' do
      page = build(:page, :requires_login)
      expect(page).to be_valid
      expect(page).to be_require_login
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    context 'title' do
      it 'requires title' do
        page = build(:page, title: nil)
        expect(page).not_to be_valid
        expect(page.errors[:title]).to include("can't be blank")
      end

      it 'accepts valid title' do
        page = build(:page, title: "Valid Page Title")
        expect(page).to be_valid
      end

      it 'rejects empty string title' do
        page = build(:page, title: "")
        expect(page).not_to be_valid
        expect(page.errors[:title]).to include("can't be blank")
      end
    end

    context 'slug' do
      it 'requires slug' do
        page = build(:page, slug: nil)
        expect(page).not_to be_valid
        expect(page.errors[:slug]).to include("can't be blank")
      end

      it 'requires unique slug' do
        create(:page, slug: "unique-slug")
        duplicate_page = build(:page, slug: "unique-slug")
        expect(duplicate_page).not_to be_valid
        expect(duplicate_page.errors[:slug]).to include("has already been taken")
      end

      it 'enforces case-insensitive slug uniqueness' do
        create(:page, slug: "my-slug")
        duplicate_page = build(:page, slug: "MY-SLUG")
        expect(duplicate_page).not_to be_valid
        expect(duplicate_page.errors[:slug]).to include("has already been taken")
      end

      it 'allows same slug if one is deleted (paranoid scope)' do
        deleted_page = create(:page, slug: "reusable-slug")
        deleted_page.destroy # Soft delete

        new_page = build(:page, slug: "reusable-slug")
        expect(new_page).to be_valid, "Should allow same slug when previous is soft-deleted"
      end

      it 'does not allow duplicate slug among non-deleted pages' do
        create(:page, slug: "active-slug")
        deleted_page = create(:page, slug: "deleted-slug")
        deleted_page.destroy

        duplicate = build(:page, slug: "active-slug")
        expect(duplicate).not_to be_valid
      end
    end

    context 'id_form' do
      it 'requires id_form' do
        page = build(:page, id_form: nil)
        expect(page).not_to be_valid
        expect(page.errors[:id_form]).to include("can't be blank")
      end

      it 'requires id_form to be greater than or equal to 0' do
        page = build(:page, id_form: -1)
        expect(page).not_to be_valid
        expect(page.errors[:id_form]).to include("must be greater than or equal to 0")
      end

      it 'accepts id_form equal to 0' do
        page = build(:page, id_form: 0)
        expect(page).to be_valid
      end

      it 'accepts positive id_form' do
        page = build(:page, id_form: 100)
        expect(page).to be_valid
      end

      it 'rejects non-numeric id_form' do
        page = build(:page)
        page.id_form = "not a number"
        expect(page).not_to be_valid
        expect(page.errors[:id_form]).to include("is not a number")
      end
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates page with valid attributes' do
      expect { create(:page) }.to change(Page, :count).by(1)
    end

    it 'reads page attributes correctly' do
      page = create(:page,
        title: "Test Title",
        slug: "test-slug",
        id_form: 42,
        require_login: true,
        promoted: true,
        priority: 5
      )

      found_page = Page.find(page.id)
      expect(found_page.title).to eq("Test Title")
      expect(found_page.slug).to eq("test-slug")
      expect(found_page.id_form).to eq(42)
      expect(found_page.require_login).to be_truthy
      expect(found_page.promoted).to be_truthy
      expect(found_page.priority).to eq(5)
    end

    it 'updates page attributes' do
      page = create(:page, title: "Original Title")
      page.update(title: "Updated Title")

      expect(page.reload.title).to eq("Updated Title")
    end

    it 'does not update with invalid attributes' do
      page = create(:page, title: "Valid Title")
      page.update(title: nil)

      expect(page).not_to be_valid
      expect(page.reload.title).to eq("Valid Title")
    end

    it 'deletes page' do
      page = create(:page)
      expect { page.destroy }.to change(Page, :count).by(-1)
    end
  end

  # ====================
  # PARANOID (SOFT DELETE) TESTS
  # ====================

  describe 'paranoid (soft delete)' do
    it 'soft deletes page when destroyed' do
      page = create(:page)
      page.destroy

      expect(page.deleted_at).not_to be_nil
      expect(page).to be_deleted
    end

    it 'excludes soft deleted page from default scope' do
      active_page = create(:page, slug: "active")
      deleted_page = create(:page, slug: "deleted")
      deleted_page.destroy

      expect(Page.all).to include(active_page)
      expect(Page.all).not_to include(deleted_page)
    end

    it 'finds soft deleted pages with with_deleted scope' do
      page = create(:page)
      page.destroy

      expect(Page.with_deleted).to include(page)
    end

    it 'finds only deleted pages with only_deleted scope' do
      active_page = create(:page, slug: "active")
      deleted_page = create(:page, slug: "deleted")
      deleted_page.destroy

      expect(Page.only_deleted).not_to include(active_page)
      expect(Page.only_deleted).to include(deleted_page)
    end

    it 'restores soft deleted page' do
      page = create(:page)
      page.destroy
      expect(page).to be_deleted

      page.restore
      expect(page).not_to be_deleted
      expect(page.deleted_at).to be_nil
    end

    it 'does not allow duplicate slug after restore if slug already exists' do
      page1 = create(:page, slug: "duplicate-slug")
      page1.destroy

      page2 = create(:page, slug: "duplicate-slug")

      page1.restore
      expect(page1).not_to be_valid
    end
  end

  # ====================
  # DEFAULT VALUE TESTS
  # ====================

  describe 'default values' do
    it 'has default value for require_login' do
      page = Page.new(title: "Test", slug: "test", id_form: 1)
      # Check database default or model default
      page.save
      # require_login defaults to false or nil depending on DB schema
      expect([false, nil]).to include(page.require_login)
    end

    it 'has default value for promoted as false' do
      page = create(:page)
      expect(page.promoted).to eq(false)
    end

    it 'has default value for priority as 0' do
      page = create(:page)
      expect(page.priority).to eq(0)
    end
  end

  # ====================
  # OPTIONAL FIELD TESTS
  # ====================

  describe 'optional fields' do
    it 'allows nil link' do
      page = build(:page, link: nil)
      expect(page).to be_valid
    end

    it 'accepts valid link' do
      page = build(:page, link: "https://example.com/form")
      expect(page).to be_valid
    end

    it 'allows nil meta_description' do
      page = build(:page, meta_description: nil)
      expect(page).to be_valid
    end

    it 'allows nil meta_image' do
      page = build(:page, meta_image: nil)
      expect(page).to be_valid
    end

    it 'allows nil text_button' do
      page = build(:page, text_button: nil)
      expect(page).to be_valid
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles very long title' do
      long_title = "A" * 1000
      page = build(:page, title: long_title)
      # This might be valid or invalid depending on DB column size
      # Adjust based on actual schema constraints
      page.save
      # Just ensure it doesn't crash
      expect(page).not_to be_nil
    end

    it 'handles special characters in slug' do
      page = build(:page, slug: "page-with-special-chars-123")
      expect(page).to be_valid
    end

    it 'handles special characters in title' do
      page = build(:page, title: "Title with 特殊 characters & symbols!")
      expect(page).to be_valid
    end

    it 'handles maximum integer for id_form' do
      page = build(:page, id_form: 2147483647) # Max 32-bit integer
      expect(page).to be_valid
    end

    it 'handles maximum integer for priority' do
      page = build(:page, priority: 2147483647)
      expect(page).to be_valid
    end
  end

  # ====================
  # MULTIPLE RECORD TESTS
  # ====================

  describe 'multiple records' do
    it 'creates multiple pages with different slugs' do
      expect {
        create(:page, slug: "page-1")
        create(:page, slug: "page-2")
        create(:page, slug: "page-3")
      }.to change(Page, :count).by(3)
    end

    it 'maintains uniqueness across multiple creates' do
      create(:page, slug: "unique")

      expect {
        create(:page, slug: "unique")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.promoted' do
      it 'returns only promoted pages' do
        promoted_page = create(:page, :promoted)
        regular_page = create(:page)

        promoted_pages = Page.promoted

        expect(promoted_pages).to include(promoted_page)
        expect(promoted_pages).not_to include(regular_page)
      end

      it 'returns empty when no promoted pages exist' do
        create(:page, promoted: false)
        create(:page, promoted: false)

        expect(Page.promoted).to be_empty
      end
    end

    describe '.ordered_by_priority' do
      it 'orders by priority descending' do
        page_low = create(:page, priority: 1)
        page_high = create(:page, priority: 100)
        page_medium = create(:page, priority: 50)

        ordered = Page.ordered_by_priority.to_a

        expect(ordered[0]).to eq(page_high)
        expect(ordered[1]).to eq(page_medium)
        expect(ordered[2]).to eq(page_low)
      end
    end

    describe '.promoted_ordered' do
      it 'returns promoted pages ordered by priority' do
        promoted_high = create(:page, promoted: true, priority: 100)
        promoted_low = create(:page, promoted: true, priority: 10)
        regular_page = create(:page, promoted: false, priority: 200)

        result = Page.promoted_ordered.to_a

        expect(result.size).to eq(2)
        expect(result[0]).to eq(promoted_high)
        expect(result[1]).to eq(promoted_low)
        expect(result).not_to include(regular_page)
      end

      it 'handles empty result' do
        create(:page, promoted: false)

        expect(Page.promoted_ordered).to be_empty
      end
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#external_plebisbrand_link?' do
      it 'returns true for plebisbrand.info links' do
        page = create(:page, link: "https://forms.plebisbrand.info/some-form/")
        expect(page).to be_external_plebisbrand_link
      end

      it 'returns true for subdomain plebisbrand.info links' do
        page = create(:page, link: "https://any.plebisbrand.info/path/")
        expect(page).to be_external_plebisbrand_link
      end

      it 'returns false for non-plebisbrand links' do
        page = create(:page, link: "https://example.com/form/")
        expect(page).not_to be_external_plebisbrand_link
      end

      it 'returns false for blank link' do
        page = create(:page, link: nil)
        expect(page).not_to be_external_plebisbrand_link
      end

      it 'returns false for empty string link' do
        page = create(:page, link: "")
        expect(page).not_to be_external_plebisbrand_link
      end

      it 'returns false for http (non-https) links' do
        page = create(:page, link: "http://forms.plebisbrand.info/form/")
        expect(page).not_to be_external_plebisbrand_link
      end

      it 'handles malformed URLs gracefully' do
        page = create(:page, link: "not a url")
        expect(page).not_to be_external_plebisbrand_link
      end
    end
  end
end
