class UpdateForeignKeyCatalog < ActiveRecord::Migration[6.1]
  def change
    # remove the old foreign_key
    #remove_foreign_key :catalogs, :products

    # add the new foreign_key
    #add_foreign_key :catalogs, :products, on_delete: :cascade
  end
end
