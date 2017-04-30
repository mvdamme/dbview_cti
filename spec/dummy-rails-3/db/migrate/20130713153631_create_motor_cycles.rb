require_relative './migration_helper'

class CreateMotorCycles < MigrationHelper.migration_base_class
  def change
    create_table :motor_cycles do |t|
      t.references :motor_vehicle
      t.boolean :offroad

      t.timestamps
    end
    
    cti_create_view('MotorCycle')
  end
end
