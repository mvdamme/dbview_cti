class CreateSpaceShuttles < ActiveRecord::Migration
  def change
    create_table :space_shuttles do |t|
      t.references :space_ship
      t.integer :power

      t.timestamps
    end
    
    add_foreign_key(:space_shuttles, :space_ships)
    cti_create_view('SpaceShuttle')
    
  end
end
