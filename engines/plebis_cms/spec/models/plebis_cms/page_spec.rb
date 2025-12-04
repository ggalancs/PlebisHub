# frozen_string_literal: true

require 'rails_helper'

module PlebisCms
  RSpec.describe Page, type: :model do
    describe 'validations' do
      describe 'presence validations' do
        it 'validates presence of id_form' do
          page = build(:page, id_form: nil)
          expect(page).not_to be_valid
          expect(page.errors[:id_form]).to be_present
        end

        it 'validates presence of slug' do
          page = build(:page, slug: nil)
          expect(page).not_to be_valid
          expect(page.errors[:slug]).to be_present
        end

        it 'validates presence of title' do
          page = build(:page, title: nil)
          expect(page).not_to be_valid
          expect(page.errors[:title]).to be_present
        end
      end

      describe 'id_form validation' do
        it 'validates numericality of id_form' do
          page = build(:page, id_form: 'not a number')
          expect(page).not_to be_valid
          expect(page.errors[:id_form]).to be_present
        end

        it 'validates id_form is an integer' do
          page = build(:page, id_form: 1.5)
          expect(page).not_to be_valid
          expect(page.errors[:id_form]).to be_present
        end

        it 'validates id_form is greater than or equal to 0' do
          page = build(:page, id_form: -1)
          expect(page).not_to be_valid
          expect(page.errors[:id_form]).to be_present
        end

        it 'allows id_form to be 0' do
          page = build(:page, id_form: 0)
          expect(page).to be_valid
        end

        it 'allows positive integers for id_form' do
          page = build(:page, id_form: 42)
          expect(page).to be_valid
        end
      end

      describe 'slug uniqueness validation' do
        it 'validates uniqueness of slug (case insensitive)' do
          create(:page, slug: 'unique-slug')
          page = build(:page, slug: 'UNIQUE-SLUG')
          expect(page).not_to be_valid
          expect(page.errors[:slug]).to be_present
        end

        it 'allows same slug for deleted pages' do
          create(:page, slug: 'deleted-slug', deleted_at: Time.current)
          page = build(:page, slug: 'deleted-slug')
          expect(page).to be_valid
        end

        it 'validates uniqueness within non-deleted pages' do
          create(:page, slug: 'active-slug')
          page = build(:page, slug: 'active-slug')
          expect(page).not_to be_valid
        end
      end
    end

    describe 'paranoia (soft delete)' do
      it 'responds to acts_as_paranoid methods' do
        page = create(:page)
        expect(page).to respond_to(:deleted_at)
        expect(page).to respond_to(:deleted?)
      end

      it 'soft deletes the record' do
        page = create(:page)
        initial_count = PlebisCms::Page.count
        page.destroy
        expect(PlebisCms::Page.count).to eq(initial_count - 1)
        expect(PlebisCms::Page.with_deleted.count).to eq(initial_count)
        expect(page.deleted_at).not_to be_nil
      end

      it 'does not include deleted pages in default scope' do
        active_page = create(:page)
        deleted_page = create(:page)
        deleted_page.destroy

        expect(PlebisCms::Page.all).to include(active_page)
        expect(PlebisCms::Page.all).not_to include(deleted_page)
      end

      it 'includes deleted pages in with_deleted scope' do
        active_page = create(:page)
        deleted_page = create(:page)
        deleted_page.destroy

        expect(PlebisCms::Page.with_deleted).to include(active_page)
        expect(PlebisCms::Page.with_deleted).to include(deleted_page)
      end

      it 'shows only deleted pages in only_deleted scope' do
        active_page = create(:page)
        deleted_page = create(:page)
        deleted_page.destroy

        expect(PlebisCms::Page.only_deleted).not_to include(active_page)
        expect(PlebisCms::Page.only_deleted).to include(deleted_page)
      end
    end

    describe 'scopes' do
      describe '.promoted' do
        it 'returns only promoted pages' do
          promoted_page = create(:page, promoted: true)
          regular_page = create(:page, promoted: false)

          expect(PlebisCms::Page.promoted).to include(promoted_page)
          expect(PlebisCms::Page.promoted).not_to include(regular_page)
        end

        it 'returns empty array when no promoted pages exist' do
          create(:page, promoted: false)
          expect(PlebisCms::Page.promoted).to be_empty
        end

        it 'returns multiple promoted pages' do
          promoted_page1 = create(:page, promoted: true)
          promoted_page2 = create(:page, promoted: true)
          create(:page, promoted: false)

          result = PlebisCms::Page.promoted
          expect(result).to include(promoted_page1, promoted_page2)
          expect(result.count).to eq(2)
        end
      end

      describe '.ordered_by_priority' do
        it 'orders pages by priority in descending order' do
          low_priority = create(:page, priority: 1)
          high_priority = create(:page, priority: 100)
          medium_priority = create(:page, priority: 50)

          result = PlebisCms::Page.ordered_by_priority.pluck(:id)
          expect(result).to eq([high_priority.id, medium_priority.id, low_priority.id])
        end

        it 'handles pages with same priority' do
          page1 = create(:page, priority: 10)
          page2 = create(:page, priority: 10)

          result = PlebisCms::Page.ordered_by_priority
          expect(result).to include(page1, page2)
        end

        it 'handles negative priorities' do
          negative_priority = create(:page, priority: -10)
          zero_priority = create(:page, priority: 0)
          positive_priority = create(:page, priority: 10)

          result = PlebisCms::Page.ordered_by_priority.pluck(:id)
          expect(result).to eq([positive_priority.id, zero_priority.id, negative_priority.id])
        end
      end

      describe '.promoted_ordered' do
        it 'returns promoted pages ordered by priority' do
          low_promoted = create(:page, promoted: true, priority: 10)
          high_promoted = create(:page, promoted: true, priority: 100)
          regular_page = create(:page, promoted: false, priority: 200)

          result = PlebisCms::Page.promoted_ordered.pluck(:id)
          expect(result).to eq([high_promoted.id, low_promoted.id])
          expect(result).not_to include(regular_page.id)
        end

        it 'returns empty array when no promoted pages exist' do
          create(:page, promoted: false, priority: 100)
          expect(PlebisCms::Page.promoted_ordered).to be_empty
        end

        it 'maintains correct order for multiple promoted pages' do
          promoted1 = create(:page, promoted: true, priority: 5)
          promoted2 = create(:page, promoted: true, priority: 50)
          promoted3 = create(:page, promoted: true, priority: 25)

          result = PlebisCms::Page.promoted_ordered.pluck(:id)
          expect(result).to eq([promoted2.id, promoted3.id, promoted1.id])
        end
      end
    end

    describe '#external_plebisbrand_link?' do
      it 'returns false when link is nil' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-1', id_form: 1, link: nil)
        expect(page.external_plebisbrand_link?).to be false
      end

      it 'returns false when link is blank' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-2', id_form: 2, link: '')
        expect(page.external_plebisbrand_link?).to be false
      end

      it 'returns false when link is just whitespace' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-3', id_form: 3, link: '   ')
        expect(page.external_plebisbrand_link?).to be false
      end

      it 'returns true for plebisbrand.info subdomain links' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-4', id_form: 4, link: 'https://forms.plebisbrand.info/form-123/')
        expect(page.external_plebisbrand_link?).to be true
      end

      it 'returns true for different plebisbrand.info subdomains' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-5', id_form: 5, link: 'https://app.plebisbrand.info/page')
        expect(page.external_plebisbrand_link?).to be true
      end

      it 'returns false for non-plebisbrand links' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-6', id_form: 6, link: 'https://example.com/page')
        expect(page.external_plebisbrand_link?).to be false
      end

      it 'returns false for plebisbrand.com (different TLD)' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-7', id_form: 7, link: 'https://forms.plebisbrand.com/form')
        expect(page.external_plebisbrand_link?).to be false
      end

      it 'returns false for http (non-https) plebisbrand.info links' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-8', id_form: 8, link: 'http://forms.plebisbrand.info/form')
        expect(page.external_plebisbrand_link?).to be false
      end

      it 'returns false for plebisbrand.info without subdomain' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-9', id_form: 9, link: 'https://plebisbrand.info/form')
        expect(page.external_plebisbrand_link?).to be false
      end

      it 'returns true for links with query parameters' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-10', id_form: 10, link: 'https://forms.plebisbrand.info/form?id=123')
        expect(page.external_plebisbrand_link?).to be true
      end

      it 'returns true for links with fragments' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-11', id_form: 11, link: 'https://forms.plebisbrand.info/form#section')
        expect(page.external_plebisbrand_link?).to be true
      end

      it 'returns true for links with multiple path segments' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-12', id_form: 12, link: 'https://api.plebisbrand.info/v1/forms/create')
        expect(page.external_plebisbrand_link?).to be true
      end

      it 'returns false for malformed URLs' do
        page = PlebisCms::Page.new(title: 'Test', slug: 'test-13', id_form: 13, link: 'not-a-url')
        expect(page.external_plebisbrand_link?).to be false
      end
    end

    describe 'table name' do
      it 'uses pages table' do
        expect(PlebisCms::Page.table_name).to eq('pages')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        page = build(:page)
        expect(page).to be_valid
      end

      it 'creates a page with all required attributes' do
        page = create(:page)
        expect(page).to be_persisted
        expect(page.title).to be_present
        expect(page.slug).to be_present
        expect(page.id_form).to be_present
      end
    end
  end
end
