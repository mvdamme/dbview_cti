class CreateSpaceShips < ActiveRecord::Migration
  def change
    create_table :space_ships do |t|
      t.references :vehicle
      t.boolean :single_use

      t.timestamps
    end
    
    add_foreign_key(:space_ships, :vehicles)
    cti_create_view('SpaceShip')
  end
end
