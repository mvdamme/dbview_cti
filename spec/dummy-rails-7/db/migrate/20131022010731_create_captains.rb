require_relative './migration_helper'

class CreateCaptains < MigrationHelper.migration_base_class
  def change
    create_table :captains do |t|
      t.references :space_ship
      t.string :name

      t.timestamps
    end

    add_foreign_key(:captains, :space_ships)
  end
end
