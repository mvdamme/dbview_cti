require_relative './migration_helper'

class CreateVehicles < MigrationHelper.migration_base_class
  def change
    create_table :vehicles do |t|
      t.string  :name
      t.integer :mass

      t.timestamps
    end
  end
end
