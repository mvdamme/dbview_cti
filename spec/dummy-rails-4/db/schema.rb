# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140411001620) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "astronauts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "astronauts_space_ships", id: false, force: true do |t|
    t.integer "astronaut_id"
    t.integer "space_ship_id"
  end

  create_table "captains", force: true do |t|
    t.integer  "space_ship_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cars", force: true do |t|
    t.integer  "motor_vehicle_id"
    t.boolean  "stick_shift"
    t.boolean  "convertible"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "experiment_space_ship_performances", force: true do |t|
    t.integer  "experiment_id"
    t.integer  "space_ship_id"
    t.date     "performed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "experiments", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "launches", force: true do |t|
    t.integer  "space_ship_id"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "motor_cycles", force: true do |t|
    t.integer  "motor_vehicle_id"
    t.boolean  "offroad"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "motor_vehicles", force: true do |t|
    t.integer  "vehicle_id"
    t.string   "fuel"
    t.integer  "number_of_wheels"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rocket_engines", force: true do |t|
    t.integer  "space_ship_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "space_ships", force: true do |t|
    t.integer  "vehicle_id"
    t.integer  "category_id"
    t.boolean  "single_use"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reliability"
  end

  create_table "space_shuttles", force: true do |t|
    t.integer  "space_ship_id"
    t.integer  "power"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "upgraded_from_id"
  end

  create_table "vehicles", force: true do |t|
    t.string   "name"
    t.integer  "mass"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  cti_create_view('MotorVehicle')
  cti_create_view('Car')
  cti_create_view('MotorCycle')
  cti_create_view('SpaceShip')
  cti_create_view('SpaceShuttle')

  add_foreign_key "astronauts_space_ships", "astronauts", :name => "astronauts_space_ships_astronaut_id_fk"
  add_foreign_key "astronauts_space_ships", "space_ships", :name => "astronauts_space_ships_space_ship_id_fk"

  add_foreign_key "captains", "space_ships", :name => "captains_space_ship_id_fk"

  add_foreign_key "experiment_space_ship_performances", "experiments", :name => "experiment_space_ship_performances_experiment_id_fk"
  add_foreign_key "experiment_space_ship_performances", "space_ships", :name => "experiment_space_ship_performances_space_ship_id_fk"

  add_foreign_key "launches", "space_ships", :name => "launches_space_ship_id_fk"

  add_foreign_key "rocket_engines", "space_ships", :name => "rocket_engines_space_ship_id_fk"

  add_foreign_key "space_ships", "categories", :name => "space_ships_category_id_fk"
  add_foreign_key "space_ships", "vehicles", :name => "space_ships_vehicle_id_fk"

  add_foreign_key "space_shuttles", "space_ships", :name => "space_shuttles_space_ship_id_fk"
  add_foreign_key "space_shuttles", "space_ships", :name => "space_shuttles_upgraded_from_id_fk", :column => "upgraded_from_id"

end
