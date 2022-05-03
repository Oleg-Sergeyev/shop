require 'rails_helper'

RSpec.describe Catalog, type: :model do
  # before do
  #   Catalog.create(name: 'New folder', element_type: 0)
  # end

  it 'Создание новой папки со вложенным в нее товаром' do
    folder = Catalog.create(name: 'New folder', element_type: 0)
    Product.create(name: 'product',
                   article: '1321321',
                   brand: 'HP',
                   specification: 'La-la-la-la',
                   price: 8000.55,
                   catalog_id: folder.id)
    expect(Catalog.find_by(name: 'New folder').products).not_to be_empty
  end

  it 'Создание вложенной папки' do
    folder = Catalog.create(name: 'New folder', element_type: 0)
    folder_second = Catalog.create(name: 'New folder 2', element_type: 0)
    folder_second.move_to_child_of(folder)
    expect(folder_second.leaf?).to be true
  end

  it 'Создание 10 вложений' do

    level_zero_folder = Catalog.create(name: 'New folder', element_type: 0)
    create_catalogs(level_zero_folder, 10)

    puts "max_depth = #{Catalog.maximum(:depth)}"
    expect(Catalog.all.count).to be 10
  end

  def create_catalogs(folder, index)
    #folder_new = Catalog.create(name: 'New folder', element_type: 0).move_to_child_of(folder)
    index -= 1
    puts "index = #{index}"
    next_folder = Catalog.create(name: 'New folder', element_type: 0)
    next_folder.move_to_child_of(folder)
    create_catalogs(next_folder, index) unless index != 0
    puts "HERE"
  end
end
