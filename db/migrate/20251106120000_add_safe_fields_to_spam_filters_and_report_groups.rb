class AddSafeFieldsToSpamFiltersAndReportGroups < ActiveRecord::Migration[7.2]
  def change
    # SpamFilter: Add JSON-based rule fields
    add_column :spam_filters, :rules_json, :jsonb
    add_column :spam_filters, :filter_type, :string

    # ReportGroup: Add JSON-based transformation fields
    add_column :report_groups, :transformation_rules, :jsonb
    add_column :report_groups, :transform_type, :string

    # Indexes for performance
    add_index :spam_filters, :filter_type
    add_index :report_groups, :transform_type
  end
end
