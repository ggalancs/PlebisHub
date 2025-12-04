# frozen_string_literal: true

require 'rails_helper'
require_relative '../../lib/paperclip_migration_helper'

RSpec.describe PaperclipMigrationHelper do
  let(:migration_class) do
    Class.new(ActiveRecord::Migration[7.0]) do
      include PaperclipMigrationHelper
    end
  end

  let(:migration) { migration_class.new }

  describe '#add_attachment' do
    let(:table_name) { :test_table }
    let(:attachment_name) { :avatar }

    it 'adds file_name column' do
      expect(migration).to receive(:add_column).with(
        table_name, 'avatar_file_name', :string
      )
      allow(migration).to receive(:add_column).with(table_name, 'avatar_content_type', :string)
      allow(migration).to receive(:add_column).with(table_name, 'avatar_file_size', :integer)
      allow(migration).to receive(:add_column).with(table_name, 'avatar_updated_at', :datetime)

      migration.add_attachment(table_name, attachment_name)
    end

    it 'adds content_type column' do
      allow(migration).to receive(:add_column).with(table_name, 'avatar_file_name', :string)
      expect(migration).to receive(:add_column).with(
        table_name, 'avatar_content_type', :string
      )
      allow(migration).to receive(:add_column).with(table_name, 'avatar_file_size', :integer)
      allow(migration).to receive(:add_column).with(table_name, 'avatar_updated_at', :datetime)

      migration.add_attachment(table_name, attachment_name)
    end

    it 'adds file_size column' do
      allow(migration).to receive(:add_column).with(table_name, 'avatar_file_name', :string)
      allow(migration).to receive(:add_column).with(table_name, 'avatar_content_type', :string)
      expect(migration).to receive(:add_column).with(
        table_name, 'avatar_file_size', :integer
      )
      allow(migration).to receive(:add_column).with(table_name, 'avatar_updated_at', :datetime)

      migration.add_attachment(table_name, attachment_name)
    end

    it 'adds updated_at column' do
      allow(migration).to receive(:add_column).with(table_name, 'avatar_file_name', :string)
      allow(migration).to receive(:add_column).with(table_name, 'avatar_content_type', :string)
      allow(migration).to receive(:add_column).with(table_name, 'avatar_file_size', :integer)
      expect(migration).to receive(:add_column).with(
        table_name, 'avatar_updated_at', :datetime
      )

      migration.add_attachment(table_name, attachment_name)
    end

    it 'adds all four columns' do
      expect(migration).to receive(:add_column).exactly(4).times

      migration.add_attachment(table_name, attachment_name)
    end

    it 'works with different table names' do
      expect(migration).to receive(:add_column).with(:users, 'photo_file_name', :string)
      expect(migration).to receive(:add_column).with(:users, 'photo_content_type', :string)
      expect(migration).to receive(:add_column).with(:users, 'photo_file_size', :integer)
      expect(migration).to receive(:add_column).with(:users, 'photo_updated_at', :datetime)

      migration.add_attachment(:users, :photo)
    end

    it 'works with different attachment names' do
      expect(migration).to receive(:add_column).with(:posts, 'image_file_name', :string)
      expect(migration).to receive(:add_column).with(:posts, 'image_content_type', :string)
      expect(migration).to receive(:add_column).with(:posts, 'image_file_size', :integer)
      expect(migration).to receive(:add_column).with(:posts, 'image_updated_at', :datetime)

      migration.add_attachment(:posts, :image)
    end

    it 'handles symbol table names' do
      expect(migration).to receive(:add_column).with(:articles, 'document_file_name', :string)
      expect(migration).to receive(:add_column).with(:articles, 'document_content_type', :string)
      expect(migration).to receive(:add_column).with(:articles, 'document_file_size', :integer)
      expect(migration).to receive(:add_column).with(:articles, 'document_updated_at', :datetime)

      migration.add_attachment(:articles, :document)
    end
  end

  describe '#remove_attachment' do
    let(:table_name) { :test_table }
    let(:attachment_name) { :avatar }

    it 'removes file_name column' do
      expect(migration).to receive(:remove_column).with(table_name, 'avatar_file_name')
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_content_type')
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_file_size')
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_updated_at')

      migration.remove_attachment(table_name, attachment_name)
    end

    it 'removes content_type column' do
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_file_name')
      expect(migration).to receive(:remove_column).with(table_name, 'avatar_content_type')
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_file_size')
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_updated_at')

      migration.remove_attachment(table_name, attachment_name)
    end

    it 'removes file_size column' do
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_file_name')
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_content_type')
      expect(migration).to receive(:remove_column).with(table_name, 'avatar_file_size')
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_updated_at')

      migration.remove_attachment(table_name, attachment_name)
    end

    it 'removes updated_at column' do
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_file_name')
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_content_type')
      allow(migration).to receive(:remove_column).with(table_name, 'avatar_file_size')
      expect(migration).to receive(:remove_column).with(table_name, 'avatar_updated_at')

      migration.remove_attachment(table_name, attachment_name)
    end

    it 'removes all four columns' do
      expect(migration).to receive(:remove_column).exactly(4).times

      migration.remove_attachment(table_name, attachment_name)
    end

    it 'works with different table names' do
      expect(migration).to receive(:remove_column).with(:users, 'photo_file_name')
      expect(migration).to receive(:remove_column).with(:users, 'photo_content_type')
      expect(migration).to receive(:remove_column).with(:users, 'photo_file_size')
      expect(migration).to receive(:remove_column).with(:users, 'photo_updated_at')

      migration.remove_attachment(:users, :photo)
    end

    it 'works with different attachment names' do
      expect(migration).to receive(:remove_column).with(:posts, 'image_file_name')
      expect(migration).to receive(:remove_column).with(:posts, 'image_content_type')
      expect(migration).to receive(:remove_column).with(:posts, 'image_file_size')
      expect(migration).to receive(:remove_column).with(:posts, 'image_updated_at')

      migration.remove_attachment(:posts, :image)
    end

    it 'handles symbol table names' do
      expect(migration).to receive(:remove_column).with(:articles, 'document_file_name')
      expect(migration).to receive(:remove_column).with(:articles, 'document_content_type')
      expect(migration).to receive(:remove_column).with(:articles, 'document_file_size')
      expect(migration).to receive(:remove_column).with(:articles, 'document_updated_at')

      migration.remove_attachment(:articles, :document)
    end
  end

  describe 'integration with ActiveRecord::Migration' do
    it 'is included in ActiveRecord::Migration' do
      expect(ActiveRecord::Migration.ancestors).to include(described_class)
    end

    it 'makes add_attachment available on migrations' do
      expect(migration).to respond_to(:add_attachment)
    end

    it 'makes remove_attachment available on migrations' do
      expect(migration).to respond_to(:remove_attachment)
    end
  end

  describe 'column naming convention' do
    it 'uses underscores to separate attachment name from column suffix' do
      expect(migration).to receive(:add_column).with(
        :table, 'my_file_file_name', :string
      )
      expect(migration).to receive(:add_column).with(
        :table, 'my_file_content_type', :string
      )
      expect(migration).to receive(:add_column).with(
        :table, 'my_file_file_size', :integer
      )
      expect(migration).to receive(:add_column).with(
        :table, 'my_file_updated_at', :datetime
      )

      migration.add_attachment(:table, :my_file)
    end
  end
end
