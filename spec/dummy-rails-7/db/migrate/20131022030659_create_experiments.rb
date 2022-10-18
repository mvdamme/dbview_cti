require_relative './migration_helper'

class CreateExperiments < MigrationHelper.migration_base_class
  def change
    create_table :experiments do |t|
      t.string :name

      t.timestamps
    end
  end
end
