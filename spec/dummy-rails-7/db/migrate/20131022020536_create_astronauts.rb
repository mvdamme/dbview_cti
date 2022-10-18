require_relative './migration_helper'

class CreateAstronauts < MigrationHelper.migration_base_class
  def change
    create_table :astronauts do |t|
      t.string :name

      t.timestamps
    end
  end
end
