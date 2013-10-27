class CreateSpaceShips < ActiveRecord::Migration
  def change
    create_table :space_ships do |t|
      t.references :vehicle

      t.references :category
      t.boolean :single_use

      t.timestamps
    end
    
    add_foreign_key(:space_ships, :vehicles)
    add_foreign_key(:space_ships, :categories)
    cti_create_view('SpaceShip')
  end
end
