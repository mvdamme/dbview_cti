# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2014_04_25_182847) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "astronauts", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name"
    t.datetime "updated_at", precision: nil
  end

  create_table "astronauts_space_ships", id: false, force: :cascade do |t|
    t.integer "astronaut_id"
    t.integer "space_ship_id"
  end

  create_table "captains", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name"
    t.integer "space_ship_id"
    t.datetime "updated_at", precision: nil
  end

  create_table "cars", id: :serial, force: :cascade do |t|
    t.boolean "convertible"
    t.datetime "created_at", precision: nil
    t.integer "motor_vehicle_id"
    t.boolean "stick_shift"
    t.datetime "updated_at", precision: nil
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name"
    t.datetime "updated_at", precision: nil
  end

  create_table "experiment_space_ship_performances", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "experiment_id"
    t.date "performed_at"
    t.integer "space_ship_id"
    t.datetime "updated_at", precision: nil
  end

  create_table "experiments", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name"
    t.datetime "updated_at", precision: nil
  end

  create_table "launches", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.date "date"
    t.integer "space_ship_id"
    t.datetime "updated_at", precision: nil
  end

  create_table "motor_cycles", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "motor_vehicle_id"
    t.boolean "offroad"
    t.datetime "updated_at", precision: nil
  end

  create_table "motor_vehicles", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "fuel"
    t.integer "number_of_wheels"
    t.datetime "updated_at", precision: nil
    t.integer "vehicle_id"
  end

  create_table "rocket_engines", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name"
    t.integer "space_ship_id"
    t.datetime "updated_at", precision: nil
  end

  create_table "space_ships", id: :serial, force: :cascade do |t|
    t.integer "category_id"
    t.datetime "created_at", precision: nil
    t.integer "reliability"
    t.boolean "single_use"
    t.datetime "updated_at", precision: nil
    t.integer "vehicle_id"
  end

  create_table "space_shuttles", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "power"
    t.integer "space_ship_id"
    t.datetime "updated_at", precision: nil
    t.integer "upgraded_from_id"
  end

  create_table "vehicles", id: :serial, force: :cascade do |t|
    t.string "bogus_field"
    t.datetime "created_at", precision: nil
    t.integer "mass"
    t.string "name"
    t.datetime "updated_at", precision: nil
  end

  add_foreign_key "astronauts_space_ships", "astronauts"
  add_foreign_key "astronauts_space_ships", "space_ships"
  add_foreign_key "captains", "space_ships"
  add_foreign_key "experiment_space_ship_performances", "experiments"
  add_foreign_key "experiment_space_ship_performances", "space_ships"
  add_foreign_key "launches", "space_ships"
  add_foreign_key "rocket_engines", "space_ships"
  add_foreign_key "space_ships", "categories"
  add_foreign_key "space_ships", "vehicles"
  add_foreign_key "space_shuttles", "space_ships"
  add_foreign_key "space_shuttles", "space_ships", column: "upgraded_from_id"
  cti_create_view('MotorVehicle')
  cti_create_view('Car')
  cti_create_view('MotorCycle')
  cti_create_view('SpaceShip')
  cti_create_view('SpaceShuttle')

end
