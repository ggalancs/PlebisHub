class CreateImpulsaEditions < ActiveRecord::Migration[4.2]
  def change
    create_table :impulsa_editions do |t|
      t.string :name, null: false
      t.date :start_at
      t.date :new_projects_until
      t.date :review_projects_until
      t.date :validation_projects_until
      t.date :ends_at

      t.timestamps null: false
    end

    # Paperclip attachment columns (legacy - for data migration to ActiveStorage)
    %w[legal schedule_model activities_resources_model requested_budget_model monitoring_evaluation_model].each do |attachment|
      add_column :impulsa_editions, "#{attachment}_file_name", :string
      add_column :impulsa_editions, "#{attachment}_content_type", :string
      add_column :impulsa_editions, "#{attachment}_file_size", :integer
      add_column :impulsa_editions, "#{attachment}_updated_at", :datetime
    end
  end
end
