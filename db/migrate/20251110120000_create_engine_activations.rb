# frozen_string_literal: true

# Migration to create engine_activations table
# This table manages which engines are enabled/disabled in the application
#
# Schema:
#   - engine_name: unique identifier for the engine
#   - enabled: whether the engine is currently active
#   - configuration: JSON configuration specific to the engine
#   - description: human-readable description
#   - load_priority: order in which engines should be loaded (lower = first)
#
class CreateEngineActivations < ActiveRecord::Migration[7.2]
  def change
    create_table :engine_activations do |t|
      t.string :engine_name, null: false, index: { unique: true }
      t.boolean :enabled, default: false, null: false
      t.jsonb :configuration, default: {}
      t.text :description
      t.integer :load_priority, default: 100

      t.timestamps
    end

    # Add index for enabled engines to speed up lookups
    add_index :engine_activations, :enabled
  end
end
