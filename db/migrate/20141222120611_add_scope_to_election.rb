class AddScopeToElection < ActiveRecord::Migration[4.2]
  def up
    add_column :elections, :scope, :int

    # Hasta este momento todas las elecciones habían sido Estatales
    # Use raw SQL to avoid loading the Election model which has dependencies on columns not yet created
    execute("UPDATE elections SET scope = 0")
  end

  def down
    remove_column :elections, :scope, :int
  end
end
