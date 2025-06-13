class AlterIndexToDocumentsWarehouseCreatedAt < ActiveRecord::Migration[7.0]
  def self.up
    execute "DROP INDEX IF EXISTS index_assessment_documents_on_warehouse_created_at"

    execute "create INDEX index_assessment_documents_on_warehouse_created_at ON assessment_documents ((warehouse_created_at::DATE))"
  end

  def self.down; end
end
