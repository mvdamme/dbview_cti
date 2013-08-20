class CreateCars < ActiveRecord::Migration
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
