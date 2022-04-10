# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products, comment: 'Элементы каталога: товары, услуги' do |t|
      t.with_options index: { unique: true } do
        t.string :name, comment: 'Наименование'
        t.string :article, comment: 'Артикул'
      end
      t.integer :type, comment: 'Тип элемента каталога, товар, услуга'
      t.string :brand, comment: 'Брэнд'
      t.string :specification, comment: 'Спецификация'
      t.float :price, comment: 'Цена'
      t.boolean :will_remove, default: false,
                              comment: 'Пометка на удаление (true - помечен)'
      t.references :catalog, foreign_key: true,
                             comment: 'Внешний ключ для связи с таблицей catalogs'
      t.timestamps
    end
  end
end
