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
   # @upload = Upload.new
  end

  # POST /uploads or /uploads.json
  def create
    @action_log = []
    @imported = parse_csv
    must_be_changed = []
    modify_array = change_array(@imported)
    if Catalog.all.count.zero?
      create_new_catalog(modify_array)
      return
    end

    modify_array.each do |array|
      Catalog.where(depth: 0).each do |element|
        element.self_and_descendants.each do |catalog|
          if catalog.name == array[:catalog_name]
            array.update(catalog_id: catalog.id)
            must_be_changed.push(array) unless must_be_changed.include?(array)
          end
        end
      end
    end

    must_be_created = modify_array.difference(must_be_changed)

    create_catalog(must_be_created) unless must_be_created.size.zero?
    update_catalog(must_be_changed) unless must_be_changed.size.zero?
    Rails.cache.clear
    render :index
  end

  def create_new_catalog(modify_array)
    create_catalog(modify_array)
    Rails.cache.clear
    render :index
  end

  def parse_csv
    array = []
    file_before = params[:import_cvs].read
    CSV.parse(file_before.force_encoding('utf-8'), headers: true) do |row|
      array.push(row.to_h)
    end
    array
  end

  def create_hash(hash, id)
    { catalog_name: hash['catalog_name'],
      name: hash['name'],
      brand: hash['brand'],
      article: hash['article'],
      specification: hash['specification'],
      price: hash['price'].to_f,
      catalog_id: id }
  end

  def change_array(array)
    array.map { |hash| create_hash(hash, nil) }
  end

  def update_catalog(array)
    array.each do |hash|
      hash.delete(:catalog_name)
      catalog_products = Catalog.find_by(id: hash[:catalog_id]).products
      size = catalog_products.count
      if size.zero?
        product_update = Product.create! hash
        @action_log.push([product_update.id, hash[:name], 'created'])
        next
      end

      catalog_products.each do |product|
        if product.article == hash[:article]
          product.update(hash)
          @action_log.push([product.id, hash[:name], 'updated'])
        else
          size -= 1
        end
      end
      if size.zero?
        product_update = Product.create! hash
        @action_log.push([product_update.id, hash[:name], 'created'])
      end
    end
  end

  def create_catalog(array)
    array.each do |hash|
      catalog_hash = { name: hash[:catalog_name], element_type: 0 }
      catalog_exist = Catalog.find_by(name: hash[:catalog_name])
      if catalog_exist
        hash.merge!(catalog_id: catalog_exist.id).delete(:catalog_name)
      else
        catalog = Catalog.create! catalog_hash
        hash.merge!(catalog_id: catalog.id).delete(:catalog_name)
      end
      product_update = Product.create! hash
      @action_log.push([product_update.id, hash[:name], 'created'])
    end
  end
end
