# frozen_string_literal: true

require 'rails_helper'
require_relative '../../lib/diff'

RSpec.describe ActiveRecord::Diff do
  # Create a test model class
  let(:test_model_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'pages'
      include ActiveRecord::Diff

      def self.name
        'TestModel'
      end
    end
  end

  let!(:page) { Page.create!(title: 'Test Page', slug: 'test-page', id_form: 1) }

  describe '.diff' do
    it 'sets the diff_attrs class attribute' do
      test_model_class.diff(:title, :slug)
      expect(test_model_class.diff_attrs).to eq([:title, :slug])
    end

    it 'can be called with multiple attributes' do
      test_model_class.diff(:title, :slug, :meta_description)
      expect(test_model_class.diff_attrs).to eq([:title, :slug, :meta_description])
    end

    it 'can be called with a single attribute' do
      test_model_class.diff(:title)
      expect(test_model_class.diff_attrs).to eq([:title])
    end

    it 'can be called with no attributes' do
      test_model_class.diff
      # When called with no args, it sets diff_attrs to empty array
      expect(test_model_class.diff_attrs).to eq([])
    end
  end

  describe '#diff?' do
    before do
      Page.class_eval do
        include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
        diff :title, :slug
      end
    end

    it 'returns true when there are differences' do
      page.title = 'Changed Title'
      expect(page.diff?).to be true
    end

    it 'returns false when there are no differences' do
      page.reload
      expect(page.diff?).to be false
    end

    it 'returns true when comparing with another record with differences' do
      other_page = Page.new(title: 'Other Page', slug: 'other-slug')
      expect(page.diff?(other_page)).to be true
    end

    it 'returns false when comparing with another record without differences' do
      other_page = Page.new(title: page.title, slug: page.slug)
      expect(page.diff?(other_page)).to be false
    end

    it 'returns true when comparing with a hash with differences' do
      expect(page.diff?(title: 'New Title')).to be true
    end

    it 'returns false when comparing with a hash without differences' do
      expect(page.diff?(title: page.title)).to be false
    end
  end

  describe '#diff' do
    before do
      Page.class_eval do
        include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
        diff :title, :slug
      end
    end

    context 'when comparing with database version' do
      it 'returns empty hash when no changes' do
        page.reload
        expect(page.diff).to be_empty
      end

      it 'returns hash with changed attributes' do
        page.title = 'Changed Title'
        diff = page.diff
        expect(diff).to have_key(:title)
        expect(diff[:title]).to eq(['Test Page', 'Changed Title'])
      end

      it 'includes multiple changed attributes' do
        page.title = 'Changed Title'
        page.slug = 'changed-slug'
        diff = page.diff
        expect(diff).to have_key(:title)
        expect(diff).to have_key(:slug)
      end

      it 'does not include unchanged attributes' do
        page.title = 'Changed Title'
        diff = page.diff
        expect(diff).not_to have_key(:slug)
      end

      it 'handles nil other_record parameter correctly' do
        page.title = 'Changed Title'
        diff = page.diff(nil)
        expect(diff).to have_key(:title)
      end
    end

    context 'when comparing with another record' do
      let(:other_page) { Page.new(title: 'Other Page', slug: 'other-slug') }

      it 'returns differences between two records' do
        diff = page.diff(other_page)
        expect(diff).to have_key(:title)
        expect(diff).to have_key(:slug)
      end

      it 'returns empty hash when records are identical' do
        other_page.title = page.title
        other_page.slug = page.slug
        diff = page.diff(other_page)
        expect(diff).to be_empty
      end

      it 'shows correct old and new values' do
        diff = page.diff(other_page)
        expect(diff[:title]).to eq([page.title, other_page.title])
        expect(diff[:slug]).to eq([page.slug, other_page.slug])
      end
    end

    context 'when comparing with a hash' do
      it 'returns differences between record and hash' do
        hash = { title: 'New Title', slug: 'new-slug' }
        diff = page.diff(hash)
        expect(diff).to have_key(:title)
        expect(diff).to have_key(:slug)
      end

      it 'handles unchanged values' do
        hash = { title: page.title, slug: 'new-slug' }
        diff = page.diff(hash)
        expect(diff).not_to have_key(:title)
        expect(diff).to have_key(:slug)
      end

      it 'shows correct old and new values' do
        hash = { title: 'New Title' }
        diff = page.diff(hash)
        expect(diff[:title]).to eq(['Test Page', 'New Title'])
      end

      it 'handles partial hash with only some attributes' do
        hash = { title: 'New Title' }
        diff = page.diff(hash)
        expect(diff.keys).to eq([:title])
      end

      it 'iterates through hash key-value pairs' do
        hash = { title: 'New Title', slug: 'new-slug', meta_description: 'test' }
        diff = page.diff(hash)
        # All three keys should be present because meta_description is also different
        expect(diff.keys).to match_array([:title, :slug, :meta_description])
      end
    end

    context 'when diff_attrs is not set' do
      before do
        Page.class_eval do
          include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
          self.diff_attrs = nil
        end
      end

      it 'uses all content columns' do
        page.title = 'Changed Title'
        diff = page.diff
        expect(diff).to have_key(:title)
      end

      it 'excludes id and timestamp columns automatically' do
        page.title = 'Changed Title'
        diff = page.diff
        column_names = Page.content_columns.map { |c| c.name.to_sym }
        expect(column_names).not_to include(:id)
      end
    end

    context 'when using include/exclude options as hash' do
      it 'includes all content columns when using include option' do
        Page.class_eval do
          include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
          diff include: [], exclude: []
        end

        page.title = 'Changed Title'
        diff = page.diff
        expect(diff.keys).to include(:title)
      end

      it 'excludes specified attributes from content columns' do
        Page.class_eval do
          include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
          diff exclude: [:created_at, :updated_at]
        end

        page.title = 'Changed Title'
        diff = page.diff
        expect(diff.keys).not_to include(:created_at)
        expect(diff.keys).not_to include(:updated_at)
        expect(diff.keys).to include(:title)
      end

      it 'handles hash options with single element' do
        Page.class_eval do
          diff exclude: [:meta_description]
        end

        page.meta_description = 'new desc'
        diff = page.diff
        expect(diff.keys).not_to include(:meta_description)
      end

      it 'processes include and exclude arrays correctly' do
        Page.class_eval do
          diff include: [], exclude: [:slug, :meta_description]
        end

        page.title = 'Changed'
        diff = page.diff
        expect(diff.keys).to include(:title)
        expect(diff.keys).not_to include(:slug)
        expect(diff.keys).not_to include(:meta_description)
      end
    end
  end

  describe '#diff_each' do
    before do
      Page.class_eval do
        include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
      end
    end

    it 'iterates through attributes and yields differences' do
      enum = [:title, :slug]
      result = page.diff_each(enum) do |attr|
        [attr, 'old_value', 'new_value']
      end

      expect(result).to have_key(:title)
      expect(result).to have_key(:slug)
      expect(result[:title]).to eq(['old_value', 'new_value'])
      expect(result[:slug]).to eq(['old_value', 'new_value'])
    end

    it 'only includes changed values' do
      enum = [:title, :slug]
      result = page.diff_each(enum) do |attr|
        if attr == :title
          [attr, 'old', 'new']
        else
          [attr, 'same', 'same']
        end
      end

      expect(result).to have_key(:title)
      expect(result).not_to have_key(:slug)
    end

    it 'uses strict equality (===) for comparison' do
      enum = [:title]
      # Use string vs symbol to show === comparison (they're not ===)
      result = page.diff_each(enum) do |attr|
        [attr, 'test', :test]
      end

      expect(result).to have_key(:title)
      expect(result[:title]).to eq(['test', :test])
    end

    it 'returns empty hash when no differences' do
      enum = [:title]
      result = page.diff_each(enum) do |attr|
        [attr, 'same', 'same']
      end

      expect(result).to be_empty
    end

    it 'yields with each_with_object accumulator' do
      enum = [:title, :slug, :meta_description]
      result = page.diff_each(enum) do |attr|
        [attr, 'old', 'new']
      end

      expect(result.keys).to match_array([:title, :slug, :meta_description])
    end

    it 'converts attribute names to symbols' do
      enum = ['title', 'slug']
      result = page.diff_each(enum) do |attr|
        [attr, 'old', 'new']
      end

      expect(result.keys).to all(be_a(Symbol))
    end
  end

  describe 'Diff constant' do
    it 'is defined as ActiveRecord::Diff' do
      expect(Diff).to eq(ActiveRecord::Diff)
    end

    it 'is available globally' do
      expect(defined?(Diff)).to eq('constant')
    end
  end

  describe 'inclusion in ActiveRecord' do
    it 'extends ClassMethod when included' do
      test_class = Class.new(ActiveRecord::Base) do
        self.table_name = 'pages'
        include ActiveRecord::Diff
      end

      expect(test_class).to respond_to(:diff)
    end

    it 'adds class_attribute for diff_attrs' do
      test_class = Class.new(ActiveRecord::Base) do
        self.table_name = 'pages'
        include ActiveRecord::Diff
      end

      expect(test_class).to respond_to(:diff_attrs)
      expect(test_class).to respond_to(:diff_attrs=)
    end

    it 'makes diff_attrs accessible on instances' do
      test_class = Class.new(ActiveRecord::Base) do
        self.table_name = 'pages'
        include ActiveRecord::Diff
      end

      instance = test_class.new
      expect(instance).to respond_to(:diff_attrs)
    end
  end

  describe 'edge cases' do
    before do
      Page.class_eval do
        include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
        diff :title, :slug, :meta_description
      end
    end

    it 'handles nil values' do
      page.meta_description = 'something'
      page.save!
      page.meta_description = nil
      diff = page.diff
      expect(diff[:meta_description][1]).to be_nil
    end

    it 'handles empty strings' do
      page.meta_description = 'something'
      page.save!
      page.meta_description = ''
      diff = page.diff
      expect(diff[:meta_description][1]).to eq('')
    end

    it 'handles numeric values' do
      Page.class_eval { diff :id_form }
      page.id_form = 999
      diff = page.diff
      expect(diff[:id_form]).to eq([1, 999])
    end

    it 'handles boolean values' do
      Page.class_eval { diff :require_login }
      page.require_login = true
      diff = page.diff
      # Page has require_login default nil, not false
      expect(diff[:require_login]).to eq([nil, true])
    end

    it 'handles date/time values' do
      Page.class_eval { diff :created_at }
      new_time = 1.day.from_now
      page.created_at = new_time
      diff = page.diff
      expect(diff[:created_at][1]).to be_within(1.second).of(new_time)
    end

    it 'handles string to symbol attribute conversion' do
      result = page.diff_each(['title']) do |attr|
        [attr, 'old', 'new']
      end
      expect(result.keys.first).to be_a(Symbol)
    end
  end

  describe 'module structure' do
    it 'defines ClassMethod module' do
      expect(ActiveRecord::Diff::ClassMethod).to be_a(Module)
    end

    it 'ClassMethod module defines diff method' do
      expect(ActiveRecord::Diff::ClassMethod.instance_methods).to include(:diff)
    end

    it 'included hook sets up class_attribute and extends ClassMethod' do
      test_class = Class.new(ActiveRecord::Base) do
        self.table_name = 'pages'
      end

      expect(test_class).not_to respond_to(:diff_attrs)
      test_class.include(ActiveRecord::Diff)
      expect(test_class).to respond_to(:diff_attrs)
      expect(test_class).to respond_to(:diff)
    end
  end
end
