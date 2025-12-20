require_relative './migration_helper'

class CreateLaunches < MigrationHelper.migration_base_class
  def change
    create_table :launches do |t|
      t.references :space_ship
      t.date :date

      t.timestamps
    end

    add_foreign_key(:launches, :space_ships)
  end
end
