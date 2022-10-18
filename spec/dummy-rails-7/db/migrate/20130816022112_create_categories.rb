require_relative './migration_helper'

class CreateCategories < MigrationHelper.migration_base_class
  def change
    create_table :categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
