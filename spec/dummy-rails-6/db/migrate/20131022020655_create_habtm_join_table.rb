require_relative './migration_helper'

class CreateHabtmJoinTable < MigrationHelper.migration_base_class
  def change
    create_table :astronauts_space_ships, id: false do |t|
      t.integer :astronaut_id
      t.integer :space_ship_id
    end

    add_foreign_key(:astronauts_space_ships, :astronauts)
    add_foreign_key(:astronauts_space_ships, :space_ships)
  end
end
