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

ActiveRecord::Schema[8.1].define(version: 2026_04_13_022608) do
  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.integer "original_timestamp"
    t.string "subject"
    t.integer "thread_id"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["thread_id"], name: "index_posts_on_thread_id"
  end

  create_table "threads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_post_at"
    t.integer "original_timestamp"
    t.datetime "updated_at", null: false
    t.index ["last_post_at"], name: "index_threads_on_last_post_at"
  end
end
