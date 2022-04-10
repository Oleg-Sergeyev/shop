class RemoveIndexFromCatalog < ActiveRecord::Migration[6.1]
  def change
    remove_index :catalogs, :name, unique: false
  end
end
