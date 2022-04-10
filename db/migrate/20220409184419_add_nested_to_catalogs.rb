# frozen_string_literal: true

class AddNestedToCatalogs < ActiveRecord::Migration[6.1]
  def self.up
    add_column :catalogs, :parent_id, :integer # Comment this line if your project already has this column
    # Category.where(parent_id: 0).update_all(parent_id: nil) # Uncomment this line if your project already has :parent_id
    add_column :catalogs, :lft,       :integer
    add_column :catalogs, :rgt,       :integer

    # optional fields
    add_column :catalogs, :depth,          :integer
    add_column :catalogs, :children_count, :integer

    # This is necessary to update :lft and :rgt columns
    # Catalog.reset_column_information
    # Catalog.rebuild!
  end

  def self.down
    remove_column :catalogs, :parent_id
    remove_column :catalogs, :lft
    remove_column :catalogs, :rgt

    # optional fields
    remove_column :catalogs, :depth
    remove_column :catalogs, :children_count
  end
end
