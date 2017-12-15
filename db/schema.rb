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

ActiveRecord::Schema.define(version: 20171215013406) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "challenge_read_entries", force: :cascade do |t|
    t.bigint "challenge_id"
    t.bigint "user_id"
    t.bigint "chapters_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id"], name: "index_challenge_read_entries_on_challenge_id"
    t.index ["chapters_id"], name: "index_challenge_read_entries_on_chapters_id"
    t.index ["user_id"], name: "index_challenge_read_entries_on_user_id"
  end

  create_table "challenges", force: :cascade do |t|
    t.bigint "sender_ministry_id"
    t.bigint "receiver_ministry_id"
    t.boolean "sender_gender"
    t.boolean "receiver_gender"
    t.bigint "sender_peer_id"
    t.bigint "receiver_class_id"
    t.boolean "winner"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_class_id"], name: "index_challenges_on_receiver_class_id"
    t.index ["receiver_ministry_id"], name: "index_challenges_on_receiver_ministry_id"
    t.index ["sender_ministry_id"], name: "index_challenges_on_sender_ministry_id"
    t.index ["sender_peer_id"], name: "index_challenges_on_sender_peer_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.string "book"
    t.integer "ch_num"
    t.integer "verse_count"
    t.text "themes", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book"], name: "index_chapters_on_book"
    t.index ["ch_num"], name: "index_chapters_on_ch_num", unique: true
  end

  create_table "counts", force: :cascade do |t|
    t.integer "count"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.bigint "parent_group_id"
    t.bigint "children_groups_id"
    t.bigint "members_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry"
    t.index ["ancestry"], name: "index_groups_on_ancestry"
    t.index ["children_groups_id"], name: "index_groups_on_children_groups_id"
    t.index ["id"], name: "index_groups_on_id"
    t.index ["members_id"], name: "index_groups_on_members_id"
    t.index ["name"], name: "index_groups_on_name", unique: true
    t.index ["parent_group_id"], name: "index_groups_on_parent_group_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id"
    t.string "type"
    t.json "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "read_events", force: :cascade do |t|
    t.datetime "read_at"
    t.boolean "personal_shadowing"
    t.bigint "user_id"
    t.bigint "chapter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_read_events_on_chapter_id"
    t.index ["user_id"], name: "index_read_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.boolean "gender"
    t.bigint "ministry_id"
    t.bigint "peer_class_id"
    t.bigint "lifetime_count_id"
    t.bigint "annual_counts_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["annual_counts_id"], name: "index_users_on_annual_counts_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["lifetime_count_id"], name: "index_users_on_lifetime_count_id"
    t.index ["ministry_id"], name: "index_users_on_ministry_id"
    t.index ["peer_class_id"], name: "index_users_on_peer_class_id"
  end

end
