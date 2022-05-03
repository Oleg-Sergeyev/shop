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

  def update_existing_catalog(products_array)
    products_array.each do |array|
      catalog_name = array[:catalog_name]
      array.delete(:catalog_name)
      hash = Catalog.where(name: catalog_name).includes(:products)
                    .pluck(:id, :article).group_by { |a| a[0] }
                    .map { |key, val| [key, val.map(&:last)] }.to_h
      if hash.count.positive?
        hash.each do |key, val|
          next unless Catalog.find(key.to_i).name == catalog_name

          if val.include?(array[:article].to_s)
            Product.find_by(catalog_id: key.to_i, article: array[:article])
                   .update(array.update(catalog_id: key.to_i))
            create_log_array(array, array[:id], 'updated')
            next
          end
          array.update(catalog_id: key.to_i)
          product_create = Product.create! array
          create_log_array(array, product_create.id, 'created')
        end
      else
        create_catalog(array, catalog_name)
      end
    end
  end

  # Функция для создания нового каталога, если нет текущего
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

  def create_catalog(array, catalog_name)
    catalog_name = array[:catalog_name] if catalog_name.nil?
    catalog_hash = { name: catalog_name, element_type: 0 }
    catalog = Catalog.create! catalog_hash
    array.merge!(catalog_id: catalog.id)
    product_create = Product.create! array
    create_log_array(array, product_create.id, 'created')
  end

  def create_log_array(hash, id, status)
    @action_log.push([id, hash, status])
  end
end
