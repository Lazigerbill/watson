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

ActiveRecord::Schema.define(version: 20160302223909) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entries", force: :cascade do |t|
    t.string   "company_name"
    t.string   "ticker"
    t.string   "event_name"
    t.date     "date"
    t.string   "speaker_name"
    t.string   "speaker_title"
    t.integer  "wcount"
    t.text     "transcript"
    t.json     "insights"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "company_name"
    t.string   "ticker"
    t.string   "speaker_name"
    t.string   "speaker_title"
    t.integer  "wcount"
    t.integer  "user_id"
    t.text     "combined_transcripts"
    t.json     "watson"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "student_id"
    t.string   "email"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "salt"
    t.string   "crypted_password"
    t.integer  "report_creations",                default: 0
  end

end
