class CreateAstronauts < ActiveRecord::Migration
  def change
    create_table :astronauts do |t|
      t.string :name

      t.timestamps
    end
  end
end
