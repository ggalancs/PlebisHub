# frozen_string_literal: true

# Helper module for Paperclip migrations
# Provides add_attachment and remove_attachment methods for migrations
# that were originally created with Paperclip but now run without it
module PaperclipMigrationHelper
  def add_attachment(table, name)
    add_column table, "#{name}_file_name", :string
    add_column table, "#{name}_content_type", :string
    add_column table, "#{name}_file_size", :integer
    add_column table, "#{name}_updated_at", :datetime
  end

  def remove_attachment(table, name)
    remove_column table, "#{name}_file_name"
    remove_column table, "#{name}_content_type"
    remove_column table, "#{name}_file_size"
    remove_column table, "#{name}_updated_at"
  end
end

# Include in ActiveRecord::Migration
ActiveRecord::Migration.include(PaperclipMigrationHelper)
