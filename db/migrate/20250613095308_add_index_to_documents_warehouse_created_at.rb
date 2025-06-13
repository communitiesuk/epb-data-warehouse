class AddIndexToDocumentsWarehouseCreatedAt < ActiveRecord::Migration[7.0]
  def self.up
    add_index :assessment_documents, :warehouse_created_at, unique: false
  end

  def self.down; end
end
