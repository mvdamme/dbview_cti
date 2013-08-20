class CreateMotorVehicles < ActiveRecord::Migration
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
