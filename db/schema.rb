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

ActiveRecord::Schema.define(version: 2022_04_12_202514) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "catalogs", comment: "Основной каталог", force: :cascade do |t|
    t.string "name", comment: "Назание позиции каталога"
    t.integer "element_type", comment: "Тип позиции каталога, товар, услуга"
    t.boolean "will_remove", default: false, comment: "Пометка на удаление (true - помечен)"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.integer "depth"
    t.integer "children_count"
  end

  create_table "products", comment: "Элементы каталога: товары, услуги", force: :cascade do |t|
    t.string "name", comment: "Наименование"
    t.string "article", comment: "Артикул"
    t.string "brand", comment: "Брэнд"
    t.string "specification", comment: "Спецификация"
    t.float "price", comment: "Цена"
    t.boolean "will_remove", default: false, comment: "Пометка на удаление (true - помечен)"
    t.bigint "catalog_id", comment: "Внешний ключ для связи с таблицей catalogs"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["catalog_id"], name: "index_products_on_catalog_id"
  end

  add_foreign_key "products", "catalogs"
end
