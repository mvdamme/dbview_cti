class CreateExperimentSpaceShipPerformances < ActiveRecord::Migration
  def change
    create_table :experiment_space_ship_performances do |t|
      t.references :experiment
      t.references :space_ship
      t.date :performed_at

      t.timestamps
    end

    add_foreign_key(:experiment_space_ship_performances, :experiments)
    add_foreign_key(:experiment_space_ship_performances, :space_ships)
  end
end
