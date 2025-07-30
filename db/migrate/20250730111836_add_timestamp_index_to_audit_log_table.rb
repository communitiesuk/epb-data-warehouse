class AddTimestampIndexToAuditLogTable < ActiveRecord::Migration[7.0]
  def self.up
    add_index :audit_logs, :timestamp
  end

  def self.down; end
end
