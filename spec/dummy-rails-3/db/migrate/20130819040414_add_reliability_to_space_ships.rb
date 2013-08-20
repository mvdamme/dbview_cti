class AddReliabilityToSpaceShips < ActiveRecord::Migration
  def up
    cti_recreate_views_after_change_to('SpaceShip') do
      add_column(:space_ships, :reliability, :integer)
    end
  end
  
  def down
    cti_recreate_views_after_change_to('SpaceShip') do
      remove_column(:space_ships, :reliability)
    end
  end
end
