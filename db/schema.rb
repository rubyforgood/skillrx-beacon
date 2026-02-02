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

ActiveRecord::Schema[8.1].define(version: 2026_01_30_221956) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_activity_logs", force: :cascade do |t|
    t.string "action_type"
    t.integer "admin_id", null: false
    t.string "browser"
    t.datetime "created_at", null: false
    t.text "details"
    t.string "ip_address"
    t.string "os"
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_admin_activity_logs_on_action_type"
    t.index ["admin_id"], name: "index_admin_activity_logs_on_admin_id"
  end

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "login_id"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["login_id"], name: "index_admins_on_login_id", unique: true
  end

  create_table "authors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "content_providers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "topic_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["topic_id"], name: "index_favorites_on_topic_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "local_files", force: :cascade do |t|
    t.integer "admin_id", null: false
    t.datetime "created_at", null: false
    t.string "folder_path"
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_local_files_on_admin_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "topic_authors", force: :cascade do |t|
    t.integer "author_id", null: false
    t.datetime "created_at", null: false
    t.integer "topic_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_topic_authors_on_author_id"
    t.index ["topic_id"], name: "index_topic_authors_on_topic_id"
  end

  create_table "topic_files", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "file_size"
    t.string "file_type"
    t.string "filename"
    t.integer "topic_id", null: false
    t.datetime "updated_at", null: false
    t.index ["topic_id"], name: "index_topic_files_on_topic_id"
  end

  create_table "topic_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "tag_id", null: false
    t.integer "topic_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_topic_tags_on_tag_id"
    t.index ["topic_id"], name: "index_topic_tags_on_topic_id"
  end

  create_table "topics", force: :cascade do |t|
    t.integer "content_provider_id", null: false
    t.datetime "created_at", null: false
    t.string "issue"
    t.string "month"
    t.string "title"
    t.string "topic_external_id"
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0
    t.string "volume"
    t.integer "year"
    t.index ["content_provider_id"], name: "index_topics_on_content_provider_id"
    t.index ["topic_external_id"], name: "index_topics_on_topic_external_id"
    t.index ["view_count"], name: "index_topics_on_view_count"
    t.index ["year", "month"], name: "index_topics_on_year_and_month"
  end

  create_table "user_activity_logs", force: :cascade do |t|
    t.string "action_type"
    t.string "browser"
    t.datetime "created_at", null: false
    t.string "file_type"
    t.string "ip_address"
    t.string "os"
    t.boolean "search_found"
    t.string "search_term"
    t.integer "topic_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["action_type"], name: "index_user_activity_logs_on_action_type"
    t.index ["topic_id"], name: "index_user_activity_logs_on_topic_id"
    t.index ["user_id"], name: "index_user_activity_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "login_count", default: 0
    t.string "login_id"
    t.datetime "updated_at", null: false
    t.index ["login_id"], name: "index_users_on_login_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_activity_logs", "admins"
  add_foreign_key "favorites", "topics"
  add_foreign_key "favorites", "users"
  add_foreign_key "local_files", "admins"
  add_foreign_key "topic_authors", "authors"
  add_foreign_key "topic_authors", "topics"
  add_foreign_key "topic_files", "topics"
  add_foreign_key "topic_tags", "tags"
  add_foreign_key "topic_tags", "topics"
  add_foreign_key "topics", "content_providers"
  add_foreign_key "user_activity_logs", "topics"
  add_foreign_key "user_activity_logs", "users"
end
