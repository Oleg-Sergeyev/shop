class ChangeColumnNameInCatalogsAndProducts < ActiveRecord::Migration[6.1]
  def change
    rename_column :catalogs, :type, :element_type
    rename_column :products, :type, :element_type
  end
end
