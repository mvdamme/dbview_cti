class CreateMotorCycles < ActiveRecord::Migration
  def change
    create_table :motor_cycles do |t|
      t.references :motor_vehicle
      t.boolean :offroad

      t.timestamps
    end
    
    cti_create_view('MotorCycle')
  end
end
