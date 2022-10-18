require_relative './migration_helper'

class CreateCars < MigrationHelper.migration_base_class
  def change
    create_table :cars do |t|
      t.references :motor_vehicle
      t.boolean :stick_shift
      t.boolean :convertible

      t.timestamps
    end
    
    cti_create_view('Car')
  end
end
