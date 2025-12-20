require_relative './migration_helper'

class CreateRocketEngines < MigrationHelper.migration_base_class
  def change
    create_table :rocket_engines do |t|
      t.references :space_ship
      t.string :name

      t.timestamps
    end
    
    add_foreign_key(:rocket_engines, :space_ships)
  end
end
