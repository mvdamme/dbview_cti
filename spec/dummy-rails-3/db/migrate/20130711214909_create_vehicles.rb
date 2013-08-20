class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.string  :name
      t.integer :mass

      t.timestamps
    end
  end
end
