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

ActiveRecord::Schema[8.1].define(version: 2026_03_20_180356) do
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

  create_table "chat_messages", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "onboarding_application_id", null: false
    t.string "role"
    t.string "step_context"
    t.datetime "updated_at", null: false
    t.index ["onboarding_application_id"], name: "index_chat_messages_on_onboarding_application_id"
  end

  create_table "document_uploads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "document_type"
    t.text "extracted_data"
    t.string "filename"
    t.integer "onboarding_application_id", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["onboarding_application_id"], name: "index_document_uploads_on_onboarding_application_id"
  end

  create_table "onboarding_applications", force: :cascade do |t|
    t.text "application_data"
    t.datetime "created_at", null: false
    t.integer "current_step"
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "vehicle_id", null: false
    t.index ["user_id"], name: "index_onboarding_applications_on_user_id"
    t.index ["vehicle_id"], name: "index_onboarding_applications_on_vehicle_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "experience_level"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "featured"
    t.string "make"
    t.integer "mileage"
    t.string "model"
    t.decimal "price"
    t.string "stock_no"
    t.datetime "updated_at", null: false
    t.integer "year"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_messages", "onboarding_applications"
  add_foreign_key "document_uploads", "onboarding_applications"
  add_foreign_key "onboarding_applications", "users"
  add_foreign_key "onboarding_applications", "vehicles"
end
