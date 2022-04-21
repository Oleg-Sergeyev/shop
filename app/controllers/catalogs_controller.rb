# frozen_string_literal: true

class CatalogsController < ApplicationController
  before_action :set_catalog, only: %i[show edit update destroy upload]

  # GET /catalogs or /catalogs.json
  def index
    default_cookies unless cookies[:sort]

    cookies[:sort] = params[:sort] if params[:sort]
    @catalogs = Catalog.scope_sort(cookies[:sort])
  end

  def default_cookies
    cookies.permanent[:sort] = :asc
  end

  # GET /catalogs/1 or /catalogs/1.json
  def show; end

  # GET /catalogs/new
  def new
    @catalog = Catalog.new
  end

  # GET /catalogs/1/edit
  def edit; end

  # POST /catalogs or /catalogs.json
  def create
    @catalog = Catalog.new(catalog_params)
    return if check_siblings?(@catalog.parent_id, @catalog.name)

    respond_to do |format|
      if @catalog.save
        Rails.cache.clear
        format.html { redirect_to catalogs_path, notice: 'Catalog was successfully created.' }
        format.json { render :show, status: :created, location: @catalog }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @catalog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /catalogs/1 or /catalogs/1.json
  def update
    respond_to do |format|
      if @catalog.update(catalog_params)
        Rails.cache.clear
        format.html { redirect_to catalogs_path, notice: 'Catalog was successfully updated.' }
        format.json { render :show, status: :ok, location: @catalog }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @catalog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /catalogs/1 or /catalogs/1.json
  def destroy
    @catalog.self_and_descendants.each do |item|
      Product.delete_by(catalog_id: item.id)
    end
    @catalog.destroy
    Rails.cache.clear
    Catalog.rebuild!
    respond_to do |format|
      format.html { redirect_to catalogs_path, notice: 'Catalog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private

  def check_siblings?(parent_id, name)
    return true unless name

    if parent_id && Catalog.find(parent_id).children.map(&:name).include?(name)
      redirect_to new_catalog_path(catalog_id: parent_id), notice: 'В разделе только уникальные наименования!'
      return true
    elsif Catalog.where(depth: 0).map(&:name).include?(name)
      redirect_to new_catalog_path(catalog_id: parent_id), notice: 'В разделе только уникальные наименования!'
      return true
    end
    false
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_catalog
    @catalog = Catalog.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def catalog_params
    params.require(:catalog).permit(:parent_id, :name, :element_type, :will_remove, :select_type, :sort, :import_cvs)
  end
end
