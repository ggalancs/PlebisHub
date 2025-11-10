class AddQrFieldsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :qr_hash, :string
    add_column :users, :qr_secret, :string
    add_column :users, :qr_created_at, :datetime
  end
end
