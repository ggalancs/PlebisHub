class AddCensusFileToElection < ActiveRecord::Migration[4.2]
  def change
    add_attachment :elections, :census_file
  end
end
