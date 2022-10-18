require_relative './migration_helper'

class CreateMotorVehicles < MigrationHelper.migration_base_class
  def change
    create_table :motor_vehicles do |t|
      t.references :vehicle
      t.string  :fuel
      t.integer :number_of_wheels

      t.timestamps
    end
    
    cti_create_view('MotorVehicle')
  end
end
