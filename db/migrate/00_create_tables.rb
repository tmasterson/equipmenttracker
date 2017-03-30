class CreateTables < ActiveRecord::Migration
  
    def change
        create_table "items", force: :cascade do |t|
            t.integer "item_no",            null: false
            t.string  "serial",       limit: 10, null: false
            t.string  "item_type", null: false
            t.integer "subitem_id"
            t.integer 'specialty_id'
            t.text    "description"
            t.index ["serial"], name: "index_equipment_serial", unique: true
            t.index ["subitem_id"], name: "index_item_on_subitem_id"
            t.index ['specialty_id'],  name: 'index_item_on_specialty_id'
        end

        create_table "event_specialties", force: :cascade do |t|
            t.integer "event_id"
            t.integer "specialty_id"
            t.index ["event_id"], name: "index_event_specialties_on_event_id"
            t.index ["specialty_id"], name: "index_event_specialties_on_specialty_id"
        end

        create_table "events", force: :cascade do |t|
            t.string "name",     null: false
            t.string "location",  null: false
            t.string "group",     null: false
            t.date   "start_date", null: false
            t.date   "end_date",   null: false
            t.index ['name', 'location'], name: 'index_event_name_location_unique', unique: true
        end

        create_table "specialties", force: :cascade do |t|
            t.string "name"
            t.string "chief"
            t.index ['name', 'chief'], name: 'index_specialties_name_chief_unique', unique: true
        end
    end
end
