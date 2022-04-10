# frozen_string_literal: true

class CreateCatalogs < ActiveRecord::Migration[6.1]
  def change
    create_table :catalogs, comment: 'Основной каталог' do |t|
      t.with_options index: { unique: true } do
        string :name, comment: 'Назание позиции каталога'
      end
      t.integer :type, comment: 'Тип позиции каталога, товар, услуга'
      t.boolean :will_remove, default: false,
                              comment: 'Пометка на удаление (true - помечен)'
      t.timestamps
    end
  end
end
