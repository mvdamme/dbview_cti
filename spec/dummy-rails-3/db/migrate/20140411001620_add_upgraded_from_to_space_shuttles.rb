class AddUpgradedFromToSpaceShuttles < ActiveRecord::Migration
  def up
    cti_recreate_views_after_change_to('SpaceShuttle') do
      add_column(:space_shuttles, :upgraded_from_id, :integer)
    end
    add_foreign_key :space_shuttles, :space_ships, :column => 'upgraded_from_id'
  end

  def down
    cti_recreate_views_after_change_to('SpaceShuttle') do
      remove_column(:space_shuttles, :upgraded_from_id)
    end
    remove_foreign_key :space_shuttles, :space_ships, :column => 'upgraded_from_id'
  end
end
