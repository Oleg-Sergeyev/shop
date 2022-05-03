class UploadsController < ApplicationController
  before_action :set_upload, only: %i[ show edit update destroy ]

  # GET /uploads or /uploads.json
  def index

  end

  # GET /uploads/1 or /uploads/1.json
  def show
  end

  # GET /uploads/new
  def new
    #@upload = Upload.new
  end

  def create
    @action_log = [] # Массив для записи статуса товара, изменем или создан
    imported = parse_csv # Получаем массив из файла
    modify_array = change_array(imported) # Приводим массив товаров к хешам вида {name: 'Name'}
    # Если каталог пуст, заполняем его и выходим
    if Catalog.all.count.zero?
      create_new_catalog(modify_array)
      return
    end
    update_existing_catalog(modify_array)
    Rails.cache.clear
    render :index
  end

  # Поиск по имени папки в текущем каталоге. Формирование хеша вида id=>{["7647", "73467"], и т.д.},
  # где "key" - id папки, "value" - массив артикулов "записанный/закрепленный" за этой папкой.
  def update_existing_catalog(products_array)
    products_array.each do |product|
      catalog_name = product[:catalog_name] # Но сохраняем в переменной, т.к. понадобится для поиска
      product.delete(:catalog_name) # В модели продукта такого поля нет, удаляем.
      hash = Catalog.where(name: catalog_name).includes(:products)
                    .pluck(:id, :article).group_by { |a| a[0] }
                    .map { |key, val| [key, val.map(&:last)] }
      hash.count.zero? ? create_catalog(product, catalog_name) : create_update(hash, product, catalog_name)
    end
  end

  # Сравнение результатов поиска с текущим товаром product
  # Бежим по результатм поиска, получаем имя папки, если не совпадает с именем товара, "берем" следующую папку
  def create_update(search, product, catalog_name)
    search.each do |key, val|
      next unless Catalog.find(key.to_i).name == catalog_name

      if val.include?(product[:article].to_s) # Если артикул есть, обновляем продукт, "берем" следующую папку
        update_product(product, key.to_i)
        next
      end
      create_product(product, key.to_i) # Создаем/прописываем в папке новый товар, если сюда дошли
    end
  end

  # Обновление продукта в нужной, существующей папки
  def update_product(product, key)
    Product.find_by(catalog_id: key, article: product[:article])
           .update(product.update(catalog_id: key))
    create_log_array(product, product[:id], 'updated')
  end

  # Создание продукта в нужной, существующей папки
  def create_product(product, key)
    product.update(catalog_id: key)
    product_create = Product.create! product
    create_log_array(product, product_create.id, 'created')
  end

  # Функция для создания нового каталога, если нет текущего, рендер индексной страницы
  def create_new_catalog(products_array)
    products_array.each do |hash|
      create_catalog(hash, nil)
    end
    Rails.cache.clear
    render :index
  end

  # Парсинг файла
  def parse_csv
    file_before = params[:import_cvs].read
    CSV.parse(file_before.force_encoding('utf-8'), headers: true).map(&:to_h)
  end

  # Формируем хеш с добавление id-папки каталога, по умолчанию со значением nil
  def create_hash(hash, id)
    { catalog_name: hash['catalog_name'],
      name: hash['name'],
      brand: hash['brand'],
      article: hash['article'],
      specification: hash['specification'],
      price: hash['price'].to_f,
      catalog_id: id }
  end

  # Создаем массив измененных хешей, товаров, с которыми дальше работаем
  def change_array(array)
    array.map { |hash| create_hash(hash, nil) }
  end

  # Создание папки каталога и привязывание товара к созданой папке
  def create_catalog(product, catalog_name)
    catalog_name = product[:catalog_name] if catalog_name.nil?
    catalog_hash = { name: catalog_name, element_type: 0 }
    catalog = Catalog.create! catalog_hash
    product.merge!(catalog_id: catalog.id).delete(:catalog_name)
    product_create = Product.create! product
    create_log_array(product, product_create.id, 'created')
  end

  # Массив для вывода статуса(создан/обновлен) товара в html
  def create_log_array(hash, id, status)
    @action_log.push([id, hash, status])
  end
end
