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

ActiveRecord::Schema.define(version: 0) do

  create_table "event_specialties", force: :cascade do |t|
    t.integer "event_id"
    t.integer "specialty_id"
    t.index ["event_id"], name: "index_event_specialties_on_event_id"
    t.index ["specialty_id"], name: "index_event_specialties_on_specialty_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name",       null: false
    t.string "location",   null: false
    t.string "group",      null: false
    t.date   "start_date", null: false
    t.date   "end_date",   null: false
    t.index ["name", "location"], name: "index_event_name_location_unique", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.integer "item_no",                 null: false
    t.string  "serial",       limit: 10, null: false
    t.string  "item_type",               null: false
    t.integer "subitem_id"
    t.integer "specialty_id"
    t.text    "description"
    t.index ["serial"], name: "index_equipment_serial", unique: true
    t.index ["specialty_id"], name: "index_item_on_specialty_id"
    t.index ["subitem_id"], name: "index_item_on_subitem_id"
  end

  create_table "specialties", force: :cascade do |t|
    t.string "name"
    t.string "chief"
    t.index ["name", "chief"], name: "index_specialties_name_chief_unique", unique: true
  end

end
