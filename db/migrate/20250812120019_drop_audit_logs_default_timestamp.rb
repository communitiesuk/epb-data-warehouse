class DropAuditLogsDefaultTimestamp < ActiveRecord::Migration[7.0]
  def self.up
    execute 'ALTER TABLE audit_logs ALTER COLUMN "timestamp" DROP DEFAULT'
  end

  def self.down; end
end
