class RemoveTypeFromProducts < ActiveRecord::Migration[6.1]
  def change
    remove_column :products, :element_type
  end
end
