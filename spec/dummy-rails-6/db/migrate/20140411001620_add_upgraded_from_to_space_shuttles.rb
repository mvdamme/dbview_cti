require_relative './migration_helper'

class AddUpgradedFromToSpaceShuttles < MigrationHelper.migration_base_class
  def up
    cti_recreate_views_after_change_to('SpaceShuttle') do
      add_column(:space_shuttles, :upgraded_from_id, :integer)
    end
    add_foreign_key :space_shuttles, :space_ships, :column => 'upgraded_from_id'
  end

  def down
    if Rails::VERSION::MAJOR >= 5
      remove_foreign_key :space_shuttles, :column => 'upgraded_from_id'
    else
      remove_foreign_key :space_shuttles, :space_ships, :column => 'upgraded_from_id'
    end
    cti_recreate_views_after_change_to('SpaceShuttle') do
      remove_column(:space_shuttles, :upgraded_from_id)
    end
  end
end
