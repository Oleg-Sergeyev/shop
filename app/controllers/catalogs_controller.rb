class CatalogsController < ApplicationController
  before_action :set_catalog, only: %i[show edit update destroy]

  # GET /catalogs or /catalogs.json
  def index
    #@catalogs = Catalog.includes(:products)#.order(:lft)
    @catalogs = Catalog.includes(:products).where(depth: 0).order(name: :asc).order(:lft)
    #@catalogs = Catalog.root.self_and_descendants.order(:lft)
    #sort(@catalogs)
  end

  def sort(catalogs)
    # catalogs.where(depth: 0).order(name: :asc).each do |element|
    #   Rails.logger.info "ROOT -> #{element.name}"
    # end
    # Catalog.order(:lft).each_with_level(catalogs) do |element, level|
    #   puts "ELEMENT  #{element.name} LFT #{element.lft} RGT #{element.rgt} LEVEL  #{level}"
    # end 
  end

  # GET /catalogs/1 or /catalogs/1.json
  def show
  end

  # GET /catalogs/new
  def new
    @catalog = Catalog.new
  end

  # GET /catalogs/1/edit
  def edit
  end

  # POST /catalogs or /catalogs.json
  def create
    @catalog = Catalog.new(catalog_params)
    return if check_siblings(@catalog.parent_id, @catalog.name)

    #@catalog.children.build
    respond_to do |format|
      if @catalog.save
        format.html { redirect_to catalogs_path, notice: "Catalog was successfully created." }
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
        #@catalog.children.build
        format.html { redirect_to catalog_url(@catalog), notice: "Catalog was successfully updated." }
        format.json { render :show, status: :ok, location: @catalog }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @catalog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /catalogs/1 or /catalogs/1.json
  def destroy
    @catalog.destroy

    respond_to do |format|
      format.html { redirect_to catalogs_url, notice: "Catalog was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def check_siblings(parent_id, name)
    if parent_id
      # if name.nil?
      Rails.logger.info "*********************** #{catalog_params} **********************"
      #   #@catalog = Catalog.find(parent_id)
      #   #@catalog.children.build
      #   @product = Product.new(params[:product])
      #   @product.save
      #   return true
      # end
      if Catalog.find(parent_id).children.map(&:name).include?(name) && name
        redirect_to catalogs_path, notice: 'В одном разделе каталога допускаются только уникальные наименования!'
        return true
      end
    else
      if Catalog.where(depth: 0).map(&:name).include?(name)
        redirect_to catalogs_path, notice: 'В одном разделе каталога допускаются только уникальные наименования!'
        return true
      end
    end
    false
  end

  private

   # Use callbacks to share common setup or constraints between actions.
  def set_catalog
    @catalog = Catalog.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def catalog_params
    params.require(:catalog).permit(:parent_id, :name, :element_type, :will_remove, :select_type)
  end
end

# product_attributes: [:catalog_id, :name, :price, :article, :specification, :brand]