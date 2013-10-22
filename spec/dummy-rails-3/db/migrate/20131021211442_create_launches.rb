class CreateLaunches < ActiveRecord::Migration
  def change
    create_table :launches do |t|
      t.references :space_ship
      t.date :date

      t.timestamps
    end

    add_foreign_key(:launches, :space_ships)
  end
end
